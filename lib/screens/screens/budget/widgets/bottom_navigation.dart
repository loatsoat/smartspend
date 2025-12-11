import 'package:flutter/material.dart';

class BudgetBottomNavigation extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChanged;

  const BudgetBottomNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
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
      onTap: () => onTabChanged(tabKey),
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
                    color: gradient.colors.first.withValues(alpha: 0.4),
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
}
