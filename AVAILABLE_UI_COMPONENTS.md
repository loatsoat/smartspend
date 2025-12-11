# 🎨 Available UI Components

You have a complete UI component library in `lib/widgets/components/ui/` that's currently **not being used** in your budget app!

---

## 📦 Available Components

### **1. Button** (`button.dart`)
```dart
CustomButton(
  text: 'Click Me',
  variant: ButtonVariant.primary, // primary, destructive, outline, secondary, ghost, link
  size: ButtonSize.medium, // small, medium, large, icon
  icon: Icon(Icons.add),
  onPressed: () {},
)
```

### **2. Input** (`input.dart`)
```dart
CustomInput(
  label: 'Email',
  placeholder: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icon(Icons.email),
  onChanged: (value) {},
)
```

### **3. Card** (`card.dart`)
```dart
CustomCard(
  child: Column(
    children: [
      CardHeader(
        title: CardTitle(text: 'Title'),
        subtitle: CardDescription(text: 'Description'),
      ),
      CardContent(child: Text('Content')),
      CardFooter(child: Text('Footer')),
    ],
  ),
)
```

### **4. Dialog** (`dialog.dart`)
```dart
CustomDialog.show(
  context: context,
  title: DialogTitle(text: 'Confirm'),
  content: DialogDescription(text: 'Are you sure?'),
  actions: [
    TextButton(child: Text('Cancel'), onPressed: () {}),
    ElevatedButton(child: Text('OK'), onPressed: () {}),
  ],
)
```

### **5. Badge** (`badge.dart`)
```dart
CustomBadge(
  text: 'New',
  variant: BadgeVariant.primary, // primary, secondary, destructive, outline
  icon: Icon(Icons.star),
)
```

### **6. Alert** (`alert.dart`)
Alert messages and notifications

### **7. Avatar** (`avatar.dart`)
User profile pictures

### **8. Checkbox** (`checkbox.dart`)
Custom checkboxes

### **9. Label** (`label.dart`)
Form labels

### **10. Progress** (`progress.dart`)
Progress indicators

### **11. Separator** (`separator.dart`)
Dividers and separators

### **12. Skeleton** (`skeleton.dart`)
Loading skeletons

### **13. Switch** (`switch.dart`)
Toggle switches

### **14. Tabs** (`tabs.dart`)
Tab navigation

### **15. Textarea** (`textarea.dart`)
Multi-line text input

### **16. Tooltip** (`tooltip.dart`)
Hover tooltips

---

## 🔧 Custom Widgets (Already Created)

### **17. GlassmorphicCard** (`lib/widgets/widgets/glassmorphic_card.dart`)
```dart
GlassmorphicCard(
  child: Text('Content'),
  borderRadius: 32,
)
```

### **18. GradientButton** (`lib/widgets/widgets/gradient_button.dart`)
```dart
GradientButton(
  onPressed: () {},
  child: Text('Click Me'),
)
```

### **19. CustomTextField** (`lib/widgets/widgets/custom_text_field.dart`)
```dart
CustomTextField(
  controller: controller,
  label: 'Label',
  hint: 'Hint',
  prefixIcon: Icons.person,
)
```

### **20. AnimatedBackground** (`lib/widgets/widgets/animated_background.dart`)
```dart
AnimatedBackground()
```

---

## 💡 How to Use in Budget App

### **Current Usage:**
Your budget app is using **custom-built widgets** instead of these reusable components.

### **Recommended Changes:**

#### **1. Replace TextField with CustomInput**
```dart
// Current
TextField(
  controller: controller,
  decoration: InputDecoration(...),
)

// Better
CustomInput(
  controller: controller,
  label: 'Budget Amount',
  placeholder: 'Enter amount',
  keyboardType: TextInputType.number,
)
```

#### **2. Use CustomButton for Actions**
```dart
// Current
ElevatedButton(
  onPressed: () {},
  child: Text('Save'),
)

// Better
CustomButton(
  text: 'Save',
  variant: ButtonVariant.primary,
  icon: Icon(Icons.save),
  onPressed: () {},
)
```

#### **3. Use CustomDialog for Confirmations**
```dart
// Current
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
)

// Better
CustomDialog.show(
  context: context,
  title: DialogTitle(text: 'Delete Category?'),
  content: DialogDescription(text: 'This action cannot be undone'),
  actions: [
    CustomButton(
      text: 'Cancel',
      variant: ButtonVariant.outline,
      onPressed: () => Navigator.pop(context),
    ),
    CustomButton(
      text: 'Delete',
      variant: ButtonVariant.destructive,
      onPressed: () {},
    ),
  ],
)
```

#### **4. Use CustomBadge for Status**
```dart
// Show budget status
CustomBadge(
  text: percentage > 90 ? 'Over Budget' : 'On Track',
  variant: percentage > 90 ? BadgeVariant.destructive : BadgeVariant.primary,
)
```

#### **5. Use CustomCard for Category Cards**
```dart
CustomCard(
  child: Column(
    children: [
      CardHeader(
        title: CardTitle(text: categoryData.name),
        subtitle: CardDescription(text: '${subcategories.length} subcategories'),
        action: CustomBadge(text: '${percentage.toInt()}%'),
      ),
      CardContent(child: ...),
    ],
  ),
)
```

---

## 🎯 Benefits of Using These Components

### **1. Consistency**
- All components follow the same design system
- Consistent spacing, colors, and typography

### **2. Maintainability**
- Change one component, update everywhere
- Easier to fix bugs

### **3. Reusability**
- Use across different screens
- Less code duplication

### **4. Theme Support**
- Automatically adapt to light/dark themes
- Respect app theme colors

### **5. Accessibility**
- Built-in accessibility features
- Better user experience

---

## 🚀 Quick Integration Example

Here's how to update your budget app to use these components:

```dart
// In app_budget.dart

// Import the components
import '../../widgets/components/ui/button.dart';
import '../../widgets/components/ui/input.dart';
import '../../widgets/components/ui/card.dart';
import '../../widgets/components/ui/dialog.dart';
import '../../widgets/components/ui/badge.dart';

// Use in your widgets
Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
  return CustomButton(
    text: label,
    icon: Icon(icon, size: 20),
    variant: ButtonVariant.primary,
    onPressed: onTap,
  );
}

// Budget input field
Widget _buildBudgetInput(String subcategoryName, SubcategoryBudget budget) {
  return CustomInput(
    label: subcategoryName,
    placeholder: 'Enter budget',
    keyboardType: TextInputType.number,
    controller: TextEditingController(text: budget.budgeted.toString()),
  );
}

// Category status badge
Widget _buildStatusBadge(double percentage) {
  return CustomBadge(
    text: '${percentage.toInt()}%',
    variant: percentage > 90 ? BadgeVariant.destructive : BadgeVariant.primary,
  );
}
```

---

## 📝 Next Steps

1. **Fix deprecation warnings** in UI components (`.withValues(alpha:)` → `.withValues()`)
2. **Integrate components** into budget app
3. **Create examples** for each component
4. **Document usage** patterns

---

## 🎨 Component Status

| Component | Available | Used in App | Status |
|-----------|-----------|-------------|--------|
| Button | ✅ | ❌ | Ready to use |
| Input | ✅ | ❌ | Ready to use |
| Card | ✅ | ❌ | Ready to use |
| Dialog | ✅ | ❌ | Ready to use |
| Badge | ✅ | ❌ | Ready to use |
| Alert | ✅ | ❌ | Ready to use |
| Avatar | ✅ | ❌ | Ready to use |
| Checkbox | ✅ | ❌ | Ready to use |
| Progress | ✅ | ❌ | Ready to use |
| Tabs | ✅ | ❌ | Ready to use |
| Tooltip | ✅ | ❌ | Ready to use |
| GlassmorphicCard | ✅ | ❌ | Ready to use |
| GradientButton | ✅ | ❌ | Ready to use |
| CustomTextField | ✅ | ❌ | Ready to use |
| AnimatedBackground | ✅ | ✅ | In use! |

**Total:** 20 components available, only 1 currently used!

---

## 💡 Recommendation

Start by integrating the most useful components first:
1. **CustomButton** - Replace all button widgets
2. **CustomInput** - Replace TextField widgets
3. **CustomDialog** - Replace AlertDialog
4. **CustomBadge** - Add status indicators
5. **CustomCard** - Improve card styling

This will make your app more consistent and easier to maintain!
