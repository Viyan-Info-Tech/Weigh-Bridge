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
    if (_isYesterday(dt)) return 'Yesterday, ${DateFormat('hh:mm a').format(dt)}';
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillBloc, BillState>(
      builder: (context, state) {
        final pendingBills = state.pendingBills;

        final filteredBills = pendingBills.where((bill) {
          final vehicleNo = _getVehicleNumber(state.vehicles, bill.vehicleId).toLowerCase();
          final partyName = _getPartyName(state.parties, bill.partyId).toLowerCase();
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

        final totalFirstWeight = filteredBills.fold<double>(0, (sum, b) => sum + b.grossWeightKg);
        final totalExpected = filteredBills.fold<double>(0, (sum, b) => sum + b.amount);

        return Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            children: [
              _buildHeader(pendingBills.length),
              _buildSummaryStrip(
                pendingCount: filteredBills.length,
                totalFirstWeightKg: totalFirstWeight,
                totalExpected: totalExpected,
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              _buildFilterBar(),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: filteredBills.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: filteredBills.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final bill = filteredBills[index];
                          return _buildCompactCard(bill, state);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int pendingCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.pending_outlined,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Weighments',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Vehicles waiting for second weighing',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: pendingCount > 0 ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: pendingCount > 0 ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: pendingCount > 0 ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$pendingCount Pending',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: pendingCount > 0 ? const Color(0xFF92400E) : const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip({
    required int pendingCount,
    required double totalFirstWeightKg,
    required double totalExpected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          _buildSummaryTile(
            value: '$pendingCount',
            label: 'Pending',
            icon: Icons.pending_outlined,
            color: const Color(0xFFD97706),
          ),
          const SizedBox(width: 10),
          _buildSummaryTile(
            value: '${totalFirstWeightKg.toStringAsFixed(0)} kg',
            label: 'Total Gross Wt',
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFF0D3B82),
          ),
          const SizedBox(width: 10),
          _buildSummaryTile(
            value: 'Rs. ${totalExpected.toStringAsFixed(0)}',
            label: 'Expected',
            icon: Icons.currency_rupee_rounded,
            color: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  hintText: 'Search bill #, vehicle, or party...',
                  hintStyle: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 14),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFD97706)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildFilterChip('ALL', 'All'),
          const SizedBox(width: 4),
          _buildFilterChip('TODAY', 'Today'),
          const SizedBox(width: 4),
          _buildFilterChip('OLDER', 'Older'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = _dateFilter == type;
    return InkWell(
      onTap: () {
        setState(() {
          _dateFilter = type;
        });
      },
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD97706) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(Weighment bill, BillState state) {
    final vehicleNo = _getVehicleNumber(state.vehicles, bill.vehicleId);
    final partyName = _getPartyName(state.parties, bill.partyId);
    final materialName = _getMaterialName(state.materials, bill.materialId);
    final timestamp = _formatTimestamp(bill.createdAt);
    final isOld = !_isToday(bill.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOld ? const Color(0xFFFCD34D) : const Color(0xFFFDE68A),
          width: isOld ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: isOld ? 0.08 : 0.04),
            blurRadius: isOld ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                bill.billNumber,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D3B82),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'TARE WEIGHT PENDING',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (isOld) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'OLD',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                timestamp,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  color: isOld ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                  fontWeight: isOld ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 13,
                color: isOld ? const Color(0xFFB45309) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                vehicleNo,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isOld ? const Color(0xFF92400E) : const Color(0xFF0F172A),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$partyName • $materialName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniWeightCell('Gross Wt', '${bill.grossWeightKg.toStringAsFixed(0)} kg'),
              _buildMiniDivider(),
              _buildMiniWeightCell('Tare Wt', 'Waiting...', textColor: const Color(0xFFD97706)),
              _buildMiniDivider(),
              _buildMiniWeightCell('Net', '—', textColor: const Color(0xFF94A3B8)),
              _buildMiniDivider(),
              _buildMiniWeightCell('Charge', 'Rs. ${bill.amount.toStringAsFixed(0)}', textColor: const Color(0xFF16A34A)),
              const Spacer(),
              ElevatedButton.icon(
                key: Key('pending_continue_button_${bill.billNumber}'),
                onPressed: () => _continueBill(bill),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text('Continue 2nd Weighing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniWeightCell(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniDivider() {
    return Container(
      width: 1,
      height: 22,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No pending bills match your search.'
                  : 'No pending weighments. All vehicles have been fully weighed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
