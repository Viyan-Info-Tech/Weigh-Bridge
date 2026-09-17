import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_bloc.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_event.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_state.dart';
import '../../../vehicle_type/presentation/pages/vehicle_type_form_page.dart'
    as vt_form;
import '../../domain/entities/vehicle.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import 'vehicle_form_page.dart' as v_form;
import 'vehicle_details_dialog.dart';
import '../../../vehicle_type/presentation/pages/vehicle_type_details_dialog.dart';
import '../../../../core/presentation/widgets/action_menu.dart';

class VehiclesMergedPage extends StatefulWidget {
  const VehiclesMergedPage({super.key});

  @override
  State<VehiclesMergedPage> createState() => _VehiclesMergedPageState();
}

class _VehiclesMergedPageState extends State<VehiclesMergedPage> {
  @override
  void initState() {
    super.initState();
    context.read<VehicleBloc>().add(const LoadVehicles());
    context.read<VehicleTypeBloc>().add(const LoadVehicleTypes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            // Breakpoint classification:
            // Full desktop (>= 1200): Side-by-side with generous 62% / 38% ratio
            // Compact desktop (960 - 1199): Side-by-side with 60% / 40% ratio
            // Narrow desktop (< 960): Stacked vertically with natural height
            final isSideBySide = availableWidth >= 960;
            final isShortHeight = availableHeight < 640;

            final pagePadding = availableWidth >= 1200
                ? const EdgeInsets.all(20)
                : availableWidth >= 960
                ? const EdgeInsets.all(16)
                : const EdgeInsets.all(14);

            if (isSideBySide && !isShortHeight) {
              return Padding(
                padding: pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(availableWidth),
                    const SizedBox(height: 16),
                    _buildSummaryCards(availableWidth),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: availableWidth >= 1200 ? 62 : 60,
                            child: const _VehiclesPanel(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: availableWidth >= 1200 ? 38 : 40,
                            child: const _VehicleTypesPanel(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Short window height or stacked mode (< 960px):
            // Outer SingleChildScrollView handles vertical overflow smoothly.
            return SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(availableWidth),
                  const SizedBox(height: 14),
                  _buildSummaryCards(availableWidth),
                  const SizedBox(height: 16),
                  if (isSideBySide) ...[
                    SizedBox(
                      height: 520,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: availableWidth >= 1200 ? 62 : 60,
                            child: const _VehiclesPanel(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: availableWidth >= 1200 ? 38 : 40,
                            child: const _VehicleTypesPanel(),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 520, child: _VehiclesPanel()),
                    const SizedBox(height: 16),
                    const SizedBox(height: 480, child: _VehicleTypesPanel()),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageHeader(double width) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F52BA).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.local_shipping_outlined,
            color: Color(0xFF0F52BA),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicles & Types',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage registered vehicles and pricing tiers',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(double width) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, vState) {
        return BlocBuilder<VehicleTypeBloc, VehicleTypeState>(
          builder: (context, vtState) {
            final totalVehicles = vState.vehicles.length;
            final activeVehicles = vState.vehicles
                .where((v) => v.isActive)
                .length;
            final inactiveVehicles = totalVehicles - activeVehicles;

            final totalTypes = vtState.vehicleTypes.length;
            final activeTypes = vtState.vehicleTypes
                .where((vt) => vt.isActive)
                .length;

            final activeRate = totalVehicles > 0
                ? ((activeVehicles / totalVehicles) * 100).round()
                : 100;

            final cardFleet = _buildStatCard(
              icon: Icons.local_shipping_rounded,
              iconColor: const Color(0xFF0F52BA),
              iconBg: const Color(0xFF0F52BA).withValues(alpha: 0.1),
              label: 'Registered Fleet',
              value: '$totalVehicles',
              subtext: '$activeVehicles Active • $inactiveVehicles Inactive',
            );

            final cardTypes = _buildStatCard(
              icon: Icons.category_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              label: 'Vehicle Categories',
              value: '$totalTypes',
              subtext: '$activeTypes Active Pricing Tiers',
            );

            final cardRate = _buildStatCard(
              icon: Icons.verified_rounded,
              iconColor: const Color(0xFF16A34A),
              iconBg: const Color(0xFF16A34A).withValues(alpha: 0.1),
              label: 'Operational Rate',
              value: '$activeRate%',
              subtext: 'Fleet readiness score',
            );

            // Responsive Layout:
            // >= 860px: 3 cards in 1 row
            // 600px - 859px: 2 cards on row 1, 1 card on row 2
            // < 600px: 3 cards stacked vertically
            if (width >= 860) {
              return Row(
                children: [
                  Expanded(child: cardFleet),
                  const SizedBox(width: 14),
                  Expanded(child: cardTypes),
                  const SizedBox(width: 14),
                  Expanded(child: cardRate),
                ],
              );
            } else if (width >= 600) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: cardFleet),
                      const SizedBox(width: 12),
                      Expanded(child: cardTypes),
                    ],
                  ),
                  const SizedBox(height: 10),
                  cardRate,
                ],
              );
            } else {
              return Column(
                children: [
                  cardFleet,
                  const SizedBox(height: 10),
                  cardTypes,
                  const SizedBox(height: 10),
                  cardRate,
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtext,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehiclesPanel extends StatefulWidget {
  const _VehiclesPanel();

  @override
  State<_VehiclesPanel> createState() => _VehiclesPanelState();
}

class _VehiclesPanelState extends State<_VehiclesPanel> {
  final _searchController = TextEditingController();
  String? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _findTypeName(int typeId, List<VehicleType> types) {
    for (final t in types) {
      if (t.id == typeId) return t.name;
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final vehicleTypes = context.watch<VehicleTypeBloc>().state.vehicleTypes;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(child: _buildVehicleTable(vehicleTypes)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final panelWidth = constraints.maxWidth;
            final isCompact = panelWidth < 380;
            final isVeryCompact = panelWidth < 300;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F52BA).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Color(0xFF0F52BA),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Vehicles',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.vehicles.length}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isVeryCompact)
                    IconButton.filled(
                      onPressed: () => v_form.VehicleFormDialog.show(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      tooltip: 'Add Vehicle',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B82),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => v_form.VehicleFormDialog.show(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(isCompact ? 'Add' : 'Add Vehicle'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B82),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;

        final searchField = SizedBox(
          height: 38,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
              context.read<VehicleBloc>().add(SearchVehicles(value));
            },
            style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Search by vehicle number, driver...',
              hintStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        context.read<VehicleBloc>().add(
                          const SearchVehicles(''),
                        );
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
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
                  color: Color(0xFF0F52BA),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
        );

        final filterDropdown = Container(
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
              isExpanded: isNarrow,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Status')),
                DropdownMenuItem(value: 'active', child: Text('Active Only')),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text('Inactive Only'),
                ),
              ],
              onChanged: (value) {
                setState(() => _statusFilter = value);
                bool? isActive;
                if (value == 'active') isActive = true;
                if (value == 'inactive') isActive = false;
                context.read<VehicleBloc>().add(
                  FilterVehiclesByStatus(isActive),
                );
              },
            ),
          ),
        );

        if (isNarrow) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 8),
                filterDropdown,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 10),
              filterDropdown,
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleTable(List<VehicleType> vehicleTypes) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state.status == VehicleStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          );
        }
        if (state.vehicles.isEmpty) {
          return _buildEmptyState();
        }

        const minTableWidth = 560.0;

        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableContent = Column(
                    children: [
                      _buildHeaderRow(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = state.vehicles[index];
                            final typeName = _findTypeName(
                              vehicle.vehicleTypeId,
                              vehicleTypes,
                            );
                            return _buildDataRow(vehicle, typeName);
                          },
                        ),
                      ),
                    ],
                  );

                  if (constraints.maxWidth < minTableWidth) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minTableWidth,
                        child: tableContent,
                      ),
                    );
                  }
                  return tableContent;
                },
              ),
            ),
            _buildTableFooter(state.vehicles.length),
          ],
        );
      },
    );
  }

  static const double _actionColumnWidth = 110.0;

  Widget _buildHeaderRow() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 30, child: _buildHeaderText('VEHICLE NUMBER')),
          Expanded(flex: 22, child: _buildHeaderText('TYPE')),
          Expanded(flex: 26, child: _buildHeaderText('DRIVER')),
          Expanded(flex: 22, child: _buildHeaderText('STATUS')),
          SizedBox(
            width: _actionColumnWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildHeaderText('ACTIONS'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDataRow(Vehicle vehicle, String typeName) {
    return _HoverableRow(
      child: Row(
        children: [
          Expanded(
            flex: 26,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F52BA).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.pin_outlined,
                    size: 13,
                    color: Color(0xFF0F52BA),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vehicle.vehicleNumber,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 18,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  typeName,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vehicle.driverName != null && vehicle.driverName!.isNotEmpty
                      ? vehicle.driverName!
                      : '-',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        vehicle.driverName != null &&
                            vehicle.driverName!.isNotEmpty
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (vehicle.driverPhone != null &&
                    vehicle.driverPhone!.isNotEmpty)
                  Text(
                    vehicle.driverPhone!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 22,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(vehicle.isActive),
            ),
          ),
          SizedBox(
            width: _actionColumnWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionMenu(
                  isActive: vehicle.isActive,
                  onView: () => VehicleDetailsDialog.show(
                    context,
                    vehicle: vehicle,
                    typeName: typeName,
                  ),
                  onEdit: () =>
                      v_form.VehicleFormDialog.show(context, vehicleId: vehicle.id),
                  onDelete: () => _confirmDeleteVehicle(context, vehicle),
                  onDeactivate: () => _confirmDeactivateVehicle(context, vehicle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No vehicles found',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add your first vehicle or adjust your search query.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => v_form.VehicleFormDialog.show(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Vehicle'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B82),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableFooter(int count) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Text(
            'Total $count ${count == 1 ? 'vehicle' : 'vehicles'}',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivateVehicle(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Deactivate Vehicle',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to deactivate vehicle "${vehicle.vehicleNumber}"?',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<VehicleBloc>().add(
                DeactivateVehicleRequested(vehicle.id),
              );
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Deactivate',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVehicle(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete Vehicle',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete vehicle "${vehicle.vehicleNumber}"?\n\nThis action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<VehicleBloc>().add(
                DeleteVehicleRequested(vehicle.id),
              );
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTypesPanel extends StatefulWidget {
  const _VehicleTypesPanel();

  @override
  State<_VehicleTypesPanel> createState() => _VehicleTypesPanelState();
}

class _VehicleTypesPanelState extends State<_VehicleTypesPanel> {
  final _searchController = TextEditingController();
  String? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(child: _buildVehicleTypeTable()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<VehicleTypeBloc, VehicleTypeState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final panelWidth = constraints.maxWidth;
            final isCompact = panelWidth < 380;
            final isVeryCompact = panelWidth < 300;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      color: Color(0xFF7C3AED),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Vehicle Types',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.vehicleTypes.length}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isVeryCompact)
                    IconButton.filled(
                      onPressed: () =>
                          vt_form.VehicleTypeFormDialog.show(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      tooltip: 'Add Type',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B82),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () =>
                          vt_form.VehicleTypeFormDialog.show(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(isCompact ? 'Add' : 'Add Type'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B82),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;

        final searchField = SizedBox(
          height: 38,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
              context.read<VehicleTypeBloc>().add(SearchVehicleTypes(value));
            },
            style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Search type...',
              hintStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        context.read<VehicleTypeBloc>().add(
                          const SearchVehicleTypes(''),
                        );
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
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
                  color: Color(0xFF0F52BA),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
        );

        final filterDropdown = Container(
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
              isExpanded: isNarrow,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Status')),
                DropdownMenuItem(value: 'active', child: Text('Active Only')),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text('Inactive Only'),
                ),
              ],
              onChanged: (value) {
                setState(() => _statusFilter = value);
                bool? isActive;
                if (value == 'active') isActive = true;
                if (value == 'inactive') isActive = false;
                context.read<VehicleTypeBloc>().add(
                  LoadVehicleTypes(filterActive: isActive),
                );
              },
            ),
          ),
        );

        if (isNarrow) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 8),
                filterDropdown,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 10),
              filterDropdown,
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleTypeTable() {
    return BlocBuilder<VehicleTypeBloc, VehicleTypeState>(
      builder: (context, state) {
        if (state.status == VehicleTypeStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          );
        }
        if (state.vehicleTypes.isEmpty) {
          return _buildEmptyState();
        }

        const minTableWidth = 420.0;

        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableContent = Column(
                    children: [
                      _buildHeaderRow(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.vehicleTypes.length,
                          itemBuilder: (context, index) {
                            final vt = state.vehicleTypes[index];
                            return _buildDataRow(vt);
                          },
                        ),
                      ),
                    ],
                  );

                  if (constraints.maxWidth < minTableWidth) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minTableWidth,
                        child: tableContent,
                      ),
                    );
                  }
                  return tableContent;
                },
              ),
            ),
            _buildTableFooter(state.vehicleTypes.length),
          ],
        );
      },
    );
  }

  static const double _actionColumnWidth = 110.0;

  Widget _buildHeaderRow() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 36, child: _buildHeaderText('TYPE NAME')),
          Expanded(flex: 20, child: _buildHeaderText('EMPTY')),
          Expanded(flex: 20, child: _buildHeaderText('LOAD')),
          Expanded(flex: 24, child: _buildHeaderText('STATUS')),
          SizedBox(
            width: _actionColumnWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildHeaderText('ACTIONS'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDataRow(VehicleType vt) {
    return _HoverableRow(
      child: Row(
        children: [
          Expanded(
            flex: 28,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    size: 13,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vt.name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 17,
            child: Text(
              '₹${vt.emptyPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 17,
            child: Text(
              '₹${vt.loadPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(vt.isActive),
            ),
          ),
          SizedBox(
            width: _actionColumnWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionMenu(
                  isActive: vt.isActive,
                  onView: () =>
                      VehicleTypeDetailsDialog.show(context, vehicleType: vt),
                  onEdit: () =>
                      vt_form.VehicleTypeFormDialog.show(context, vehicleType: vt),
                  onDelete: () => _confirmDeleteVehicleType(context, vt),
                  onDeactivate: () => _confirmDeactivateVehicleType(context, vt),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category_outlined,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No vehicle types found',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add your first vehicle type or adjust your search filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => vt_form.VehicleTypeFormDialog.show(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Type'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B82),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableFooter(int count) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Text(
            'Total $count ${count == 1 ? 'type' : 'types'}',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivateVehicleType(BuildContext context, VehicleType vt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Deactivate Vehicle Type',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to deactivate "${vt.name}"? Existing records will be preserved.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<VehicleTypeBloc>().add(
                DeactivateVehicleTypeRequested(vt.id),
              );
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Deactivate',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVehicleType(BuildContext context, VehicleType vt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete Vehicle Type',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${vt.name}"?\n\nThis action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<VehicleTypeBloc>().add(
                DeleteVehicleTypeRequested(vt.id),
              );
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableRow extends StatefulWidget {
  final Widget child;

  const _HoverableRow({required this.child});

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFF8FAFC) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: widget.child,
      ),
    );
  }
}
