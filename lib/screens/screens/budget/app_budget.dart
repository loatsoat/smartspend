import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import 'widgets/budget_header.dart';
import 'widgets/circular_budget_chart.dart';
import 'widgets/category_card.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/budget_animated_background.dart';
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

  // Add a mutable budget variable at the top of _BudgetAppState
  double manualBudget = 1000.0;

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
  double get totalBudget => manualBudget;

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
            onBudgetTap: () {
              showEditBudgetDialog(
                context,
                manualBudget,
                (newBudget) {
                  setState(() {
                    manualBudget = newBudget;
                  });
                },
              );
            },
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