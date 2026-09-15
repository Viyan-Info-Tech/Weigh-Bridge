import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as app_material;
import '../../../../core/presentation/widgets/form_dialog.dart';

class MaterialFormDialog extends StatefulWidget {
  final int? materialId;

  const MaterialFormDialog({super.key, this.materialId});

  @override
  State<MaterialFormDialog> createState() => _MaterialFormDialogState();

  static Future<void> show(BuildContext context, {int? materialId}) {
    return showDialog(
      context: context,
      builder: (_) => MaterialFormDialog(materialId: materialId),
    );
  }
}

class _MaterialFormDialogState extends State<MaterialFormDialog> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();

  bool get isEditing => widget.materialId != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      context.read<MaterialBloc>().add(LoadMaterialById(widget.materialId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaterialBloc, app_material.MaterialState>(
      listener: (context, state) {
        if (state.status == app_material.AppMaterialStatus.success) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.successMessage ?? 'Material saved successfully',
              ),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context);
        }
        if (state.status == app_material.AppMaterialStatus.error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        if (state.selectedMaterial != null && isEditing) {
          _populateForm(state.selectedMaterial!);
        }
      },
      child: FormDialogWrapper(
        title: isEditing ? 'Edit Material' : 'Add Material',
        subtitle: isEditing
            ? 'Update material details'
            : 'Add material details to your master',
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormDialogTextField(
                label: 'Material Name',
                controller: _nameController,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              FormDialogTextField(
                label: 'Category',
                controller: _categoryController,
              ),
              const SizedBox(height: 24),
              FormDialogActions(
                submitLabel: isEditing ? 'Update Material' : 'Save Material',
                isLoading: _isLoading,
                onSubmit: _saveMaterial,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _populateForm(dynamic material) {
    _nameController.text = material.name;
    _categoryController.text = material.category ?? '';
  }

  void _saveMaterial() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (isEditing) {
      context.read<MaterialBloc>().add(
        UpdateMaterialRequested(
          id: widget.materialId!,
          name: _nameController.text,
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text
              : null,
        ),
      );
    } else {
      context.read<MaterialBloc>().add(
        CreateMaterialRequested(
          name: _nameController.text,
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text
              : null,
        ),
      );
    }
  }
}
