import 'package:flutter/material.dart';

class BillFormRow extends StatelessWidget {
  const BillFormRow({
    super.key,
    required this.label,
    required this.labelWidth,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final String label;
  final double labelWidth;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 400;
        final label = Text(
          this.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: 0.4,
          ),
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [label, const SizedBox(height: 5), child],
          );
        }

        final effectiveLabelWidth = labelWidth.clamp(
          100.0,
          constraints.maxWidth * 0.40,
        );
        return Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: crossAxisAlignment == CrossAxisAlignment.start ? 13.0 : 0.0,
              ),
              child: SizedBox(width: effectiveLabelWidth, child: label),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
