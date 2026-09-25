import 'package:flutter/material.dart';

class ReportHeader extends StatelessWidget {
  const ReportHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'REPORTS',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'View, filter and export weighment records',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
