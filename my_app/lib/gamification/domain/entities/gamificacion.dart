import 'package:my_app/gamification/domain/entities/modulo_progreso.dart';

class Gamificacion {
  final EstadoGeneral estadoGeneral;
  final Map<String, ModuloProgreso> modulos;
  final List<String> insigniasUsuario;
  final List<int> historialEventos;

  const Gamificacion({
    required this.estadoGeneral,
    required this.modulos,
    required this.insigniasUsuario,
    required this.historialEventos,
  });

  Gamificacion copyWith({
    EstadoGeneral? estadoGeneral,
    Map<String, ModuloProgreso>? modulos,
    List<String>? insigniasUsuario,
    List<int>? historialEventos,
  }) {
    return Gamificacion(
      estadoGeneral: estadoGeneral ?? this.estadoGeneral,
      modulos: modulos ?? this.modulos,
      insigniasUsuario: insigniasUsuario ?? this.insigniasUsuario,
      historialEventos: historialEventos ?? this.historialEventos,
    );
  }
}

class EstadoGeneral {
  final double plantaValor;
  final int salud;
  final String etapa;
  final DateTime ultimaActualizacion;

  const EstadoGeneral({
    required this.plantaValor,
    required this.salud,
    required this.etapa,
    required this.ultimaActualizacion,
  });

  EstadoGeneral copyWith({
    double? plantaValor,
    int? salud,
    String? etapa,
    DateTime? ultimaActualizacion,
  }) {
    return EstadoGeneral(
      plantaValor: plantaValor ?? this.plantaValor,
      salud: salud ?? this.salud,
      etapa: etapa ?? this.etapa,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }
}