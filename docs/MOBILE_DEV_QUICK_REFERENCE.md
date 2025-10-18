# 📱 Mobile Development Quick Reference

**For:** Flutter Mobile App Development  
**Focus:** Owner Features Parity with Web

---

## 🎯 START HERE

**Main Document:** [Owner Features Complete Comparison](OWNER_FEATURES_COMPLETE_COMPARISON.md)

---

## ✅ Quick Checklist - What's Missing on Mobile

### 🔴 HIGH PRIORITY

#### Payment Management
- [ ] Gradient stat cards
- [ ] Total revenue stat
- [ ] Filter tabs (All, Pending, Submitted, Paid, Expired)
- [ ] Receipt viewer/download
- [ ] Time left indicator
- [ ] Status update dropdown
- [ ] Card-based layout with gradients

#### Booking Management  
- [ ] Booking type badge (Whole/Shared)
- [ ] Duration display
- [ ] Filter tabs
- [ ] "Contact Student" button → Messages
- [ ] Gradient stat cards

#### Tenant Management
- [ ] Payment history screen/modal
- [ ] Payment timeline view
- [ ] "Contact Tenant" button → Messages
- [ ] Tenant avatars with initials
- [ ] Card-based layout

### 🟡 MEDIUM PRIORITY

#### Dorm Management
- [ ] Deposit required field
- [ ] Deposit months field (1-12)
- [ ] Multiple image upload (up to 5)
- [ ] Image carousel
- [ ] Gradient card backgrounds
- [ ] Amenity icons (not just text)

#### Room Management
- [ ] Card-based layout
- [ ] Gradient backgrounds
- [ ] Color-coded status badges
- [ ] Group rooms by dorm

#### Dashboard
- [ ] Gradient stat cards
- [ ] Quick action buttons (Add Dorm, Bookings, Messages)
- [ ] Recent bookings preview
- [ ] Recent payments preview
- [ ] Recent messages preview

### 🟢 LOW PRIORITY

#### Messages
- [ ] Purple gradient for owner messages
- [ ] Circular avatars with gradients
- [ ] Unread message badges
- [ ] Dorm info in conversation list

---

## 🎨 Design System Quick Reference

### Colors

```dart
// Primary Purple Gradient
final primaryGradient = LinearGradient(
  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
);

// Status Gradients
final statusGradients = {
  'pending': LinearGradient(
    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
  ),
  'submitted': LinearGradient(
    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
  ),
  'paid': LinearGradient(
    colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
  ),
  'expired': LinearGradient(
    colors: [Color(0xFFfc4a1a), Color(0xFFf7b733)],
  ),
  'approved': LinearGradient(
    colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
  ),
  'rejected': LinearGradient(
    colors: [Color(0xFFfc4a1a), Color(0xFFf7b733)],
  ),
};

// Text Colors
final darkText = Color(0xFF2c3e50);
final mediumText = Color(0xFF495057);
final lightText = Color(0xFF6c757d);
```

### Typography

```dart
// Header
TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Color(0xFF2c3e50),
)

// Body
TextStyle(
  fontSize: 16,
  color: Color(0xFF495057),
)

// Secondary
TextStyle(
  fontSize: 14,
  color: Color(0xFF6c757d),
)
```

### Card Design

```dart
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(...), // When applicable
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: YourContent(),
    ),
  ),
)
```

---

## 🧩 Reusable Components to Create

### 1. StatCard

```dart
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
                Text(title, style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6c757d),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. StatusBadge

```dart
class StatusBadge extends StatelessWidget {
  final String status;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient ?? statusGradients[status.toLowerCase()],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

### 3. AvatarCircle

```dart
class AvatarCircle extends StatelessWidget {
  final String name;
  final double radius;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
```

### 4. GradientButton

```dart
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 5. FilterTabBar

```dart
class FilterTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabChanged;
  
  @override
  _FilterTabBarState createState() => _FilterTabBarState();
}

class _FilterTabBarState extends State<FilterTabBar> {
  int activeIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isActive = index == activeIndex;
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tab),
              selected: isActive,
              onSelected: (selected) {
                setState(() => activeIndex = index);
                widget.onTabChanged(index);
              },
              backgroundColor: Colors.white,
              selectedColor: Color(0xFF667eea),
              labelStyle: TextStyle(
                color: isActive ? Colors.white : Color(0xFF495057),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

---

## 📁 File Locations

### Owner Screens (Mobile)
```
mobile/lib/screens/owner/
├── owner_dashboard.dart          → Needs gradient stats + quick actions
├── manage_dorms_screen.dart      → Needs deposit fields + multiple images
├── manage_rooms_screen.dart      → Needs card layout + grouping
├── bookings_screen.dart          → Needs booking type + filters
├── owner_payments_screen.dart    → Needs complete redesign
├── tenants_screen.dart           → Needs payment history feature
├── messages_screen.dart          → Needs gradient updates
└── owner_profile_screen.dart     → ✅ Complete
```

### API Endpoints (Web)
```
Main/modules/api/
├── fetch_payments.php           → Payment data
├── fetch_bookings.php           → Booking data
├── fetch_messages.php           → Messages data
└── fetch_tenants.php            → Tenant data
```

---

## 🔧 Common Patterns

### Fetch Data with Loading State

```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool isLoading = true;
  List<dynamic> data = [];
  
  @override
  void initState() {
    super.initState();
    fetchData();
  }
  
  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getData();
      setState(() {
        data = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      // Show error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (data.isEmpty) {
      return EmptyState(message: 'No data found');
    }
    
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => DataCard(data[index]),
    );
  }
}
```

### Navigate to Messages with Context

```dart
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesScreen(
          studentId: booking.studentId,
          dormId: booking.dormId,
        ),
      ),
    );
  },
  child: Text('Contact Student'),
)
```

---

## 🚀 Implementation Order

### Week 1-2: Critical Features
1. Payment management complete redesign
2. Booking management filters + booking type
3. Tenant payment history feature

### Week 3-4: UI Modernization
4. Dorm management deposit fields + images
5. Room management card layout
6. Dashboard gradient stats

### Week 5: Polish
7. Messages gradient updates
8. Component library
9. Testing & bug fixes

---

## 📊 Progress Tracking

Track your progress in: [OWNER_FEATURES_COMPLETE_COMPARISON.md](OWNER_FEATURES_COMPLETE_COMPARISON.md)

Update checkboxes as you complete features!

---

## 💡 Pro Tips

1. **Reuse Components** - Create once, use everywhere
2. **Match Web Design** - Keep consistency with web platform
3. **Test on Real Devices** - Emulator isn't always accurate
4. **Use Gradients** - They make everything look modern
5. **Add Animations** - Smooth transitions enhance UX
6. **Handle Loading States** - Always show feedback
7. **Handle Empty States** - Guide users when no data
8. **Handle Errors** - Show helpful error messages

---

## 🎯 Success Metrics

Your mobile app is ready when:
- ✅ All web features available
- ✅ Consistent UI with gradients
- ✅ All stats match web
- ✅ Real-time updates work
- ✅ No critical bugs
- ✅ Performance optimized
- ✅ User testing complete

---

**Need more details?** Check the full [Owner Features Comparison](OWNER_FEATURES_COMPLETE_COMPARISON.md)

**Happy Coding! 🚀**

