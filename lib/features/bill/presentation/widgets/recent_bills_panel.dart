import 'package:flutter/material.dart' hide Material;
import 'package:intl/intl.dart';

import '../../domain/entities/party.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/material.dart' as domain;
import '../../domain/entities/weighment.dart';

class RecentBillsPanel extends StatefulWidget {
  final List<Weighment> recentBills;
  final List<Party> parties;
  final List<Vehicle> vehicles;
  final List<domain.Material> materials;
  final ValueChanged<Weighment>? onBillSelected;

  const RecentBillsPanel({
    super.key,
    required this.recentBills,
    required this.parties,
    required this.vehicles,
    this.materials = const [],
    this.onBillSelected,
  });

  @override
  State<RecentBillsPanel> createState() => _RecentBillsPanelState();
}

class _RecentBillsPanelState extends State<RecentBillsPanel> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'ALL'; // ALL, COMPLETED, PENDING

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getVehicleNumber(int vehicleId) {
    try {
      return widget.vehicles.firstWhere((v) => v.id == vehicleId).vehicleNumber;
    } catch (_) {
      return 'Vehicle #$vehicleId';
    }
  }

  String _getPartyName(int partyId) {
    try {
      return widget.parties.firstWhere((p) => p.id == partyId).name;
    } catch (_) {
      return 'Party #$partyId';
    }
  }

  String _getMaterialName(int materialId) {
    try {
      return widget.materials.firstWhere((m) => m.id == materialId).name;
    } catch (_) {
      return 'Material #$materialId';
    }
  }

  void _showBillSlipDialog(Weighment bill) {
    final vehicleNo = _getVehicleNumber(bill.vehicleId);
    final partyName = _getPartyName(bill.partyId);
    final materialName = _getMaterialName(bill.materialId);
    final dateFormatted = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(bill.createdAt);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF0D3B82),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VIYAN WEIGHBRIDGE',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Weighment Slip: ${bill.billNumber}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 20),
              _buildSlipRow('Date & Time', dateFormatted),
              _buildSlipRow('Vehicle No', vehicleNo, isBold: true),
              _buildSlipRow('Party', partyName),
              _buildSlipRow('Material', materialName),
              _buildSlipRow('Entry Type', bill.entryType.toUpperCase()),
              _buildSlipRow('Payment Mode', bill.paymentMode.toUpperCase()),
              const Divider(height: 20),
              _buildSlipRow(
                '1st Weight (Gross/Tare)',
                '${bill.firstWeightKg.toStringAsFixed(0)} kg',
              ),
              _buildSlipRow(
                '2nd Weight (Tare/Gross)',
                '${bill.secondWeightKg.toStringAsFixed(0)} kg',
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Net Weight',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${bill.netWeightKg.toStringAsFixed(0)} kg (${(bill.netWeightKg / 1000).toStringAsFixed(3)} T)',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D3B82),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildSlipRow(
                'Rate per Ton',
                '₹ ${bill.ratePerTon.toStringAsFixed(2)}',
              ),
              _buildSlipRow(
                'Total Charges',
                '₹ ${bill.amount.toStringAsFixed(2)}',
                isBold: true,
                textColor: const Color(0xFF16A34A),
              ),
              if (bill.remarks != null && bill.remarks!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildSlipRow('Remarks', bill.remarks!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(fontFamily: 'PlusJakartaSans'),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Print job sent for ${bill.billNumber}'),
                  backgroundColor: const Color(0xFF16A34A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Print Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B82),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlipRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: textColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter bills based on search query and status filter
    final filteredBills = widget.recentBills.where((bill) {
      final vehicleNo = _getVehicleNumber(bill.vehicleId).toLowerCase();
      final partyName = _getPartyName(bill.partyId).toLowerCase();
      final billNo = bill.billNumber.toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          vehicleNo.contains(query) ||
          partyName.contains(query) ||
          billNo.contains(query);

      if (!matchesSearch) return false;

      if (_filterType == 'COMPLETED') {
        return bill.secondWeightKg > 0;
      } else if (_filterType == 'PENDING') {
        return bill.secondWeightKg <= 0;
      }
      return true;
    }).toList();

    // Calculate summary statistics
    final totalNetWeightTon =
        widget.recentBills.fold<double>(0, (sum, b) => sum + b.netWeightKg) /
        1000;
    final totalRevenue = widget.recentBills.fold<double>(
      0,
      (sum, b) => sum + b.amount,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Panel Header with Title & Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Color(0xFF0D3B82),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Billings',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Real-time transaction log',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.recentBills.length} Total',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Summary KPI Metric Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Total Bills',
                        '${widget.recentBills.length}',
                        const Color(0xFF0D3B82),
                        Icons.format_list_numbered_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        'Net Tonnage',
                        '${totalNetWeightTon.toStringAsFixed(1)} T',
                        const Color(0xFF0284C7),
                        Icons.scale_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        'Total Revenue',
                        '₹${totalRevenue.toStringAsFixed(0)}',
                        const Color(0xFF16A34A),
                        Icons.currency_rupee_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Search & Filter Bar
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          key: const Key('recent_bills_search_field'),
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search bill #, vehicle, or party...',
                            hintStyle: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF0D3B82),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('ALL', 'All'),
                    const SizedBox(width: 4),
                    _buildFilterChip('COMPLETED', 'Done'),
                    const SizedBox(width: 4),
                    _buildFilterChip('PENDING', 'Pending'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 4. Full-Height Scrollable Bills List
          Expanded(
            child: filteredBills.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBills.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final bill = filteredBills[index];
                      return _buildBillCard(bill);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    Color accentColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = _filterType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _filterType = type;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D3B82) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard(Weighment bill) {
    final vehicleNo = _getVehicleNumber(bill.vehicleId);
    final partyName = _getPartyName(bill.partyId);
    final materialName = _getMaterialName(bill.materialId);
    final isCompleted = bill.secondWeightKg > 0;
    final timeStr = DateFormat('hh:mm a').format(bill.createdAt);
    final dateStr = DateFormat('dd MMM').format(bill.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFFDE68A), // Amber border for pending 2nd wt
          width: isCompleted ? 1.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Bill Number, Status Badge & Timestamp
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bill.billNumber,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D3B82),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted ? 'COMPLETED' : 'PENDING 2ND WT',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$dateStr, $timeStr',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Vehicle Plate & Party & Material
          Row(
            children: [
              // Styled Vehicle Plate
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 14,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vehicleNo,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  partyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  materialName,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Weight Values Breakdown Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildWeightCell(
                  '1st Wt',
                  '${bill.firstWeightKg.toStringAsFixed(0)} kg',
                ),
                _buildVerticalLine(),
                _buildWeightCell(
                  '2nd Wt',
                  isCompleted
                      ? '${bill.secondWeightKg.toStringAsFixed(0)} kg'
                      : 'Waiting...',
                  textColor: isCompleted ? null : const Color(0xFFD97706),
                ),
                _buildVerticalLine(),
                _buildWeightCell(
                  'Net Weight',
                  '${bill.netWeightKg.toStringAsFixed(0)} kg',
                  isBold: true,
                  textColor: const Color(0xFF0D3B82),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 4: Total Amount, Payment Badge, Slip Action
          Row(
            children: [
              Text(
                '₹ ${bill.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bill.paymentMode.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4338CA),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bill.entryType.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const Spacer(),
              // View / Print Slip Button
              IconButton(
                key: Key('print_slip_button_${bill.billNumber}'),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: const Color(0xFF0D3B82),
                tooltip: 'View & Print Slip',
                visualDensity: VisualDensity.compact,
                onPressed: () => _showBillSlipDialog(bill),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCell(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: textColor ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLine() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matching billings'
                  : 'No Recent Billings Yet',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching with a different keyword'
                  : 'Saved weighment tickets will appear here in real time.',
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
