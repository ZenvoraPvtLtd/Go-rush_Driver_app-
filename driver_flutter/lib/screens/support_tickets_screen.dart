import 'package:flutter/material.dart';
import '../core/app_toast.dart';
import '../core/theme.dart';

class SupportTicketsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onCreateTicketTap;

  const SupportTicketsScreen({
    super.key,
    this.onBackTap,
    this.onCreateTicketTap,
  });

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  int _selectedTab = 0; // 0: Active (2), 1: Resolved (8)

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
          'Support Tickets',
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
        child: Column(
          children: [
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Row(
                  children: [
                    _buildTab('Active (2)', 0),
                    _buildTab('Resolved (8)', 1),
                  ],
                ),
              ),
            ),

            // Tickets List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTicketCard(
                    id: '#QS-9821',
                    title: 'Toll reimbursement for DND flyway',
                    category: 'Toll & Charges',
                    status: 'In Review',
                    statusColor: QuickServeColors.primaryOrange,
                    amount: '₹ 40',
                    date: 'Today, 11:15 AM',
                    description: 'FASTag deducted ₹40 at toll plaza but was not added to passenger invoice.',
                  ),
                  const SizedBox(height: 12),
                  _buildTicketCard(
                    id: '#QS-9750',
                    title: 'Fare difference on Connaught Place trip',
                    category: 'Fare Dispute',
                    status: 'Resolved',
                    statusColor: QuickServeColors.statusGreen,
                    amount: '₹ 60',
                    date: 'Yesterday, 06:40 PM',
                    description: 'Extra distance detour due to VIP security route. Reimbursement credited to bank.',
                  ),
                ],
              ),
            ),

            // Bottom CTA: Create Ticket
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: widget.onCreateTicketTap ?? () {
                  AppToast.show(context, 'Opening new support dispute ticket form...');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text('Create Support Ticket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? QuickServeColors.primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : QuickServeColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required String id,
    required String title,
    required String category,
    required String status,
    required Color statusColor,
    required String amount,
    required String date,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QuickServeColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$id • $category',
                style: const TextStyle(
                  color: QuickServeColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: QuickServeColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: QuickServeColors.borderLight),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(color: QuickServeColors.textMuted, fontSize: 11),
              ),
              Text(
                'Claim: $amount',
                style: const TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
