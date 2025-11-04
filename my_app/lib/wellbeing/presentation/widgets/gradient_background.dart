import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget de fondo con gradiente y decoraciones para el módulo de wellbeing
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Gradiente de fondo con tonos del ajolote (rosado, coral, salmón)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF2e1a1f), // Rosa oscuro
                      const Color(0xFF2e241a), // Coral oscuro
                      const Color(0xFF2e1f1a), // Salmón oscuro
                    ]
                  : [
                      const Color(0xFFFFE8E8), // Rosa muy claro
                      const Color(0xFFFFE4D6), // Coral muy claro
                      const Color(0xFFFFF0E0), // Salmón/Melocotón muy claro
                    ],
            ),
          ),
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
                colors: isDark
                    ? [
                        const Color(0xFFFF9999).withOpacity(0.15),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFFFFB6B6).withOpacity(0.25),
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
                colors: isDark
                    ? [
                        const Color(0xFFFFAA88).withOpacity(0.15),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFFFFCC99).withOpacity(0.25),
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
                colors: isDark
                    ? [
                        const Color(0xFFFFBB99).withOpacity(0.1),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFFFFDDCC).withOpacity(0.2),
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
            painter: WavesPainter(isDark: isDark),
          ),
        ),

        // Contenido
        child,
      ],
    );
  }
}

/// Painter personalizado para ondas decorativas
class WavesPainter extends CustomPainter {
  final bool isDark;

  WavesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = isDark
          ? const Color(0xFFFF9999).withOpacity(0.08)
          : const Color(0xFFFFB6B6).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = isDark
          ? const Color(0xFFFFAA88).withOpacity(0.05)
          : const Color(0xFFFFCC99).withOpacity(0.12)
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
