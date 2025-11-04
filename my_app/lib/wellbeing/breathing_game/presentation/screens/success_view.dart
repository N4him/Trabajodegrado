import 'package:flutter/material.dart';
import '../../domain/models/breathing_mode.dart';

// Color principal
const Color primaryColor = Color(0xFFAFB99B);

/// Vista de éxito al completar una sesión de respiración
class SuccessView extends StatelessWidget {
  final BreathingMode mode;
  final int particlesCollected;
  final int totalParticles;
  final int cyclesCompleted;
  final int durationSeconds;
  final VoidCallback onFinish;

  const SuccessView({
    super.key,
    required this.mode,
    required this.particlesCollected,
    required this.totalParticles,
    required this.cyclesCompleted,
    required this.durationSeconds,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = breathingModes[mode]!;
    final collectionRate = totalParticles > 0 ? (particlesCollected / totalParticles * 100).round() : 0;

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
              color: primaryColor.withOpacity(0.2),
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: primaryColor,
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
              color: primaryColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Tarjeta de porcentaje de recolección
          Card(
            color: _getCollectionColor(collectionRate).withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _getCollectionColor(collectionRate).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '$collectionRate%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getCollectionColor(collectionRate),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tasa de recolección',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPerformanceFeedback(collectionRate),
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
                  color: primaryColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.repeat,
                  value: '$cyclesCompleted',
                  label: 'Ciclos',
                  color: const Color(0xFF9CA986), // Variación más oscura
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
                  icon: Icons.stars,
                  value: '$particlesCollected',
                  label: 'Recolectadas',
                  color: const Color(0xFFC5D1B0), // Variación más clara
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.remove_red_eye,
                  value: '$totalParticles',
                  label: 'Total aparecidas',
                  color: primaryColor.withOpacity(0.7),
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
              color: primaryColor.withOpacity(0.15),
              border: Border.all(color: primaryColor.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Ganaste 1 punto de bienestar!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? primaryColor.withOpacity(0.9) : const Color(0xFF7A8468),
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
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
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

  Color _getCollectionColor(int collectionRate) {
    if (collectionRate >= 70) return primaryColor;
    if (collectionRate >= 40) return const Color(0xFF9CA986); // Variación más oscura
    return const Color(0xFFC5D1B0); // Variación más clara
  }

  String _getPerformanceFeedback(int collectionRate) {
    if (collectionRate >= 70) return "¡Excelente concentración y atención!";
    if (collectionRate >= 40) return "Buen trabajo, mantén el ritmo.";
    return "Recuerda que recolectar es opcional, lo importante es respirar.";
  }
}