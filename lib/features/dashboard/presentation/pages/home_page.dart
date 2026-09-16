import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../bill/presentation/bloc/bill_bloc.dart';
import '../../../bill/presentation/bloc/bill_state.dart';
import '../../../bill/presentation/pages/bill_page.dart';
import '../../../bill/presentation/pages/pending_page.dart';
import '../../../party/presentation/pages/party_list_page.dart';
import '../../../vehicle/presentation/pages/vehicles_merged_page.dart';
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
  bool _isMastersExpanded = true;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const BillPage(),
      const PartyListPage(),
      const VehiclesMergedPage(),
      const MaterialListPage(),
      PendingPage(onSwitchToBill: () => setState(() => _selectedIndex = 0)),
      const ReportPage(),
      const SettingsPage(),
      const AboutPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Material(
        color: Colors.blueGrey.shade900,
        child: Column(
        children: [
          Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const ViyanWeighbridgeLogo(size: 38),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIYAN',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          color: Color(0xFF00F5FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'WEIGHBRIDGE',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.blueGrey),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(
                  icon: Icons.description_outlined,
                  label: 'Bill',
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _buildMastersSection(),
                _SidebarItem(
                  icon: Icons.pending_outlined,
                  label: 'Pending',
                  isSelected: _selectedIndex == 4,
                  onTap: () => setState(() => _selectedIndex = 4),
                  trailing: BlocBuilder<BillBloc, BillState>(
                    builder: (context, state) {
                      final count = state.pendingBills.length;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _SidebarItem(
                  icon: Icons.report_outlined,
                  label: 'Report',
                  isSelected: _selectedIndex == 5,
                  onTap: () => setState(() => _selectedIndex = 5),
                ),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: _selectedIndex == 6,
                  onTap: () => setState(() => _selectedIndex = 6),
                ),
                _SidebarItem(
                  icon: Icons.info_outlined,
                  label: 'About',
                  isSelected: _selectedIndex == 7,
                  onTap: () => setState(() => _selectedIndex = 7),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.blueGrey),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final username = state.user?.username ?? 'Admin';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blueGrey.shade700,
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white70,
                      size: 20,
                    ),
                    tooltip: 'Logout',
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMastersSection() {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.storage_outlined,
            color: Colors.blueGrey.shade300,
            size: 20,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Masters',
                  style: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                _isMastersExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.blueGrey.shade400,
                size: 20,
              ),
            ],
          ),
          dense: true,
          onTap: () => setState(() => _isMastersExpanded = !_isMastersExpanded),
        ),
        if (_isMastersExpanded) ...[
          _SidebarSubItem(
            icon: Icons.people_outline,
            label: 'Parties',
            isSelected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          _SidebarSubItem(
            icon: Icons.local_shipping_outlined,
            label: 'Vehicles',
            isSelected: _selectedIndex == 2,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          _SidebarSubItem(
            icon: Icons.inventory_2_outlined,
            label: 'Materials',
            isSelected: _selectedIndex == 3,
            onTap: () => setState(() => _selectedIndex = 3),
          ),
        ],
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.blueGrey.shade300,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blueGrey.shade300,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: trailing,
      selected: isSelected,
      selectedTileColor: Colors.blueGrey.shade800,
      dense: true,
      onTap: onTap,
    );
  }
}

class _SidebarSubItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarSubItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.blueGrey.shade400,
          size: 18,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey.shade400,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.blueGrey.shade800,
        dense: true,
        onTap: onTap,
      ),
    );
  }
}
