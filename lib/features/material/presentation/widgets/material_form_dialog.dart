import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/material_item.dart';
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';

/// Dialog for adding or editing a material. Fields: Material Name (text) and
/// Vehicle Type (Empty / Load dropdown).
class MaterialFormDialog extends StatefulWidget {
  final MaterialItem? material;

  const MaterialFormDialog({super.key, this.material});

  static Future<void> show(
    BuildContext context, {
    MaterialBloc? bloc,
    MaterialItem? material,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc ?? context.read<MaterialBloc>(),
        child: MaterialFormDialog(material: material),
      ),
    );
  }

  @override
  State<MaterialFormDialog> createState() => _MaterialFormDialogState();
}

class _MaterialFormDialogState extends State<MaterialFormDialog> {
  late final TextEditingController _nameController;
  String _vehicleType = 'Empty';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _vehicleType = widget.material?.vehicleType ?? 'Empty';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final bloc = context.read<MaterialBloc>();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Please enter a material name');
      return;
    }
    bloc.add(
      MaterialSavedEvent(
        MaterialItem(
          id: widget.material?.id,
          name: name,
          vehicleType: _vehicleType,
          isActive: widget.material?.isActive ?? true,
          createdAt: widget.material?.createdAt,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = (constraints.maxWidth - 32).clamp(280.0, 420.0);
          return Container(
            width: maxWidth,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.material == null ? 'Add Material' : 'Edit Material',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Material Name',
                    hintText: 'e.g. Auto',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _vehicleType,
                  decoration: const InputDecoration(labelText: 'Vehicle Type'),
                  items: const [
                    DropdownMenuItem(value: 'Empty', child: Text('Empty')),
                    DropdownMenuItem(value: 'Load', child: Text('Load')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _vehicleType = value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.material == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
