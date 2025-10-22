import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/stop_game_bloc.dart';
import '../blocs/stop_game_event.dart';
import '../blocs/stop_game_state.dart';

/// Vista de respiración con círculo animado
class BreathingView extends StatefulWidget {
  final BreathingState state;

  const BreathingView({
    super.key,
    required this.state,
  });

  @override
  State<BreathingView> createState() => _BreathingViewState();
}

class _BreathingViewState extends State<BreathingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const double minScale = 0.5;
  static const double maxScale = 1.0;
  static const double successThreshold = 0.9;
  String? _feedbackText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: minScale,
      upperBound: maxScale,
    )
      ..addListener(() => setState(() {}))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final ok = _controller.value >= successThreshold;

    setState(() {
      _feedbackText = ok ? "¡Bien!" : "Fallaste";
    });

    context.read<StopGameBloc>().add(BreatheTapped(ok));

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _feedbackText = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_controller.value - minScale) / (maxScale - minScale);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra de progreso
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ronda ${widget.state.round} de 4',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.state.successes} aciertos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Instrucción
          Text(
            'Respira profundamente',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            progress < 0.5 ? 'Inhala...' : 'Exhala...',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),

          const Spacer(),

          // Círculo animado
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: 200 * _controller.value,
              height: 200 * _controller.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'TAP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Feedback
          if (_feedbackText != null)
            Text(
              _feedbackText!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _feedbackText == "¡Bien!" ? Colors.green : Colors.red,
              ),
            )
          else
            const SizedBox(height: 32),

          const Spacer(),

          // Instrucción inferior
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
                    'Toca cuando el círculo esté en su punto máximo',
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
}
