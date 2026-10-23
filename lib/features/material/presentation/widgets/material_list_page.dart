import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/material_item.dart';
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as material;
import 'material_details_dialog.dart';
import 'material_form_dialog.dart';

/// Materials master data management screen. One row per material name +
/// vehicle type (e.g. `Auto - Empty`) - the value shown on bills.
class MaterialListPage extends StatefulWidget {
  const MaterialListPage({super.key});

  @override
  State<MaterialListPage> createState() => _MaterialListPageState();
}

class _MaterialListPageState extends State<MaterialListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _typeFilter = 'All'; // 'All', 'Load', 'Empty'
  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'

  @override
  void initState() {
    super.initState();
    // Refresh whenever the tab is opened so new materials always show.
    context.read<MaterialBloc>().add(const LoadMaterialsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor:
              isError ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  List<MaterialItem> _filterMaterials(List<MaterialItem> materials) {
    final query = _searchController.text.trim().toLowerCase();
    return materials.where((m) {
      // 1. Text query filter
      if (query.isNotEmpty) {
        final nameMatch = m.name.toLowerCase().contains(query);
        final displayMatch = m.displayValue.toLowerCase().contains(query);
        final idMatch = m.id?.toString().contains(query) ?? false;
        if (!nameMatch && !displayMatch && !idMatch) return false;
      }

      // 2. Type filter
      if (_typeFilter != 'All') {
        if (m.vehicleType.toLowerCase() != _typeFilter.toLowerCase()) {
          return false;
        }
      }

      // 3. Status filter
      if (_statusFilter != 'All') {
        final isActive = _statusFilter == 'Active';
        if (m.isActive != isActive) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<MaterialBloc, material.MaterialState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            _showMessage(state.successMessage!);
          }
          if (state.error != null) {
            _showMessage(state.error!, isError: true);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.materials.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          final filteredMaterials = _filterMaterials(state.materials);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Banner
                _buildHeader(context, state),
                const SizedBox(height: 16),

                // 2. Metrics & KPI summary bar
                if (state.materials.isNotEmpty) ...[
                  _buildKpiRow(state),
                  const SizedBox(height: 14),
                ],

                // 3. Search and filter toolbar
                if (state.materials.isNotEmpty) ...[
                  _buildToolbar(state),
                  const SizedBox(height: 12),
                ],

                // 4. Main Table or Empty State
                Expanded(
                  child: state.materials.isEmpty
                      ? _buildEmptyState(context)
                      : _buildTableCard(context, state, filteredMaterials),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 1. Page Header with Title, Count badge, and Add Material button
  Widget _buildHeader(BuildContext context, material.MaterialState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 22,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Materials',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (state.materials.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          '${state.materials.length} materials',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Manage master materials and associated tare vehicle types for billing',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showFormDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            shadowColor: const Color(0x3310B981),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'Add Material',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  /// 2. KPI Summary Cards
  Widget _buildKpiRow(material.MaterialState state) {
    final total = state.materials.length;
    final active = state.materials.where((m) => m.isActive).length;
    final loadCount =
        state.materials.where((m) => m.vehicleType.toLowerCase() == 'load').length;
    final emptyCount =
        state.materials.where((m) => m.vehicleType.toLowerCase() == 'empty').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ((constraints.maxWidth - 36) / 4).clamp(160.0, 320.0);
        return Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'TOTAL MATERIALS',
                count: total,
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFF0F9FF),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'ACTIVE STATUS',
                count: active,
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'LOAD TYPE',
                count: loadCount,
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'EMPTY TYPE',
                count: emptyCount,
                icon: Icons.rv_hookup_outlined,
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Search & Filter Toolbar
  Widget _buildToolbar(material.MaterialState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Search box
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  hintText: 'Search materials by name or display value...',
                  hintStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    color: Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          color: const Color(0xFF94A3B8),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Type Filter Dropdown
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _typeFilter,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Type: All')),
                  DropdownMenuItem(value: 'Load', child: Text('Type: Load')),
                  DropdownMenuItem(value: 'Empty', child: Text('Type: Empty')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _typeFilter = val);
                },
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Status Filter Dropdown
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Status: All')),
                  DropdownMenuItem(
                    value: 'Active',
                    child: Text('Status: Active'),
                  ),
                  DropdownMenuItem(
                    value: 'Inactive',
                    child: Text('Status: Inactive'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _statusFilter = val);
                },
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Reset filters button
          if (_searchController.text.isNotEmpty ||
              _typeFilter != 'All' ||
              _statusFilter != 'All')
            Tooltip(
              message: 'Reset filters',
              child: InkWell(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _typeFilter = 'All';
                    _statusFilter = 'All';
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.filter_alt_off_rounded,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Reset',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 4. Main Table Card
  Widget _buildTableCard(
    BuildContext context,
    material.MaterialState state,
    List<MaterialItem> filteredMaterials,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text('ID', style: _headerStyle),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text('MATERIAL NAME', style: _headerStyle),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: Text('TYPE', style: _headerStyle),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: Text('STATUS', style: _headerStyle),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text('DISPLAY VALUE', style: _headerStyle),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('ACTIONS', style: _headerStyle),
                  ),
                ),
              ],
            ),
          ),

          // Table content or empty search result
          Expanded(
            child: filteredMaterials.isEmpty
                ? _buildEmptySearchResult()
                : Scrollbar(
                    controller: _scrollController,
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: filteredMaterials.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Color(0xFFF1F5F9),
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final materialItem = filteredMaterials[index];
                        return _buildRow(context, materialItem, index);
                      },
                    ),
                  ),
          ),

          // Table footer with count info
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredMaterials.length} of ${state.materials.length} materials',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (_searchController.text.isNotEmpty ||
                    _typeFilter != 'All' ||
                    _statusFilter != 'All')
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _typeFilter = 'All';
                        _statusFilter = 'All';
                      });
                    },
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
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

  /// Individual row in the table
  Widget _buildRow(BuildContext context, MaterialItem materialItem, int index) {
    final isLoad = materialItem.vehicleType.toLowerCase() == 'load';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetailsDialog(context, materialItem),
        hoverColor: const Color(0xFFF8FAFC),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
          child: Row(
            children: [
              // 1. ID badge
              SizedBox(
                width: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${materialItem.id}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 2. Material Name
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        materialItem.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. Vehicle Type Badge
              SizedBox(
                width: 110,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: isLoad
                          ? const Color(0xFFEEF2FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isLoad
                            ? const Color(0xFFC7D2FE)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLoad
                              ? Icons.local_shipping_outlined
                              : Icons.rv_hookup_outlined,
                          size: 13,
                          color: isLoad
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          materialItem.vehicleType,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isLoad
                                ? const Color(0xFF4338CA)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 4. Status Badge
              SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: materialItem.isActive
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: materialItem.isActive
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: materialItem.isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          materialItem.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: materialItem.isActive
                                ? const Color(0xFF15803D)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 5. Display Value tag
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          materialItem.displayValue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 6. Action buttons
              SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildRowActions(context, materialItem),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Action buttons with modern icon capsules
  Widget _buildRowActions(BuildContext context, MaterialItem materialItem) {
    Widget actionButton({
      required IconData icon,
      required Color color,
      required Color bgColor,
      required String tooltip,
      required VoidCallback onTap,
    }) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          hoverColor: bgColor,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 16),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        actionButton(
          icon: Icons.visibility_outlined,
          color: const Color(0xFF0284C7),
          bgColor: const Color(0xFFF0F9FF),
          tooltip: 'View Details',
          onTap: () => _showDetailsDialog(context, materialItem),
        ),
        const SizedBox(width: 4),
        actionButton(
          icon: Icons.edit_outlined,
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFFFBEB),
          tooltip: 'Edit',
          onTap: () => _showFormDialog(context, materialItem),
        ),
        const SizedBox(width: 4),
        actionButton(
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEF2F2),
          tooltip: 'Delete',
          onTap: () => _deleteMaterial(context, materialItem),
        ),
      ],
    );
  }

  /// Empty state when no materials exist
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 44,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No materials found. Click "Add Material" to create one.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Master materials streamline billing and automated tare workflows.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showFormDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Add Material',
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

  /// Empty state when search filters return 0 results
  Widget _buildEmptySearchResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            const Text(
              'No matching materials found',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try adjusting your search query or reset active filters.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _typeFilter = 'All';
                  _statusFilter = 'All';
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, [MaterialItem? materialItem]) {
    MaterialFormDialog.show(
      context,
      bloc: context.read<MaterialBloc>(),
      material: materialItem,
    );
  }

  void _showDetailsDialog(BuildContext context, MaterialItem materialItem) {
    showDialog<void>(
      context: context,
      builder: (_) => MaterialDetailsDialog(material: materialItem),
    );
  }

  void _deleteMaterial(BuildContext context, MaterialItem materialItem) {
    final bloc = context.read<MaterialBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirm Deletion',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${materialItem.displayValue}"?\n\n'
          'If weighments already use it, deactivation is offered instead.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF475569),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(MaterialDeletedEvent(materialItem.id!));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
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
}

const _headerStyle = TextStyle(
  fontFamily: 'PlusJakartaSans',
  fontWeight: FontWeight.w700,
  fontSize: 11,
  color: Color(0xFF64748B),
  letterSpacing: 0.5,
);
