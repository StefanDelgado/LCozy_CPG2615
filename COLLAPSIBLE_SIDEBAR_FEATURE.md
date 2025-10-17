# Collapsible Sidebar Feature

## What's New

Added a collapsible/retractable sidebar with a hamburger menu button!

## Features

### 1. **Hamburger Menu Button**
- Purple button in the top-left corner
- Fixed position that stays visible while scrolling
- Smooth animations on hover and click
- Icon changes: 
  - ☰ (bars) when sidebar is visible
  - ✕ (times) when sidebar is hidden

### 2. **Smooth Animations**
- Sidebar slides in/out smoothly (0.3s transition)
- Main content area adjusts automatically
- Button repositions smoothly

### 3. **Persistent State**
- Uses localStorage to remember your preference
- Sidebar state persists across page reloads
- If you collapse it, it stays collapsed on all pages

### 4. **Mobile Responsive**
- On mobile (< 768px), sidebar starts collapsed
- Overlay appears when sidebar opens on mobile
- Click overlay to close sidebar

## How to Use

### Desktop:
1. **Click the hamburger button** (☰) in top-left to hide the sidebar
2. Content area expands to full width
3. **Click again** (✕ icon) to show the sidebar
4. Your preference is saved automatically

### Mobile:
1. Sidebar is hidden by default
2. Click hamburger button to open
3. Dark overlay appears
4. Click overlay or X button to close

## CSS Classes Added

- `.sidebar.collapsed` - Sidebar hidden state (translateX -280px)
- `.main.expanded` - Main content expanded to full width (margin-left: 0)
- `.hamburger-btn` - Toggle button styling
- `.hamburger-btn.shifted` - Button position when sidebar is open
- `.sidebar-overlay` - Dark overlay for mobile
- `.sidebar-overlay.active` - Overlay visible state

## JavaScript Functions

### `toggleSidebar()`
- Toggles all necessary classes
- Changes icon between bars and times
- Saves state to localStorage

### DOMContentLoaded Event
- Runs on page load
- Checks localStorage for saved state
- Restores sidebar state if previously collapsed

## Benefits

✅ **More screen space** - Hide sidebar when you don't need it
✅ **Better mobile experience** - Sidebar doesn't take up mobile screen
✅ **User preference** - Remembers your choice
✅ **Smooth UX** - Beautiful animations
✅ **Accessibility** - Easy to toggle with one click

## Compatibility

- Works on all modern browsers
- Responsive design for mobile/tablet/desktop
- No additional libraries required (uses Font Awesome icons already loaded)

## Upload Instructions

Upload the updated `Main/partials/header.php` to your GoDaddy server to enable this feature on all pages!
