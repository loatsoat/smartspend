# 📚 Quick Reference Guide - Budget App Files

## 🗂️ File Locations

### **Models**
```
lib/models/budget_models.dart
```
- Transaction, CategoryData, SubcategoryBudget models
- Default categories configuration

### **Main Screen**
```
lib/screens/screens/budget/app_budget.dart
```
- Main budget app logic and state management

### **Reusable Widgets**
```
lib/screens/screens/budget/widgets/
  ├── budget_header.dart
  ├── circular_budget_chart.dart
  ├── category_card.dart
  ├── bottom_navigation.dart
  └── budget_animated_background.dart
```

---

## 🎯 What Each File Does

### **budget_models.dart**
📦 **Data structures for the entire budget app**
- Transaction model (id, type, amount, category, date, etc.)
- CategoryData (name, colors, icon, subcategories)
- SubcategoryBudget (budgeted amount, spent amount)
- Default categories (Housing, Food, Savings, Income)

### **budget_header.dart**
🎨 **Top section of the app**
- `BudgetStatusBar` - Time, date, battery indicator
- `BudgetHeader` - Title, settings button, edit/save button

### **circular_budget_chart.dart**
📊 **Budget visualization**
- Circular progress indicator showing budget usage
- Displays: budget left, total budget, spent amount
- Color changes based on usage (red if >90%)

### **category_card.dart**
🏷️ **Category display cards**
- Shows category icon, name, and budget info
- Expandable to show subcategories
- Edit button in edit mode
- Tap to expand/collapse

### **bottom_navigation.dart**
🧭 **Tab navigation**
- Overview tab (cyan gradient)
- Budget tab (pink gradient)
- Animated active state
- Smooth transitions

### **budget_animated_background.dart**
✨ **Animated background effects**
- Rotating gradient orbs
- Adds visual depth
- Smooth continuous animation

---

## 🔧 How to Modify

### **Add a New Category**
Edit: `lib/models/budget_models.dart`
```dart
'newCategory': CategoryData(
  name: 'New Category',
  gradientColors: [Color(0xFF...), Color(0xFF...)],
  solidColor: Color(0xFF...),
  glowColor: Color(0xFF...).withValues(alpha: 0.6),
  icon: '🎯',
  subcategories: ['Sub1', 'Sub2'],
),
```

### **Change Header Title**
Edit: `lib/screens/screens/budget/widgets/budget_header.dart`
```dart
const Text(
  'Your New Title', // Change this
  style: TextStyle(...),
),
```

### **Modify Budget Chart Colors**
Edit: `lib/screens/screens/budget/widgets/circular_budget_chart.dart`
```dart
valueColor: AlwaysStoppedAnimation<Color>(
  budgetPercentage > 90
      ? Colors.red  // Change warning color
      : const Color(0xFF00F5FF),  // Change normal color
),
```

### **Add New Tab**
Edit: `lib/screens/screens/budget/widgets/bottom_navigation.dart`
```dart
_buildNavItem(
  'newTab',
  Icons.your_icon,
  'NEW TAB',
  const LinearGradient(
    colors: [Color(0xFF...), Color(0xFF...)],
  ),
),
```

---

## 📝 Common Tasks

### **Task: Update a Category Icon**
1. Open `lib/models/budget_models.dart`
2. Find the category in `defaultCategories`
3. Change the `icon` field
4. Save and hot reload

### **Task: Change Budget Warning Threshold**
1. Open `lib/screens/screens/budget/widgets/circular_budget_chart.dart`
2. Find `budgetPercentage > 90`
3. Change `90` to your desired threshold
4. Save and hot reload

### **Task: Add New Widget to Budget Screen**
1. Create new widget file in `lib/screens/screens/budget/widgets/`
2. Import in `app_budget.dart`
3. Add widget to the build method
4. Pass required parameters

### **Task: Modify Animation Speed**
1. Open `lib/screens/screens/budget/app_budget.dart`
2. Find `AnimationController` initialization
3. Change `duration` value
4. Save and hot reload

---

## 🐛 Troubleshooting

### **Import Errors**
✅ Make sure to import from correct path:
```dart
import 'package:hci_app/models/budget_models.dart';
import 'widgets/budget_header.dart';
```

### **Widget Not Updating**
✅ Check if you're calling `setState()` in parent widget
✅ Verify parameters are being passed correctly

### **Colors Not Showing**
✅ Use `.withValues(alpha: ...)` instead of `.withOpacity()`
✅ Check if gradient colors are defined correctly

### **Animation Not Working**
✅ Verify `AnimationController` is initialized in `initState()`
✅ Check if controller is disposed in `dispose()`
✅ Ensure `TickerProviderStateMixin` is added to State class

---

## 🎨 Color Palette Reference

### **Category Colors**
- **Income:** Cyan `#00F5FF`
- **Housing:** Pink `#FF6B9D`
- **Food:** Purple `#A855F7`
- **Savings:** Green `#10F4B1`

### **UI Colors**
- **Background Dark:** `#0A0E1A`
- **Background Mid:** `#1A1F33`
- **Card Background:** `#1A1F3A` / `#2A2F4A`
- **Text Primary:** `Colors.white`
- **Text Secondary:** `Colors.white70`

---

## 📱 Screen Structure

```
BudgetApp
├── AnimatedBackground
├── SafeArea
│   ├── BudgetStatusBar
│   ├── BudgetHeader
│   └── Content (Tab-based)
│       ├── Overview Tab
│       │   ├── Balance Card
│       │   ├── Quick Actions
│       │   └── Transaction List
│       └── Budget Tab
│           ├── CircularBudgetChart
│           └── CategoryCard (multiple)
│               └── Subcategory Items
└── BudgetBottomNavigation
```

---

## 🚀 Performance Tips

1. **Use `const` constructors** where possible
2. **Avoid rebuilding entire tree** - use specific setState
3. **Cache expensive calculations** - store in variables
4. **Use `ListView.builder`** for long lists
5. **Dispose controllers** in dispose() method

---

## 📖 Further Reading

- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [State Management](https://docs.flutter.dev/data-and-backend/state-mgmt)
- [Animation Guide](https://docs.flutter.dev/ui/animations)
- [Material Design](https://m3.material.io/)
