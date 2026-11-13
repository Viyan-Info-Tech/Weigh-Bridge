import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/material_item.dart';
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as material;
import 'material_details_dialog.dart';
import 'material_empty_state.dart';
import 'material_form_dialog.dart';
import 'material_header.dart';
import 'material_kpi_section.dart';
import 'material_table.dart';
import 'material_toolbar.dart';

/// Materials master data management screen.
class MaterialListPage extends StatefulWidget {
  const MaterialListPage({super.key});

  @override
  State<MaterialListPage> createState() => _MaterialListPageState();
}

class _MaterialListPageState extends State<MaterialListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _typeFilter = 'All';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<MaterialBloc>().add(const LoadMaterialsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: isError
              ? const Color(0xFFDC2626)
              : const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  List<MaterialItem> _filterMaterials(List<MaterialItem> materials) {
    final query = _searchController.text.trim().toLowerCase();
    return materials.where((m) {
      if (query.isNotEmpty) {
        final nameMatch = m.name.toLowerCase().contains(query);
        final displayMatch = m.displayValue.toLowerCase().contains(query);
        final idMatch = m.id?.toString().contains(query) ?? false;
        if (!nameMatch && !displayMatch && !idMatch) return false;
      }
      if (_typeFilter != 'All') {
        if (m.vehicleType.toLowerCase() != _typeFilter.toLowerCase()) {
          return false;
        }
      }
      if (_statusFilter != 'All') {
        final isActive = _statusFilter == 'Active';
        if (m.isActive != isActive) return false;
      }
      return true;
    }).toList();
  }

  void _showFormDialog(BuildContext context, [MaterialItem? materialItem]) {
    MaterialFormDialog.show(
      context,
      bloc: context.read<MaterialBloc>(),
      material: materialItem,
    );
  }

  void _showDetailsDialog(BuildContext context, MaterialItem materialItem) {
    showDialog<void>(
      context: context,
      builder: (_) => MaterialDetailsDialog(material: materialItem),
    );
  }

  void _deleteMaterial(BuildContext context, MaterialItem materialItem) {
    final bloc = context.read<MaterialBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirm Deletion',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${materialItem.displayValue}"?\n\n'
          'If weighments already use it, deactivation is offered instead.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF475569),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(MaterialDeletedEvent(materialItem.id!));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      _typeFilter != 'All' ||
      _statusFilter != 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<MaterialBloc, material.MaterialState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            _showMessage(state.successMessage!);
          }
          if (state.error != null) {
            _showMessage(state.error!, isError: true);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.materials.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          final filteredMaterials = _filterMaterials(state.materials);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialHeader(
                  materialCount: state.materials.length,
                  onAdd: () => _showFormDialog(context),
                ),
                const SizedBox(height: 16),
                if (state.materials.isNotEmpty) ...[
                  MaterialKpiSection(materials: state.materials),
                  const SizedBox(height: 14),
                ],
                if (state.materials.isNotEmpty) ...[
                  MaterialToolbar(
                    searchController: _searchController,
                    typeFilter: _typeFilter,
                    statusFilter: _statusFilter,
                    onSearchChanged: (_) => setState(() {}),
                    onTypeChanged: (val) {
                      if (val != null) setState(() => _typeFilter = val);
                    },
                    onStatusChanged: (val) {
                      if (val != null) setState(() => _statusFilter = val);
                    },
                    onClearSearch: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    onResetFilters: () {
                      _searchController.clear();
                      setState(() {
                        _typeFilter = 'All';
                        _statusFilter = 'All';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: state.materials.isEmpty
                      ? MaterialEmptyState(
                          onAdd: () => _showFormDialog(context),
                        )
                      : MaterialTable(
                          scrollController: _scrollController,
                          filteredMaterials: filteredMaterials,
                          totalCount: state.materials.length,
                          hasActiveFilters: _hasActiveFilters,
                          onView: (m) => _showDetailsDialog(context, m),
                          onEdit: (m) => _showFormDialog(context, m),
                          onDelete: (m) => _deleteMaterial(context, m),
                          onClearFilters: () {
                            _searchController.clear();
                            setState(() {
                              _typeFilter = 'All';
                              _statusFilter = 'All';
                            });
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
