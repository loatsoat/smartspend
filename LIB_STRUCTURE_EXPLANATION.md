# Flutter App Structure Explanation

## 📁 Project Overview
This is a **SmartSpend Budget Tracking App** built with Flutter. It features authentication, budget management, transaction tracking, and a beautiful glassmorphic UI with animated backgrounds.

---

## 📂 File Structure & Explanations

### **Root Files**

#### `lib/main.dart`
**Purpose:** Application entry point
- Initializes the Flutter app
- Sets up light/dark theme support with `AppTheme`
- Configures the home screen to use `BudgetApp`
- Enables system theme mode detection

---

### **Main App**

#### `lib/app_budget.dart`
**Purpose:** Core budget tracking application
**Features:**
- **Transaction Management:** Add, view, and categorize expenses/income
- **Budget Tracking:** Set budgets per category and subcategory
- **Category System:** Predefined categories (Housing, Food, Savings, Income) with icons and colors
- **Visual Budget Display:** Circular progress chart showing budget usage
- **Animated UI:** Smooth transitions and glassmorphic design
- **Tab Navigation:** Overview and Budget tabs

**Key Components:**
- `Transaction` model - stores transaction data
- `CategoryData` model - defines category properties
- `SubcategoryBudget` model - tracks budgeted vs spent amounts
- Budget calculations and percentage tracking
- Expandable category cards with subcategory details
- Edit mode for updating budgets

---

### **🎨 Themes**

#### `lib/themes/app_theme.dart`
**Purpose:** Centralized theme configuration
**Features:**
- Light theme with white backgrounds
- Dark theme with dark backgrounds
- Consistent color palette across the app
- Material 3 design system
- Custom text styles for all typography
- Styled input fields, buttons, and cards

**Color Scheme:**
- Primary: `#030213` (dark blue)
- Accent: `#395587` (blue)
- Destructive: `#D4183D` (red)
- Borders and backgrounds with proper opacity

---

### **🔐 Authentication**

#### `lib/data/services/auth_service.dart`
**Purpose:** Mock authentication service (singleton pattern)
**Methods:**
- `login(email, password)` - Validates and logs in user
- `signup(name, email, password)` - Creates new account
- `resetPassword(email)` - Sends password reset
- `logout()` - Clears authentication state

**Note:** This is a mock implementation. In production, connect to a real backend API.

---

### **📱 Screens**

#### `lib/screens/screens/auth/auth_screen.dart`
**Purpose:** Authentication flow coordinator
- Manages switching between login, signup, and forgot password screens
- Uses `AnimatedSwitcher` for smooth transitions
- Includes animated background

#### `lib/screens/screens/auth/login_screen.dart`
**Purpose:** User login interface
**Features:**
- Email and password input fields
- Form validation
- Password visibility toggle
- Animated logo with pulsing effect
- Links to signup and forgot password
- Loading state during authentication

#### `lib/screens/screens/auth/signup_screen.dart`
**Purpose:** New user registration
**Features:**
- Username, email, and password fields
- Password confirmation
- Form validation (min 6 characters)
- Back to login navigation
- Loading state

#### `lib/screens/screens/auth/forgot_password_screen.dart`
**Purpose:** Password reset flow
**Features:**
- Email input for reset link
- Success/error feedback
- Auto-redirect to login after success

#### `lib/screens/screens/home/home_screen.dart`
**Purpose:** Main app home screen (placeholder)
**Features:**
- Two tabs: Overview and Budget
- Animated background
- Bottom navigation with gradient effects
- Settings button
- Placeholder content (full features in `app_budget.dart`)

---

### **🎨 Reusable Widgets**

#### `lib/widgets/widgets/animated_background.dart`
**Purpose:** Animated lava lamp background effect
**How it works:**
- Creates 5 animated gradient orbs
- Uses `CustomPainter` for rendering
- Continuous rotation and movement
- Adds depth and visual interest to screens

#### `lib/widgets/widgets/custom_text_field.dart`
**Purpose:** Styled text input component
**Features:**
- Label and hint text
- Prefix icon support
- Optional suffix icon (e.g., password visibility toggle)
- Form validation support
- Glassmorphic styling
- Keyboard type configuration

#### `lib/widgets/widgets/glassmorphic_card.dart`
**Purpose:** Frosted glass effect container
**Features:**
- Backdrop blur filter
- Gradient background
- Border and shadow effects
- Configurable border radius and padding
- Creates modern, depth-filled UI

#### `lib/widgets/widgets/gradient_button.dart`
**Purpose:** Styled gradient button
**Features:**
- Blue gradient background
- Glow shadow effect
- Ripple touch feedback
- Configurable height and border radius
- Disabled state support

---

## 🎯 Key Features Summary

### ✅ Authentication System
- Login, signup, and password reset flows
- Form validation
- Mock authentication service (ready for backend integration)

### ✅ Budget Management
- Category-based budgeting
- Subcategory tracking
- Visual budget progress
- Edit mode for budget adjustments

### ✅ Transaction Tracking
- Add income/expenses
- Categorize transactions
- Transaction history
- Date-based organization

### ✅ Modern UI/UX
- Glassmorphic design
- Animated backgrounds
- Smooth transitions
- Dark/light theme support
- Gradient accents and glows

---

## 🔧 Technical Details

### State Management
- Uses `StatefulWidget` with `setState()`
- Animation controllers for smooth effects
- Form state management with `GlobalKey<FormState>`

### Design Patterns
- Singleton pattern for `AuthService`
- Model classes for data structures
- Reusable widget components
- Separation of concerns (screens, widgets, services, themes)

### Dependencies Used
- `flutter/material.dart` - Material Design widgets
- `dart:math` - Mathematical calculations for animations
- `dart:ui` - Backdrop filter for glassmorphic effects

---

## 🚀 Next Steps for Development

1. **Backend Integration:** Replace mock `AuthService` with real API calls
2. **Database:** Add local storage (SQLite/Hive) or cloud database (Firebase)
3. **Transaction CRUD:** Complete add/edit/delete transaction functionality
4. **Analytics:** Add spending insights and charts
5. **Notifications:** Budget alerts and reminders
6. **Export:** PDF/CSV export of transactions
7. **Multi-currency:** Support for different currencies

---

## ✨ All Errors Fixed!

All deprecated `.withOpacity()` calls have been replaced with `.withValues(alpha: ...)` for Flutter 3.27+ compatibility.
