class CompletionRecordEntity {
  final String id;
  final String userId; // ¡NUEVO CAMPO: Necesario para la ruta anidada!
  final String habitId;
  final DateTime date; // Solo la fecha (YYYY-MM-DD)
  final bool isCompleted;
  final DateTime registeredAt; // Momento exacto del registro

  CompletionRecordEntity({
    required this.id,
    required this.userId, // requerido
    required this.habitId,
    required this.date,
    required this.isCompleted,
    required this.registeredAt,
  });
}