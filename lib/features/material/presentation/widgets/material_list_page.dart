import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/material_item.dart';
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as material;
import 'material_details_dialog.dart';
import 'material_form_dialog.dart';

/// Materials master data management screen. One row per material name +
/// vehicle type (e.g. `Auto - Empty`) - the value shown on bills.
class MaterialListPage extends StatefulWidget {
  const MaterialListPage({super.key});

  @override
  State<MaterialListPage> createState() => _MaterialListPageState();
}

class _MaterialListPageState extends State<MaterialListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Refresh whenever the tab is opened so new materials always show.
    context.read<MaterialBloc>().add(const LoadMaterialsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 16),
                Expanded(
                  child: state.isLoading && state.materials.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.materials.isEmpty
                          ? const Center(
                              child: Text(
                                'No materials found. Click "Add Material" to create one.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : _buildTable(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, material.MaterialState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.category, size: 24, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Materials',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (state.materials.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.materials.length} materials',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showFormDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add Material'),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, material.MaterialState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: const Row(
              children: [
                SizedBox(width: 44, child: Text('ID', style: _headerStyle)),
                SizedBox(width: 8),
                Expanded(flex: 2, child: Text('Material', style: _headerStyle)),
                SizedBox(width: 8),
                SizedBox(width: 60, child: Text('Type', style: _headerStyle)),
                SizedBox(width: 8),
                Expanded(child: Text('Status', style: _headerStyle)),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text('Display Value', style: _headerStyle),
                ),
                SizedBox(width: 4),
                SizedBox(width: 100, child: Text('Actions', style: _headerStyle)),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.materials.length,
                itemBuilder: (context, index) {
                  final materialItem = state.materials[index];
                  return _buildRow(context, materialItem, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    MaterialItem materialItem,
    int index,
  ) {
    final statusColor = materialItem.isActive ? Colors.green : Colors.grey;
    return Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          // ID: fixed but small; it never grows.
          SizedBox(width: 44, child: Text('${materialItem.id}')),
          const SizedBox(width: 8),
          // Name: flexible, truncates instead of forcing the row wider.
          Expanded(
            flex: 2,
            child: Text(
              materialItem.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          // Vehicle type: short fixed content.
          SizedBox(
            width: 60,
            child: Text(
              materialItem.vehicleType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Status badge: intrinsic width, never clipped.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              materialItem.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Display value: flexible, truncates gracefully.
          Expanded(
            flex: 2,
            child: Text(
              materialItem.displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          // Actions: intrinsic width from compact buttons, so the row never
          // overflows regardless of how many actions exist.
          _buildRowActions(context, materialItem),
        ],
      ),
    );
  }

  /// Compact action buttons sized to their content (32px each) so three of
  /// them need ~100px intrinsically instead of forcing a fixed 144px box.
  Widget _buildRowActions(BuildContext context, MaterialItem materialItem) {
    Widget action(IconData icon, Color color, String tooltip, VoidCallback onTap) {
      return IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon, color: color, size: 18),
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        padding: EdgeInsets.zero,
        splashRadius: 16,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        action(
          Icons.visibility,
          Colors.blue,
          'View Details',
          () => _showDetailsDialog(context, materialItem),
        ),
        action(
          Icons.edit,
          Colors.orange,
          'Edit',
          () => _showFormDialog(context, materialItem),
        ),
        action(
          Icons.delete,
          Colors.red,
          'Delete',
          () => _deleteMaterial(context, materialItem),
        ),
      ],
    );
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
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete "${materialItem.displayValue}"?\n\n'
          'If weighments already use it, deactivation is offered instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(MaterialDeletedEvent(materialItem.id!));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

const _headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
