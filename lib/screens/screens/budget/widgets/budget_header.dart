import 'package:flutter/material.dart';

class BudgetStatusBar extends StatelessWidget {
  const BudgetStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class BudgetHeader extends StatelessWidget {
  final String activeTab;
  final bool isEditingBudgets;
  final VoidCallback onEditToggle;

  const BudgetHeader({
    super.key,
    required this.activeTab,
    required this.isEditingBudgets,
    required this.onEditToggle,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: onEditToggle,
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
}
