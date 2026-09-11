import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/safe_avatar.dart';

class FleetAdminOperationsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FleetAdminOperationsScreen({super.key, this.onBack});

  @override
  State<FleetAdminOperationsScreen> createState() => _FleetAdminOperationsScreenState();
}

class _FleetAdminOperationsScreenState extends State<FleetAdminOperationsScreen> {
  int _selectedNavIndex = 1; // 1: Drivers (Active)
  int _selectedFilter = 0; // 0: All, 1: Active, 2: Pending, 3: Inactive

  final List<Map<String, dynamic>> _drivers = [
    {
      'name': 'Rohit Sharma',
      'phone': '+91 98765 43210',
      'vehicle': 'Honda City (DL 01 AB 1234)',
      'status': 'Active',
      'rating': '4.8 ★',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    },
    {
      'name': 'Amit Singh',
      'phone': '+91 98111 22334',
      'vehicle': 'Maruti Dzire (DL 04 CD 5678)',
      'status': 'Active',
      'rating': '4.9 ★',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
    {
      'name': 'Vikram Rao',
      'phone': '+91 98222 33445',
      'vehicle': 'Hyundai Aura (UP 16 XY 9012)',
      'status': 'Pending',
      'rating': '--',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
    {
      'name': 'Sandeep Yadav',
      'phone': '+91 98333 44556',
      'vehicle': 'Toyota Innova (HR 26 AB 3456)',
      'status': 'Active',
      'rating': '4.7 ★',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    },
    {
      'name': 'Pankaj Kumar',
      'phone': '+91 98444 55667',
      'vehicle': 'Tata Tigor EV (DL 02 EV 7890)',
      'status': 'Inactive',
      'rating': '4.6 ★',
      'avatar': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      body: Row(
        children: [
          // Dark Navy Sidebar (#0F172A)
          _buildSidebar(),

          // Main Admin Content Area
          Expanded(
            child: Column(
              children: [
                _buildTopAdminHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title, Search Bar & Filter Bar
                        _buildControlsBar(),

                        const SizedBox(height: 16),

                        // Drivers Table Card
                        _buildDriversTable(),

                        const SizedBox(height: 16),

                        // Pagination Footer
                        _buildPaginationFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final navItems = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.people_alt, 'label': 'Drivers'},
      {'icon': Icons.directions_car_outlined, 'label': 'Rides'},
      {'icon': Icons.payment_outlined, 'label': 'Payments'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Reports'},
      {'icon': Icons.settings_outlined, 'label': 'Settings'},
    ];

    return Container(
      width: 220,
      color: QuickServeColors.adminSidebar, // #0F172A
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QuickServe Admin Logo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: QuickServeColors.primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.speed, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'QuickServe',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Admin Portal',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nav Links
            Expanded(
              child: ListView.builder(
                itemCount: navItems.length,
                itemBuilder: (context, idx) {
                  final item = navItems[idx];
                  final isSelected = _selectedNavIndex == idx;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected ? QuickServeColors.primaryOrange : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      title: Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      onTap: () => setState(() => _selectedNavIndex = idx),
                    ),
                  );
                },
              ),
            ),

            // Admin User Info
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: QuickServeColors.primaryOrange,
                    child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Fleet Ops Admin', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Super Admin Role', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAdminHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: QuickServeColors.borderLight)),
      ),
      child: Row(
        children: [
          if (widget.onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
              onPressed: widget.onBack,
            ),
          const Text(
            'Driver Management',
            style: TextStyle(
              color: QuickServeColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: QuickServeColors.statusGreen, size: 8),
                SizedBox(width: 6),
                Text(
                  '480 Drivers Online',
                  style: TextStyle(color: QuickServeColors.statusGreen, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return Row(
      children: [
        // Search bar
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: QuickServeColors.borderLight),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search by driver name, phone, or vehicle number...',
                hintStyle: TextStyle(color: QuickServeColors.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: QuickServeColors.textSecondary, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Status Filter Chips
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: QuickServeColors.borderLight),
          ),
          child: Row(
            children: [
              _buildFilterChip('All', 0),
              _buildFilterChip('Active', 1),
              _buildFilterChip('Pending', 2),
              _buildFilterChip('Inactive', 3),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Add Driver Button
        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Driver'),
          style: ElevatedButton.styleFrom(
            backgroundColor: QuickServeColors.primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add driver modal dialog opened')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? QuickServeColors.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : QuickServeColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDriversTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(2.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.2),
          5: FlexColumnWidth(1.2),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Table Header
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            children: [
              _buildTableHeaderCell('DRIVER NAME'),
              _buildTableHeaderCell('PHONE NUMBER'),
              _buildTableHeaderCell('VEHICLE DETAILS'),
              _buildTableHeaderCell('STATUS'),
              _buildTableHeaderCell('RATING'),
              _buildTableHeaderCell('ACTION'),
            ],
          ),
          // Rows
          ..._drivers.map((d) {
            final isPending = d['status'] == 'Pending';
            final isActive = d['status'] == 'Active';
            final statusColor = isActive
                ? QuickServeColors.statusGreen
                : (isPending ? QuickServeColors.primaryOrange : const Color(0xFF64748B));

            return TableRow(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: QuickServeColors.borderLight)),
              ),
              children: [
                // Driver Name + Avatar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      SafeAvatar(imageUrl: d['avatar'] as String, radius: 16, fallbackText: d['name'][0]),
                      const SizedBox(width: 10),
                      Text(
                        d['name'] as String,
                        style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Phone
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    d['phone'] as String,
                    style: const TextStyle(color: QuickServeColors.textSecondary, fontSize: 13),
                  ),
                ),
                // Vehicle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    d['vehicle'] as String,
                    style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13),
                  ),
                ),
                // Status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      d['status'] as String,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Rating
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    d['rating'] as String,
                    style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                // Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: isPending ? QuickServeColors.primaryOrange : QuickServeColors.textDark,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(isPending ? 'Verify' : 'View', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: QuickServeColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Showing 1 to 5 of 480 driver partners',
          style: TextStyle(color: QuickServeColors.textSecondary, fontSize: 12),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20, color: QuickServeColors.textSecondary),
              onPressed: () {},
            ),
            _buildPageNumber('1', true),
            _buildPageNumber('2', false),
            _buildPageNumber('3', false),
            _buildPageNumber('4', false),
            _buildPageNumber('5', false),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20, color: QuickServeColors.textSecondary),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageNumber(String page, bool isSelected) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? QuickServeColors.primaryOrange : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          page,
          style: TextStyle(
            color: isSelected ? Colors.white : QuickServeColors.textDark,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
