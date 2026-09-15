import 'package:flutter/material.dart';

class ActionMenu extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDeactivate;
  final bool isActive;

  const ActionMenu({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onDeactivate,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 64),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 32,
            child: IconButton(
              onPressed: onView,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 18,
              tooltip: 'View',
              icon: const Icon(
                Icons.visibility_outlined,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: 30,
            height: 32,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 18,
              tooltip: 'More actions',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                  case 'deactivate':
                    onDeactivate();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xFF0F52BA),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(
                          Icons.block_outlined,
                          size: 16,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Deactivate',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              child: const Icon(
                Icons.more_vert,
                size: 18,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
