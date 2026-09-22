import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as app_material;
import '../../domain/entities/material_item.dart';
import '../../../../core/presentation/widgets/form_dialog.dart';
import '../../../../app/app.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

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
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaterialBloc, app_material.MaterialState>(
      listener: (context, state) {
        if (state.status == app_material.AppMaterialStatus.success) {
          setState(() => _isLoading = false);
          showAppSnackBar(
            state.successMessage ?? 'Material saved successfully',
            backgroundColor: const Color(0xFF16A34A),
          );
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
        if (state.status == app_material.AppMaterialStatus.error) {
          setState(() => _isLoading = false);
          showAppSnackBar(
            state.errorMessage ?? 'An error occurred',
            backgroundColor: Colors.red.shade700,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormDialogTextField(
                  key: const Key('material_code_field'),
                  label: 'Material Code',
                  controller: _codeController,
                  isRequired: true,
                  hintText: 'e.g. 1, 2, 3',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Material code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FormDialogTextField(
                  key: const Key('material_name_field'),
                  label: 'Material Name',
                  controller: _nameController,
                  isRequired: true,
                  hintText: 'e.g. Sand, Gravel, Cement',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Material name is required';
                    }
                    return null;
                  },
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
      ),
    );
  }

  void _populateForm(MaterialItem material) {
    _codeController.text = material.code;
    _nameController.text = material.name;
  }

  void _saveMaterial() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final code = _codeController.text.trim();
    final name = _nameController.text.trim();

    if (isEditing) {
      context.read<MaterialBloc>().add(
        UpdateMaterialRequested(id: widget.materialId!, code: code, name: name),
      );
    } else {
      context.read<MaterialBloc>().add(
        CreateMaterialRequested(code: code, name: name),
      );
    }
  }
}
