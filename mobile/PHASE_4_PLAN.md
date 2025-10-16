# Phase 4: Auth & Remaining Screens - Refactoring Plan

## 📋 Overview
Phase 4 focuses on refactoring the authentication screens (Login and Register) and the chat functionality that's still using legacy code.

## 🎯 Goals
1. Refactor `Login.dart` → `login_screen.dart`
2. Refactor `Register.dart` → `register_screen.dart`
3. Create reusable auth widgets
4. Update `main.dart` to use new auth screens
5. Plan chat screen refactoring (student_owner_chat.dart)

## 📊 Current State

### Files to Refactor

#### 1. Login.dart (316 lines)
**Current Structure:**
- Login logic with API call
- Email/password fields
- Loading states
- Error handling
- Navigation to owner/student dashboards
- Register button

**Issues:**
- Hardcoded API URL
- Mixed UI and business logic
- No input validation
- Repeated styling code
- Certificate handling in UI layer

#### 2. Register.dart (339 lines)
**Current Structure:**
- Registration form (name, email, password, confirm password)
- Role selection dropdown (Student/Owner)
- API call for registration
- Navigation to login on success
- Error handling

**Issues:**
- Hardcoded API URL
- Validation logic in UI
- Repeated form field styling
- Mixed concerns

## 🏗️ Refactoring Strategy

### New Structure

```
lib/
├── screens/
│   └── auth/
│       ├── login_screen.dart           # Main login screen (clean, ~200 lines)
│       └── register_screen.dart        # Main register screen (clean, ~220 lines)
│
├── widgets/
│   └── auth/
│       ├── auth_header.dart           # Reusable header (logo + title)
│       ├── auth_text_field.dart       # Reusable text field
│       ├── role_selector.dart         # Role dropdown widget
│       └── auth_button.dart           # Reusable button widget
│
├── services/
│   └── auth_service.dart              # Authentication API calls
│
└── utils/
    ├── api_constants.dart             # Already exists
    └── validators.dart                # Already exists (enhance)
```

## 📝 Implementation Plan

### Step 1: Create Auth Service
- [ ] Create `services/auth_service.dart`
- [ ] Move login API logic
- [ ] Move register API logic
- [ ] Handle certificate issues properly
- [ ] Return structured responses

### Step 2: Enhance Validators
- [ ] Add email validation
- [ ] Add password strength validation
- [ ] Add password match validation
- [ ] Add name validation

### Step 3: Create Auth Widgets
- [ ] Create `auth_header.dart` - CozyDorm logo and title section
- [ ] Create `auth_text_field.dart` - Reusable text input with consistent styling
- [ ] Create `role_selector.dart` - Student/Owner dropdown
- [ ] Create `auth_button.dart` - Reusable button (primary/secondary)

### Step 4: Refactor Login Screen
- [ ] Create `screens/auth/login_screen.dart`
- [ ] Use AuthService for API calls
- [ ] Use auth widgets for UI
- [ ] Use validators for input validation
- [ ] Update navigation to use refactored screens
- [ ] Add proper error handling

### Step 5: Refactor Register Screen
- [ ] Create `screens/auth/register_screen.dart`
- [ ] Use AuthService for API calls
- [ ] Use auth widgets for UI
- [ ] Use validators for input validation
- [ ] Update navigation to login screen
- [ ] Add proper error handling

### Step 6: Update Main.dart
- [ ] Update imports to use new auth screens
- [ ] Update routes configuration
- [ ] Test navigation flow

### Step 7: Testing & Verification
- [ ] Test login with student account
- [ ] Test login with owner account
- [ ] Test registration flow
- [ ] Test error handling
- [ ] Test validation
- [ ] Run flutter analyze

## 🎨 Widget Breakdown

### 1. AuthHeader Widget
**Purpose:** Reusable header for auth screens
**Props:**
- `title`: String
- `subtitle`: String
- `showBackButton`: bool (default: false)

**Usage:**
```dart
AuthHeader(
  title: 'Welcome Back',
  subtitle: 'Sign in to continue to your account',
)
```

### 2. AuthTextField Widget
**Purpose:** Reusable text field with consistent styling
**Props:**
- `controller`: TextEditingController
- `label`: String
- `hintText`: String
- `prefixIcon`: IconData
- `obscureText`: bool (default: false)
- `keyboardType`: TextInputType
- `validator`: String? Function(String?)?
- `onChanged`: Function(String)?

**Usage:**
```dart
AuthTextField(
  controller: emailController,
  label: 'Email Address',
  hintText: 'Enter your email',
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
)
```

### 3. RoleSelector Widget
**Purpose:** Role selection dropdown
**Props:**
- `selectedRole`: String
- `onChanged`: Function(String?)

**Usage:**
```dart
RoleSelector(
  selectedRole: selectedRole,
  onChanged: (value) => setState(() => selectedRole = value!),
)
```

### 4. AuthButton Widget
**Purpose:** Reusable button with loading state
**Props:**
- `text`: String
- `onPressed`: VoidCallback?
- `isLoading`: bool (default: false)
- `isPrimary`: bool (default: true)

**Usage:**
```dart
AuthButton(
  text: 'Sign In',
  onPressed: login,
  isLoading: isLoading,
)
```

## 📈 Expected Improvements

### Code Metrics
| Screen | Before | After | Reduction | Widgets Created |
|--------|--------|-------|-----------|-----------------|
| Login | 316 lines | ~200 lines | ~37% | 4 |
| Register | 339 lines | ~220 lines | ~35% | 4 |
| **TOTAL** | **655 lines** | **~420 lines** | **~36%** | **8** |

### Quality Improvements
- ✅ Separated concerns (UI, logic, API)
- ✅ Reusable auth widgets
- ✅ Centralized API calls
- ✅ Proper validation
- ✅ Consistent styling
- ✅ Better error handling
- ✅ Testable code

## 🚀 Chat Screen Planning

### student_owner_chat.dart Analysis
**Status:** Currently used by multiple screens
**Plan:** Refactor in Phase 5 or as separate mini-phase

**Approach:**
1. Analyze current implementation
2. Extract chat widgets (message bubble, input field, etc.)
3. Create `screens/shared/chat_screen.dart`
4. Update all references

## 📚 Documentation
- [ ] Create PHASE_4_COMPLETE.md after completion
- [ ] Update README.md
- [ ] Update PROJECT_STRUCTURE.md

## ✅ Success Criteria
- [ ] All auth screens refactored
- [ ] Zero compilation errors
- [ ] Zero lint warnings
- [ ] All navigation working
- [ ] Login/register flow tested
- [ ] Code reduction achieved
- [ ] Reusable widgets created

---

**Phase Start:** October 16, 2025  
**Estimated Completion:** Same day  
**Status:** Planning Complete - Ready to Execute
