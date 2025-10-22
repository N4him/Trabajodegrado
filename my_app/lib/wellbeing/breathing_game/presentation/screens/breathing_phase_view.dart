import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/breathing_game_bloc.dart';
import '../blocs/breathing_game_event.dart';
import '../blocs/breathing_game_state.dart';

const double _minSize = 100;
const double _maxSize = 200;
const double _threshold = 0.90;
const double _perfectThr = 0.95;
const double _barHeight = 200;
const double _barWidth = 12;

/// Vista de la fase de respiración en progreso
class BreathingPhaseView extends StatefulWidget {
  final PhaseInProgress state;

  const BreathingPhaseView({
    super.key,
    required this.state,
  });

  @override
  State<BreathingPhaseView> createState() => _BreathingPhaseViewState();
}

class _BreathingPhaseViewState extends State<BreathingPhaseView> {
  String? _feedbackText;

  void _handleTap() {
    final e = widget.state.elapsed;
    String result;
    if (e >= _perfectThr) {
      result = "¡Perfecto!";
    } else if (e >= _threshold) {
      result = "¡Bien!";
    } else {
      result = "Fallaste";
    }

    context.read<BreathingGameBloc>().add(TapPhase());
    setState(() => _feedbackText = result);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _feedbackText = null);
    });
  }

  String _phaseInstruction() {
    switch (widget.state.phase) {
      case BreathingPhase.inhale:
        return "Inhala";
      case BreathingPhase.hold:
        return "Retén";
      case BreathingPhase.exhale:
        return "Exhala";
      case BreathingPhase.holdEmpty:
        return "Retén (vacío)";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calcula el tamaño y color del círculo
    final double size = _calculateCircleSize();
    final Color color = _getPhaseColor();

    // Posición del thumb en la barra
    final double thumbPos = widget.state.elapsed * _barHeight;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra de progreso superior
          _buildProgressBar(isDark),

          const SizedBox(height: 24),

          // Área central con círculo y barra
          Expanded(
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Columna con instrucción, círculo + feedback
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Texto de instrucción de fase
                        Text(
                          _phaseInstruction(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Círculo animado
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.4),
                          ),
                        ),

                        const SizedBox(height: 24),
                        if (_feedbackText != null)
                          Text(
                            _feedbackText!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 32),

                    // Barra lateral con zonas y thumb
                    Container(
                      width: _barWidth,
                      height: _barHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Zona "Bien" (gris) del 0% al 90%
                          Positioned.fill(
                            top: (1 - _threshold) * _barHeight,
                            child: Container(color: Colors.grey.shade300),
                          ),
                          // Zona "Perfecto" (verde) del 90% al 95%
                          Positioned.fill(
                            top: (1 - _perfectThr) * _barHeight,
                            bottom: _threshold * _barHeight,
                            child: Container(color: Colors.greenAccent.withOpacity(0.6)),
                          ),
                          // Thumb indicador
                          Positioned(
                            bottom: thumbPos - 6,
                            left: -4,
                            child: Container(
                              width: _barWidth + 8,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Estadísticas inferiores
          _buildStatsCards(isDark),
        ],
      ),
    );
  }

  double _calculateCircleSize() {
    switch (widget.state.phase) {
      case BreathingPhase.inhale:
        return _minSize + (_maxSize - _minSize) * widget.state.elapsed;
      case BreathingPhase.hold:
        return _maxSize;
      case BreathingPhase.exhale:
        return _minSize + (_maxSize - _minSize) * (1 - widget.state.elapsed);
      case BreathingPhase.holdEmpty:
        return _minSize;
    }
  }

  Color _getPhaseColor() {
    switch (widget.state.phase) {
      case BreathingPhase.inhale:
        return Colors.lightBlueAccent;
      case BreathingPhase.hold:
        return Colors.greenAccent;
      case BreathingPhase.exhale:
        return Colors.purpleAccent;
      case BreathingPhase.holdEmpty:
        return Colors.grey;
    }
  }

  Widget _buildProgressBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ciclo ${widget.state.cycleCount + 1}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.state.successes} aciertos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600]),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.state.successes}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Puntaje',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange[600]),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.state.comboCount}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Combo',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
