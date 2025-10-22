/// Modelo para un paso en el Escaneo Corporal (Viaje Sensorial)
class ScanStep {
  /// Título de la zona corporal (p.ej. "Plantas de los pies").
  final String title;

  /// Instrucción breve para el usuario.
  final String instruction;

  /// Constructor.
  ScanStep({
    required this.title,
    required this.instruction,
  });
}
