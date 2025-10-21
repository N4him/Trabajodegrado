import 'dart:core'; // Siempre disponible, pero explícito para claridad
import '../../domain/entities/habit_entity.dart';

class HabitModel {
  final String id;
  final String userId;
  final String name;
  final int frequencyDays;
  final DateTime startDate;
  final String? reminderTime; // Ej: "09:00 AM"

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequencyDays,
    required this.startDate,
    this.reminderTime,
  });

  // Convierte la Entidad del Dominio a un Modelo (útil para inyección de dependencias)
  factory HabitModel.fromEntity(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      frequencyDays: entity.frequencyDays,
      startDate: entity.startDate,
      reminderTime: entity.reminderTime,
    );
  }

  // Convierte el Modelo a un Map<String, dynamic> (Para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'frequencyDays': frequencyDays,
      // Se guarda como String simple (YYYY-MM-DD)
      'startDate': startDate.toIso8601String().substring(0, 10),
      'reminderTime': reminderTime,
    };
  }

  // Crea un Modelo a partir de un Map (Para leer de Firestore)
  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitModel(
      id: id,
      userId: map['userId'] as String,
      name: map['name'] as String,
      frequencyDays: map['frequencyDays'] as int,
      // Parsea el String (YYYY-MM-DD) de vuelta a DateTime
      startDate: DateTime.parse(map['startDate']),
      reminderTime: map['reminderTime'] as String?,
    );
  }

  // Convierte el Modelo de vuelta a la Entidad (Para devolver al Dominio)
  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      userId: userId,
      name: name,
      frequencyDays: frequencyDays,
      startDate: startDate,
      reminderTime: reminderTime,
    );
  }
}