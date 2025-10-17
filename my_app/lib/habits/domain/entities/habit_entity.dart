
class HabitEntity {
  final String id;
  final String userId;
  final String name;
  final int frequencyDays; // 7 (diario), 3 (3 veces/sem), etc.
  final DateTime startDate;
  final String? reminderTime;

  HabitEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequencyDays,
    required this.startDate,
    this.reminderTime,
  });
}

