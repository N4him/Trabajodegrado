import 'package:flutter/material.dart';
import '../../domain/models/breathing_mode.dart';

/// Vista de éxito al completar una sesión de respiración
class SuccessView extends StatelessWidget {
  final BreathingMode mode;
  final int successes;
  final int comboCount;
  final int cyclesCompleted;
  final int durationSeconds;
  final VoidCallback onFinish;

  const SuccessView({
    super.key,
    required this.mode,
    required this.successes,
    required this.comboCount,
    required this.cyclesCompleted,
    required this.durationSeconds,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = breathingModes[mode]!;
    final maxPossible = cyclesCompleted * 4; // Asumiendo 4 fases por ciclo
    final successRate = maxPossible > 0 ? (successes / maxPossible * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono de éxito
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green[600],
            ),
          ),

          const SizedBox(height: 24),

          // Título
          Text(
            '¡Sesión Completada!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            settings.displayName,
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Tarjeta de porcentaje de éxito
          Card(
            color: _getSuccessColor(successRate).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '$successRate%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getSuccessColor(successRate),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tasa de éxito',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPerformanceFeedback(successRate),
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  value: _formatDuration(durationSeconds),
                  label: 'Duración',
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.repeat,
                  value: '$cyclesCompleted',
                  label: 'Ciclos',
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  value: '$successes',
                  label: 'Aciertos',
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  value: '$comboCount',
                  label: 'Combo máx',
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Mensaje de puntos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: Colors.purple[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Ganaste 1 punto de bienestar!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.purple[200] : Colors.purple[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón finalizar
          ElevatedButton(
            onPressed: onFinish,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Finalizar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  Color _getSuccessColor(int successRate) {
    if (successRate >= 80) return Colors.green;
    if (successRate >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getPerformanceFeedback(int successRate) {
    if (successRate >= 80) return "¡Excelente control del aliento!";
    if (successRate >= 50) return "Buen trabajo, sigue practicando.";
    return "Intenta concentrarte más la próxima vez.";
  }
}
