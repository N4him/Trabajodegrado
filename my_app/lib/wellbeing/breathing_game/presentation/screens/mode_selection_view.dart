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
              color: isDark
                  ? const Color(0xFF2e1a1f).withOpacity(0.9)
                  : const Color(0xFFFFE8E8).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.air,
                  size: 64,
                  color: const Color(0xFFFF9999),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ejercicios de Respiración',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Técnicas basadas en mindfullness',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

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
                Icon(Icons.stars, color: Colors.amber[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Durante el ejercicio aparecerán partículas flotantes. Recolecta las que puedas, pero recuerda: lo importante es respirar conscientemente.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.amber[200] : Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cyclic Sighing
          _buildModeCard(
            context,
            mode: BreathingMode.cyclicSighing,
            icon: Icons.self_improvement,
            color: const Color(0xFFFF9999),
            settings: breathingModes[BreathingMode.cyclicSighing]!,
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          // Box Breathing
          _buildModeCard(
            context,
            mode: BreathingMode.boxBreathing,
            icon: Icons.crop_square,
            color: const Color(0xFFFFAA88),
            settings: breathingModes[BreathingMode.boxBreathing]!,
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          // Cyclic Hyperventilation
          _buildModeCard(
            context,
            mode: BreathingMode.cyclicHyperventilation,
            icon: Icons.bolt,
            color: const Color(0xFFFFBB99),
            settings: breathingModes[BreathingMode.cyclicHyperventilation]!,
            isDark: isDark,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required BreathingMode mode,
    required IconData icon,
    required Color color,
    required BreathingSettings settings,
    required bool isDark,
  }) {
    // Calcular duración aproximada
    int totalSeconds = 0;
    if (settings.hasDoubleInhale) {
      totalSeconds = (settings.inhale + settings.secondInhale! + settings.exhale) * settings.cycles;
    } else {
      totalSeconds = (settings.inhale + settings.hold + settings.exhale + settings.holdEmpty) * settings.cycles;
    }
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final durationText = seconds > 0 ? '$minutes:${seconds.toString().padLeft(2, '0')} min' : '$minutes min';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onModeSelected(mode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      settings.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      settings.benefits,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${settings.cycles} ciclos',
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          durationText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
