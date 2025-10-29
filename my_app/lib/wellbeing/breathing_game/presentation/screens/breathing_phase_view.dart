import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/breathing_game_bloc.dart';
import '../blocs/breathing_game_event.dart';
import '../blocs/breathing_game_state.dart';

const double _minSize = 100;
const double _maxSize = 200;
const double _barHeight = 200;
const double _barWidth = 12;

class Particle {
  final int id;
  Offset position;
  final double size;
  final Color color;
  bool collected;
  double opacity;

  Particle({
    required this.id,
    required this.position,
    required this.size,
    required this.color,
    this.collected = false,
    this.opacity = 1.0,
  });
}

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

class _BreathingPhaseViewState extends State<BreathingPhaseView> with SingleTickerProviderStateMixin {
  final List<Particle> _particles = [];
  final Random _random = Random();
  Timer? _particleSpawnTimer;
  int _particleIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _startParticleSpawning();
  }

  @override
  void dispose() {
    _particleSpawnTimer?.cancel();
    super.dispose();
  }

  void _startParticleSpawning() {
    // Spawn una partícula cada 3-5 segundos
    _particleSpawnTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _spawnParticle();
      }
    });
  }

  void _spawnParticle() {
    final screenSize = MediaQuery.of(context).size;
    final particleSize = 30.0 + _random.nextDouble() * 20; // 30-50px

    // Posición aleatoria evitando bordes
    final x = 50 + _random.nextDouble() * (screenSize.width - 100);
    final y = 100 + _random.nextDouble() * (screenSize.height - 300);

    final particle = Particle(
      id: _particleIdCounter++,
      position: Offset(x, y),
      size: particleSize,
      color: _getRandomParticleColor(),
    );

    setState(() {
      _particles.add(particle);
    });

    // Incrementar contador total de partículas en el BLoC
    context.read<BreathingGameBloc>().incrementTotalParticles();

    // Auto-eliminar la partícula después de 6 segundos si no fue recolectada
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _particles.removeWhere((p) => p.id == particle.id && !p.collected);
        });
      }
    });
  }

  Color _getRandomParticleColor() {
    final colors = [
      Colors.yellowAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.lightBlueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _handleParticleTap(Particle particle) {
    if (!particle.collected) {
      setState(() {
        particle.collected = true;
      });

      context.read<BreathingGameBloc>().add(CollectParticle(particle.id));

      // Animar desaparición de la partícula
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _particles.removeWhere((p) => p.id == particle.id);
          });
        }
      });
    }
  }

  String _phaseInstruction() {
    switch (widget.state.phase) {
      case BreathingPhase.inhale:
        return "Inhala";
      case BreathingPhase.secondInhale:
        return "Segunda inhalación";
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

          // Área central con círculo, barra y partículas
          Expanded(
            child: Stack(
              children: [
                // Partículas flotantes
                ..._particles.map((particle) => _buildParticle(particle)),

                // Contenido principal
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Columna con instrucción y círculo
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
                      ],
                    ),

                    const SizedBox(width: 32),

                    // Barra lateral como indicador de progreso
                    Container(
                      width: _barWidth,
                      height: _barHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey.shade200,
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Barra de progreso
                          Positioned.fill(
                            top: (1 - widget.state.elapsed) * _barHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
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
              ],
            ),
          ),

          // Estadísticas inferiores
          _buildStatsCard(isDark),
        ],
      ),
    );
  }

  Widget _buildParticle(Particle particle) {
    return Positioned(
      left: particle.position.dx - particle.size / 2,
      top: particle.position.dy - particle.size / 2,
      child: GestureDetector(
        onTap: () => _handleParticleTap(particle),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: particle.collected ? 0.0 : particle.opacity,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: particle.collected ? 1.5 : 1.0,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: particle.color.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: particle.color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: particle.size * 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateCircleSize() {
    switch (widget.state.phase) {
      case BreathingPhase.inhale:
        return _minSize + (_maxSize - _minSize) * widget.state.elapsed;
      case BreathingPhase.secondInhale:
        // Ya está casi lleno, solo un pequeño incremento
        return _maxSize - 10 + (10 * widget.state.elapsed);
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
      case BreathingPhase.secondInhale:
        return Colors.cyanAccent;
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
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  '${widget.state.particlesCollected}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Icon(Icons.stars, color: Colors.amber[600], size: 32),
                const SizedBox(height: 8),
                Text(
                  '${widget.state.particlesCollected}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Recolectadas',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[300],
            ),
            Column(
              children: [
                Icon(Icons.remove_red_eye, color: Colors.blue[600], size: 32),
                const SizedBox(height: 8),
                Text(
                  '${widget.state.totalParticles}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total aparecidas',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
