import 'package:flutter/material.dart';

import '../../domain/entities/material_item.dart';

/// Read-only details dialog for a material record.
class MaterialDetailsDialog extends StatelessWidget {
  final MaterialItem material;

  const MaterialDetailsDialog({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Never wider than the space the dialog actually has, so it never
          // overflows small or scaled windows.
          final maxWidth = (constraints.maxWidth - 32).clamp(280.0, 420.0);
          return Container(
            width: maxWidth,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Material Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(label: 'ID', value: '${material.id}'),
                        _DetailRow(label: 'Material', value: material.name),
                        _DetailRow(
                          label: 'Vehicle Type',
                          value: material.vehicleType,
                        ),
                        _DetailRow(
                          label: 'Display Value',
                          value: material.displayValue,
                        ),
                        _DetailRow(
                          label: 'Status',
                          value: material.isActive ? 'Active' : 'Inactive',
                        ),
                        _DetailRow(
                          label: 'Created',
                          value: material.createdAt != null
                              ? '${material.createdAt!.day.toString().padLeft(2, '0')}/'
                                  '${material.createdAt!.month.toString().padLeft(2, '0')}/'
                                  '${material.createdAt!.year} '
                                  '${material.createdAt!.hour.toString().padLeft(2, '0')}:'
                                  '${material.createdAt!.minute.toString().padLeft(2, '0')}'
                              : 'N/A',
                        ),
                        _DetailRow(
                          label: 'Updated',
                          value: material.updatedAt != null
                              ? '${material.updatedAt!.day.toString().padLeft(2, '0')}/'
                                  '${material.updatedAt!.month.toString().padLeft(2, '0')}/'
                                  '${material.updatedAt!.year} '
                                  '${material.updatedAt!.hour.toString().padLeft(2, '0')}:'
                                  '${material.updatedAt!.minute.toString().padLeft(2, '0')}'
                              : 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
