import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback? onSosTap;
  final bool showSosBadge;

  const AppBottomNav({
    super.key,
    int? selectedIndex,
    int? currentIndex,
    Function(int)? onTabSelected,
    Function(int)? onTap,
    this.onSosTap,
    this.showSosBadge = false,
  })  : selectedIndex = selectedIndex ?? currentIndex ?? 0,
        onTabSelected = onTabSelected ?? onTap ?? _noop;

  static void _noop(int _) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: QuickServeColors.white,
        border: Border(top: BorderSide(color: QuickServeColors.borderLight, width: 1)),
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Earnings'),
              _buildNavItem(2, Icons.history, Icons.history, 'History'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              size: 22,
              color: isSelected ? QuickServeColors.primaryOrange : QuickServeColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? QuickServeColors.primaryOrange : QuickServeColors.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
