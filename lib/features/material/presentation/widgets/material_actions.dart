import 'package:flutter/material.dart';

/// Action buttons (view, edit, delete) for a material row.
class MaterialRowActions extends StatelessWidget {
  const MaterialRowActions({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    Widget actionButton({
      required IconData icon,
      required Color color,
      required Color bgColor,
      required String tooltip,
      required VoidCallback onTap,
    }) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          hoverColor: bgColor,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 16),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        actionButton(
          icon: Icons.visibility_outlined,
          color: const Color(0xFF0284C7),
          bgColor: const Color(0xFFF0F9FF),
          tooltip: 'View Details',
          onTap: onView,
        ),
        const SizedBox(width: 4),
        actionButton(
          icon: Icons.edit_outlined,
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFFFBEB),
          tooltip: 'Edit',
          onTap: onEdit,
        ),
        const SizedBox(width: 4),
        actionButton(
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEF2F2),
          tooltip: 'Delete',
          onTap: onDelete,
        ),
      ],
    );
  }
}
