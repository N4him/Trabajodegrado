import 'package:flutter/material.dart';
import '../../domain/models/breathing_mode.dart';

/// Vista para seleccionar el modo de respiración
class ModeSelectionView extends StatelessWidget {
  final Function(BreathingMode) onModeSelected;

  const ModeSelectionView({
    super.key,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.air,
                  size: 64,
                  color: Colors.purple[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Ejercicio de Respiración',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona un modo para comenzar',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Modos disponibles
          _buildModeCard(
            context,
            mode: BreathingMode.calmaRapida,
            icon: Icons.spa,
            color: Colors.blue,
            title: 'Calma Rápida',
            description: 'Box Breathing clásico: 4-4-4-4',
            duration: '6 ciclos • ~2 minutos',
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          _buildModeCard(
            context,
            mode: BreathingMode.enfoqueMental,
            icon: Icons.psychology,
            color: Colors.orange,
            title: 'Enfoque Mental',
            description: 'Respiración equilibrada: 5-5-5-5',
            duration: '8 ciclos • ~3 minutos',
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          _buildModeCard(
            context,
            mode: BreathingMode.relajacionProfunda,
            icon: Icons.self_improvement,
            color: Colors.purple,
            title: 'Relajación Profunda',
            description: 'Exhale extendida: 4-7-8',
            duration: '10 ciclos • ~4 minutos',
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Instrucciones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Toca la pantalla al final de cada fase para obtener puntos',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.amber[200] : Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required BreathingMode mode,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String duration,
    required bool isDark,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onModeSelected(mode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
