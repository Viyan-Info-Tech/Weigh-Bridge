import 'package:flutter/material.dart';

import 'ambient_background_painter.dart';
import 'truck_logo.dart';

class AuthBrandingPanel extends StatelessWidget {
  const AuthBrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F56CD),
            Color(0xFF0A3E9C),
            Color(0xFF072B70),
            Color(0xFF051D4E),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: BlueConcentricArcsPainter()),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 380,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x33000000), Colors.black],
                  stops: [0.0, 0.25, 0.75],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/weighbridge_truck.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF0A2E6E).withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0A3E9C).withValues(alpha: 0.4),
                          const Color(0xFF051D4E).withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ViyanWeighbridgeLogo(size: 58),
                const SizedBox(height: 18),
                const Text(
                  'Viyan',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'Weighbridge',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Accurate Weighing. Smarter Operations.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.95),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 28),

                Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildFeatureItem(
                        customIcon: const _WeightSackIcon(size: 26),
                        label: 'Accurate\nWeighing',
                      ),
                      _buildDivider(),
                      _buildFeatureItem(
                        icon: Icons.article_outlined,
                        label: 'Digital\nRecords',
                      ),
                      _buildDivider(),
                      _buildFeatureItem(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: 'Better\nInsights',
                      ),
                      _buildDivider(),
                      _buildFeatureItem(
                        icon: Icons.gpp_good_outlined,
                        label: 'Secure\n& Reliable',
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weigh Today\nBuild Tomorrow',
                      style: TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CustomPaint(
                      size: const Size(135, 14),
                      painter: ScriptUnderlinePainter(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  '© 2026 Viyan Weighbridge. All rights reserved.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    IconData? icon,
    Widget? customIcon,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customIcon != null)
            customIcon
          else if (icon != null)
            Icon(icon, size: 24, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

class _WeightSackIcon extends StatelessWidget {
  final double size;

  const _WeightSackIcon({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _WeightSackPainter()),
    );
  }
}

class _WeightSackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    canvas.drawArc(
      Rect.fromLTWH(w * 0.32, h * 0.08, w * 0.36, h * 0.28),
      3.14,
      3.14,
      false,
      stroke,
    );

    final path = Path();
    path.moveTo(w * 0.26, h * 0.36);
    path.lineTo(w * 0.74, h * 0.36);
    path.lineTo(w * 0.88, h * 0.88);
    path.lineTo(w * 0.12, h * 0.88);
    path.close();
    canvas.drawPath(path, stroke);

    canvas.drawLine(
      Offset(w * 0.5, h * 0.48),
      Offset(w * 0.5, h * 0.76),
      stroke,
    );
    final upArrow = Path()
      ..moveTo(w * 0.42, h * 0.56)
      ..lineTo(w * 0.50, h * 0.46)
      ..lineTo(w * 0.58, h * 0.56)
      ..close();
    canvas.drawPath(upArrow, fill);

    final downArrow = Path()
      ..moveTo(w * 0.42, h * 0.68)
      ..lineTo(w * 0.50, h * 0.78)
      ..lineTo(w * 0.58, h * 0.68)
      ..close();
    canvas.drawPath(downArrow, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
