import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilterResult {
  final DateTime? startDate;
  final DateTime? endDate;
  final String label;

  const DateRangeFilterResult({
    this.startDate,
    this.endDate,
    required this.label,
  });
}

class DateRangeFilterPopover extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const DateRangeFilterPopover({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  static Future<DateRangeFilterResult?> show({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) async {
    final result = await showDialog<DateRangeFilterResult>(
      context: context,
      builder: (_) => DateRangeFilterPopover(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
      ),
    );
    return result;
  }

  @override
  State<DateRangeFilterPopover> createState() => _DateRangeFilterPopoverState();
}

class _DateRangeFilterPopoverState extends State<DateRangeFilterPopover> {
  late DateTime _viewMonth;
  DateTime? _startDate;
  DateTime? _endDate;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _viewMonth = _startDate ?? DateTime.now();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  bool _isRangeStart(DateTime date) =>
      _startDate != null && _isSameDay(date, _startDate!);
  bool _isRangeEnd(DateTime date) =>
      _endDate != null && _isSameDay(date, _endDate!);

  void _onQuickSelect(String type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (type) {
      case 'today':
        setState(() {
          _startDate = today;
          _endDate = today;
          _viewMonth = today;
        });
        break;
      case 'yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        setState(() {
          _startDate = yesterday;
          _endDate = yesterday;
          _viewMonth = yesterday;
        });
        break;
      case 'this_week':
        final weekday = now.weekday;
        final weekStart = today.subtract(Duration(days: weekday - 1));
        setState(() {
          _startDate = weekStart;
          _endDate = today;
          _viewMonth = today;
        });
        break;
      case 'this_month':
        setState(() {
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = today;
          _viewMonth = today;
        });
        break;
    }
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else {
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  void _applyFilter() {
    String label;
    if (_startDate != null && _endDate != null) {
      if (_isSameDay(_startDate!, _endDate!)) {
        label = DateFormat('dd MMM yyyy').format(_startDate!);
      } else {
        label =
            '${DateFormat('dd MMM').format(_startDate!)} – ${DateFormat('dd MMM yyyy').format(_endDate!)}';
      }
    } else if (_startDate != null) {
      label = DateFormat('dd MMM yyyy').format(_startDate!);
    } else {
      label = 'All dates';
    }
    Navigator.of(context).pop(
      DateRangeFilterResult(
        startDate: _startDate,
        endDate: _endDate,
        label: label,
      ),
    );
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Month',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final isSelected = _viewMonth.month == index + 1;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _viewMonth = DateTime(_viewMonth.year, index + 1);
                      });
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0D3B82)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0D3B82)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        _months[index].substring(0, 3),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showYearPicker() {
    final currentYear = DateTime.now().year;
    final years = List.generate(9, (i) => currentYear - 4 + i);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Year',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = _viewMonth.year == year;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _viewMonth = DateTime(year, _viewMonth.month);
                      });
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0D3B82)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0D3B82)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        '$year',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filter by date',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.grey.shade400,
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildDateField('From', _startDate)),
                const SizedBox(width: 12),
                Expanded(child: _buildDateField('To', _endDate)),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Quick select',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuickChip('Today', 'today'),
                const SizedBox(width: 6),
                _buildQuickChip('Yesterday', 'yesterday'),
                const SizedBox(width: 6),
                _buildQuickChip('This Week', 'this_week'),
                const SizedBox(width: 6),
                _buildQuickChip('This Month', 'this_month'),
              ],
            ),
            const SizedBox(height: 16),

            _buildMonthYearCalendar(),
            const SizedBox(height: 16),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B82),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
                  child: const Text('Apply Filter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: date != null
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: date != null
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: date != null ? FontWeight.w600 : FontWeight.w400,
              color: date != null
                  ? const Color(0xFF1E40AF)
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label, String type) {
    return Expanded(
      child: InkWell(
        onTap: () => _onQuickSelect(type),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearCalendar() {
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday;
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            InkWell(
              onTap: _showMonthPicker,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMMM').format(_viewMonth),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D3B82),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: Color(0xFF0D3B82),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _showYearPicker,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_viewMonth.year}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D3B82),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: Color(0xFF0D3B82),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                setState(() {
                  _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                setState(() {
                  _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (d) => Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: (firstWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              return const SizedBox.shrink();
            }
            final day = index - (firstWeekday - 1) + 1;
            final date = DateTime(_viewMonth.year, _viewMonth.month, day);
            final isTodayDate = _isToday(date);
            final isStart = _isRangeStart(date);
            final isEnd = _isRangeEnd(date);
            final isInRange = _isInRange(date);
            final isFuture = date.isAfter(today);

            Color bgColor = Colors.transparent;
            Color textColor = const Color(0xFF334155);
            FontWeight fontWeight = FontWeight.w400;

            if (isStart || isEnd) {
              bgColor = const Color(0xFF0D3B82);
              textColor = Colors.white;
              fontWeight = FontWeight.w700;
            } else if (isInRange) {
              bgColor = const Color(0xFFDBEAFE);
              textColor = const Color(0xFF1E40AF);
            } else if (isTodayDate) {
              textColor = const Color(0xFF0D3B82);
              fontWeight = FontWeight.w700;
            }

            return GestureDetector(
              onTap: isFuture ? null : () => _onDateTap(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: fontWeight,
                    color: isFuture ? Colors.grey.shade300 : textColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
