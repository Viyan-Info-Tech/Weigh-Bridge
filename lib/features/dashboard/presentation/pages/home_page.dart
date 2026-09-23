import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../bill/presentation/pages/bill_page.dart';
import '../../../customer/presentation/pages/customer_list_page.dart';
import '../../../material/presentation/pages/material_list_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../report/presentation/pages/report_page.dart';
import '../../../auth/presentation/widgets/truck_logo.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pages = [
      const BillPage(),
      const CustomerListPage(),
      const MaterialListPage(),
      const ReportPage(),
      const SettingsPage(),
      const AboutPage(),
    ];

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Application Header
            _buildAppHeader(context),

            // 2. Horizontal Navigation Tabs Bar
            _buildTopNavigationBar(context),

            // 3. Main Active Content Screen
            Expanded(child: _pages[_selectedIndex]),

            // 4. Bottom Industrial Status Bar
            _buildAppStatusBar(context),
          ],
        ),
      ),
    );
  }

  /// 1. Top Application Header (Branding, Live Date/Time, User Profile)
  Widget _buildAppHeader(BuildContext context) {
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(_currentTime);
    final timeStr = DateFormat('hh:mm:ss a').format(_currentTime);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          // Left: Logo & Company Branding
          _buildBrandLogo(),

          const Spacer(),

          // Right: Live Date
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // Live Clock
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // User Profile Pill
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final username = state.user?.username ?? 'Admin';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 18,
                      color: Color(0xFF1E293B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      username,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ViyanWeighbridgeLogo(size: 38),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'VIYAN ',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  TextSpan(
                    text: 'WEIGHBRIDGE',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFF0284C7),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Accurate Weighing  Reliable Business',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 2. Horizontal Navigation Tabs Bar (Icon on Top, Label Below, with Clean Dividers)
  Widget _buildTopNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          _buildNavTab(index: 0, icon: Icons.scale_rounded, label: 'Weighment'),
          _buildNavDivider(),
          _buildNavTab(
            index: 1,
            icon: Icons.people_alt_rounded,
            label: 'Customers',
          ),
          _buildNavDivider(),
          _buildNavTab(
            index: 2,
            icon: Icons.inventory_2_rounded,
            label: 'Materials',
          ),
          _buildNavDivider(),
          _buildNavTab(
            index: 3,
            icon: Icons.bar_chart_rounded,
            label: 'Reports',
          ),
          _buildNavDivider(),
          _buildNavTab(
            index: 4,
            icon: Icons.settings_rounded,
            label: 'Settings',
          ),
          _buildNavDivider(),
          _buildExitButton(context),
        ],
      ),
    );
  }

  Widget _buildNavDivider() {
    return Container(width: 1, height: 36, color: const Color(0xFFE2E8F0));
  }

  Widget _buildNavTab({
    required int index,
    required IconData icon,
    required String label,
    Widget? badge,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: Material(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          hoverColor: const Color(0xFFF8FAFC),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? const Color(0xFF0D53FC)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? const Color(0xFF0D53FC)
                      : const Color(0xFF475569),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF0D53FC)
                              : const Color(0xFF1E293B),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (badge != null) ...[const SizedBox(width: 4), badge],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmLogout(context),
          hoverColor: const Color(0xFFFEF2F2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.transparent, width: 3),
              ),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.power_settings_new_rounded,
                  size: 22,
                  color: Color(0xFFDC2626),
                ),
                SizedBox(height: 4),
                Text(
                  'Exit',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 10),
            Text(
              'Exit Application',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out and exit your session?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Exit',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Persistent Bottom Industrial Status Bar
  Widget _buildAppStatusBar(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          // Status cluster scrolls horizontally so it never overflows on
          // narrow or compact window sizes.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ready indicator
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ready',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(width: 20),
                  _buildStatusDivider(),
                  const SizedBox(width: 20),

                  // Database: Connected
                  const Icon(
                    Icons.storage_rounded,
                    size: 15,
                    color: Color(0xFF1E293B),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Database: Connected',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(width: 20),
                  _buildStatusDivider(),
                  const SizedBox(width: 20),

                  // Printer: Ready
                  const Icon(
                    Icons.print_rounded,
                    size: 15,
                    color: Color(0xFF1E293B),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Printer: Ready',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),

          // App Version / About
          InkWell(
            onTap: () => setState(() => _selectedIndex = 5),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Viyan Weighbridge v1.0.0',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDivider() {
    return Container(width: 1, height: 16, color: const Color(0xFFCBD5E1));
  }
}
