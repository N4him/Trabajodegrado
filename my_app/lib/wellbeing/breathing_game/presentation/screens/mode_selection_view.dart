import 'package:flutter/material.dart';
import '../../domain/models/breathing_mode.dart';

// Color principal
const Color primaryColor = Color(0xFFAFB99B);

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

    return Container(
      color: const Color(0xFFF5F7F3), // Mismo color de fondo que WellbeingHomeScreen
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.air,
                    size: 64,
                    color: primaryColor,
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
                color: primaryColor.withOpacity(0.1),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars, color: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Durante el ejercicio aparecerán partículas flotantes. Recolecta las que puedas, pero recuerda: lo importante es respirar conscientemente.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? primaryColor.withOpacity(0.9) : const Color(0xFF7A8468),
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
              color: primaryColor,
              settings: breathingModes[BreathingMode.cyclicSighing]!,
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // Box Breathing
            _buildModeCard(
              context,
              mode: BreathingMode.boxBreathing,
              icon: Icons.crop_square,
              color: const Color(0xFF9CA986), // Variación más oscura
              settings: breathingModes[BreathingMode.boxBreathing]!,
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // Cyclic Hyperventilation
            _buildModeCard(
              context,
              mode: BreathingMode.cyclicHyperventilation,
              icon: Icons.bolt,
              color: const Color(0xFFC5D1B0), // Variación más clara
              settings: breathingModes[BreathingMode.cyclicHyperventilation]!,
              isDark: isDark,
            ),

            const SizedBox(height: 24),
          ],
        ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
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
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.4),
                    width: 2,
                  ),
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
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 1,
                            ),
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
                        Icon(Icons.access_time, size: 14, color: color.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          durationText,
                          style: TextStyle(
                            fontSize: 12,
                            color: color.withOpacity(0.8),
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
                color: color.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}