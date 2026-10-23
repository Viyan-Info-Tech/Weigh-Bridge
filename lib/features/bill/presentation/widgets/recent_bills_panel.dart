import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'recent_bill_card.dart';
import 'weighment_slip_dialog.dart';
import 'date_range_filter_popover.dart';

import '../../../../core/utils/text_formatters.dart';
import '../../domain/entities/weighment.dart';

/// Read-only history of saved weighments.
///
/// This panel never writes to the active bill form. Completed bills are
/// immutable records, so tapping one opens a preview of that ticket instead of
/// loading it back into the entry form.
class RecentBillsPanel extends StatefulWidget {
  final List<Weighment> recentBills;
  final DateTime? billsDate;
  final DateTime? billsStartDate;
  final DateTime? billsEndDate;
  final String weightUnit;
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
    this.weightUnit = 'kg',
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
  String _dateFilterLabel = 'Today';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  /// Opens the read-only ticket preview for a saved bill.
  void _showBillSlipDialog(Weighment bill) {
    showDialog(
      context: context,
      builder: (context) => WeighmentSlipDialog(bill: bill),
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

    // Filter bills based on the search query. Vehicle numbers are compared
    // case- and space-insensitively, so searching "TN30EN3000" also finds a
    // bill saved as "TN 30 EN 3000".
    final normalizedQuery = normalizeVehicleNumber(_searchQuery);
    final filteredBills = displayBills.where((bill) {
      final vehicleNo = normalizeVehicleNumber(bill.vehicleNumber);
      final billNo = bill.billNumber.toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty ||
          vehicleNo.contains(normalizedQuery) ||
          billNo.contains(query);

      return matchesSearch;
    }).toList();

    final totalNetWeightKg = displayBills.fold<double>(
      0,
      (sum, b) => sum + (b.netWeightKg ?? 0),
    );
    final isTon = widget.weightUnit.toLowerCase() == 'ton';
    final netWeightDisplay = isTon
        ? '${(totalNetWeightKg / 1000).toStringAsFixed(1)} ton'
        : '${NumberFormat('#,##0').format(totalNetWeightKg)} kg';

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
                                "Today's Weighments",
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
                          constraints: const BoxConstraints(maxWidth: 85),
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
                              Flexible(
                                child: Text(
                                  countLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Keep compact panel metrics in a vertical stack.
                    if (isCompact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMetricTile(
                            'Total Weighments',
                            '${displayBills.length}',
                            const Color(0xFF0D3B82),
                            Icons.format_list_numbered_rounded,
                          ),
                          const SizedBox(height: 8),
                          _buildMetricTile(
                            'Total Net Weight',
                            netWeightDisplay,
                            const Color(0xFF0284C7),
                            Icons.scale_rounded,
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              'Total Weighments',
                              '${displayBills.length}',
                              const Color(0xFF0D3B82),
                              Icons.format_list_numbered_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricTile(
                              'Total Net Weight',
                              netWeightDisplay,
                              const Color(0xFF0284C7),
                              Icons.scale_rounded,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // 3. Search & Filter Bar (Adaptive Layout)
                    // 3. Search & Filter Bar
                    if (isCompact) ...[
                      SizedBox(height: 38, child: _buildSearchTextField()),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildDateFilterButton(),
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
                          return _cardFor(bill, isCompact: isCompact);
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
                            return _cardFor(bill, isCompact: isCompact);
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 95),
                  child: Text(
                    _dateFilterLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
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
        hintText: 'Search bill # or vehicle...',
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

  Widget _cardFor(Weighment bill, {required bool isCompact}) {
    return RecentBillCard(
      key: ValueKey(bill.id),
      bill: bill,
      weightUnit: widget.weightUnit,
      isCompact: isCompact,
      // Tapping a saved bill only previews it. The active new-bill form is never
      // populated from history.
      onSelected: () => _showBillSlipDialog(bill),
      onPrintSlip: () => _showBillSlipDialog(bill),
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
