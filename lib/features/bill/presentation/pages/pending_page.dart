import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../material/domain/entities/material_item.dart' as domain;
import '../../domain/entities/weighment.dart';
import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';
import '../widgets/weighment_slip_dialog.dart';

class PendingPage extends StatefulWidget {
  final VoidCallback? onSwitchToBill;

  const PendingPage({super.key, this.onSwitchToBill});

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _dateFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<BillBloc>().add(const LoadPendingBills());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _continueBill(Weighment bill) {
    context.read<BillBloc>().add(LoadPendingBill(bill.id));
    widget.onSwitchToBill?.call();
  }

  void _showPendingSlipDialog(Weighment bill, BillState state) {
    Vehicle? vehicle;
    try {
      vehicle = state.vehicles.firstWhere((v) => v.id == bill.vehicleId);
    } catch (_) {}

    Party? party;
    try {
      party = state.parties.firstWhere((p) => p.id == bill.partyId);
    } catch (_) {}

    final materialName = _getMaterialName(state.materials, bill.materialId);
    final isGrossPending = bill.firstWeightType.toUpperCase() == 'TARE';

    showDialog(
      context: context,
      builder: (dialogContext) => WeighmentSlipDialog(
        bill: bill,
        vehicle: vehicle,
        party: party,
        vehicleTypes: state.vehicleTypes,
        materialName: materialName,
        continueLabel: isGrossPending ? 'Gross Weight' : 'Tare Weight',
        onContinue: () {
          _continueBill(bill);
        },
      ),
    );
  }

  String _getVehicleNumber(List<Vehicle> vehicles, int vehicleId) {
    try {
      return vehicles.firstWhere((v) => v.id == vehicleId).vehicleNumber;
    } catch (_) {
      return 'Vehicle #$vehicleId';
    }
  }

  String _getPartyName(List<Party> parties, int partyId) {
    try {
      return parties.firstWhere((p) => p.id == partyId).name;
    } catch (_) {
      return 'Party #$partyId';
    }
  }

  String _getMaterialName(List<domain.MaterialItem> materials, int materialId) {
    try {
      return materials.firstWhere((m) => m.id == materialId).name;
    } catch (_) {
      return 'Material #$materialId';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());

  bool _isYesterday(DateTime date) =>
      _isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));

  String _formatTimestamp(DateTime dt) {
    if (_isToday(dt)) return DateFormat('hh:mm a').format(dt);
    if (_isYesterday(dt)) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(dt)}';
    }
    return DateFormat('dd MMM, hh:mm a').format(dt);
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

            final isShortHeight = availableHeight < 620;
            final pagePadding = availableWidth >= 1200
                ? const EdgeInsets.all(20)
                : availableWidth >= 900
                ? const EdgeInsets.all(16)
                : const EdgeInsets.all(12);

            return BlocBuilder<BillBloc, BillState>(
              builder: (context, state) {
                final pendingBills = state.pendingBills;

                final filteredBills = pendingBills.where((bill) {
                  final vehicleNo = _getVehicleNumber(
                    state.vehicles,
                    bill.vehicleId,
                  ).toLowerCase();
                  final partyName = _getPartyName(
                    state.parties,
                    bill.partyId,
                  ).toLowerCase();
                  final billNo = bill.billNumber.toLowerCase();
                  final query = _searchQuery.toLowerCase();

                  final matchesSearch =
                      query.isEmpty ||
                      vehicleNo.contains(query) ||
                      partyName.contains(query) ||
                      billNo.contains(query);

                  if (!matchesSearch) return false;

                  if (_dateFilter == 'TODAY') return _isToday(bill.createdAt);
                  if (_dateFilter == 'OLDER') return !_isToday(bill.createdAt);
                  return true;
                }).toList();

                final totalFirstWeight = filteredBills.fold<double>(
                  0,
                  (sum, b) => sum + b.firstWeightKg,
                );
                final totalExpected = filteredBills.fold<double>(
                  0,
                  (sum, b) => sum + b.amount,
                );

                final headerWidget = _buildPageHeader(filteredBills.length);
                final summaryCardsWidget = _buildSummaryCards(
                  availableWidth: availableWidth,
                  pendingCount: filteredBills.length,
                  totalFirstWeightKg: totalFirstWeight,
                  totalExpected: totalExpected,
                );

                final cardContent = Container(
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
                      _buildCardHeader(filteredBills.length),
                      _buildSearchAndFilter(),
                      Expanded(child: _buildPendingTable(filteredBills, state)),
                    ],
                  ),
                );

                // If height is normal, fit inside viewport with Expanded card
                if (!isShortHeight) {
                  return Padding(
                    padding: pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerWidget,
                        const SizedBox(height: 16),
                        summaryCardsWidget,
                        const SizedBox(height: 16),
                        Expanded(child: cardContent),
                      ],
                    ),
                  );
                }

                // If height is short (< 620px), enable outer SingleChildScrollView
                // with a comfortable bounded card height (500px)
                return SingleChildScrollView(
                  padding: pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headerWidget,
                      const SizedBox(height: 14),
                      summaryCardsWidget,
                      const SizedBox(height: 16),
                      SizedBox(height: 500, child: cardContent),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageHeader(int pendingCount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD97706).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.pending_actions_rounded,
            color: Color(0xFFD97706),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pending Weighments',
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
                'Vehicles waiting for tare weighing to complete the bill',
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

  Widget _buildSummaryCards({
    required double availableWidth,
    required int pendingCount,
    required double totalFirstWeightKg,
    required double totalExpected,
  }) {
    final cardQueue = _buildStatCard(
      icon: Icons.timer_outlined,
      iconColor: const Color(0xFFD97706),
      iconBg: const Color(0xFFFFF7ED),
      label: 'Pending Queue',
      value: '$pendingCount',
      subtext: 'Awaiting Tare Weight',
    );

    final cardWeight = _buildStatCard(
      icon: Icons.scale_rounded,
      iconColor: const Color(0xFF0F52BA),
      iconBg: const Color(0xFFEFF6FF),
      label: 'Gross Weight Captured',
      value: '${totalFirstWeightKg.toStringAsFixed(0)} kg',
      subtext: 'Gross weight captured',
    );

    final cardExpected = _buildStatCard(
      icon: Icons.currency_rupee_rounded,
      iconColor: const Color(0xFF16A34A),
      iconBg: const Color(0xFFF0FDF4),
      label: 'Expected Charges',
      value: '₹ ${totalExpected.toStringAsFixed(0)}',
      subtext: 'Estimated billing amount',
    );

    // Responsive layout:
    // >= 860px: 3 cards in 1 row
    // 600px - 859px: 2 cards on row 1, 1 card on row 2
    // < 600px: 3 cards stacked vertically
    if (availableWidth >= 860) {
      return Row(
        children: [
          Expanded(child: cardQueue),
          const SizedBox(width: 14),
          Expanded(child: cardWeight),
          const SizedBox(width: 14),
          Expanded(child: cardExpected),
        ],
      );
    } else if (availableWidth >= 600) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cardQueue),
              const SizedBox(width: 12),
              Expanded(child: cardWeight),
            ],
          ),
          const SizedBox(height: 10),
          cardExpected,
        ],
      );
    } else {
      return Column(
        children: [
          cardQueue,
          const SizedBox(height: 10),
          cardWeight,
          const SizedBox(height: 10),
          cardExpected,
        ],
      );
    }
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

  Widget _buildCardHeader(int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final isCompact = cardWidth < 360;
        final isVeryCompact = cardWidth < 290;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pending_actions_outlined,
                  color: Color(0xFFD97706),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Flexible(
                child: Text(
                  'Pending Bills',
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
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
                IconButton.outlined(
                  onPressed: () {
                    context.read<BillBloc>().add(const LoadPendingBills());
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  tooltip: 'Refresh',
                  style: IconButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<BillBloc>().add(const LoadPendingBills());
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 8 : 12,
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
              setState(() => _searchQuery = value);
            },
            style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Search by bill #, vehicle, or party...',
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
                        setState(() => _searchQuery = '');
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
              value: _dateFilter,
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
                DropdownMenuItem(value: 'ALL', child: Text('All Time')),
                DropdownMenuItem(value: 'TODAY', child: Text('Today')),
                DropdownMenuItem(value: 'OLDER', child: Text('Older')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _dateFilter = value);
                }
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

  Widget _buildPendingTable(List<Weighment> bills, BillState state) {
    if (bills.isEmpty) {
      return _buildEmptyState();
    }

    const minTableWidth = 800.0;

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
                      itemCount: bills.length,
                      itemBuilder: (context, index) {
                        final bill = bills[index];
                        return _buildDataRow(bill, state);
                      },
                    ),
                  ),
                ],
              );

              if (constraints.maxWidth < minTableWidth) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: minTableWidth, child: tableContent),
                );
              }
              return tableContent;
            },
          ),
        ),
        _buildTableFooter(bills.length),
      ],
    );
  }

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
          Expanded(flex: 20, child: _buildHeaderText('BILL NUMBER')),
          Expanded(flex: 18, child: _buildHeaderText('VEHICLE')),
          Expanded(flex: 26, child: _buildHeaderText('PARTY & MATERIAL')),
          Expanded(flex: 16, child: _buildHeaderText('FIRST WEIGHT')),
          Expanded(flex: 12, child: _buildHeaderText('TIME')),
          Expanded(
            flex: 18,
            child: _buildHeaderText('ACTION', align: TextAlign.right),
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

  Widget _buildDataRow(Weighment bill, BillState state) {
    final vehicleNo = _getVehicleNumber(state.vehicles, bill.vehicleId);
    final partyName = _getPartyName(state.parties, bill.partyId);
    final materialName = _getMaterialName(state.materials, bill.materialId);

    final isGrossPending = bill.firstWeightType.toUpperCase() == 'TARE';
    final actionText = isGrossPending ? 'Gross Weight' : 'Tare Weight';
    final badgeText = isGrossPending
        ? 'PENDING • GROSS WT'
        : 'PENDING • TARE WT';
    final displayedWeightKg = bill.firstWeightKg;
    final weightSubtitle = isGrossPending
        ? 'Tare • ₹${bill.amount.toStringAsFixed(0)}'
        : 'Gross • ₹${bill.amount.toStringAsFixed(0)}';

    return _HoverableRow(
      onTap: () => _showPendingSlipDialog(bill, state),
      child: Row(
        children: [
          // Bill Number
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 14,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bill.billNumber,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: isGrossPending
                              ? const Color(0xFFE0F2FE)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: isGrossPending
                                ? const Color(0xFF0369A1)
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Vehicle Number
          Expanded(
            flex: 18,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F52BA).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    size: 13,
                    color: Color(0xFF0F52BA),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vehicleNo,
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

          // Party & Material
          Expanded(
            flex: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  partyName,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEA580C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        materialName,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Gross / Tare Weight
          Expanded(
            flex: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${displayedWeightKg.toStringAsFixed(bill.weightUnit == 'kg' ? 0 : 3)} ${bill.weightUnit}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    weightSubtitle,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Time
          Expanded(
            flex: 12,
            child: Text(
              _formatTimestamp(bill.createdAt),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Action button
          Expanded(
            flex: 18,
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _continueBill(bill),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: Text(actionText),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
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
            'Total $count ${count == 1 ? 'pending weighment' : 'pending weighments'}',
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
                Icons.check_circle_outline_rounded,
                size: 36,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No pending weighments',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'All gross weighments have been completed or no bills are awaiting tare weight.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverableRow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HoverableRow({required this.child, this.onTap});

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
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
      ),
    );
  }
}
