import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quest_map_bloc.dart';
import '../blocs/quest_map_event.dart';
import '../blocs/quest_map_state.dart';

/// Vista de pausa de respiración entre sentidos
class BreathingPauseView extends StatefulWidget {
  final BreathingPause state;

  const BreathingPauseView({
    super.key,
    required this.state,
  });

  @override
  State<BreathingPauseView> createState() => _BreathingPauseViewState();
}

class _BreathingPauseViewState extends State<BreathingPauseView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.indigo.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mensaje de completado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.state.justCompletedSense.name} completado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.green[200] : Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Círculo de respiración animado
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  final isInhaling = _controller.value < 0.5;

                  return Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.blue.withOpacity(0.3),
                              Colors.purple.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[300],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.5),
                                    blurRadius: 30 * _scaleAnimation.value,
                                    spreadRadius: 10 * _scaleAnimation.value,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.air,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isInhaling ? 'Inhala...' : 'Exhala...',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // Instrucciones
              Text(
                'Toma un momento para respirar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Respira profundamente a tu propio ritmo.\nCuando estés listo, continúa al siguiente sentido.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Próximo sentido
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Siguiente:',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSenseIcon(widget.state.nextSense),
                          color: _getSenseColor(widget.state.nextSense),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.state.nextSense.question,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botón continuar
              ElevatedButton.icon(
                onPressed: () {
                  context.read<QuestMapBloc>().add(CompleteBreathingPause());
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getSenseColor(widget.state.nextSense),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSenseColor(SenseType sense) {
    switch (sense) {
      case SenseType.sight:
        return Colors.blue;
      case SenseType.touch:
        return Colors.green;
      case SenseType.sound:
        return Colors.orange;
      case SenseType.smell:
        return Colors.purple;
      case SenseType.taste:
        return Colors.pink;
    }
  }

  IconData _getSenseIcon(SenseType sense) {
    switch (sense) {
      case SenseType.sight:
        return Icons.visibility;
      case SenseType.touch:
        return Icons.touch_app;
      case SenseType.sound:
        return Icons.hearing;
      case SenseType.smell:
        return Icons.air;
      case SenseType.taste:
        return Icons.restaurant;
    }
  }
}
