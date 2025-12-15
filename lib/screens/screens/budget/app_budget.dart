import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import '../../../services/simple_auth_manager.dart';
import '../../../widgets/components/ui/input.dart';
import 'widgets/budget_header.dart';
import 'widgets/circular_budget_chart.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/budget_animated_background.dart';
import '../bank/widgets/floating_connect_card.dart';
import '../overview/wallet_overview_screen.dart';
import 'category_manager.dart';

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key});

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> with TickerProviderStateMixin {
  // State variables
  String activeTab = 'overview';
  double totalBudget = 1000; // Total budget amount
  List<Transaction> transactions = [];
  Map<String, CategoryData> categories = Map.from(defaultCategories);
  List<String> expandedCategories = [];
  bool isEditingBudgets = false;
  Map<String, String> tempBudgetValues = {};
  
  // Sample bank transactions for the floating connect card
  List<Transaction> bankTransactions = [
    Transaction(
      id: '1',
      type: TransactionType.expense,
      amount: 45.99,
      category: 'Groceries',
      categoryKey: 'food',
      note: 'Weekly groceries',
      date: DateTime.now(),
      merchant: 'Whole Foods Market',
    ),
    Transaction(
      id: '2',
      type: TransactionType.expense,
      amount: 32.50,
      category: 'Transport',
      categoryKey: 'transport',
      note: 'Gas',
      date: DateTime.now().subtract(const Duration(days: 1)),
      merchant: 'Shell Station',
    ),
    Transaction(
      id: '3',
      type: TransactionType.expense,
      amount: 120.00,
      category: 'Entertainment',
      categoryKey: 'entertainment',
      note: 'Movie tickets',
      date: DateTime.now().subtract(const Duration(days: 2)),
      merchant: 'Cinema ABC',
    ),
  ];

  // Budget data
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets = {
    'housing': {
      'Rent': SubcategoryBudget(budgeted: 200, spent: 200),
      'Gym': SubcategoryBudget(budgeted: 10, spent: 10),
    },
    'food': {'Groceries': SubcategoryBudget(budgeted: 30, spent: 30)},
  };

  // Animation controller
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  // Calculations
  double get totalSpent {
    double spent = 0;
    categoryBudgets.forEach((_, subcats) {
      subcats.forEach((_, budget) {
        spent += budget.spent;
      });
    });
    return spent;
  }

  double get budgetLeft => totalBudget - totalSpent;
  double get budgetPercentage => (totalSpent / totalBudget) * 100;

  void _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      SimpleAuthManager.instance.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SmartSpend',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1A), Color(0xFF1A1F33), Color(0xFF0A0E1A)],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background
            BudgetAnimatedBackground(controller: _rotationController),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  const BudgetStatusBar(),
                  BudgetHeader(
                    activeTab: activeTab,
                    isEditingBudgets: isEditingBudgets,
                    onEditToggle: () {
                      setState(() {
                        if (isEditingBudgets) {
                          _saveAllBudgets();
                        } else {
                          _enterEditMode();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: activeTab == 'budget'
                        ? _buildBudgetTab()
                        : const WalletOverviewContent(),
                  ),
                ],
              ),
            ),

            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BudgetBottomNavigation(
                activeTab: activeTab,
                onTabChanged: (tab) => setState(() => activeTab = tab),
              ),
            ),

            // Floating Connect Card Button
            FloatingConnectCard(
              transactions: bankTransactions,
              onCardConnected: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bank card connected successfully!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
              onTransactionAction: (transaction, isAccepted) {
                setState(() {
                  if (isAccepted) {
                    // Save transaction - add to the transactions list
                    transactions.add(transaction);
                    
                    // Update budget spent amount
                    final categoryKey = transaction.categoryKey;
                    if (categoryBudgets.containsKey(categoryKey)) {
                      final subcategory = transaction.category;
                      if (categoryBudgets[categoryKey]!.containsKey(subcategory)) {
                        categoryBudgets[categoryKey]![subcategory]!.spent += transaction.amount;
                      } else {
                        // Create new subcategory if it doesn't exist
                        categoryBudgets[categoryKey]![subcategory] = SubcategoryBudget(
                          budgeted: 0,
                          spent: transaction.amount,
                        );
                      }
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Transaction saved: ${transaction.merchant}'),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    );
                  } else {
                    // Edit transaction - show edit dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Edit transaction: ${transaction.merchant}'),
                        backgroundColor: const Color(0xFFFF9800),
                      ),
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircularBudgetChart(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            budgetLeft: budgetLeft,
            budgetPercentage: budgetPercentage,
            onBudgetTap: _showEditBudgetDialog,
          ),
          const SizedBox(height: 24),
          _buildCategoriesList(),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '€${totalSpent.toStringAsFixed(0)} / €${totalBudget.toStringAsFixed(0)} spent',
                  style: const TextStyle(
                    color: Color(0xFF00F5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (isEditingBudgets)
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF00F5FF),
                  size: 24,
                ),
                onPressed: () {
                  _showManageCategoriesDialog();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...categoryBudgets.entries.map((entry) {
          final categoryKey = entry.key;
          final subcategories = entry.value;
          final categoryData = categories[categoryKey];

          if (categoryData == null) return const SizedBox.shrink();

          final isExpanded = expandedCategories.contains(categoryKey);
          final categorySpent = subcategories.values.fold<double>(0.0, (sum, b) => sum + b.spent);
          final categoryBudgeted = subcategories.values.fold<double>(0.0, (sum, b) => sum + b.budgeted); // ADD THIS LINE

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1F3A).withValues(alpha:0.85),
                  const Color(0xFF2A2F4A).withValues(alpha:0.6),
                ],
              ),
              border: Border.all(color: categoryData.solidColor.withValues(alpha:0.25)),
            ),
            child: Column(
              children: [
                // Header
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedCategories.remove(categoryKey);
                      } else {
                        expandedCategories.add(categoryKey);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: categoryData.solidColor.withValues(alpha:0.18),
                          ),
                          child: Center(
                            child: Text(categoryData.icon, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryData.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '€${categorySpent.toStringAsFixed(0)} / €${categoryBudgeted.toStringAsFixed(0)}', // CHANGE THIS LINE
                                style: TextStyle(
                                  color: categorySpent > categoryBudgeted ? Colors.red : categoryData.solidColor, // CHANGE THIS LINE
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isEditingBudgets)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white70),
                            onPressed: () => _showEditCategoryDialog(categoryKey, categoryData),
                          ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
                // Subcategories
                if (isExpanded)
                  Column(
                    children: [
                      for (final subEntry in subcategories.entries)
                        _buildSubcategoryItem(subEntry.key, subEntry.value, categoryData.solidColor),
                      if (subcategories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'No subcategories.',
                            style: TextStyle(color: Colors.white.withValues(alpha:0.6)),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubcategoryItem(
    String subcategoryName,
    SubcategoryBudget budget,
    Color categoryColor,
  ) {
    final percentage = budget.budgeted > 0
        ? (budget.spent / budget.budgeted) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha:0.1)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 64),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcategoryName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withValues(alpha:0.1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (percentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: percentage > 90 ? Colors.red : categoryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '€${budget.spent.toStringAsFixed(0)} / €${budget.budgeted.toStringAsFixed(0)}',
            style: TextStyle(
              color: categoryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog() {
    final controller = TextEditingController(text: totalBudget.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
            ),
          ),
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Color(0xFF00F5FF), size: 24),
              SizedBox(width: 12),
              Text(
                'Edit Total Budget',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set your monthly budget amount',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: controller,
                label: 'Budget Amount',
                placeholder: 'Enter amount',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newBudget = double.tryParse(controller.text);
                if (newBudget != null && newBudget > 0) {
                  setState(() {
                    totalBudget = newBudget;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Budget updated to €${newBudget.toStringAsFixed(0)}'),
                      backgroundColor: const Color(0xFF00F5FF),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F5FF),
                foregroundColor: const Color(0xFF1A1F3A),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _enterEditMode() {
    tempBudgetValues.clear();
    setState(() => isEditingBudgets = true);
  }

  void _saveAllBudgets() {
    tempBudgetValues.forEach((key, value) {
      final amount = double.tryParse(value);
      if (amount != null) {
        debugPrint('Saving budget for $key: €$amount');
      }
    });

    tempBudgetValues.clear();
    setState(() => isEditingBudgets = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budgets saved successfully!'),
        backgroundColor: Color(0xFF00F5FF),
      ),
    );
  }

  void _showEditCategoryDialog(String categoryKey, CategoryData categoryData) {
    showEditCategoryDialog(
      context,
      categories,
      categoryKey,
      categoryData,
      categoryBudgets,
      () => setState(() {}),
    );
  }

  void _showManageCategoriesDialog() {
    showManageCategoriesDialog(
      context,
      categories,
      categoryBudgets,
      (key, data) => _showEditCategoryDialog(key, data),
      () => setState(() {}),
    );
  }
}
