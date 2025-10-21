import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;

/// Widget animado que representa la planta del usuario con Rive
/// Incluye imagen de fondo y card de información
class PlantaAnimationWidget extends StatefulWidget {
  final double plantaValor; // 0.0 a 100.0
  final int salud; // 0 a 100
  final String etapa; // 'semilla', 'brote', 'planta', 'arbol'
  final double size;

  const PlantaAnimationWidget({
    super.key,
    required this.plantaValor,
    required this.salud,
    required this.etapa,
    this.size = 200.0,
  });

  @override
  State<PlantaAnimationWidget> createState() => _PlantaAnimationWidgetState();
}

class _PlantaAnimationWidgetState extends State<PlantaAnimationWidget> {
  Artboard? _riveArtboard;
  StateMachineController? _stateMachineController;
  SMIInput? _growthInput;
  late double _currentValue;
  Timer? _growthTimer;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.plantaValor;
    _initializeRive();
  }

  Future<void> _initializeRive() async {
    try {
      // Cargar el archivo .riv usando rootBundle
      final data = await rootBundle.load('assets/tree_demo (3).riv');
      final file = RiveFile.import(data);

      // Obtener el artboard según la etapa
      final artboardName = _getArtboardName(widget.etapa);
      final artboard = file.artboardByName(artboardName) ?? file.mainArtboard;

      // Obtener el State Machine Controller
      _stateMachineController = StateMachineController.fromArtboard(
        artboard,
        'Grow', // Nombre del State Machine en Rive
      );

      if (_stateMachineController != null) {
        artboard.addController(_stateMachineController!);

        // Obtener el input como double (SMINumber en Rive es double)
        _growthInput = _stateMachineController!.findInput<double>('input');
        
        // Establecer valor inicial usando plantaValor
        if (_growthInput != null) {
          _growthInput!.value = widget.plantaValor;
        }
      }

      setState(() {
        _riveArtboard = artboard;
      });
    // ignore: empty_catches
    } catch (e) {
    }
  }

  String _getArtboardName(String etapa) {
    switch (etapa) {
      case 'semilla':
        return 'Semilla';
      case 'brote':
        return 'Brote';
      case 'planta':
        return 'Planta';
      case 'arbol':
        return 'Arbol';
      default:
        return 'Semilla';
    }
  }

  @override
  void didUpdateWidget(PlantaAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambió plantaValor, animar el crecimiento/decrecimiento
    if (oldWidget.plantaValor != widget.plantaValor) {
      _animateGrowth(oldWidget.plantaValor, widget.plantaValor);
    }

    // Si cambió la etapa, reinicializar
    if (oldWidget.etapa != widget.etapa) {
      _growthTimer?.cancel();
      _stateMachineController?.dispose();
      _initializeRive();
    }
  }

  void _animateGrowth(double oldValue, double newValue) {
    // Cancelar cualquier animación anterior
    _growthTimer?.cancel();
    
    // Determinar si es crecimiento o decrecimiento
    final isGrowing = newValue > oldValue;
    final step = isGrowing ? 1.0 : -1.0;
    
    // Crear timer que incrementa/decrementa de 1 en 1
    _growthTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (isGrowing) {
          // Crecimiento: sumar 1 hasta llegar al nuevo valor
          if (_currentValue < newValue) {
            _currentValue += step;
            if (_currentValue > newValue) {
              _currentValue = newValue;
            }
          } else {
            timer.cancel();
          }
        } else {
          // Decrecimiento: restar 1 hasta llegar al nuevo valor
          if (_currentValue > newValue) {
            _currentValue += step;
            if (_currentValue < newValue) {
              _currentValue = newValue;
            }
          } else {
            timer.cancel();
          }
        }
        
        // Actualizar el input de Rive
        _growthInput?.value = _currentValue;
      });
    });
  }

  @override
  void dispose() {
    _growthTimer?.cancel();
    _stateMachineController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo de imagen ocupando todo el espacio
        Positioned.fill(
          child: Image.asset(
            'assets/images/arboles (1).png',
            fit: BoxFit.cover,
          ),
        ),
        // Árbol posicionado más arriba
        Positioned(
          top: -95, // Ajusta este valor para mover más arriba o abajo
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: widget.size * 3.8,
              height: widget.size * 3.5,
              child: _riveArtboard != null
                  ? Rive(artboard: _riveArtboard!)
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ),
        // Card de información compacta en la parte inferior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildInfoCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B8E6B),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A7C59).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Icono de etapa
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C59),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getEtapaIcon(),
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            // Nombre de etapa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getEtapaName(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A3D),
                    ),
                  ),
                  Text(
                    _getEtapaDescription(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B8E6B),
                    ),
                  ),
                ],
              ),
            ),
            // Estadísticas compactas
            _buildMiniStat(
              'Crec.',
              widget.plantaValor,
              Icons.trending_up,
              const Color(0xFF4A7C59),
            ),
            const SizedBox(width: 8),
            _buildMiniStat(
              'Salud',
              widget.salud.toDouble(),
              Icons.favorite,
              const Color(0xFF6B8E6B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(height: 2),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getEtapaDescription() {
    switch (widget.etapa) {
      case 'semilla':
        return 'Inicio del crecimiento';
      case 'brote':
        return 'Primeras hojas';
      case 'planta':
        return 'En desarrollo';
      case 'arbol':
        return 'Totalmente desarrollado';
      default:
        return 'Estado desconocido';
    }
  }

  IconData _getEtapaIcon() {
    switch (widget.etapa) {
      case 'semilla':
        return Icons.circle;
      case 'brote':
        return Icons.eco;
      case 'planta':
        return Icons.local_florist;
      case 'arbol':
        return Icons.park;
      default:
        return Icons.eco;
    }
  }

  String _getEtapaName() {
    switch (widget.etapa) {
      case 'semilla':
        return 'Semilla';
      case 'brote':
        return 'Brote';
      case 'planta':
        return 'Planta';
      case 'arbol':
        return 'Árbol';
      default:
        return 'Desconocido';
    }
  }
}