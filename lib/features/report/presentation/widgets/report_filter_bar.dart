import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/report_filter.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class ReportFilterBar extends StatelessWidget {
  const ReportFilterBar({
    super.key,
    required this.filter,
    required this.state,
    required this.vehicleNumberController,
    required this.datePickerFormat,
    required this.selectCustomDate,
  });

  final ReportFilter filter;
  final ReportState state;
  final TextEditingController vehicleNumberController;
  final DateFormat datePickerFormat;
  final Future<void> Function({
    required BuildContext context,
    required bool isStartDate,
    required ReportFilter filter,
  })
  selectCustomDate;

  @override
  Widget build(BuildContext context) {
    final isCustomDate = filter.datePreset == DateRangePreset.custom;
    final bloc = context.read<ReportBloc>();

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune_rounded, size: 16, color: Color(0xFF475569)),
              SizedBox(width: 6),
              Text(
                'Filters',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Date Range Preset Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Date Range',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DateRangePreset>(
                      value: filter.datePreset,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          bloc.add(ReportFilterPresetChanged(val));
                        }
                      },
                      items: DateRangePreset.values
                          .map(
                            (preset) => DropdownMenuItem(
                              value: preset,
                              child: Text(preset.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // If Custom Range, show Date Pickers
              if (isCustomDate) ...[
                Expanded(
                  flex: 2,
                  child: _buildDateButton(
                    label: 'Date From',
                    dateText: datePickerFormat.format(
                      filter.effectiveStartDate,
                    ),
                    onTap: () => selectCustomDate(
                      context: context,
                      isStartDate: true,
                      filter: filter,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildDateButton(
                    label: 'Date To',
                    dateText: datePickerFormat.format(filter.effectiveEndDate),
                    onTap: () => selectCustomDate(
                      context: context,
                      isStartDate: false,
                      filter: filter,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Customer Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Customer',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: filter.customerId,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (val) {
                        bloc.add(ReportCustomerFilterChanged(val));
                      },
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'All Customers',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...state.customers.map(
                          (c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Vehicle Number Filter
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Vehicle No',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      TextField(
                        controller: vehicleNumberController,
                        textInputAction: TextInputAction.search,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 5,
                          ),
                          border: InputBorder.none,
                          hintText: 'Enter Vehicle No',
                          hintStyle: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        onChanged: (val) {
                          bloc.add(ReportVehicleFilterChanged(val));
                        },
                        onSubmitted: (_) {
                          bloc.add(const ApplyReportFilters());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Material Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Material',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: filter.materialId,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (val) {
                        bloc.add(ReportMaterialFilterChanged(val));
                      },
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'All Materials',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...state.materials.map(
                          (m) => DropdownMenuItem<int?>(
                            value: m.id,
                            child: Text(
                              m.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Payment Mode Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Payment',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filter.paymentMode,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          bloc.add(ReportPaymentFilterChanged(val));
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Modes'),
                        ),
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(
                          value: 'credit',
                          child: Text('Credit'),
                        ),
                        DropdownMenuItem(value: 'upi', child: Text('UPI')),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Apply and Reset Buttons
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      vehicleNumberController.clear();
                      bloc.add(const ResetReportFilters());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      bloc.add(const ApplyReportFilters());
                    },
                    icon: const Icon(Icons.filter_alt_outlined, size: 16),
                    label: const Text(
                      'Apply',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer({
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
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
          child,
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required String dateText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
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
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateText,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
