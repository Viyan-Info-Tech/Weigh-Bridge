import 'package:flutter/material.dart';

import '../../../auth/presentation/widgets/truck_logo.dart';

/// Navigation item model for the sidebar
class SidebarNavItem {
  final String label;
  final IconData icon;
  final String? badge;

  const SidebarNavItem({
    required this.label,
    required this.icon,
    this.badge,
  });
}

/// A modern, beautiful desktop sidebar matching the Viyan Weighbridge brand aesthetic:
/// - Prominent circular brand mark and typography header
/// - Elevated pill navigation items with active glow and hover transitions
/// - Watermarked footer with handwritten brand motto and copyright
class AppSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const AppSidebar({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late int _currentIndex;

  static const List<SidebarNavItem> _navItems = [
    SidebarNavItem(
      label: 'Billing',
      icon: Icons.description_rounded,
    ),
    SidebarNavItem(
      label: 'Vehicles',
      icon: Icons.local_shipping_rounded,
    ),
    SidebarNavItem(
      label: 'Parties',
      icon: Icons.people_alt_rounded,
    ),
    SidebarNavItem(
      label: 'Pending',
      icon: Icons.access_time_filled_rounded,
    ),
    SidebarNavItem(
      label: 'Reports',
      icon: Icons.bar_chart_rounded,
    ),
    SidebarNavItem(
      label: 'Masters',
      icon: Icons.storage_rounded,
    ),
    SidebarNavItem(
      label: 'Settings',
      icon: Icons.settings_rounded,
    ),
    SidebarNavItem(
      label: 'Help',
      icon: Icons.help_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      setState(() {
        _currentIndex = widget.selectedIndex;
      });
    }
  }

  void _handleItemTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(index);
    } else {
      if (index != 0) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_navItems[index].label} view coming soon'),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F5FA),
        border: Border(
          right: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          // 1. Top Brand Logo & Header
          _buildBrandHeader(),

          const SizedBox(height: 8),

          // 2. Navigation List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              itemCount: _navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return _SidebarTile(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _handleItemTap(index),
                );
              },
            ),
          ),

          // 3. Bottom Watermark & Brand Motto Section
          _buildBottomMotto(),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        children: [
          // Circular Logo Badge
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD0E1F4), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D3B82).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const TruckWeighbridgeLogo(
              color: Color(0xFF0D3B82),
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          // Brand Title
          const Text(
            'Viyan',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D3B82),
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Weighbridge',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D3B82),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomMotto() {
    return Stack(
      children: [
        // Watermark Bridge Graphic (Softly faded in bottom left)
        Positioned(
          left: -20,
          bottom: -15,
          child: Opacity(
            opacity: 0.12,
            child: Image.asset(
              'assets/images/bridge_watermark.jpg',
              width: 170,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),

        // Motto & Copyright Content
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tilted Handwritten Script
              Transform.rotate(
                angle: -0.09,
                child: const Text(
                  'Weigh Today\nBuild Tomorrow',
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                    height: 1.05,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Legal Copyright
              const Text(
                '© 2025 Viyan Weighbridge\nAll rights reserved.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// An individual navigation tile with active pill state and smooth hover effect
class _SidebarTile extends StatefulWidget {
  final SidebarNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    final Color bgColor;
    final Color contentColor;
    final List<BoxShadow> shadows;

    if (isSelected) {
      bgColor = const Color(0xFF1E70EB); // Vivid brand blue
      contentColor = Colors.white;
      shadows = [
        BoxShadow(
          color: const Color(0xFF1E70EB).withValues(alpha: 0.35),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    } else if (_isHovered) {
      bgColor = const Color(0xFFE2EDF8);
      contentColor = const Color(0xFF0D3B82);
      shadows = const [];
    } else {
      bgColor = Colors.transparent;
      contentColor = const Color(0xFF1E293B);
      shadows = const [];
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: shadows,
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                color: contentColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: contentColor,
                  ),
                ),
              ),
              if (widget.item.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFF0D3B82).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.item.badge!,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF0D3B82),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
