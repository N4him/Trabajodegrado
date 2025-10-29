/// Define los modos de respiración disponibles basados en investigación científica
enum BreathingMode {
  cyclicSighing,      // Énfasis en exhalaciones (Stanford)
  boxBreathing,       // Respiración cuadrada (Navy SEALs)
  cyclicHyperventilation, // Inhalaciones robustas (Wim Hof style)
}

/// Configuración de duraciones y ciclos para un modo
class BreathingSettings {
  final int inhale;
  final int? secondInhale; // Solo para Cyclic Sighing
  final int hold;
  final int exhale;
  final int holdEmpty;
  final int cycles;
  final String displayName;
  final String description;
  final String benefits;

  const BreathingSettings({
    required this.inhale,
    this.secondInhale,
    required this.hold,
    required this.exhale,
    required this.holdEmpty,
    required this.cycles,
    required this.displayName,
    required this.description,
    required this.benefits,
  });

  /// Verifica si este modo tiene doble inhalación (Cyclic Sighing)
  bool get hasDoubleInhale => secondInhale != null;
}

/// Parámetros basados en evidencia para cada modo
final Map<BreathingMode, BreathingSettings> breathingModes = {
  // 1. Cyclic Sighing: Énfasis en exhalaciones prolongadas (ratio 1:2)
  // Basado en técnicas de respiración consciente
  BreathingMode.cyclicSighing: const BreathingSettings(
    inhale: 3,
    secondInhale: 1, // Segunda inhalación corta para llenar pulmones
    hold: 0,
    exhale: 8, // Exhalación prolongada (ratio 1:2)
    holdEmpty: 0,
    cycles: 30,
    displayName: 'Suspiro Cíclico',
    description: 'Doble inhalación + exhalación prolongada',
    benefits: 'Favorece la atención plena y la calma interior',
  ),

  // 2. Box Breathing: Duración igual (ratio 1:1:1:1)
  // Técnica estructurada de respiración consciente
  BreathingMode.boxBreathing: const BreathingSettings(
    inhale: 4,
    hold: 4,
    exhale: 4,
    holdEmpty: 4,
    cycles: 21,
    displayName: 'Respiración Cuadrada',
    description: 'Patrón rítmico (4-4-4-4)',
    benefits: 'Promueve la concentración y el equilibrio mental',
  ),

  // 3. Cyclic Hyperventilation: Inhalaciones robustas, exhalaciones rápidas
  // Técnica de respiración dinámica consciente
  BreathingMode.cyclicHyperventilation: const BreathingSettings(
    inhale: 3, // Inhalación robusta
    hold: 1,   // Retención corta
    exhale: 1, // Exhalación rápida
    holdEmpty: 0,
    cycles: 33,
    displayName: 'Respiración Energizante',
    description: 'Inhalaciones profundas + exhalaciones breves',
    benefits: 'Ayuda a conectar con el momento presente y la vitalidad',
  ),
};

/// Convierte enum a string
String breathingModeToString(BreathingMode mode) {
  switch (mode) {
    case BreathingMode.cyclicSighing:
      return 'cyclicSighing';
    case BreathingMode.boxBreathing:
      return 'boxBreathing';
    case BreathingMode.cyclicHyperventilation:
      return 'cyclicHyperventilation';
  }
}

/// Convierte string a enum
BreathingMode breathingModeFromString(String mode) {
  switch (mode) {
    case 'cyclicSighing':
      return BreathingMode.cyclicSighing;
    case 'boxBreathing':
      return BreathingMode.boxBreathing;
    case 'cyclicHyperventilation':
      return BreathingMode.cyclicHyperventilation;
    default:
      return BreathingMode.boxBreathing; // Default más común
  }
}
