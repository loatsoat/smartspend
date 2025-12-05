import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import 'widgets/budget_header.dart';
import 'widgets/circular_budget_chart.dart';
import 'widgets/category_card.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/budget_animated_background.dart';
import 'category_manager.dart';

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key});

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> with TickerProviderStateMixin {
  // State variables
  String activeTab = 'overview';
  List<Transaction> transactions = [];
  Map<String, CategoryData> categories = Map.from(defaultCategories);
  List<String> expandedCategories = [];
  bool isEditingBudgets = false;
  Map<String, String> tempBudgetValues = {};

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
  double get totalBudget => 1000;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        : _buildOverviewTab(),
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
            const Text(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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

          return CategoryCard(
            categoryKey: categoryKey,
            categoryData: categoryData,
            subcategories: subcategories,
            isExpanded: expandedCategories.contains(categoryKey),
            isEditingBudgets: isEditingBudgets,
            onTap: () {
              setState(() {
                if (expandedCategories.contains(categoryKey)) {
                  expandedCategories.remove(categoryKey);
                } else {
                  expandedCategories.add(categoryKey);
                }
              });
            },
            onEditCategory: _showEditCategoryDialog,
            buildSubcategoryItem: _buildSubcategoryItem,
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
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
                    color: Colors.white.withValues(alpha: 0.1),
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
          if (isEditingBudgets)
            SizedBox(
              width: 80,
              child: TextField(
                controller: TextEditingController(
                  text: tempBudgetValues['$subcategoryName'] ??
                      budget.budgeted.toStringAsFixed(0),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: categoryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: categoryColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  tempBudgetValues[subcategoryName] = value;
                },
              ),
            )
          else
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

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Balance card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF395587).withValues(alpha: 0.3),
                  const Color(0xFF4a6aa0).withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  '€${budgetLeft.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Add Income',
                  Icons.add,
                  const Color(0xFF00F5FF),
                  () => _showAddTransaction(TransactionType.income),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  'Add Expense',
                  Icons.remove,
                  const Color(0xFFFF6B9D),
                  () => _showAddTransaction(TransactionType.expense),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent transactions
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            ...transactions.take(5).map((transaction) {
              return _buildTransactionItem(transaction);
            }),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final categoryData = categories[transaction.categoryKey];
    final isExpense = transaction.type == TransactionType.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A).withValues(alpha: 0.6),
            const Color(0xFF2A2F4A).withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Row(
        children: [
          if (categoryData != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: categoryData.gradientColors),
              ),
              child: Center(
                child: Text(
                  categoryData.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: const Icon(Icons.category, color: Colors.white, size: 20),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note.isNotEmpty
                      ? transaction.note
                      : transaction.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}€${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isExpense
                  ? const Color(0xFFFF6B9D)
                  : const Color(0xFF00F5FF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _showAddTransaction(TransactionType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add ${type.name} transaction - Coming soon!'),
        backgroundColor: type == TransactionType.income
            ? const Color(0xFF00F5FF)
            : const Color(0xFFFF6B9D),
      ),
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
