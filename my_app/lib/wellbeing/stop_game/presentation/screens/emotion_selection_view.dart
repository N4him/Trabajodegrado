import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/stop_game_bloc.dart';
import '../blocs/stop_game_event.dart';
import '../blocs/stop_game_state.dart';

/// Vista para seleccionar la emoción identificada
class EmotionSelectionView extends StatelessWidget {
  final EmotionState state;

  const EmotionSelectionView({
    super.key,
    required this.state,
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
              color: isDark ? Colors.grey[900] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.visibility,
                  size: 48,
                  color: Colors.orange[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Observa tus emociones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Qué estás sintiendo ahora?',
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

          // Estadística de respiración
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Respiración: ${state.breathSuccesses}/4 aciertos',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Emociones disponibles
          ...state.availableEmotions.map((emotion) {
            final isSelected = emotion == state.selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEmotionCard(
                context: context,
                emotion: emotion,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  context.read<StopGameBloc>().add(EmotionIdentified(emotion));
                },
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          // Información
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay emociones buenas o malas, solo experiencias',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.blue[200] : Colors.blue[900],
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

  Widget _buildEmotionCard({
    required BuildContext context,
    required String emotion,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final emotionIcons = {
      'Ansiedad': Icons.psychology_outlined,
      'Ira': Icons.whatshot,
      'Tristeza': Icons.cloud,
      'Alegría': Icons.sentiment_satisfied_alt,
      'Calma': Icons.spa,
    };

    final emotionColors = {
      'Ansiedad': Colors.purple,
      'Ira': Colors.red,
      'Tristeza': Colors.blue,
      'Alegría': Colors.yellow,
      'Calma': Colors.green,
    };

    final icon = emotionIcons[emotion] ?? Icons.circle;
    final color = emotionColors[emotion] ?? Colors.grey;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  emotion,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
