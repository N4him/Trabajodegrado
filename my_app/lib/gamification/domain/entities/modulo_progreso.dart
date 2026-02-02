import 'package:cloud_firestore/cloud_firestore.dart';

class ModuloProgreso {
  final int diasCumplidos;
  final int rachaActual;
  final int publicaciones;
  final int puntosObtenidos;
  final int lecturas;
  final int testsAprobados;
  final int sesionesCompletadas;
    final DateTime? ultimaActividad; // <-- agregar esto


  const ModuloProgreso({
    this.diasCumplidos = 0,
    this.rachaActual = 0,
    this.publicaciones = 0,
    this.puntosObtenidos = 0,
    this.lecturas = 0,
    this.testsAprobados = 0,
    this.sesionesCompletadas = 0,    this.ultimaActividad, // <-- agregar esto

  });

  ModuloProgreso copyWith({
    int? diasCumplidos,
    int? rachaActual,
    int? publicaciones,
    int? puntosObtenidos,
    int? lecturas,
    int? testsAprobados,
    int? sesionesCompletadas,
      DateTime? ultimaActividad,

  }) {
    return ModuloProgreso(
      diasCumplidos: diasCumplidos ?? this.diasCumplidos,
      rachaActual: rachaActual ?? this.rachaActual,
      publicaciones: publicaciones ?? this.publicaciones,
      puntosObtenidos: puntosObtenidos ?? this.puntosObtenidos,
      lecturas: lecturas ?? this.lecturas,
      testsAprobados: testsAprobados ?? this.testsAprobados,
      sesionesCompletadas: sesionesCompletadas ?? this.sesionesCompletadas,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,

    );
  }

Map<String, dynamic> toMap() {
  return {
    'dias_cumplidos': diasCumplidos,
    'racha_actual': rachaActual,
    'publicaciones': publicaciones,
    'puntos_obtenidos': puntosObtenidos,
    'lecturas': lecturas,
    'tests_aprobados': testsAprobados,
    'sesiones_completadas': sesionesCompletadas,
    'ultima_actividad': ultimaActividad != null
        ? Timestamp.fromDate(ultimaActividad!)
        : null,
  };
}
factory ModuloProgreso.fromMap(Map<String, dynamic> map) {
  return ModuloProgreso(
    diasCumplidos: map['dias_cumplidos'] ?? 0,
    rachaActual: map['racha_actual'] ?? 0,
    publicaciones: map['publicaciones'] ?? 0,
    puntosObtenidos: map['puntos_obtenidos'] ?? 0,
    lecturas: map['lecturas'] ?? 0,
    testsAprobados: map['tests_aprobados'] ?? 0,
    sesionesCompletadas: map['sesiones_completadas'] ?? 0,
    ultimaActividad: map['ultima_actividad'] != null
        ? (map['ultima_actividad'] as Timestamp).toDate()
        : null,
  );
}
}