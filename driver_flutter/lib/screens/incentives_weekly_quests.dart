import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/app_top_header.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/floating_sos_button.dart';

class IncentivesWeeklyQuestsScreen extends StatefulWidget {
  final VoidCallback? onSosTap;
  final Function(int)? onBottomNavTap;

  const IncentivesWeeklyQuestsScreen({
    super.key,
    this.onSosTap,
    this.onBottomNavTap,
  });

  @override
  State<IncentivesWeeklyQuestsScreen> createState() => _IncentivesWeeklyQuestsScreenState();
}

class _IncentivesWeeklyQuestsScreenState extends State<IncentivesWeeklyQuestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoRushColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppTopHeader(
                  title: 'PARTNER FLEET\nRadar',
                  isOnline: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Pro Tier Banner
                        _buildProTierBanner(),
                        const SizedBox(height: 10),
                        // Shift Boost Card
                        _buildShiftBoostCard(),
                        const SizedBox(height: 14),
                        // Active Quests
                        const Text('Active Quests', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildQuestItem(
                          title: 'Peak Hour Rush',
                          subtitle: '5:00 PM - 9:00 PM Window',
                          reward: '+₹300',
                          timeLeft: '1h 24m left',
                          progress: 2 / 4,
                          progressLabel: '2 of 4 rides',
                          accentColor: GoRushColors.primaryGreen,
                        ),
                        const SizedBox(height: 10),
                        _buildQuestItem(
                          title: 'Weekend Warrior',
                          subtitle: '25 Trips Target (Fri - Sun)',
                          reward: '+₹1,500',
                          timeLeft: '24% completed',
                          progress: 6 / 25,
                          progressLabel: '6 of 25 rides',
                          accentColor: GoRushColors.gold,
                        ),
                        const SizedBox(height: 10),
                        _buildQuestItem(
                          title: 'Zero Cancellation Streak',
                          subtitle: 'Maintain 100% acceptance today',
                          reward: '+₹200',
                          timeLeft: 'ACTIVE',
                          progress: 1.0,
                          progressLabel: 'All 9 trips accepted',
                          accentColor: GoRushColors.blueAccent,
                        ),
                        const SizedBox(height: 16),
                        // Weekly Milestones
                        _buildMilestonesCard(),
                        const SizedBox(height: 16),
                        // Fleet Leaderboard
                        _buildLeaderboardCard(),
                        const SizedBox(height: 14),
                        // Referral Program Card
                        _buildReferralCard(),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onSosTap != null)
            FloatingSosButton(
              onTap: widget.onSosTap!,
              bottomOffset: 70,
              rightOffset: 14,
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppBottomNav(
              selectedIndex: 3,
              onTabSelected: (index) {
                if (widget.onBottomNavTap != null) {
                  widget.onBottomNavTap!(index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTierBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF142036),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GoRushColors.gold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: GoRushColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium, color: GoRushColors.gold, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Level 4 Pro Partner',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: GoRushColors.primaryGreen, size: 14),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Top 5% Tier • 1.15x Multiplier Perks >',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: GoRushColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x2200E676),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Active', style: TextStyle(color: GoRushColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftBoostCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF11293D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GoRushColors.primaryGreen.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt, color: GoRushColors.primaryGreen, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '+₹2,000 In Reach Today',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'Surge Active',
            style: TextStyle(color: GoRushColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestItem({
    required String title,
    required String subtitle,
    required String reward,
    required String timeLeft,
    required double progress,
    required String progressLabel,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GoRushColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GoRushColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(reward, style: TextStyle(color: accentColor, fontSize: 15, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: GoRushColors.textMuted, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Text(timeLeft, style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            backgroundColor: const Color(0xFF162544),
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
          const SizedBox(height: 4),
          Text(progressLabel, style: const TextStyle(color: GoRushColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMilestonesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GoRushColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GoRushColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Milestones', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text('Resets Mon midnight', style: TextStyle(color: GoRushColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMilestoneNode('15 Trips', '₹500', isDone: false),
              Container(width: 40, height: 2, color: const Color(0xFF1E355A)),
              _buildMilestoneNode('30 Trips', '₹1,200', isDone: false),
              Container(width: 40, height: 2, color: const Color(0xFF1E355A)),
              _buildMilestoneNode('45 Trips', '₹2,500', isDone: false),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '14 more trips to unlock Tier 2 bonus • 4 days left',
              style: TextStyle(color: GoRushColors.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode(String label, String reward, {required bool isDone}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone ? GoRushColors.primaryGreen : const Color(0xFF162644),
            shape: BoxShape.circle,
            border: Border.all(color: isDone ? GoRushColors.primaryGreen : GoRushColors.surfaceBorder),
          ),
          child: Center(
            child: Icon(
              isDone ? Icons.check : Icons.lock_outline,
              size: 14,
              color: isDone ? Colors.black : GoRushColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        Text(reward, style: const TextStyle(color: GoRushColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLeaderboardCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GoRushColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GoRushColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fleet Leaderboard', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text('Delhi NCR • Weekly', style: TextStyle(color: GoRushColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 10),
          _buildLeaderboardRow('1', 'Manpreet S.', 'South Delhi Fleet • 68 trips', '₹28,400', isFirst: true),
          const SizedBox(height: 8),
          _buildLeaderboardRow('2', 'Rajesh K. (You)', 'Gurugram Central • 58 trips', '₹24,800', isUser: true),
          const SizedBox(height: 8),
          _buildLeaderboardRow('3', 'Vikram T.', 'Noida Sector 62 • 54 trips', '₹23,900'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(String rank, String name, String subtitle, String earnings, {bool isFirst = false, bool isUser = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF142B3F) : const Color(0xFF0F1A2D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isUser ? GoRushColors.primaryGreen.withOpacity(0.5) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isFirst ? GoRushColors.gold : (isUser ? GoRushColors.primaryGreen : const Color(0xFF1E355A)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank,
                style: TextStyle(
                  color: (isFirst || isUser) ? Colors.black : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: isUser ? GoRushColors.primaryGreen : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: GoRushColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          Text(earnings, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GoRushColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DRIVER REFERRAL PROGRAM', style: TextStyle(color: GoRushColors.gold, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          const Text('Invite fellow drivers & earn ₹1,000', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          const Text('Bonus is credited immediately when your referred partner completes their first 20 trips.', style: TextStyle(color: GoRushColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.share, size: 14, color: Colors.black),
            label: const Text('Share Invite Link [RAJESH100]', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: GoRushColors.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
