import 'package:flutter/material.dart';
import '../../domain/entities/habit_progress.dart';

/// Widget que muestra un gráfico de líneas de la tendencia semanal
class WeeklyTrendChart extends StatelessWidget {
  final List<WeeklyProgress> weeklyData;

  const WeeklyTrendChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return const Center(
        child: Text(
          'Sin datos suficientes para mostrar tendencia',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Tendencia Mensual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Últimas ${weeklyData.length} semanas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Gráfico de líneas
            SizedBox(
              height: 200,
              child: _LineChart(weeklyData: weeklyData),
            ),

            const SizedBox(height: 16),

            // Leyenda de semanas
            _buildWeekLabels(),

            const SizedBox(height: 16),

            // Insight
            _buildInsight(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weeklyData.asMap().entries.map((entry) {
        final index = entry.key;
        final week = entry.value;
        return Expanded(
          child: Column(
            children: [
              Text(
                week.getWeekLabel(index),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${week.completed}/${week.expected}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsight() {
    if (weeklyData.length < 2) return const SizedBox.shrink();

    final lastWeek = weeklyData.last.completionRate;
    final previousWeek = weeklyData[weeklyData.length - 2].completionRate;
    final difference = lastWeek - previousWeek;

    String emoji;
    String message;
    Color color;

    if (difference > 10) {
      emoji = '🎉';
      message = '¡Vas mejorando! Aumentaste ${difference.toInt()}%';
      color = Colors.green;
    } else if (difference < -10) {
      emoji = '⚠️';
      message = 'Bajaste ${difference.abs().toInt()}%. ¡No te rindas!';
      color = Colors.orange;
    } else {
      emoji = '💪';
      message = 'Te mantienes consistente';
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color.darken(0.3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que dibuja el gráfico de líneas
class _LineChart extends StatelessWidget {
  final List<WeeklyProgress> weeklyData;

  const _LineChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LineChartPainter(weeklyData: weeklyData),
        );
      },
    );
  }
}

/// Painter que dibuja el gráfico de líneas
class _LineChartPainter extends CustomPainter {
  final List<WeeklyProgress> weeklyData;

  _LineChartPainter({required this.weeklyData});

  @override
  void paint(Canvas canvas, Size size) {
    if (weeklyData.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final areaPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Margen para el texto y los puntos
    const padding = 30.0;
    final chartHeight = size.height - padding;
    final chartWidth = size.width;
    final segmentWidth = chartWidth / (weeklyData.length - 1);

    // Dibujar líneas de cuadrícula horizontales (0%, 25%, 50%, 75%, 100%)
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    for (int i = 0; i <= 4; i++) {
      final y = chartHeight - (chartHeight * i / 4);
      final percentage = i * 25;

      // Línea de cuadrícula
      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint,
      );

      // Etiqueta de porcentaje
      textPainter.text = TextSpan(
        text: '$percentage%',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width - 4, y - textPainter.height / 2),
      );
    }

    // Crear path para la línea y el área
    final linePath = Path();
    final areaPath = Path();
    final points = <Offset>[];

    // Calcular puntos
    for (int i = 0; i < weeklyData.length; i++) {
      final x = i * segmentWidth;
      final percentage = weeklyData[i].completionRate;
      final y = chartHeight - (chartHeight * (percentage / 100));

      points.add(Offset(x, y));

      if (i == 0) {
        linePath.moveTo(x, y);
        areaPath.moveTo(x, chartHeight);
        areaPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }

    // Completar el área
    areaPath.lineTo(points.last.dx, chartHeight);
    areaPath.close();

    // Dibujar área bajo la línea
    canvas.drawPath(areaPath, areaPaint);

    // Dibujar línea principal
    canvas.drawPath(linePath, paint);

    // Dibujar puntos y porcentajes
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final percentage = weeklyData[i].completionRate;

      // Color del punto según el porcentaje
      final pointColor = _getColorForPercentage(percentage);
      dotPaint.color = pointColor;

      // Dibujar borde blanco del punto
      canvas.drawCircle(point, 6, dotBorderPaint);

      // Dibujar punto
      canvas.drawCircle(point, 5, dotPaint);

      // Dibujar porcentaje arriba del punto
      textPainter.text = TextSpan(
        text: '${percentage.toInt()}%',
        style: TextStyle(
          color: pointColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, point.dy - 20),
      );
    }
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Extension para oscurecer colores
extension ColorExtension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}
