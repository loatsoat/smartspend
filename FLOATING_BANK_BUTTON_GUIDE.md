# Floating Bank Connection Button - User Guide

## Overview
The floating bank connection button allows users to connect their bank card and review transactions with swipe gestures.

## Features

### 1. Floating Button
- **Location**: Bottom-right corner of the screen
- **Icon**: Purple gradient wallet icon
- **Action**: Tap to open the bank card connection dialog

### 2. Bank Card Connection Dialog
- **Purpose**: Simulates connecting a bank card
- **Fields**: Card number input (placeholder)
- **Action**: Click "CONNECT CARD" button to proceed to transaction review

### 3. Transaction Swiper
- **Purpose**: Review and manage imported bank transactions
- **Gestures**:
  - **Swipe Right**: Save/Accept the transaction
  - **Swipe Left**: Edit the transaction
- **Display**: Shows one transaction at a time with:
  - Merchant name
  - Amount
  - Description
  - Category
  - Date
  - Progress indicator (e.g., "1/3")

### 4. Transaction Actions

#### Swipe Right (Save)
- Adds the transaction to your budget
- Updates the spent amount for the category
- Shows success notification

#### Swipe Left (Edit)
- Triggers edit mode (currently shows notification)
- Can be extended to open an edit dialog

## Implementation Details

### Files Created/Modified

1. **lib/screens/screens/bank/bank_connection_screen.dart** ⭐ NEW
   - Dedicated full-screen for transaction review
   - Handles swipe gestures for save/edit
   - Shows completion view when done
   - Better UX with larger cards and clearer instructions

2. **lib/screens/screens/budget/widgets/floating_connect_card.dart**
   - Floating button widget
   - Bank card connection dialog
   - Navigates to BankConnectionScreen

3. **lib/screens/screens/budget/app_budget.dart**
   - Integrated FloatingConnectCard widget
   - Added sample bank transactions
   - Implemented transaction save logic

4. **lib/models/budget_models.dart**
   - Transaction model with merchant and description fields
   - Supports bank transaction data

### Sample Transactions
The app includes 3 sample transactions:
1. Whole Foods Market - $45.99 (Groceries)
2. Shell Station - $32.50 (Transport)
3. Cinema ABC - $120.00 (Entertainment)

## Usage Flow

1. User taps the floating wallet button (bottom-right)
2. Bank card connection dialog appears
3. User clicks "CONNECT CARD"
4. **Full-screen transaction review opens** (new dedicated screen)
5. User swipes right to save or left to edit each transaction
6. Progress indicator shows current position (e.g., "2 of 3")
7. Process repeats for each transaction
8. "All done!" completion view appears with "BACK TO BUDGET" button

## Customization

### Adding More Transactions
Edit the `bankTransactions` list in `app_budget.dart`:

```dart
bankTransactions = [
  Transaction(
    id: '4',
    type: TransactionType.expense,
    amount: 25.00,
    category: 'Coffee',
    categoryKey: 'food',
    note: 'Morning coffee',
    date: DateTime.now(),
    merchant: 'Starbucks',
  ),
  // Add more...
];
```

### Customizing Colors
The button uses a purple gradient:
- Primary: `Color(0xFFD8A5FF)`
- Secondary: `Color(0xFFC77FE8)`

Change these in `floating_connect_card.dart` to match your theme.

## Future Enhancements

- Real bank API integration
- Edit transaction dialog
- Category auto-detection
- Transaction filtering
- Bulk import/export
- Transaction history view
