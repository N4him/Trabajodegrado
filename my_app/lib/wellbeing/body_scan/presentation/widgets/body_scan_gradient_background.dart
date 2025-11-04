import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget de fondo con color principal #afb99b para el body scan
class BodyScanGradientBackground extends StatelessWidget {
  final Widget child;

  // Color principal
  static const Color primaryColor = Color(0xFFAFB99B);

  const BodyScanGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Fondo sólido
        Container(
          color: isDark ? Colors.grey[900] : Colors.grey[50],
        ),

        // Decoraciones - Círculos grandes difuminados
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withOpacity(isDark ? 0.1 : 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withOpacity(isDark ? 0.1 : 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 200,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withOpacity(isDark ? 0.08 : 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Ondas decorativas
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(double.infinity, 150),
            painter: BodyScanWavesPainter(isDark: isDark),
          ),
        ),

        // Contenido
        child,
      ],
    );
  }
}

/// Painter personalizado para ondas decorativas del body scan
class BodyScanWavesPainter extends CustomPainter {
  final bool isDark;
  static const Color primaryColor = Color(0xFFAFB99B);

  BodyScanWavesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = primaryColor.withOpacity(isDark ? 0.05 : 0.1)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = primaryColor.withOpacity(isDark ? 0.03 : 0.08)
      ..style = PaintingStyle.fill;

    // Primera onda
    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(
        i,
        size.height * 0.3 + math.sin((i / size.width) * 4 * math.pi) * 20,
      );
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Segunda onda
    final path2 = Path();
    path2.moveTo(0, size.height * 0.5);
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.5 + math.cos((i / size.width) * 3 * math.pi) * 25,
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}