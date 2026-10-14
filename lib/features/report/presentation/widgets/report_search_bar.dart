import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/print_report_dialog.dart';

class ReportSearchBar extends StatelessWidget {
  const ReportSearchBar({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
  });

  final ReportState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReportBloc>();

    return Row(
      children: [
        // Live Search Input
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search bill number or vehicle...',
                hintStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Print Report button
        OutlinedButton.icon(
          onPressed: () {
            final vehicleLabel = state.filter.vehicleNumber.trim().isEmpty
                ? 'All Vehicles'
                : state.filter.vehicleNumber;

            PrintReportDialog.show(
              context: context,
              records: state.records,
              summary: state.summary,
              filter: state.filter,
              weightUnit: state.weightUnit,
              vehicleLabel: vehicleLabel,
            );
          },
          icon: const Icon(Icons.print_outlined, size: 16),
          label: const Text(
            'Print Report',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E293B),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 10),

        // Export CSV button
        ElevatedButton.icon(
          onPressed: state.isExporting
              ? null
              : () {
                  bloc.add(const ExportReportCsv());
                },
          icon: state.isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download_rounded, size: 16),
          label: Text(
            state.isExporting ? 'Exporting...' : 'Export CSV',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF64748B),
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
