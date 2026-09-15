import 'package:flutter/material.dart';
import '../core/app_toast.dart';
import '../core/theme.dart';

class SafetyHubSosCenterScreen extends StatefulWidget {
  final VoidCallback? onBackTap;

  const SafetyHubSosCenterScreen({
    super.key,
    this.onBackTap,
  });

  @override
  State<SafetyHubSosCenterScreen> createState() => _SafetyHubSosCenterScreenState();
}

class _SafetyHubSosCenterScreenState extends State<SafetyHubSosCenterScreen> {
  bool _isSosActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Safety & SOS Center',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Broadcast Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: QuickServeColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Emergency SOS',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Press and hold to instantly broadcast your live GPS to GoRush Emergency Dispatch and Police.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Large Red Circular SOS Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSosActive = !_isSosActive;
                        });
                        if (_isSosActive) {
                          AppToast.error(context, 'EMERGENCY BEACON TRIGGERED: Police & GoRush notified!');
                        } else {
                          AppToast.show(context, 'Emergency SOS beacon deactivated.');
                        }
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: QuickServeColors.statusRed,
                          boxShadow: [
                            BoxShadow(
                              color: QuickServeColors.statusRed.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              _isSosActive ? 'ACTIVE' : 'EMERGENCY',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      '24x7 GoRush Emergency Response Protocol Active',
                      style: TextStyle(
                        color: QuickServeColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4 Safety Action Cards Grid (2x2)
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.contact_phone_outlined,
                      title: 'Emergency Contacts',
                      subtitle: 'Family & Guardians',
                      color: QuickServeColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.share_location_outlined,
                      title: 'Share Trip',
                      subtitle: 'Live GPS link',
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.security,
                      title: 'Safety Center',
                      subtitle: 'Guidelines & FAQs',
                      color: QuickServeColors.statusGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.report_problem_outlined,
                      title: 'Report Incident',
                      subtitle: 'Disputes & Accidents',
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Direct Helpline Calls
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.local_police, color: QuickServeColors.statusRed),
                      label: const Text('Call Police (112)'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: QuickServeColors.statusRed),
                        foregroundColor: QuickServeColors.statusRed,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        AppToast.error(context, 'Dialing 112...');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.support_agent, color: Colors.white),
                      label: const Text('Safety Desk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuickServeColors.textDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () => AppToast.show(context, 'Connecting to GoRush Safety Desk...'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: QuickServeColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
