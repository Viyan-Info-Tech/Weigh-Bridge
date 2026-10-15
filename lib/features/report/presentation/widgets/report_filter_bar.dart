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

  static const double _controlHeight = 56.0;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 680;

          final dateRangeControl = _buildFieldContainer(
            label: 'Date Range',
            child: _buildDropdown(
              value: filter.datePreset,
              onChanged: (val) {
                if (val != null) {
                  bloc.add(ReportFilterPresetChanged(val));
                }
              },
            ),
          );

          final vehicleNoControl = _buildFieldContainer(
            label: 'Vehicle No',
            child: _buildVehicleTextField(
              controller: vehicleNumberController,
              onChanged: (val) {
                bloc.add(ReportVehicleFilterChanged(val));
              },
              onSubmitted: () {
                bloc.add(const ApplyReportFilters());
              },
            ),
          );

          final actionButtons = _buildActionButtons(
            context,
            bloc,
            vehicleNumberController,
          );

          if (!isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(child: dateRangeControl),
                              const SizedBox(width: 12),
                              Expanded(child: vehicleNoControl),
                            ],
                          ),
                          if (isCustomDate) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDateButton(
                                    label: 'Date To',
                                    dateText: datePickerFormat.format(
                                      filter.effectiveEndDate,
                                    ),
                                    onTap: () => selectCustomDate(
                                      context: context,
                                      isStartDate: false,
                                      filter: filter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    actionButtons,
                  ],
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              dateRangeControl,
              if (isCustomDate) ...[
                const SizedBox(height: 10),
                _buildDateButton(
                  label: 'Date From',
                  dateText: datePickerFormat.format(filter.effectiveStartDate),
                  onTap: () => selectCustomDate(
                    context: context,
                    isStartDate: true,
                    filter: filter,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDateButton(
                  label: 'Date To',
                  dateText: datePickerFormat.format(filter.effectiveEndDate),
                  onTap: () => selectCustomDate(
                    context: context,
                    isStartDate: false,
                    filter: filter,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              vehicleNoControl,
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [actionButtons],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
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
    );
  }

  Widget _buildFieldContainer({
    required String label,
    required Widget child,
  }) {
    return SizedBox(
      height: _controlHeight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required DateRangePreset value,
    required ValueChanged<DateRangePreset?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<DateRangePreset>(
        value: value,
        isExpanded: true,
        isDense: true,
        icon: const Icon(
          Icons.arrow_drop_down,
          size: 20,
          color: Color(0xFF64748B),
        ),
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
        ),
        onChanged: onChanged,
        items: DateRangePreset.values
            .map(
              (preset) => DropdownMenuItem(
                value: preset,
                child: Text(
                  preset.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildVehicleTextField({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required VoidCallback onSubmitted,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintText: 'Enter Vehicle No',
        hintStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
      ),
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted(),
    );
  }

  Widget _buildDateButton({
    required String label,
    required String dateText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: _buildFieldContainer(
        label: label,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateText,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ReportBloc bloc,
    TextEditingController vehicleNumberController,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _controlHeight,
          child: OutlinedButton(
            onPressed: () {
              vehicleNumberController.clear();
              bloc.add(const ResetReportFilters());
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: _controlHeight,
          child: ElevatedButton.icon(
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
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
