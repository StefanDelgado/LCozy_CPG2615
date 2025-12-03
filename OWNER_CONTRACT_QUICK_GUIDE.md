# Owner Contract Upload - Quick Reference

## What's New? 🎉
Dorm owners can now upload and view booking contracts, just like students!

## Where to Find It 📍
- **Location**: Owner Booking Screen → Approved/Active Bookings
- **Appears**: Below booking info, above cancellation reasons
- **Visibility**: Only shows for approved or active bookings

## Visual Overview

```
╔═══════════════════════════════════════════════════════════╗
║                    BOOKING CARD                           ║
║                                                           ║
║  Student: John Doe                                        ║
║  Dorm: Sunset View                                        ║
║  Room: Deluxe Suite                                       ║
║  Check-in: 2024-01-15                                     ║
║  Check-out: 2024-06-15                                    ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │ 📄 Booking Contracts                                │ ║
║  │                                                     │ ║
║  │  ┌────────────────────────────────────────────┐   │ ║
║  │  │ 🎓 Student Contract:         [👁️ View]   │   │ ║
║  │  └────────────────────────────────────────────┘   │ ║
║  │                                                     │ ║
║  │  ┌────────────────────────────────────────────┐   │ ║
║  │  │ 🏢 Your Contract:         [📤 Upload]     │   │ ║
║  │  │                          or                 │   │ ║
║  │  │                  [👁️ View] [🔄 Replace]   │   │ ║
║  │  └────────────────────────────────────────────┘   │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  [✅ Approve]  [❌ Reject]                                ║
╚═══════════════════════════════════════════════════════════╝
```

## Features at a Glance

### 📥 Upload Contract
- Click "Upload" button
- Choose PDF, JPG, or PNG file
- Max size: 5MB
- Instant upload with feedback

### 👁️ View Contract
- Click "View" button on any uploaded contract
- Opens in external app (PDF reader, image viewer, browser)
- Works for both student and owner contracts

### 🔄 Replace Contract
- Click "Replace" button (appears after upload)
- Upload new version
- Old version is replaced

### ✓ Validation
- ✓ File type checked (PDF, JPG, JPEG, PNG only)
- ✓ File size checked (5MB limit)
- ✓ Error messages shown for invalid files
- ✓ Success messages after upload

## User Flows

### First Time Upload
```
1. See "Upload" button
2. Tap "Upload"
3. Choose file from device
4. Wait for upload (loading indicator)
5. See success message
6. Buttons change to "View" + "Replace"
```

### View Existing Contract
```
1. See "View" button
2. Tap "View"
3. Contract opens in external app
```

### Replace Contract
```
1. See "Replace" button
2. Tap "Replace"
3. Choose new file
4. Confirm upload
5. New version uploaded
```

## Color Guide

| Element | Color | Meaning |
|---------|-------|---------|
| Container | Blue gradient | Contract section |
| Student icon | Green | Student's document |
| Owner icon | Blue | Owner's document |
| Upload button | Blue | Action needed |
| View button | Matching icon color | View action |
| Replace button | Blue | Update action |

## Status Indicators

### Not Uploaded
```
🎓 Student Contract:    Not uploaded
```
Gray italic text, no button

### Uploaded - View Only (Student)
```
🎓 Student Contract:    [👁️ View]
```
Green view button

### Uploaded - View + Replace (Owner)
```
🏢 Your Contract:    [👁️ View] [🔄 Replace]
```
Blue buttons for both actions

### Upload Available (Owner)
```
🏢 Your Contract:    [📤 Upload]
```
Blue upload button

## Messages You Might See

### ✅ Success
- "Contract uploaded successfully" (green)

### ❌ Errors
- "File size exceeds 5MB limit" (red)
- "Failed to upload contract" (red)
- "Contract not available" (orange)
- "Error opening contract: [details]" (red)

## Technical Info

### Supported Files
- **PDF**: ✅ Recommended
- **JPG/JPEG**: ✅ Supported
- **PNG**: ✅ Supported
- **Other**: ❌ Not allowed

### File Size Limit
- **Maximum**: 5MB (5,242,880 bytes)
- **Typical sizes**:
  - Scanned PDF: 1-3 MB
  - Photo (high quality): 2-5 MB
  - Photo (compressed): 0.5-2 MB

### Storage Location
- Server path: `/uploads/contracts/owner/`
- Secure and backed up
- Only accessible via the app

## Tips for Best Results

### 📸 Taking Photos
1. Use good lighting
2. Keep document flat
3. Fill the frame
4. Keep it under 5MB (use phone's "compress" option if available)

### 📄 Scanning PDFs
1. Use 300 DPI or less
2. Black & white is fine
3. Compress if over 5MB
4. Single file per booking

### 🔒 Security
- Contracts are private
- Only you and the student can view
- Files are securely stored
- Cannot be deleted (only replaced)

## Frequently Asked Questions

**Q: Can I upload multiple contracts?**
A: One contract per booking. Use "Replace" to update.

**Q: What if the student hasn't uploaded their contract?**
A: You'll see "Not uploaded" but you can still upload yours.

**Q: Can I delete a contract?**
A: No, but you can replace it with a new version.

**Q: What happens to the old contract when I replace?**
A: It's deleted and replaced with the new file.

**Q: Can students see my contract?**
A: Yes, both parties can view both contracts for transparency.

**Q: Can I upload before the booking is approved?**
A: No, contracts are only available for approved or active bookings.

**Q: What if my file is too large?**
A: Compress it or take a photo with lower quality settings.

**Q: Can I upload Word documents?**
A: No, convert to PDF first.

**Q: Do I need internet to view contracts?**
A: Yes, contracts are stored on the server.

**Q: Can I download contracts to my device?**
A: Currently opens in external viewer. Save option coming soon.

## Quick Troubleshooting

### Problem: Can't see contract section
- ✓ Check booking status (must be approved or active)
- ✓ Scroll down below booking info

### Problem: Upload button doesn't work
- ✓ Check internet connection
- ✓ Wait for any ongoing uploads to finish
- ✓ Try again after a few seconds

### Problem: File won't upload
- ✓ Check file type (must be PDF, JPG, or PNG)
- ✓ Check file size (must be under 5MB)
- ✓ Check internet connection
- ✓ Try compressing the file

### Problem: Can't view contract
- ✓ Check internet connection
- ✓ Make sure you have a PDF reader or image viewer installed
- ✓ Try again after a few seconds

### Problem: Loading forever
- ✓ Check internet connection
- ✓ Close and reopen the app
- ✓ Contact support if persists

## Summary

✅ **Feature Parity**: Owners now have same contract capabilities as students
✅ **Easy to Use**: Simple tap to upload or view
✅ **Secure**: Private and backed up
✅ **Validated**: File type and size checks
✅ **Flexible**: Can replace contracts anytime
✅ **Transparent**: Both parties see both contracts

---

**Last Updated**: January 2024
**Version**: 1.0
**Status**: ✅ Complete and Ready to Use
