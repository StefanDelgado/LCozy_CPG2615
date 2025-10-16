# 📁 Mobile App Project Structure

## Overview
Clean, organized Flutter project structure following best practices with separated concerns and reusable components.

## Directory Tree

```
mobile/
├── lib/
│   ├── main.dart                              # App entry point
│   │
│   ├── screens/                               # Main screen components
│   │   ├── student/
│   │   │   ├── view_details_screen.dart       # ✅ Dorm details (681→350 lines)
│   │   │   ├── student_home_screen.dart       # ✅ Student dashboard (564→360 lines)
│   │   │   └── student_payments_screen.dart   # ✅ Payments (525→280 lines)
│   │   └── owner/
│   │       └── owner_dashboard_screen.dart    # ✅ Owner dashboard (732→420 lines)
│   │
│   ├── widgets/                               # Reusable widget components
│   │   ├── common/
│   │   │   ├── loading_widget.dart            # Loading indicator
│   │   │   └── error_widget.dart              # Error display
│   │   │
│   │   ├── student/
│   │   │   ├── view_details/
│   │   │   │   ├── overview_tab.dart          # Dorm overview tab
│   │   │   │   ├── rooms_tab.dart             # Rooms list tab
│   │   │   │   ├── reviews_tab.dart           # Reviews tab
│   │   │   │   ├── contact_tab.dart           # Contact tab
│   │   │   │   └── stat_chip.dart             # Stat chip widget
│   │   │   │
│   │   │   ├── home/
│   │   │   │   ├── dashboard_stat_card.dart   # Dashboard stats
│   │   │   │   ├── booking_card.dart          # Booking card
│   │   │   │   ├── quick_action_button.dart   # Quick action button
│   │   │   │   └── empty_bookings_widget.dart # Empty state
│   │   │   │
│   │   │   └── payments/
│   │   │       ├── payment_stat_card.dart     # Payment stats
│   │   │       └── payment_card.dart          # Payment card
│   │   │
│   │   └── owner/
│   │       ├── dashboard/
│   │       │   ├── owner_stat_card.dart       # Owner stats
│   │       │   ├── owner_quick_action_tile.dart # Quick actions
│   │       │   ├── owner_activity_tile.dart   # Activity items
│   │       │   └── owner_messages_list.dart   # Messages list
│   │       │
│   │       ├── dorms/
│   │       │   └── dorm_card.dart             # Dorm card widget
│   │       │
│   │       └── tenants/
│   │           └── tenant_card.dart           # Tenant card widget
│   │
│   ├── utils/                                 # Utility functions and constants
│   │   ├── constants.dart                     # API endpoints, UI constants, enums
│   │   ├── helpers.dart                       # Helper functions (15+)
│   │   └── validators.dart                    # Form validators (8+)
│   │
│   ├── services/                              # Business logic and API services
│   │   └── (future: API service classes)
│   │
│   ├── models/                                # Data models
│   │   └── (future: data model classes)
│   │
│   └── legacy/                                # 📦 ARCHIVED: Original files
│       ├── README.md                          # Legacy documentation
│       └── MobileScreen/                      # Original 18 screen files
│           ├── Login.dart                     # ⚠️ Still used by main.dart
│           ├── Register.dart                  # ⚠️ Still used by main.dart
│           ├── student_home.dart              # ✅ Replaced
│           ├── student_payments.dart          # ✅ Replaced
│           ├── viewdetails.dart               # ✅ Replaced
│           ├── ownerdashboard.dart            # ✅ Replaced
│           ├── browse_dorms.dart              # ⚠️ Used by student_home_screen
│           ├── booking_form.dart              # ⚠️ Used by view_details_screen
│           ├── student_owner_chat.dart        # ⚠️ Used by multiple screens
│           ├── ownerdorms.dart                # ⚠️ Used by owner_dashboard
│           ├── ownertenants.dart              # ⚠️ Used by owner_dashboard
│           ├── ownerbooking.dart              # ⚠️ Used by owner_dashboard
│           ├── ownerpayments.dart             # ⚠️ Used by owner_dashboard
│           ├── ownersetting.dart              # ⚠️ Used by owner_dashboard
│           ├── home.dart
│           ├── profile.dart
│           ├── notification.dart
│           └── search.dart
│
├── android/                                   # Android native code
├── ios/                                       # iOS native code
├── web/                                       # Web platform code
├── windows/                                   # Windows platform code
├── linux/                                     # Linux platform code
├── macos/                                     # macOS platform code
├── test/                                      # Test files
│
├── pubspec.yaml                               # Dependencies
├── analysis_options.yaml                      # Lint rules
├── README.md                                  # Project documentation
├── REFACTORING_SUMMARY.md                     # Refactoring documentation
└── REFACTORING_PLAN.md                        # Refactoring plan

```

## File Statistics

### Refactored Files (4)
| Original File | New File | Original Lines | New Lines | Reduction | Widgets Extracted |
|--------------|----------|----------------|-----------|-----------|-------------------|
| viewdetails.dart | view_details_screen.dart | 681 | 350 | 48% | 5 |
| student_home.dart | student_home_screen.dart | 564 | 360 | 36% | 4 |
| student_payments.dart | student_payments_screen.dart | 525 | 280 | 47% | 2 |
| ownerdashboard.dart | owner_dashboard_screen.dart | 732 | 420 | 43% | 4 |
| **TOTAL** | | **2,502** | **1,410** | **44%** | **15** |

### New Files Created (27)
- **4** main screen files
- **19** widget files
- **3** utility files
- **1** legacy README

## Import Patterns

### From Refactored Screens
```dart
// Utils
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

// Common widgets
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

// Feature-specific widgets
import '../../widgets/student/home/dashboard_stat_card.dart';

// Legacy imports (temporary)
import '../../legacy/MobileScreen/booking_form.dart';
```

### From Widgets
```dart
// From lib/widgets/student/home/booking_card.dart
import 'package:flutter/material.dart';

// No circular dependencies
```

## Key Features

### ✅ Modular Architecture
- Screens separated from widgets
- Utilities centralized
- Clear import hierarchy

### ✅ Reusable Components
- 19 reusable widgets
- Common loading/error states
- Consistent UI patterns

### ✅ Clean Code
- Average 44% code reduction
- Single Responsibility Principle
- DRY (Don't Repeat Yourself)

### ✅ Maintainable
- Easy to locate files
- Clear naming conventions
- Logical organization

### ✅ Scalable
- Easy to add new features
- Simple to extend existing code
- Prepared for testing

## Dependencies Status

### Temporary Legacy Dependencies
These new screens still import from legacy:
- `screens/student/view_details_screen.dart` → `booking_form.dart`, `student_owner_chat.dart`
- `screens/student/student_home_screen.dart` → `browse_dorms.dart`, `student_payments.dart` (old)
- `screens/owner/owner_dashboard_screen.dart` → Multiple owner screens
- `main.dart` → `Login.dart`, `Register.dart`

### Future Migration
Will refactor/move:
1. Auth screens → `screens/auth/`
2. Owner screens → `screens/owner/`
3. Shared screens → `screens/shared/`
4. Chat → `screens/shared/chat_screen.dart`
5. Booking → `screens/student/booking_form_screen.dart`

## Usage Guidelines

### Adding New Screens
```dart
// 1. Create in appropriate directory
lib/screens/student/new_feature_screen.dart

// 2. Extract reusable widgets
lib/widgets/student/new_feature/component_widget.dart

// 3. Use existing utilities
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
```

### Adding New Widgets
```dart
// 1. Create in appropriate category
lib/widgets/common/new_widget.dart       // For all screens
lib/widgets/student/new_widget.dart      // For student screens
lib/widgets/owner/new_widget.dart        // For owner screens

// 2. Keep focused and reusable
// 3. Accept parameters via constructor
// 4. Avoid business logic
```

### Using Utilities
```dart
// Constants
import 'package:yourapp/utils/constants.dart';
final url = ApiConstants.baseUrl;

// Helpers
import 'package:yourapp/utils/helpers.dart';
String formatted = Helpers.formatCurrency(1000);

// Validators
import 'package:yourapp/utils/validators.dart';
String? error = Validators.validateEmail(email);
```

## Migration Roadmap

### Phase 1: ✅ Core Refactoring (COMPLETE)
- [x] Refactor largest/most complex screens
- [x] Create utility libraries
- [x] Create common widgets
- [x] Move old files to legacy
- [x] Update imports

### Phase 2: Remaining Screens (IN PROGRESS)
- [ ] Refactor auth screens (Login, Register)
- [ ] Refactor owner management screens
- [ ] Refactor shared screens (home, profile, etc.)
- [ ] Create proper chat wrapper
- [ ] Create proper booking form wrapper

### Phase 3: Service Layer (FUTURE)
- [ ] Create API service classes
- [ ] Add error handling layer
- [ ] Implement caching
- [ ] Add offline support

### Phase 4: State Management (FUTURE)
- [ ] Add Provider/Riverpod
- [ ] Centralize state
- [ ] Improve reactivity

### Phase 5: Testing (FUTURE)
- [ ] Unit tests for utilities
- [ ] Widget tests for components
- [ ] Integration tests for screens

### Phase 6: Cleanup (FINAL)
- [ ] Remove all legacy dependencies
- [ ] Delete legacy folder
- [ ] Final documentation update

## Best Practices

### ✅ DO
- Keep widgets small and focused
- Use const constructors when possible
- Extract reusable components
- Follow naming conventions
- Add documentation comments
- Use utility functions

### ❌ DON'T
- Create files > 500 lines
- Mix business logic with UI
- Duplicate code
- Import from legacy for new features
- Ignore linter warnings
- Skip error handling

## Documentation

- **REFACTORING_SUMMARY.md** - Complete refactoring report
- **REFACTORING_PLAN.md** - Original refactoring strategy
- **legacy/README.md** - Legacy files documentation
- **FIX_IMAGE_PICKER.md** - Image picker setup guide

---

**Last Updated**: October 16, 2025  
**Status**: Phase 1 Complete (67%)  
**Maintainer**: Development Team
