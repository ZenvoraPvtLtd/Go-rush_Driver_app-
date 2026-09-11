import 'package:flutter/material.dart';
import '../core/theme.dart';

class HelpCenterSupportTicketsScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onRaiseTicketTap;

  const HelpCenterSupportTicketsScreen({
    super.key,
    this.onBackTap,
    this.onRaiseTicketTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Help & Support',
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
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search help topics, fares, payouts...',
                    hintStyle: TextStyle(color: QuickServeColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: QuickServeColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Raise Support Ticket Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.primaryOrange.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: QuickServeColors.primaryOrange.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECE6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.confirmation_number_outlined, color: QuickServeColors.primaryOrange, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Direct Help?',
                            style: TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Raise a formal dispute or toll review ticket.',
                            style: TextStyle(
                              color: QuickServeColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onRaiseTicketTap ?? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ticket created: Case #QS-9822')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuickServeColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Raise Ticket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildFaqItem('How do toll reimbursements work?', 'Toll charges are automatically detected via FASTag or uploaded receipt and credited within 2 hours.'),
              const SizedBox(height: 10),
              _buildFaqItem('When are weekly quest incentives credited?', 'Weekly incentives are calculated every Sunday at midnight and sent to your bank on Monday morning.'),
              const SizedBox(height: 10),
              _buildFaqItem('How do I update my vehicle registration?', 'Go to Profile > Vehicle Details > Update RC to upload new scanned documents.'),
              const SizedBox(height: 10),
              _buildFaqItem('What should I do if a passenger cancels late?', 'A ₹50 cancellation fee is automatically credited if passenger cancels after 3 minutes of arrival.'),

              const SizedBox(height: 24),

              // Contact Support Channels
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.phone_in_talk, color: QuickServeColors.textDark, size: 18),
                      label: const Text('24x7 Helpline'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: QuickServeColors.borderLight),
                        foregroundColor: QuickServeColors.textDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling QuickServe Partner Helpline 1800-419-0099...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                      label: const Text('Live Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuickServeColors.textDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Starting Live Support Session with Agent...')),
                        );
                      },
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

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: QuickServeColors.primaryOrange,
        collapsedIconColor: QuickServeColors.textSecondary,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Text(
            answer,
            style: const TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
