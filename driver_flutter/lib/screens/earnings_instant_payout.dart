import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/app_bottom_nav.dart';

class EarningsInstantPayoutScreen extends StatefulWidget {
  final VoidCallback? onCashOutTap;
  final VoidCallback? onSosTap;
  final Function(int)? onBottomNavTap;

  const EarningsInstantPayoutScreen({
    super.key,
    this.onCashOutTap,
    this.onSosTap,
    this.onBottomNavTap,
  });

  @override
  State<EarningsInstantPayoutScreen> createState() => _EarningsInstantPayoutScreenState();
}

class _EarningsInstantPayoutScreenState extends State<EarningsInstantPayoutScreen> {
  int _selectedTab = 0; // 0: Today, 1: Week, 2: Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Earnings',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: QuickServeColors.textDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Viewing past payout statements')),
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availHeight = constraints.maxHeight;
                  final bool isCompact = availHeight < 620;

                  final double padV = (availHeight * 0.015).clamp(5.5, 9.0);
                  final double bottomMargin = (availHeight * 0.02).clamp(8.0, 14.0);

                  // Base section paddings and gaps scaled for optimal viewport coverage
                  final double cardPadV = (availHeight < 680) ? 9.0 : ((availHeight - 680.0) * 0.02 + 9.5).clamp(9.0, 13.0);
                  final double breakdownPadV = (availHeight < 680) ? 6.5 : ((availHeight - 680.0) * 0.015 + 7.0).clamp(6.5, 9.5);
                  final double gridRowGap = isCompact ? 5.0 : 6.5;
                  final double bankPadV = (availHeight < 680) ? 6.5 : ((availHeight - 680.0) * 0.015 + 7.0).clamp(6.5, 9.0);
                  final double btnPadV = (availHeight < 680) ? 9.5 : ((availHeight - 680.0) * 0.015 + 10.0).clamp(9.5, 12.5);
                  final double btnGap = isCompact ? 5.5 : 7.0;

                  // Dynamic gap between the major sections so content naturally fills available screen height
                  final double gap = ((availHeight - 490.0) / 14.0 + 7.5).clamp(7.5, 12.5);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: padV),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Time Tabs: Today / Week / Month
                        _buildTimeTabs(isCompact),

                        SizedBox(height: gap),

                        // Main Total Earnings Card
                        _buildMainEarningsCard(isCompact, cardPadV),

                        SizedBox(height: gap),

                        // 4 Breakdown Cards (Cash, Online, Tips, Incentives)
                        _buildBreakdownGrid(isCompact, breakdownPadV, gridRowGap),

                        SizedBox(height: gap),

                        // Recent Payout Status Banner
                        _buildLinkedBankBanner(isCompact, bankPadV),

                        SizedBox(height: gap),

                        // Orange Instant Cash Out CTA
                        _buildCashOutButton(isCompact, btnPadV),

                        SizedBox(height: btnGap),

                        // Outlined View Earnings Statement CTA
                        _buildStatementButton(isCompact, btnPadV),

                        SizedBox(height: bottomMargin),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Bar (Earnings tab active: index 1)
            AppBottomNav(
              currentIndex: 1,
              onTap: (idx) {
                if (widget.onBottomNavTap != null) {
                  widget.onBottomNavTap!(idx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTabs(bool isCompact) {
    final tabs = ['Today', 'Week', 'Month'];
    return Container(
      padding: EdgeInsets.all(isCompact ? 3 : 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSel = _selectedTab == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = idx;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: isCompact ? 6 : 7),
                decoration: BoxDecoration(
                  color: isSel ? QuickServeColors.primaryOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    tabs[idx],
                    style: TextStyle(
                      color: isSel ? Colors.white : QuickServeColors.textSecondary,
                      fontSize: isCompact ? 12 : 13,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainEarningsCard(bool isCompact, double cardPadV) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 16,
        vertical: cardPadV,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Today's Net Earnings",
            style: TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: isCompact ? 11 : 12,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 3),
          Text(
            '₹ 2,480',
            style: TextStyle(
              color: QuickServeColors.textDark,
              fontSize: isCompact ? 26 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 6 : 8,
                  vertical: isCompact ? 2 : 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: QuickServeColors.statusGreen, size: isCompact ? 12 : 13),
                    const SizedBox(width: 3),
                    Text(
                      '+12% vs yesterday',
                      style: TextStyle(
                        color: QuickServeColors.statusGreen,
                        fontSize: isCompact ? 10 : 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 7 : 9),
          const Divider(height: 1, color: QuickServeColors.borderLight),
          SizedBox(height: isCompact ? 6 : 7),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Completed Rides', style: TextStyle(color: QuickServeColors.textMuted, fontSize: isCompact ? 10 : 11)),
                    const SizedBox(height: 2),
                    Text('12 Rides', style: TextStyle(color: QuickServeColors.textDark, fontSize: isCompact ? 13 : 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Online Duration', style: TextStyle(color: QuickServeColors.textMuted, fontSize: isCompact ? 10 : 11)),
                    const SizedBox(height: 2),
                    Text('6h 30m', style: TextStyle(color: QuickServeColors.textDark, fontSize: isCompact ? 13 : 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownGrid(bool isCompact, double breakdownPadV, double gridRowGap) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBreakdownCard('Cash Collected', '₹ 820', Icons.money, const Color(0xFF10B981), isCompact, breakdownPadV),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBreakdownCard('Online Payments', '₹ 1,240', Icons.credit_card, const Color(0xFF3B82F6), isCompact, breakdownPadV),
            ),
          ],
        ),
        SizedBox(height: gridRowGap),
        Row(
          children: [
            Expanded(
              child: _buildBreakdownCard('Passenger Tips', '₹ 120', Icons.favorite, const Color(0xFFF59E0B), isCompact, breakdownPadV),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBreakdownCard('Peak Incentives', '₹ 300', Icons.stars, QuickServeColors.primaryOrange, isCompact, breakdownPadV),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(String title, String amount, IconData icon, Color color, bool isCompact, double breakdownPadV) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: breakdownPadV,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 4 : 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: isCompact ? 15 : 16),
          ),
          SizedBox(height: isCompact ? 4 : 5),
          Text(
            amount,
            style: TextStyle(
              color: QuickServeColors.textDark,
              fontSize: isCompact ? 14 : 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            title,
            style: TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedBankBanner(bool isCompact, double bankPadV) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: bankPadV,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 6 : 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8EE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.account_balance, color: QuickServeColors.statusGreen, size: isCompact ? 16 : 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Linked Bank: HDFC Bank',
                  style: TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: isCompact ? 12 : 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'A/C ending in •••• 4092 (Instant UPI Enabled)',
                  style: TextStyle(
                    color: QuickServeColors.textSecondary,
                    fontSize: isCompact ? 10 : 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: QuickServeColors.statusGreen, size: isCompact ? 16 : 17),
        ],
      ),
    );
  }

  Widget _buildCashOutButton(bool isCompact, double btnPadV) {
    return ElevatedButton(
      onPressed: widget.onCashOutTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instant Payout Initiated: ₹ 2,480 credited to HDFC Bank'),
            backgroundColor: QuickServeColors.statusGreen,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: QuickServeColors.primaryOrange,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: btnPadV),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(
        'Instant Cash Out (₹ 2,480)',
        style: TextStyle(fontSize: isCompact ? 14 : 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatementButton(bool isCompact, double btnPadV) {
    return OutlinedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading detailed PDF statement...')),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: QuickServeColors.borderLight),
        foregroundColor: QuickServeColors.textDark,
        padding: EdgeInsets.symmetric(vertical: (btnPadV - 1.5).clamp(8.0, 12.0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        'View Earnings Statement',
        style: TextStyle(fontSize: isCompact ? 13 : 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
