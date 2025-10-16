# Payment Card Button Fix

## Issue
The Complete and Reject buttons weren't showing for pending payments because:

1. **Status Mismatch**: The widget was checking for exact status `'pending'`, but the API returns `'submitted'` status
2. **Old Status Detection**: The isPending flag only checked for `status == 'pending'`

## Fix Applied

Updated the status detection in `payment_card.dart`:

```dart
// OLD (only checked exact matches):
final isCompleted = status.toLowerCase() == 'completed';
final isPending = status.toLowerCase() == 'pending';
final isFailed = status.toLowerCase() == 'failed';

// NEW (checks multiple status values):
final statusLower = status.toLowerCase();
final isCompleted = statusLower == 'completed' || statusLower == 'paid';
final isPending = statusLower == 'pending' || statusLower == 'submitted';
final isFailed = statusLower == 'failed' || statusLower == 'rejected';
```

## Status Mappings

Now the card correctly recognizes:

**Completed:**
- `'completed'` ✅
- `'paid'` ✅

**Pending:**
- `'pending'` ✅
- `'submitted'` ✅ (This is what your payment shows!)

**Failed:**
- `'failed'` ✅
- `'rejected'` ✅

## Buttons Behavior

### For "submitted" status (shown in screenshot):
✅ **View button** - Shows
✅ **Reject button** - Shows (red, left side)
✅ **Complete button** - Shows (green, right side)

### For "paid" status:
✅ **View button** - Shows
❌ **Reject button** - Hidden
❌ **Complete button** - Hidden

### For "rejected" status:
✅ **View button** - Shows
❌ **Reject button** - Hidden
❌ **Complete button** - Hidden

## To See the Changes

**You MUST Hot Restart (not reload):**

1. **Stop the app completely**
2. **Run again**: `flutter run` 
   OR
3. **Press Ctrl+Shift+F5** (Hot Restart)
   OR
4. **Click the "Restart" button** in VS Code

**Hot Reload (R) won't work** because we changed the widget structure!

## Expected Result

After restart, the payment card for "Ethan Castillo" should show:

```
┌─────────────────────────────────────────────┐
│ ⏱️ Ethan Castillo              ₱3000.00     │
│ Good Runners - Single                       │
│ Due Date: 2025-10-23                        │
│ Method: GCash  Transaction ID: receipt_...  │
│ ┌───────────┐              ┌──────────────┐ │
│ │ submitted │              │ View 📄      │ │
│ └───────────┘              └──────────────┘ │
│ ┌──────────────────┐  ┌──────────────────┐ │
│ │ ❌ Reject        │  │ ✅ Complete      │ │
│ └──────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────┘
```

The two action buttons at the bottom should now appear!

## Why This Happened

The database/API uses `'submitted'` status when a student uploads a receipt, but the widget was only checking for `'pending'` status, so `isPending` was false and the buttons were hidden.

Now with `isPending = status == 'pending' OR 'submitted'`, the buttons show correctly! 🎉
