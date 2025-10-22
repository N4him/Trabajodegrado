import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/stop_game_bloc.dart';
import '../blocs/stop_game_event.dart';
import '../blocs/stop_game_state.dart';

/// Vista para seleccionar la acción a tomar
class ActionSelectionView extends StatelessWidget {
  final ActionState state;

  const ActionSelectionView({
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
              color: isDark ? Colors.grey[900] : Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  size: 48,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Procede',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Qué harás ahora?',
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

          // Progreso
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProgressIndicator(
                        icon: Icons.check_circle,
                        label: 'Respiración',
                        value: '${state.breathSuccesses}/4',
                        color: Colors.blue,
                      ),
                      _buildProgressIndicator(
                        icon: Icons.psychology,
                        label: 'Emoción',
                        value: state.emotion,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Acciones disponibles
          ...state.options.map((action) {
            final isSelected = action == state.chosen;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActionCard(
                context: context,
                action: action,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  context.read<StopGameBloc>().add(ActionChosen(action));
                },
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          // Información
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.green[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Elige una acción que te ayude a manejar lo que sientes',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.green[200] : Colors.green[900],
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

  Widget _buildProgressIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String action,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final actionIcons = {
      'Escribir en un diario': Icons.book_outlined,
      'Hablar con alguien': Icons.people_outline,
      'Respirar de nuevo': Icons.air,
      'Tomar un descanso': Icons.coffee_outlined,
    };

    final actionColors = {
      'Escribir en un diario': Colors.indigo,
      'Hablar con alguien': Colors.teal,
      'Respirar de nuevo': Colors.blue,
      'Tomar un descanso': Colors.amber,
    };

    final icon = actionIcons[action] ?? Icons.check_circle_outline;
    final color = actionColors[action] ?? Colors.grey;

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
                  action,
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
