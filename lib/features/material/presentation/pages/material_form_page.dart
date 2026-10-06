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
  String? _codeErrorText;
  String? _nameErrorText;

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
          final error = state.errorMessage ?? '';
          if (error.toLowerCase().contains(
            'material with this code already exists',
          )) {
            setState(() {
              _codeErrorText =
                  'Material code "${_codeController.text.trim()}" already exists. Please use another code.';
            });
            _formKey.currentState?.validate();
            return;
          }
          showAppSnackBar(
            error.isEmpty ? 'An error occurred' : error,
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveMaterial(),
                  validator: (value) {
                    if (_codeErrorText != null) return _codeErrorText;
                    if (value == null || value.trim().isEmpty) {
                      return 'Material code is required';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    if (_codeErrorText != null) {
                      setState(() => _codeErrorText = null);
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                FormDialogTextField(
                  key: const Key('material_name_field'),
                  label: 'Material Name',
                  controller: _nameController,
                  isRequired: true,
                  hintText: 'e.g. Sand, Gravel, Cement',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveMaterial(),
                  validator: (value) {
                    if (_nameErrorText != null) return _nameErrorText;
                    if (value == null || value.trim().isEmpty) {
                      return 'Material name is required';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    if (_nameErrorText != null) {
                      setState(() => _nameErrorText = null);
                      _formKey.currentState?.validate();
                    }
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

  /// Single entry point for saving, shared by the submit button and by Enter in
  /// either field.
  ///
  /// [FormDialogActions] disables the button while a save is in flight, but
  /// Enter bypasses that, so the guard lives here too. Without it a second
  /// Enter during the async duplicate-code lookup would dispatch a second
  /// update for the same material.
  Future<void> _saveMaterial() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final code = _codeController.text.trim();
    final name = _nameController.text.trim();

    try {
      final existing = await context.read<MaterialBloc>().findMaterialByCode(
        code,
      );
      if (!mounted) return;
      if (existing != null && existing.id != widget.materialId) {
        setState(() {
          _isLoading = false;
          _codeErrorText =
              'Material code "$code" already exists. Please use another code.';
        });
        _formKey.currentState?.validate();
        return;
      }
      final duplicateName = await context
          .read<MaterialBloc>()
          .findMaterialByName(name);
      if (!mounted) return;
      if (duplicateName != null && duplicateName.id != widget.materialId) {
        setState(() {
          _isLoading = false;
          _nameErrorText = 'Material name "$name" is already registered.';
        });
        _formKey.currentState?.validate();
        return;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppSnackBar(
        'Could not check material code: $error',
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

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
