import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../blocs/quest_map_bloc.dart';
import '../blocs/quest_map_event.dart';
import '../blocs/quest_map_state.dart';

/// Vista para ingresar respuestas de cada sentido
class SenseInputView extends StatefulWidget {
  final ExploringSense state;

  const SenseInputView({
    super.key,
    required this.state,
  });

  @override
  State<SenseInputView> createState() => _SenseInputViewState();
}

class _SenseInputViewState extends State<SenseInputView> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _hintTimer;
  bool _showHint = false;

  late AnimationController _particleController;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _startHintTimer();

    // Animación de partículas
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _hintTimer?.cancel();
    _particleController.dispose();
    super.dispose();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    setState(() => _showHint = false);

    _hintTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && widget.state.currentAnswers.isEmpty) {
        setState(() => _showHint = true);
      }
    });
  }

  void _addAnswer() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<QuestMapBloc>().add(AddAnswer(text));
    _textController.clear();
    _focusNode.requestFocus();

    // Reiniciar timer de hint
    _startHintTimer();

    // Mostrar animación de partículas
    _particleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final senseColor = _getSenseColor(widget.state.currentSense);

    return Stack(
      children: [
        // Contenido principal
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progreso del conejito
              _buildBunnyProgress(),

              const SizedBox(height: 24),

              // Pregunta del sentido
              Card(
                color: senseColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        _getSenseIcon(widget.state.currentSense),
                        size: 48,
                        color: senseColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.state.currentSense.question,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nombra ${widget.state.currentSense.requiredAnswers} ${widget.state.currentSense.requiredAnswers == 1 ? "cosa" : "cosas"}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Círculos de progreso
              _buildProgressCircles(senseColor),

              const SizedBox(height: 24),

              // Campo de entrada
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu respuesta...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: senseColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: senseColor, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _addAnswer(),
                      enabled: !widget.state.isCurrentSenseComplete,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: widget.state.isCurrentSenseComplete ? null : _addAnswer,
                    backgroundColor: senseColor,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Hint si se quedan atascados
              if (_showHint && widget.state.currentAnswers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.state.currentSense.hint,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.blue[200] : Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Lista de respuestas
              if (widget.state.currentAnswers.isNotEmpty) ...[
                Text(
                  'Tus respuestas:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  widget.state.currentAnswers.length,
                  (index) => _buildAnswerCard(
                    widget.state.currentAnswers[index],
                    index,
                    senseColor,
                    isDark,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botón continuar
              if (widget.state.isCurrentSenseComplete)
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<QuestMapBloc>().add(CompleteSense());
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    widget.state.currentSense == SenseType.taste
                        ? 'Finalizar'
                        : 'Continuar',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: senseColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),

        // Efecto de partículas
        if (_particleAnimation.value > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ParticlePainter(
                  animation: _particleAnimation.value,
                  color: senseColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBunnyProgress() {
    final totalSteps = 5;
    final currentStepIndex = SenseType.values.indexOf(widget.state.currentSense);

    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          // Línea de progreso
          Positioned(
            left: 20,
            right: 20,
            top: 38,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Línea completada
          Positioned(
            left: 20,
            right: 20 + (MediaQuery.of(context).size.width - 40) * (1 - currentStepIndex / (totalSteps - 1)),
            top: 38,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Círculos de pasos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStepIndex;
              final isCurrent = index == currentStepIndex;

              return Column(
                children: [
                  if (isCurrent)
                    const Text('🐰', style: TextStyle(fontSize: 32)),
                  if (!isCurrent)
                    const SizedBox(height: 32),
                  const SizedBox(height: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? Colors.green
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? Colors.green[700]! : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? Colors.white : Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircles(Color color) {
    final required = widget.state.currentSense.requiredAnswers;
    final current = widget.state.currentAnswers.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(required, (index) {
        final isFilled = index < current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? color : Colors.grey[300],
              boxShadow: isFilled
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: isFilled
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnswerCard(String answer, int index, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: color.withOpacity(0.1),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            answer,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.state.isCurrentSenseComplete
                ? null
                : () => context.read<QuestMapBloc>().add(RemoveAnswer(index)),
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

/// Painter para efecto de partículas
class ParticlePainter extends CustomPainter {
  final double animation;
  final Color color;

  ParticlePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6 * (1 - animation))
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 3;

    // Dibujar partículas que se expanden
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * 3.14159;
      final distance = animation * 100;
      final x = centerX + distance * cos(angle);
      final y = centerY + distance * sin(angle);
      final radius = 4 * (1 - animation);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  double cos(double radians) => radians.cos();
  double sin(double radians) => radians.sin();
}

extension on double {
  double cos() {
    return (this == 0) ? 1 : 0; // Simplified for demo
  }

  double sin() {
    return (this == 0) ? 0 : 1; // Simplified for demo
  }
}
