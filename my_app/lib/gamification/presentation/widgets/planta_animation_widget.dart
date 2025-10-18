import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

/// Widget animado que representa la planta del usuario con Rive
/// Se actualiza según plantaValor y salud del EstadoGeneral
class PlantaAnimationWidget extends StatefulWidget {
  final double plantaValor; // 0.0 a 100.0
  final int salud; // 0 a 100
  final String etapa; // 'semilla', 'brote', 'planta', 'arbol'
  final double size;

  const PlantaAnimationWidget({
    Key? key,
    required this.plantaValor,
    required this.salud,
    required this.etapa,
    this.size = 200.0,
  }) : super(key: key);

  @override
  State<PlantaAnimationWidget> createState() => _PlantaAnimationWidgetState();
}

class _PlantaAnimationWidgetState extends State<PlantaAnimationWidget> {
  Artboard? _riveArtboard;
  StateMachineController? _stateMachineController;
  SMIInput? _growthInput;
  SMIInput? _healthInput;
  late double _currentValue;

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

        // Debug: imprime todos los inputs disponibles
        print('=== State Machine encontrado ===');
        print('Inputs disponibles en el State Machine:');
        for (var input in _stateMachineController!.inputs) {
          print('  - ${input.name} (${input.runtimeType})');
        }

        // Obtener el input como double (SMINumber en Rive es double)
        _growthInput = _stateMachineController!.findInput<double>('input');
        
        if (_growthInput != null) {
          print('✓ Input "input" encontrado (SMINumber)');
          _growthInput!.value = _currentValue;
          print('✓ Valor inicial establecido: $_currentValue');
        } else {
          print('✗ Input "input" NO encontrado');
        }

        // Establecer valores iniciales
        if (_growthInput != null) {
          _growthInput!.value = widget.plantaValor;
        }
        if (_healthInput != null) {
          _healthInput!.value = widget.salud.toDouble();
        }
      }

      setState(() {
        _riveArtboard = artboard;
      });
    } catch (e) {
      print('Error cargando archivo Rive: $e');
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

    // Actualizar el valor de crecimiento SIEMPRE
    if (_growthInput != null) {
      _growthInput!.value = widget.plantaValor;
      print('Actualizando growth input a: ${widget.plantaValor}');
    }

    // Si cambió la etapa, reinicializar
    if (oldWidget.etapa != widget.etapa) {
      _stateMachineController?.dispose();
      _initializeRive();
    }
  }

  @override
  void dispose() {
    _stateMachineController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: _riveArtboard != null
                ? Rive(artboard: _riveArtboard!)
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          const SizedBox(height: 16),
          // Slider para cambiar el valor manualmente
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Growth Value: ${_currentValue.toStringAsFixed(1)}'),
                const SizedBox(height: 8),
                Slider(
                  min: 0,
                  max: 100,
                  value: _currentValue,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                      _growthInput?.value = value;
                      print('Slider value: $value');
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget con información adicional de la planta
class PlantaInfoCard extends StatelessWidget {
  final String etapa;
  final int salud;
  final double plantaValor;

  const PlantaInfoCard({
    Key? key,
    required this.etapa,
    required this.salud,
    required this.plantaValor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEtapaIcon(),
                  color: _getColorBySalud(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _getEtapaName(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              'Crecimiento',
              plantaValor,
              100.0,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildProgressBar(
              'Salud',
              salud.toDouble(),
              100.0,
              _getColorBySalud(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    double value,
    double max,
    Color color,
  ) {
    final percentage = (value / max * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / max,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  IconData _getEtapaIcon() {
    switch (etapa) {
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
    switch (etapa) {
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

  Color _getColorBySalud() {
    if (salud >= 70) {
      return const Color(0xFF4CAF50);
    } else if (salud >= 40) {
      return const Color(0xFF8BC34A);
    } else {
      return const Color(0xFFCDDC39);
    }
  }
}