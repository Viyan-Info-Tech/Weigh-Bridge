import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../bill/presentation/pages/bill_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          const Expanded(child: BillPage()),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.blueGrey.shade900,
      child: Column(
        children: [
          Container(
            height: 64,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'WEIGHBRIDGE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
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
                  isSelected: true,
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.store_outlined,
                  label: 'Vendor',
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.pending_outlined,
                  label: 'Pending',
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.report_outlined,
                  label: 'Report',
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.info_outlined,
                  label: 'About',
                  onTap: () {},
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
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
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
      selected: isSelected,
      selectedTileColor: Colors.blueGrey.shade800,
      dense: true,
      onTap: onTap,
    );
  }
}
