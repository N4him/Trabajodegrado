import 'package:flutter/material.dart';
import '../blocs/stop_game_state.dart';

/// Vista de éxito al completar el STOP game
class SuccessView extends StatelessWidget {
  final SessionSaved state;

  const SuccessView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final breathRate = (state.breathSuccesses / 4) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Icono de éxito
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green[600],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título
          Text(
            '¡Sesión completada!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Has ganado 1 punto de bienestar',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Resumen de la sesión
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de tu sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Respiración
                  _buildSummaryRow(
                    icon: Icons.air,
                    iconColor: Colors.blue,
                    label: 'Respiración',
                    value: '${state.breathSuccesses}/4 aciertos',
                    subtitle: '${breathRate.toStringAsFixed(0)}% de precisión',
                  ),

                  const Divider(height: 24),

                  // Emoción identificada
                  _buildSummaryRow(
                    icon: Icons.psychology,
                    iconColor: Colors.orange,
                    label: 'Emoción identificada',
                    value: state.emotion,
                  ),

                  const Divider(height: 24),

                  // Acción elegida
                  _buildSummaryRow(
                    icon: Icons.play_arrow_rounded,
                    iconColor: Colors.green,
                    label: 'Acción a tomar',
                    value: state.action,
                  ),

                  const Divider(height: 24),

                  // Duración
                  _buildSummaryRow(
                    icon: Icons.timer_outlined,
                    iconColor: Colors.purple,
                    label: 'Duración',
                    value: _formatDuration(state.durationSeconds),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mensaje motivacional
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.2),
                  Colors.blue.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.green[700],
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getMotivationalMessage(breathRate),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón para volver
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.home),
            label: const Text('Volver al inicio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botón secundario
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Hacer otra sesión'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes min $secs seg';
    }
    return '$secs segundos';
  }

  String _getMotivationalMessage(double breathRate) {
    if (breathRate >= 75) {
      return '¡Excelente trabajo! Has logrado una gran conexión con tu respiración.';
    } else if (breathRate >= 50) {
      return '¡Bien hecho! Cada práctica te acerca más a la calma interior.';
    } else {
      return '¡Gran primer paso! La práctica hace al maestro. Sigue intentando.';
    }
  }
}
