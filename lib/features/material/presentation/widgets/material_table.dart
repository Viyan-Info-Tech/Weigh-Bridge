import 'package:flutter/material.dart';

import '../../domain/entities/material_item.dart';
import 'material_empty_state.dart';
import 'material_table_row.dart';

/// Main materials table container with header, scrollable rows and footer.
class MaterialTable extends StatelessWidget {
  const MaterialTable({
    super.key,
    required this.scrollController,
    required this.filteredMaterials,
    required this.totalCount,
    required this.hasActiveFilters,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onClearFilters,
  });

  final ScrollController scrollController;
  final List<MaterialItem> filteredMaterials;
  final int totalCount;
  final bool hasActiveFilters;
  final void Function(MaterialItem) onView;
  final void Function(MaterialItem) onEdit;
  final void Function(MaterialItem) onDelete;
  final VoidCallback onClearFilters;

  static const TextStyle _headerStyle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    fontSize: 11,
    color: Color(0xFF64748B),
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 50, child: Text('ID', style: _headerStyle)),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text('MATERIAL NAME', style: _headerStyle),
                ),
                SizedBox(width: 12),
                SizedBox(width: 110, child: Text('TYPE', style: _headerStyle)),
                SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: Text('STATUS', style: _headerStyle),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text('DISPLAY VALUE', style: _headerStyle),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('ACTIONS', style: _headerStyle),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredMaterials.isEmpty
                ? MaterialEmptySearchResult(onClearFilters: onClearFilters)
                : Scrollbar(
                    controller: scrollController,
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: filteredMaterials.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Color(0xFFF1F5F9),
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final materialItem = filteredMaterials[index];
                        return MaterialTableRow(
                          materialItem: materialItem,
                          index: index,
                          onView: () => onView(materialItem),
                          onEdit: () => onEdit(materialItem),
                          onDelete: () => onDelete(materialItem),
                        );
                      },
                    ),
                  ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredMaterials.length} of $totalCount materials',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (hasActiveFilters)
                  InkWell(
                    onTap: onClearFilters,
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
