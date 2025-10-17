import '../../domain/entities/completion_record_entity.dart';

class CompletionRecordModel {
  final String id;
  final String userId; // Campo añadido
  final String habitId;
  final DateTime date;
  final bool isCompleted;
  final DateTime registeredAt;

  CompletionRecordModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.isCompleted,
    required this.registeredAt,
  });

  // 🔄 De Entidad a Modelo (Para guardar)
  factory CompletionRecordModel.fromEntity(CompletionRecordEntity entity) {
    return CompletionRecordModel(
      id: entity.id,
      userId: entity.userId,
      habitId: entity.habitId,
      date: entity.date,
      isCompleted: entity.isCompleted,
      registeredAt: entity.registeredAt,
    );
  }

  // 📝 A Map<String, dynamic> 
  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // Guardado por seguridad, aunque esté en la ruta
      'habitId': habitId,
      'date': date.toIso8601String().substring(0, 10),
      'isCompleted': isCompleted,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  // 📥 De Map<String, dynamic>
  factory CompletionRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return CompletionRecordModel(
      id: id,
      userId: map['userId'] as String,
      habitId: map['habitId'] as String,
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] as bool,
      registeredAt: DateTime.parse(map['registeredAt']),
    );
  }

  // 📤 De Modelo a Entidad
  CompletionRecordEntity toEntity() {
    return CompletionRecordEntity(
      id: id,
      userId: userId,
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
      registeredAt: registeredAt,
    );
  }
}