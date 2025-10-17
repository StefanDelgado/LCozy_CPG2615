# Phase 5: Chat & Shared Screens - Refactoring Plan

## 📋 Overview
Phase 5 focuses on refactoring the chat functionality which is currently the last remaining legacy screen in use.

## 🎯 Goals
1. Refactor `student_owner_chat.dart` → 2 new screens + chat service
2. Extract reusable chat widgets
3. Create ChatService for API calls
4. Update all references to use new chat screens
5. Complete removal of legacy screen dependencies

## 📊 Current State

### File to Refactor: student_owner_chat.dart (277 lines)

**Current Structure:**
- Two screens in one file:
  1. `StudentChatListScreen` - Shows list of conversations
  2. `StudentOwnerChatScreen` - Shows individual chat conversation
- Hardcoded API URL
- Mixed UI and business logic
- No reusable widgets

**Issues:**
- Two screens in single file
- Hardcoded API URL (different from main app)
- API logic mixed with UI
- No chat widgets extracted
- No error handling
- No loading states
- No retry capability

## 🏗️ Refactoring Strategy

### New Structure

```
lib/
├── screens/
│   └── shared/
│       ├── chat_list_screen.dart          # Conversations list (~150 lines)
│       └── chat_conversation_screen.dart  # Individual chat (~180 lines)
│
├── widgets/
│   └── chat/
│       ├── chat_list_tile.dart           # Conversation preview
│       ├── message_bubble.dart           # Individual message
│       └── message_input.dart            # Input field with send button
│
├── services/
│   └── chat_service.dart                 # Chat API calls (~150 lines)
│
└── utils/
    └── api_constants.dart                # Update with chat API URL
```

## 📝 Implementation Plan

### Step 1: Create Chat Service
- [ ] Create `services/chat_service.dart`
- [ ] Move API calls from UI
- [ ] Methods:
  - `getUserChats()` - Get user's conversations
  - `getMessages()` - Get messages for a chat
  - `sendMessage()` - Send a new message
  - `getUserName()` - Get user's display name
- [ ] Return structured responses
- [ ] Add error handling

### Step 2: Create Chat Widgets
- [ ] Create `chat_list_tile.dart` - Conversation preview with avatar
- [ ] Create `message_bubble.dart` - Individual message display
- [ ] Create `message_input.dart` - Text input with send button

### Step 3: Create Chat List Screen
- [ ] Create `screens/shared/chat_list_screen.dart`
- [ ] Use ChatService for data
- [ ] Use ChatListTile widget
- [ ] Add loading states
- [ ] Add error handling
- [ ] Add pull-to-refresh

### Step 4: Create Chat Conversation Screen
- [ ] Create `screens/shared/chat_conversation_screen.dart`
- [ ] Use ChatService for data
- [ ] Use MessageBubble widget
- [ ] Use MessageInput widget
- [ ] Add loading states
- [ ] Add error handling
- [ ] Auto-scroll to bottom

### Step 5: Update References
- [ ] Find all imports of `student_owner_chat.dart`
- [ ] Update to use new screens
- [ ] Test navigation

### Step 6: Testing & Verification
- [ ] Test chat list loading
- [ ] Test sending messages
- [ ] Test receiving messages
- [ ] Test navigation between screens
- [ ] Run flutter analyze
- [ ] Verify zero errors

## 🎨 Widget Breakdown

### 1. ChatListTile Widget
**Purpose:** Display conversation preview in list
**Props:**
- `otherUserEmail`: String
- `lastMessage`: String
- `currentUserEmail`: String
- `onTap`: VoidCallback

**Usage:**
```dart
ChatListTile(
  otherUserEmail: 'owner@example.com',
  lastMessage: 'Hello, is the room still available?',
  currentUserEmail: userEmail,
  onTap: () => navigateToChat(),
)
```

### 2. MessageBubble Widget
**Purpose:** Display individual message
**Props:**
- `message`: String
- `isMe`: bool
- `timestamp`: DateTime?

**Usage:**
```dart
MessageBubble(
  message: 'Hello!',
  isMe: true,
)
```

### 3. MessageInput Widget
**Purpose:** Text input with send button
**Props:**
- `onSend`: Function(String)
- `controller`: TextEditingController?

**Usage:**
```dart
MessageInput(
  onSend: (text) => sendMessage(text),
)
```

## 📈 Expected Improvements

### Code Metrics
| File | Before | After | Reduction | Widgets Created |
|------|--------|-------|-----------|-----------------|
| student_owner_chat.dart | 277 lines | 2 screens + 3 widgets + 1 service | ~40% | 3 |
| - chat_list_screen.dart | - | ~150 lines | - | - |
| - chat_conversation_screen.dart | - | ~180 lines | - | - |
| - chat_service.dart | - | ~150 lines | - | - |
| **TOTAL** | **277 lines** | **~480 lines** | **Better organized** | **3** |

**Note:** Line count increases but code is better organized, reusable, and maintainable.

### Quality Improvements
- ✅ Separated concerns (UI, logic, API)
- ✅ Reusable chat widgets
- ✅ Centralized API calls
- ✅ Proper error handling
- ✅ Loading states
- ✅ Better UX
- ✅ Testable code

## ✅ Success Criteria
- [ ] All chat screens refactored
- [ ] Zero compilation errors
- [ ] Zero lint warnings
- [ ] All chat features working
- [ ] Navigation working
- [ ] No legacy screen dependencies remaining

## 🎉 Phase 5 Completion Impact
Upon completion, ALL legacy screens will be refactored:
- ✅ 13 screens refactored (Phases 1-4)
- ✅ 2 chat screens refactored (Phase 5)
- ✅ **15 total screens refactored**
- ✅ **ZERO legacy screen dependencies**
- ✅ **100% modern architecture**

---

**Phase Start:** October 16, 2025  
**Estimated Completion:** Same day  
**Status:** Planning Complete - Ready to Execute
