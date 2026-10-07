import 'package:flutter/material.dart';

import '../../../material/domain/entities/material_item.dart';
import 'master_lookup_dialog.dart';

/// Opens the material master as the legacy weighbridge software presented it.
///
/// Reached from the search icon beside MATERIAL CODE on the ticket screen: a
/// titled `S.No. / Material Code / Material Name` grid where picking a row
/// fills in both the code and the material name, so the operator never has to
/// type a code.
class MaterialMasterDialog {
  const MaterialMasterDialog._();

  static const String dialogTitle = 'SELECT MATERIAL';

  static Future<MaterialItem?> show(
    BuildContext context, {
    required List<MaterialItem> materials,
    MaterialItem? selectedMaterial,
  }) {
    return MasterLookupDialog.show<MaterialItem>(
      context,
      title: dialogTitle,
      items: materials,
      selectedItem: selectedMaterial,
      searchHint: 'Search by code or material name',
      emptyMessage: 'No materials found',
      columns: const [
        MasterLookupColumn<MaterialItem>(
          title: 'Material Code',
          value: _code,
          flex: 3,
          align: TextAlign.center,
          bold: true,
        ),
        MasterLookupColumn<MaterialItem>(
          title: 'Material Name',
          value: _name,
          flex: 5,
          bold: true,
        ),
      ],
    );
  }

  static String _code(MaterialItem item) => item.code;

  static String _name(MaterialItem item) => item.name;
}