/// Define los modos de respiración disponibles
enum BreathingMode {
  calmaRapida,
  enfoqueMental,
  relajacionProfunda,
}

/// Configuración de duraciones y ciclos para un modo
class BreathingSettings {
  final int inhale;
  final int hold;
  final int exhale;
  final int holdEmpty;
  final int cycles;
  final String displayName;

  const BreathingSettings({
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdEmpty,
    required this.cycles,
    required this.displayName,
  });
}

/// Parámetros basados en evidencia para cada modo
final Map<BreathingMode, BreathingSettings> breathingModes = {
  BreathingMode.calmaRapida: const BreathingSettings(
    inhale: 4,
    hold: 4,
    exhale: 4,
    holdEmpty: 4,
    cycles: 6,
    displayName: 'Calma Rápida',
  ),
  BreathingMode.enfoqueMental: const BreathingSettings(
    inhale: 5,
    hold: 5,
    exhale: 5,
    holdEmpty: 5,
    cycles: 8,
    displayName: 'Enfoque Mental',
  ),
  BreathingMode.relajacionProfunda: const BreathingSettings(
    inhale: 4,
    hold: 7,
    exhale: 8,
    holdEmpty: 0,
    cycles: 10,
    displayName: 'Relajación Profunda',
  ),
};

/// Convierte enum a string
String breathingModeToString(BreathingMode mode) {
  switch (mode) {
    case BreathingMode.calmaRapida:
      return 'calmaRapida';
    case BreathingMode.enfoqueMental:
      return 'enfoqueMental';
    case BreathingMode.relajacionProfunda:
      return 'relajacionProfunda';
  }
}

/// Convierte string a enum
BreathingMode breathingModeFromString(String mode) {
  switch (mode) {
    case 'calmaRapida':
      return BreathingMode.calmaRapida;
    case 'enfoqueMental':
      return BreathingMode.enfoqueMental;
    case 'relajacionProfunda':
      return BreathingMode.relajacionProfunda;
    default:
      return BreathingMode.calmaRapida;
  }
}
