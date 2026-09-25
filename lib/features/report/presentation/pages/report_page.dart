import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

import '../../domain/entities/report_filter.dart';
import '../../domain/usecases/export_report_usecase.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/report_export_listener.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_header.dart';
import '../widgets/report_search_bar.dart';
import '../widgets/report_summary_bar.dart';
import '../widgets/report_table.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final DateFormat _datePickerFormat = DateFormat('dd/MM/yyyy');
  final ScrollController _hScrollController = ScrollController();
  StreamSubscription<SettingsState>? _settingsSubscription;
  String? _lastSettingsWeightUnit;

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(const LoadReportInitial());
    try {
      final settingsBloc = context.read<SettingsBloc>();
      _lastSettingsWeightUnit = settingsBloc.state.settings?.weightUnit;
      _settingsSubscription = settingsBloc.stream.listen((state) {
        final unit = state.settings?.weightUnit;
        if (mounted && unit != null && unit != _lastSettingsWeightUnit) {
          _lastSettingsWeightUnit = unit;
          context.read<ReportBloc>().add(const RefreshReport());
        }
      });
    } catch (_) {
      // Standalone page previews may not provide application settings.
    }
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _searchController.dispose();
    _vehicleNumberController.dispose();
    _hScrollController.dispose();
    super.dispose();
  }

  Future<void> _selectCustomDate({
    required BuildContext context,
    required bool isStartDate,
    required ReportFilter filter,
  }) async {
    final bloc = context.read<ReportBloc>();
    final initialDate = isStartDate
        ? (filter.customStartDate ?? filter.effectiveStartDate)
        : (filter.customEndDate ?? filter.effectiveEndDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0284C7),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartDate) {
        bloc.add(
          ReportCustomDateChanged(
            startDate: picked,
            endDate: filter.customEndDate ?? filter.effectiveEndDate,
          ),
        );
      } else {
        bloc.add(
          ReportCustomDateChanged(
            startDate: filter.customStartDate ?? filter.effectiveStartDate,
            endDate: picked,
          ),
        );
      }
    }
  }

  void _handleExportResult(BuildContext context, ReportState state) {
    final result = state.exportResult;
    if (result == null) return;

    context.read<ReportBloc>().add(const ClearExportResult());

    switch (result.type) {
      case ExportResultType.noRecords:
        ReportExportListener.showExportFailureDialog(
          context,
          'No Records to Export',
          'There are no weighment records matching the selected filters.',
        );
        break;

      case ExportResultType.failure:
        ReportExportListener.showExportFailureDialog(
          context,
          'Unable to Export Report',
          result.errorMessage ??
              'The file could not be saved to the selected location.\n\n'
                  'Please choose another location and try again.',
          isError: true,
        );
        break;

      case ExportResultType.cancelled:
        break;

      case ExportResultType.success:
        final filePath = result.filePath!;
        final fileName = result.fileName ?? p.basename(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '✓ Report exported successfully',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Folder',
              textColor: Colors.white,
              onPressed: () => ReportExportListener.openFolder(filePath),
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          }

          if (state.exportResult != null) {
            _handleExportResult(context, state);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, viewport) {
                final reportTable = ReportTable(
                  hScrollController: _hScrollController,
                  state: state,
                );
                if (_vehicleNumberController.text !=
                    state.filter.vehicleNumber) {
                  _vehicleNumberController.value = TextEditingValue(
                    text: state.filter.vehicleNumber,
                    selection: TextSelection.collapsed(
                      offset: state.filter.vehicleNumber.length,
                    ),
                  );
                }

                if (viewport.maxHeight >= 560) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ReportHeader(),
                      const SizedBox(height: 16),
                      ReportSummaryBar(
                        summary: state.summary,
                        weightUnit: state.weightUnit,
                      ),
                      const SizedBox(height: 16),
                      ReportFilterBar(
                        filter: state.filter,
                        state: state,
                        vehicleNumberController: _vehicleNumberController,
                        datePickerFormat: _datePickerFormat,
                        selectCustomDate: _selectCustomDate,
                      ),
                      const SizedBox(height: 16),
                      ReportSearchBar(
                        state: state,
                        searchController: _searchController,
                        onSearchChanged: (val) {
                          context.read<ReportBloc>().add(
                            ReportSearchQueryChanged(val),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: reportTable),
                    ],
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ReportHeader(),
                      const SizedBox(height: 16),
                      ReportSummaryBar(
                        summary: state.summary,
                        weightUnit: state.weightUnit,
                      ),
                      const SizedBox(height: 16),
                      ReportFilterBar(
                        filter: state.filter,
                        state: state,
                        vehicleNumberController: _vehicleNumberController,
                        datePickerFormat: _datePickerFormat,
                        selectCustomDate: _selectCustomDate,
                      ),
                      const SizedBox(height: 16),
                      ReportSearchBar(
                        state: state,
                        searchController: _searchController,
                        onSearchChanged: (val) {
                          context.read<ReportBloc>().add(
                            ReportSearchQueryChanged(val),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      reportTable,
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
