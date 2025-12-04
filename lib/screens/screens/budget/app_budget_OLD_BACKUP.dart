import 'package:flutter/material.dart';
import 'dart:math' as math;

// Models
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String categoryKey;
  final String note;
  final DateTime date;
  final bool excludeFromBudget;
  final String? merchant;
  final String? description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.categoryKey,
    required this.note,
    required this.date,
    this.excludeFromBudget = false,
    this.merchant,
    this.description,
  });
}

enum TransactionType { expense, income, transfer }

class CategoryData {
  final String name;
  final List<Color> gradientColors;
  final Color solidColor;
  final Color glowColor;
  final String icon;
  final List<String> subcategories;

  CategoryData({
    required this.name,
    required this.gradientColors,
    required this.solidColor,
    required this.glowColor,
    required this.icon,
    required this.subcategories,
  });
}

class SubcategoryBudget {
  final double budgeted;
  final double spent;

  SubcategoryBudget({required this.budgeted, required this.spent});
}

// Default Categories
final Map<String, CategoryData> defaultCategories = {
  'income': CategoryData(
    name: 'Income',
    gradientColors: [
      const Color(0xFF00F5FF),
      const Color(0xFF00D4FF),
      const Color(0xFF00B8FF),
    ],
    solidColor: const Color(0xFF00F5FF),
    glowColor: const Color(0xFF00F5FF).withValues(alpha: 0.6),
    icon: '💰',
    subcategories: ['Income'],
  ),
  'housing': CategoryData(
    name: 'Housing',
    gradientColors: [
      const Color(0xFFFF6B9D),
      const Color(0xFFFE5196),
      const Color(0xFFFF3D8F),
    ],
    solidColor: const Color(0xFFFF6B9D),
    glowColor: const Color(0xFFFF6B9D).withValues(alpha: 0.6),
    icon: '🏠',
    subcategories: [
      'Rent',
      'Telephone',
      'Insurance',
      'Electricity',
      'Gym',
      'Internet',
      'Subscription',
    ],
  ),
  'food': CategoryData(
    name: 'Food',
    gradientColors: [
      const Color(0xFFA855F7),
      const Color(0xFF9333EA),
      const Color(0xFF7E22CE),
    ],
    solidColor: const Color(0xFFA855F7),
    glowColor: const Color(0xFFA855F7).withValues(alpha: 0.6),
    icon: '🍽️',
    subcategories: ['Groceries', 'Restaurant'],
  ),
  'savings': CategoryData(
    name: 'Savings',
    gradientColors: [
      const Color(0xFF10F4B1),
      const Color(0xFF00E396),
      const Color(0xFF00D084),
    ],
    solidColor: const Color(0xFF10F4B1),
    glowColor: const Color(0xFF10F4B1).withValues(alpha: 0.6),
    icon: '🐷',
    subcategories: ['Emergency funds', 'Vacation fund'],
  ),
};

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key});

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> with TickerProviderStateMixin {
  // State variables
  String activeTab = 'overview';
  String overviewSubTab = 'overview';
  bool showNewTransaction = false;
  bool showCategoryPicker = false;
  List<Transaction> transactions = [];
  Map<String, CategoryData> categories = Map.from(defaultCategories);
  Map<String, String> selectedCategory = {'name': 'Food', 'key': 'food'};
  bool showCardConnection = false;
  bool showCardSwiper = false;
  bool isCardConnected = false;
  List<Transaction> pendingTransactions = [];
  List<String> expandedCategories = [];
  bool isEditingBudgets = false;
  Map<String, String> tempBudgetValues = {};
  String currentMonth = 'November';
  int currentYear = 2025;

  // Budget data
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets = {
    'housing': {
      'Rent': SubcategoryBudget(budgeted: 200, spent: 200),
      'Gym': SubcategoryBudget(budgeted: 10, spent: 10),
    },
    'food': {'Groceries': SubcategoryBudget(budgeted: 30, spent: 30)},
  };

  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
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
  
  double get totalCategoryBudgets {
    double total = 0;
    categoryBudgets.forEach((_, subcats) {
      subcats.forEach((_, budget) {
        total += budget.budgeted;
      });
    });
    return total;
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
            _buildAnimatedBackground(),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  _buildStatusBar(),
                  _buildHeader(),
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
              child: _buildBottomNavigation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Rotating gradient orbs
            Positioned(
              top: 100,
              left: -50,
              child: Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00F5FF).withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 300,
              right: -100,
              child: Transform.rotate(
                angle: -_rotationController.value * 2 * math.pi,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFA855F7).withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F3A), Color(0xFF2A2F4A), Color(0xFF1A1F3A)],
        ),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF00F5FF).withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '23:34 Tuesday 4 Nov.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Row(
            children: [
              const Text(
                '100%',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00F5FF).withValues(alpha: 0.6),
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5FF), Color(0xFF00B8FF)],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F3A), Color(0xFF2A2F4A), Color(0xFF1A1F3A)],
        ),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFA855F7).withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
          const Text(
            'Personal Wallet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          if (activeTab == 'budget')
            IconButton(
              onPressed: () {
                setState(() {
                  if (isEditingBudgets) {
                    _saveAllBudgets();
                  } else {
                    _enterEditMode();
                  }
                });
              },
              icon: Icon(
                isEditingBudgets ? Icons.check : Icons.edit,
                color: Colors.white70,
                size: 24,
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildCircularBudgetChart(),
          const SizedBox(height: 24),
          _buildCategoriesList(),
        ],
      ),
    );
  }

  Widget _buildCircularBudgetChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F3A), Color(0xFF2A2F4A), Color(0xFF1A1F3A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Budget Circle
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: budgetPercentage / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetPercentage > 90
                          ? Colors.red
                          : const Color(0xFF00F5FF),
                    ),
                  ),
                ),
                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '€${budgetLeft.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'left to spend',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${budgetPercentage.toStringAsFixed(1)}% used',
                      style: TextStyle(
                        color: budgetPercentage > 90
                            ? Colors.red
                            : const Color(0xFF00F5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Budget summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBudgetSummaryItem(
                'Budget',
                '€${totalBudget.toStringAsFixed(0)}',
                const Color(0xFF00F5FF),
              ),
              _buildBudgetSummaryItem(
                'Spent',
                '€${totalSpent.toStringAsFixed(0)}',
                const Color(0xFFFF6B9D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
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
                  '€${totalCategoryBudgets.toStringAsFixed(0)} / €${totalBudget.toStringAsFixed(0)} budgeted',
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

          return _buildCategoryCard(categoryKey, categoryData, subcategories);
        }),
      ],
    );
  }

  Widget _buildCategoryCard(
    String categoryKey,
    CategoryData categoryData,
    Map<String, SubcategoryBudget> subcategories,
  ) {
    final isExpanded = expandedCategories.contains(categoryKey);
    final totalBudgeted = subcategories.values.fold(
      0.0,
      (sum, budget) => sum + budget.budgeted,
    );
    final totalSpent = subcategories.values.fold(
      0.0,
      (sum, budget) => sum + budget.spent,
    );
    final percentage = totalBudgeted > 0
        ? (totalSpent / totalBudgeted) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: categoryData.solidColor.withValues(alpha: 0.3),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A).withValues(alpha: 0.8),
            const Color(0xFF2A2F4A).withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: categoryData.glowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category header
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
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Category icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: categoryData.gradientColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: categoryData.glowColor.withValues(alpha: 0.4),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        categoryData.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category info
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
                        const SizedBox(height: 4),
                        Text(
                          '€${totalSpent.toStringAsFixed(0)} / €${totalBudgeted.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: categoryData.solidColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress and actions
                  Column(
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: percentage > 90 ? Colors.red : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isEditingBudgets)
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: categoryData.solidColor,
                            size: 20,
                          ),
                          onPressed: () => _showEditCategoryDialog(
                            categoryKey,
                            categoryData,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      else
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white70,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Subcategories (when expanded)
          if (isExpanded)
            ...subcategories.entries.map((subEntry) {
              return _buildSubcategoryItem(
                subEntry.key,
                subEntry.value,
                categoryData.solidColor,
              );
            }),
        ],
      ),
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
          const SizedBox(width: 64), // Align with category content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcategoryName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                // Progress bar
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
                  text:
                      tempBudgetValues['$subcategoryName'] ??
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
                const Text(
                  '€${760.00}',
                  style: TextStyle(
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
          // Category icon
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
          // Transaction details
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
          // Amount
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

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1F33).withValues(alpha: 0.95),
            const Color(0xFF0A0E1A).withValues(alpha: 0.98),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                'overview',
                Icons.dashboard,
                'OVERVIEW',
                const LinearGradient(
                  colors: [Color(0xFF00F5FF), Color(0xFF00B8FF)],
                ),
              ),
              _buildNavItem(
                'budget',
                Icons.account_balance_wallet,
                'BUDGET',
                const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF3D8F)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    String tabKey,
    IconData icon,
    String label,
    Gradient gradient,
  ) {
    final isActive = activeTab == tabKey;

    return GestureDetector(
      onTap: () => setState(() => activeTab = tabKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive ? gradient : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (gradient as LinearGradient).colors.first.withValues(
                      alpha: 0.4,
                    ),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods
  void _showAddTransaction(TransactionType type) {
    // TODO: Implement add transaction dialog
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
    isEditingBudgets = true;
    setState(() {});
  }

  void _saveAllBudgets() {
    tempBudgetValues.forEach((key, value) {
      final amount = double.tryParse(value);
      if (amount != null) {
        debugPrint('Saving budget for $key: €$amount');
      }
    });

    tempBudgetValues.clear();
    isEditingBudgets = false;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budgets saved successfully!'),
        backgroundColor: Color(0xFF00F5FF),
      ),
    );
  }

  void _showEditCategoryDialog(String categoryKey, CategoryData categoryData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          'Edit ${categoryData.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Existing subcategories
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Subcategories',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              if (categoryBudgets.containsKey(categoryKey))
                ...categoryBudgets[categoryKey]!.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: categoryData.solidColor.withValues(alpha: 0.3),
                      ),
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '€${entry.value.budgeted.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: categoryData.solidColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                          onPressed: () {
                            final budgetController = TextEditingController(
                              text: entry.value.budgeted.toStringAsFixed(0),
                            );
                            final nameController = TextEditingController(
                              text: entry.key,
                            );
                            _showEditSubcategoryDialog(
                              categoryKey,
                              entry.key,
                              budgetController,
                              nameController,
                              categoryData,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          onPressed: () {
                            setState(() {
                              categoryBudgets[categoryKey]?.remove(entry.key);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: categoryData.solidColor,
            ),
            onPressed: () {
              _showAddSubcategoryDialog(categoryKey, categoryData);
            },
            child: const Text('Add Subcategory'),
          ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog(
    String categoryKey,
    CategoryData categoryData,
  ) {
    final subcategoryController = TextEditingController();
    final budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'Add New Subcategory',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subcategoryController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Subcategory name',
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: 'Name',
                labelStyle: TextStyle(color: categoryData.solidColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: budgetController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Budget amount',
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: 'Budget',
                labelStyle: TextStyle(color: categoryData.solidColor),
                prefixText: '€ ',
                prefixStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: categoryData.solidColor,
            ),
            onPressed: () {
              if (subcategoryController.text.isNotEmpty &&
                  budgetController.text.isNotEmpty) {
                final budget = double.tryParse(budgetController.text) ?? 0;
                setState(() {
                  if (!categoryBudgets.containsKey(categoryKey)) {
                    categoryBudgets[categoryKey] = {};
                  }
                  categoryBudgets[categoryKey]![subcategoryController.text] =
                      SubcategoryBudget(budgeted: budget, spent: 0);
                });
                Navigator.pop(context);
                Navigator.pop(context); // Close the edit dialog too
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditSubcategoryDialog(
    String categoryKey,
    String oldName,
    TextEditingController budgetController,
    TextEditingController nameController,
    CategoryData categoryData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'Edit Subcategory',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Subcategory name',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Budget amount',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixText: '€ ',
                prefixStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: categoryData.solidColor,
            ),
            onPressed: () {
              final newBudget = double.tryParse(budgetController.text) ?? 0;
              setState(() {
                if (nameController.text != oldName) {
                  final oldBudget = categoryBudgets[categoryKey]![oldName];
                  categoryBudgets[categoryKey]?.remove(oldName);
                  categoryBudgets[categoryKey]![nameController.text] =
                      SubcategoryBudget(
                    budgeted: newBudget,
                    spent: oldBudget?.spent ?? 0,
                  );
                } else {
                  categoryBudgets[categoryKey]![oldName] = SubcategoryBudget(
                    budgeted: newBudget,
                    spent: categoryBudgets[categoryKey]![oldName]?.spent ?? 0,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'Manage Categories',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Existing categories
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Categories',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              ...categoryBudgets.entries.map((entry) {
                final categoryKey = entry.key;
                final categoryData = categories[categoryKey];

                if (categoryData == null) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: categoryData.solidColor.withValues(alpha: 0.3),
                    ),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: categoryData.gradientColors,
                          ),
                        ),
                        child: Center(
                          child: Text(categoryData.icon, style: const TextStyle(fontSize: 16)),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${entry.value.length} subcategories',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditCategoryNameDialog(categoryKey, categoryData);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        onPressed: () {
                          setState(() {
                            categoryBudgets.remove(categoryKey);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${categoryData.name} and all its subcategories deleted',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F5FF),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showAddNewCategoryDialog();
            },
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryNameDialog(String categoryKey, CategoryData categoryData) {
    final nameController = TextEditingController(text: categoryData.name);
    final iconController = TextEditingController(text: categoryData.icon);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'Edit Category',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Category name',
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: 'Name',
                labelStyle: TextStyle(color: categoryData.solidColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              maxLength: 1,
              decoration: InputDecoration(
                hintText: 'Pick an emoji',
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: 'Icon',
                labelStyle: TextStyle(color: categoryData.solidColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: categoryData.solidColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: categoryData.solidColor,
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final updatedCategory = CategoryData(
                    name: nameController.text,
                    gradientColors: categoryData.gradientColors,
                    solidColor: categoryData.solidColor,
                    glowColor: categoryData.glowColor,
                    icon: iconController.text.isNotEmpty ? iconController.text : categoryData.icon,
                    subcategories: categoryData.subcategories,
                  );
                  categories[categoryKey] = updatedCategory;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category updated successfully!'),
                    backgroundColor: Color(0xFF00F5FF),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddNewCategoryDialog() {
    final nameController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'Add New Category',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Category name',
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: 'Name',
                labelStyle: const TextStyle(color: Color(0xFF00F5FF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF00F5FF),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: Color(0xFF00F5FF),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              maxLength: 1,
              decoration: InputDecoration(
                hintText: 'Pick an emoji',
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: 'Icon',
                labelStyle: const TextStyle(color: Color(0xFF00F5FF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF00F5FF),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: Color(0xFF00F5FF),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F5FF),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty && iconController.text.isNotEmpty) {
                setState(() {
                  final newKey = nameController.text.toLowerCase().replaceAll(' ', '_');
                  categories[newKey] = CategoryData(
                    name: nameController.text,
                    gradientColors: [
                      const Color(0xFF00F5FF),
                      const Color(0xFF00D4FF),
                      const Color(0xFF00B8FF),
                    ],
                    solidColor: const Color(0xFF00F5FF),
                    glowColor: const Color(0xFF00F5FF).withValues(alpha: 0.6),
                    icon: iconController.text,
                    subcategories: [],
                  );
                  categoryBudgets[newKey] = {};
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New category added successfully!'),
                    backgroundColor: Color(0xFF00F5FF),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
