# Color Migration Script - Orange to Darker Purple

## Overview
Migrating entire mobile app from orange (#FF9800) to darker purple (#7C3AED) theme.

## Color Replacements
- `Color(0xFFFF9800)` → `AppTheme.primary` (#7C3AED)
- `Colors.orange` → `AppTheme.primary`
- `Colors.orange[50]` → `AppTheme.primary.withValues(alpha: 0.1)`
- `Colors.orange[700]` → `AppTheme.primaryDark`
- `Colors.orange[900]` → `AppTheme.primaryDark`
- `Colors.orange.withOpacity(0.1)` → `AppTheme.primary.withValues(alpha: 0.1)`
- `Colors.orange.withValues(alpha: 0.1)` → `AppTheme.primary.withValues(alpha: 0.1)`
- `BitmapDescriptor.hueOrange` → `BitmapDescriptor.hueViolet` (270.0)

## Files to Update

### Owner Screens
- ✅ owner_dashboard_screen.dart - Already uses AppTheme
- ✅ owner_payments_screen.dart - COMPLETED
- ✅ owner_booking_screen.dart - COMPLETED
- ❌ owner_settings_screen.dart
- ❌ owner_dorms_screen.dart

### Student Screens
- ✅ student_home_screen.dart - Already uses AppTheme
- ❌ student_payments_screen.dart
- ❌ student_profile_screen.dart
- ❌ browse_dorms_screen.dart
- ❌ browse_dorms_map_screen.dart
- ❌ booking_form_screen.dart
- ❌ view_details_screen.dart

### Shared Screens
- ❌ chat_list_screen.dart
- ❌ chat_conversation_screen.dart
- ❌ messages_screen.dart

### Auth Screens
- ❌ register_screen.dart

### Widgets
- ❌ payment_card.dart (owner)
- ❌ payment_card.dart (student)
- ❌ edit_dorm_dialog.dart
- ❌ tenant_card.dart
- ❌ booking_card.dart (student/home)
- ❌ quick_action_button.dart
- ❌ rooms_tab.dart
- ❌ reviews_tab.dart
- ❌ contact_tab.dart
- ❌ location_tab.dart
- ❌ dorm_marker_info_window.dart

### Utils
- ❌ map_helpers.dart

## Execution Order
1. Update all _orange constants to use AppTheme.primary
2. Update all Colors.orange to AppTheme.primary
3. Update all Color(0xFFFF9800) to AppTheme.primary
4. Update all orange shade variations
5. Update map markers from orange to purple
