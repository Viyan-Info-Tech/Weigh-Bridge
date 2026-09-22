import 'package:flutter/material.dart' hide Material;
import 'package:intl/intl.dart';

import 'weighment_slip_dialog.dart';
import 'date_range_filter_popover.dart';

import '../../../customer/domain/entities/customer.dart';
import '../../../material/domain/entities/material_item.dart' as domain;
import '../../domain/entities/weighment.dart';

class RecentBillsPanel extends StatefulWidget {
  final List<Weighment> recentBills;
  final DateTime? billsDate;
  final DateTime? billsStartDate;
  final DateTime? billsEndDate;
  final List<Customer> customers;
  final List<domain.MaterialItem> materials;
  final ValueChanged<Weighment>? onBillSelected;
  final ValueChanged<DateTime>? onDateChanged;
  final void Function(DateTime? startDate, DateTime? endDate)?
  onDateRangeChanged;
  final FocusNode? searchFocusNode;
  final bool shrinkWrap;

  const RecentBillsPanel({
    super.key,
    required this.recentBills,
    this.billsDate,
    this.billsStartDate,
    this.billsEndDate,
    required this.customers,
    this.materials = const [],
    this.onBillSelected,
    this.onDateChanged,
    this.onDateRangeChanged,
    this.searchFocusNode,
    this.shrinkWrap = false,
  });

  @override
  State<RecentBillsPanel> createState() => _RecentBillsPanelState();
}

class _RecentBillsPanelState extends State<RecentBillsPanel> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'ALL'; // ALL, COMPLETED, PENDING
  String _dateFilterLabel = 'Today';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCustomerName(int customerId) {
    try {
      return widget.customers.firstWhere((c) => c.id == customerId).name;
    } catch (_) {
      return 'Customer #$customerId';
    }
  }

  String _getMaterialName(int materialId) {
    try {
      return widget.materials.firstWhere((m) => m.id == materialId).name;
    } catch (_) {
      return 'Material #$materialId';
    }
  }

  Customer? _getCustomer(int customerId) {
    try {
      return widget.customers.firstWhere((c) => c.id == customerId);
    } catch (_) {
      return null;
    }
  }

  DateTime get _selectedDay {
    final d = widget.billsDate ?? DateTime.now();
    return DateTime(d.year, d.month, d.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get _hasDateRange =>
      widget.billsStartDate != null || widget.billsEndDate != null;

  bool get _isViewingToday {
    if (_hasDateRange) return false;
    final now = DateTime.now();
    final d = _selectedDay;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Future<void> _showDateRangeFilter() async {
    final result = await DateRangeFilterPopover.show(
      context: context,
      initialStartDate: widget.billsStartDate,
      initialEndDate: widget.billsEndDate,
    );
    if (result != null) {
      widget.onDateRangeChanged?.call(result.startDate, result.endDate);
      setState(() {
        _dateFilterLabel = result.label;
      });
    }
  }

  void _showBillSlipDialog(Weighment bill) {
    final customer = _getCustomer(bill.customerId);
    final materialName = _getMaterialName(bill.materialId);

    showDialog(
      context: context,
      builder: (context) => WeighmentSlipDialog(
        bill: bill,
        customer: customer,
        materialName: materialName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayBills = widget.recentBills.where((bill) {
      if (_hasDateRange) {
        final start = widget.billsStartDate;
        final end = widget.billsEndDate;
        final billDate = DateTime(
          bill.createdAt.year,
          bill.createdAt.month,
          bill.createdAt.day,
        );
        if (start != null && end != null) {
          final s = DateTime(start.year, start.month, start.day);
          final e = DateTime(end.year, end.month, end.day);
          return (billDate.isAfter(s) || billDate.isAtSameMomentAs(s)) &&
              (billDate.isBefore(e) || billDate.isAtSameMomentAs(e));
        } else if (start != null) {
          final s = DateTime(start.year, start.month, start.day);
          return billDate.isAfter(s) || billDate.isAtSameMomentAs(s);
        } else if (end != null) {
          final e = DateTime(end.year, end.month, end.day);
          return billDate.isBefore(e) || billDate.isAtSameMomentAs(e);
        }
        return true;
      } else {
        return _isSameDay(bill.createdAt, _selectedDay);
      }
    }).toList();

    // Filter bills based on search query and status filter
    final filteredBills = displayBills.where((bill) {
      final vehicleNo = bill.vehicleNumber.toLowerCase();
      final customerName = _getCustomerName(bill.customerId).toLowerCase();
      final billNo = bill.billNumber.toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          vehicleNo.contains(query) ||
          customerName.contains(query) ||
          billNo.contains(query);

      if (!matchesSearch) return false;

      if (_filterType == 'COMPLETED') {
        return bill.isCompleted;
      }
      return true;
    }).toList();

    final totalNetWeightTon =
        displayBills.fold<double>(0, (sum, b) => sum + (b.netWeightKg ?? 0)) /
        1000;
    final totalRevenue = displayBills.fold<double>(
      0,
      (sum, b) => sum + b.amount,
    );

    String countLabel;
    String subtitle;
    if (_hasDateRange) {
      final start = widget.billsStartDate;
      final end = widget.billsEndDate;
      if (start != null && end != null) {
        if (_isSameDay(start, end)) {
          countLabel =
              '${displayBills.length} · ${DateFormat('dd MMM').format(start)}';
          subtitle =
              'Weighments for ${DateFormat('dd MMM yyyy').format(start)}';
        } else {
          countLabel =
              '${displayBills.length} · ${DateFormat('dd MMM').format(start)} – ${DateFormat('dd MMM').format(end)}';
          subtitle =
              'Weighments from ${DateFormat('dd MMM').format(start)} – ${DateFormat('dd MMM yyyy').format(end)}';
        }
      } else if (start != null) {
        countLabel =
            '${displayBills.length} · From ${DateFormat('dd MMM').format(start)}';
        subtitle = 'Weighments from ${DateFormat('dd MMM yyyy').format(start)}';
      } else {
        countLabel =
            '${displayBills.length} · Until ${DateFormat('dd MMM').format(end!)}';
        subtitle = 'Weighments until ${DateFormat('dd MMM yyyy').format(end)}';
      }
    } else if (_isViewingToday) {
      countLabel = '${displayBills.length} Today';
      subtitle = "Today's weighments";
    } else {
      countLabel =
          '${displayBills.length} · ${DateFormat('dd MMM').format(_selectedDay)}';
      subtitle =
          'Weighments for ${DateFormat('dd MMM yyyy').format(_selectedDay)}';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth;
        final isCompact = panelWidth < 460;

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
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 14 : 20,
                  isCompact ? 14 : 20,
                  isCompact ? 14 : 20,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0D3B82,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFF0D3B82),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recent Billings',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                subtitle,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                countLabel,
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
                            '${displayBills.length}',
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

                    // 3. Search & Filter Bar (Adaptive Layout)
                    if (isCompact) ...[
                      SizedBox(height: 38, child: _buildSearchTextField()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDateFilterButton(),
                          const Spacer(),
                          _buildFilterChip('ALL', 'All'),
                          const SizedBox(width: 4),
                          _buildFilterChip('COMPLETED', 'Done'),
                        ],
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 38,
                              child: _buildSearchTextField(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildDateFilterButton(),
                          const SizedBox(width: 8),
                          _buildFilterChip('ALL', 'All'),
                          const SizedBox(width: 4),
                          _buildFilterChip('COMPLETED', 'Done'),
                        ],
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // 4. Full-Height Scrollable Bills List / Natural Height in Stacked Mode
              if (widget.shrinkWrap)
                (filteredBills.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBills.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final bill = filteredBills[index];
                          return _buildBillCard(bill);
                        },
                      ))
              else
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
      },
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
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

  Widget _buildDateFilterButton() {
    final hasActiveFilter = _hasDateRange;
    return Tooltip(
      message: hasActiveFilter ? _dateFilterLabel : 'Filter by date',
      child: InkWell(
        key: const Key('recent_bills_date_filter_button'),
        onTap: _showDateRangeFilter,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: hasActiveFilter
                ? const Color(0xFF0D3B82)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: hasActiveFilter
                  ? const Color(0xFF0D3B82)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: hasActiveFilter ? Colors.white : const Color(0xFF64748B),
              ),
              if (hasActiveFilter) ...[
                const SizedBox(width: 6),
                Text(
                  _dateFilterLabel,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
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

  Widget _buildSearchTextField() {
    return TextField(
      key: const Key('recent_bills_search_field'),
      controller: _searchController,
      focusNode: widget.searchFocusNode,
      onChanged: (val) {
        setState(() {
          _searchQuery = val;
        });
      },
      style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search bill #, vehicle, or customer...',
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
                icon: const Icon(Icons.clear_rounded, size: 16),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
          borderSide: const BorderSide(color: Color(0xFF0D3B82)),
        ),
      ),
    );
  }

  Widget _buildBillCard(Weighment bill) {
    final vehicleNo = bill.vehicleNumber;
    final customerName = _getCustomerName(bill.customerId);
    final materialName = _getMaterialName(bill.materialId);
    final isCompleted = bill.isCompleted;
    final timeStr = DateFormat('hh:mm a').format(bill.createdAt);
    final dateStr = DateFormat('dd MMM').format(bill.createdAt);
    final timestampLabel = _isSameDay(bill.createdAt, DateTime.now())
        ? timeStr
        : '$dateStr, $timeStr';

    final String statusBadgeText;
    final Color statusBadgeBg;
    final Color statusBadgeColor;

    statusBadgeText = 'COMPLETED';
    statusBadgeBg = const Color(0xFFDCFCE7);
    statusBadgeColor = const Color(0xFF16A34A);

    final String grossDisplay;
    final String tareDisplay;
    final String netDisplay;

    final unit = bill.weightUnit;
    final isTon = unit.toLowerCase() == 'ton' || unit.toLowerCase() == 'tonne';
    final decimals = isTon ? 3 : 0;
    double? toDisplay(double? kg) {
      if (kg == null) return null;
      return isTon ? kg / 1000 : kg;
    }

    grossDisplay = bill.grossWeightKg != null && isCompleted
        ? '${toDisplay(bill.grossWeightKg)!.toStringAsFixed(decimals)} $unit'
        : '—';
    tareDisplay = bill.tareWeightKg != null && isCompleted
        ? '${toDisplay(bill.tareWeightKg)!.toStringAsFixed(decimals)} $unit'
        : '—';
    netDisplay = bill.netWeightKg != null && isCompleted
        ? '${toDisplay(bill.netWeightKg)!.toStringAsFixed(decimals)} $unit'
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
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
                  color: statusBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusBadgeText,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusBadgeColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timestampLabel,
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

          // Row 2: Vehicle Plate & Customer & Material
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
                  customerName,
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
                constraints: const BoxConstraints(maxWidth: 120),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  materialName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                _buildWeightCell('Gross Wt', grossDisplay),
                _buildVerticalLine(),
                _buildWeightCell('Tare Wt', tareDisplay),
                _buildVerticalLine(),
                _buildWeightCell(
                  'Net Weight',
                  netDisplay,
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
                '₹${NumberFormat('#,##0.00').format(bill.amount)}',
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
              const Spacer(),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: textColor ?? const Color(0xFF1E293B),
              ),
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
                  : _filterType == 'COMPLETED'
                  ? 'No Completed Billings'
                  : _isViewingToday
                  ? 'No billings today'
                  : 'No billings on this date',
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
                  : _filterType == 'COMPLETED'
                  ? 'No completed weighments yet.'
                  : _isViewingToday
                  ? "Today's weighment tickets will appear here as they are saved."
                  : 'Choose another date or open Report for historical bills.',
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
