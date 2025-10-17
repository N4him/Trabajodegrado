import 'package:flutter/material.dart';
import '../../domain/entities/habit_progress.dart';

/// Widget que muestra el progreso de un hábito con métricas visuales
class HabitProgressCard extends StatelessWidget {
  final HabitProgress progress;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const HabitProgressCard({
    super.key,
    required this.progress,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nombre y emoji de progreso
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          progress.progressEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                progress.habit.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                progress.frequencyText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón de completar
                  IconButton(
                    icon: Icon(
                      progress.isTodayCompleted
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: progress.isTodayCompleted
                          ? Colors.green
                          : Colors.grey,
                    ),
                    onPressed: progress.isTodayCompleted ? null : onComplete,
                    tooltip: progress.isTodayCompleted
                        ? 'Completado hoy'
                        : 'Marcar como completado',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de progreso semanal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso Semanal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${progress.completedThisWeek}/${progress.expectedThisWeek}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(progress.weeklyStatus),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.weeklyCompletionRate / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(progress.weeklyStatus),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Métricas en fila
              Row(
                children: [
                  // Racha actual
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.local_fire_department,
                      label: 'Racha',
                      value: '${progress.currentStreak}',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mejor racha
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.emoji_events,
                      label: 'Mejor',
                      value: '${progress.bestStreak}',
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tasa global
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.trending_up,
                      label: 'Global',
                      value: '${progress.overallSuccessRate.toInt()}%',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Estado semanal
              _WeeklyStatusBadge(status: progress.weeklyStatus),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(WeeklyStatus status) {
    switch (status) {
      case WeeklyStatus.onTrack:
        return Colors.green;
      case WeeklyStatus.atRisk:
        return Colors.orange;
      case WeeklyStatus.behind:
        return Colors.red;
    }
  }
}

/// Chip pequeño para mostrar una métrica
class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge que muestra el estado semanal
class _WeeklyStatusBadge extends StatelessWidget {
  final WeeklyStatus status;

  const _WeeklyStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'],
            size: 14,
            color: statusInfo['color'],
          ),
          const SizedBox(width: 6),
          Text(
            statusInfo['text'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusInfo['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo() {
    switch (status) {
      case WeeklyStatus.onTrack:
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'text': 'Cumpliendo meta',
        };
      case WeeklyStatus.atRisk:
        return {
          'color': Colors.orange,
          'icon': Icons.warning,
          'text': 'En riesgo',
        };
      case WeeklyStatus.behind:
        return {
          'color': Colors.red,
          'icon': Icons.error,
          'text': 'Por debajo',
        };
    }
  }
}
