import 'package:flutter/material.dart';
import '../../domain/entities/habit_progress.dart';
import '../widgets/weekly_trend_chart.dart';

class HabitDetailScreen extends StatelessWidget {
  final HabitProgress progress;

  const HabitDetailScreen({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(progress.habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implementar edición de hábito
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edición de hábito próximamente'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Editar hábito',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información principal
            _buildHeader(context),
            const SizedBox(height: 24),

            // Métricas principales
            _buildMetricsCards(),
            const SizedBox(height: 24),

            // Gráfico de tendencia
            WeeklyTrendChart(weeklyData: progress.monthlyTrend),
            const SizedBox(height: 24),

            // Estadísticas detalladas
            _buildDetailedStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji y nombre
            Row(
              children: [
                Text(
                  progress.progressEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.habit.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        progress.frequencyText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progreso semanal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso Semanal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${progress.completedThisWeek}/${progress.expectedThisWeek}',
                      style: TextStyle(
                        fontSize: 14,
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
                    minHeight: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estado semanal
            _buildStatusBadge(progress.weeklyStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.local_fire_department,
            label: 'Racha Actual',
            value: '${progress.currentStreak}',
            unit: progress.habit.frequencyDays == 7 ? 'días' : 'semanas',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            icon: Icons.emoji_events,
            label: 'Mejor Racha',
            value: '${progress.bestStreak}',
            unit: progress.habit.frequencyDays == 7 ? 'días' : 'semanas',
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatRow(
              label: 'Tasa de Éxito Global',
              value: '${progress.overallSuccessRate.toInt()}%',
              icon: Icons.trending_up,
            ),
            _StatRow(
              label: 'Completado Hoy',
              value: progress.isTodayCompleted ? 'Sí' : 'No',
              icon: progress.isTodayCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              valueColor: progress.isTodayCompleted ? Colors.green : Colors.grey,
            ),
            _StatRow(
              label: 'Fecha de Inicio',
              value:
                  '${progress.habit.startDate.day}/${progress.habit.startDate.month}/${progress.habit.startDate.year}',
              icon: Icons.calendar_today,
            ),
            if (progress.habit.reminderTime != null)
              _StatRow(
                label: 'Recordatorio',
                value: progress.habit.reminderTime!,
                icon: Icons.notifications,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(WeeklyStatus status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
            size: 16,
            color: statusInfo['color'],
          ),
          const SizedBox(width: 8),
          Text(
            statusInfo['text'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: statusInfo['color'],
            ),
          ),
        ],
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

  Map<String, dynamic> _getStatusInfo(WeeklyStatus status) {
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
          'text': 'Por debajo de la meta',
        };
    }
  }
}

/// Card para mostrar una métrica individual
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de estadística
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
