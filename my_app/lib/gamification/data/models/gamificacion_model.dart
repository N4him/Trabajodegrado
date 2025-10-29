import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/gamificacion.dart';
import '../../domain/entities/modulo_progreso.dart';

class GamificacionModel extends Gamificacion {
  const GamificacionModel({
    required super.estadoGeneral,
    required super.modulos,
    required super.insigniasUsuario,
    required super.historialEventos,
  });

  factory GamificacionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return GamificacionModel.empty();
    }

    return GamificacionModel(
      estadoGeneral: _parseEstadoGeneral(data['estado_general']),
      modulos: _parseModulos(data['modulos']),
    insigniasUsuario: (data['insignias_usuario'] as List<dynamic>?)?.cast<String>() ?? [],
      historialEventos: List<int>.from(data['historial_eventos'] ?? []),
    );
  }

  factory GamificacionModel.empty() {
    return GamificacionModel(
      estadoGeneral: EstadoGeneral(
        plantaValor: 0.0,
        salud: 100,
        etapa: 'semilla',
        ultimaActualizacion: DateTime.now(),
      ),
      modulos: {
        'habitos': const ModuloProgreso(),
        'foro': const ModuloProgreso(),
        'biblioteca': const ModuloProgreso(),
        'equilibrio': const ModuloProgreso(),
      },
      insigniasUsuario: [],
      historialEventos: [],
    );
  }

  static EstadoGeneral _parseEstadoGeneral(dynamic data) {
    if (data == null) {
      return EstadoGeneral(
        plantaValor: 0.0,
        salud: 100,
        etapa: 'semilla',
        ultimaActualizacion: DateTime.now(),
      );
    }

    final map = data as Map<String, dynamic>;
    return EstadoGeneral(
      plantaValor: (map['planta_valor'] ?? 0.0).toDouble(),
      salud: map['salud'] ?? 100,
      etapa: map['etapa'] ?? 'semilla',
      ultimaActualizacion: (map['ultima_actualizacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, ModuloProgreso> _parseModulos(dynamic data) {
    if (data == null) {
      return {
        'habitos': const ModuloProgreso(),
        'foro': const ModuloProgreso(),
        'biblioteca': const ModuloProgreso(),
        'equilibrio': const ModuloProgreso(),
      };
    }

    final map = data as Map<String, dynamic>;
    return {
      'habitos': ModuloProgreso.fromMap(map['habitos'] ?? {}),
      'foro': ModuloProgreso.fromMap(map['foro'] ?? {}),
      'biblioteca': ModuloProgreso.fromMap(map['biblioteca'] ?? {}),
      'equilibrio': ModuloProgreso.fromMap(map['equilibrio'] ?? {}),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'estado_general': {
        'planta_valor': estadoGeneral.plantaValor,
        'salud': estadoGeneral.salud,
        'etapa': estadoGeneral.etapa,
        'ultima_actualizacion': Timestamp.fromDate(estadoGeneral.ultimaActualizacion),
      },
      'modulos': {
        'habitos': modulos['habitos']?.toMap() ?? {},
        'foro': modulos['foro']?.toMap() ?? {},
        'biblioteca': modulos['biblioteca']?.toMap() ?? {},
        'equilibrio': modulos['equilibrio']?.toMap() ?? {},
      },
      'insignias_usuario': insigniasUsuario,
      'historial_eventos': historialEventos,
    };
  }
}