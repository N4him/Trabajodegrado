import 'package:equatable/equatable.dart';

/// Tipo de sentido en la técnica 5-4-3-2-1
enum SenseType {
  sight, // Vista - 5 respuestas
  touch, // Tacto - 4 respuestas
  sound, // Oído - 3 respuestas
  smell, // Olfato - 2 respuestas
  taste, // Gusto - 1 respuesta
}

/// Extensión para obtener información del sentido
extension SenseTypeExtension on SenseType {
  String get name {
    switch (this) {
      case SenseType.sight:
        return 'Vista';
      case SenseType.touch:
        return 'Tacto';
      case SenseType.sound:
        return 'Oído';
      case SenseType.smell:
        return 'Olfato';
      case SenseType.taste:
        return 'Gusto';
    }
  }

  String get question {
    switch (this) {
      case SenseType.sight:
        return '¿Qué PUEDES VER?';
      case SenseType.touch:
        return '¿Qué PUEDES TOCAR?';
      case SenseType.sound:
        return '¿Qué PUEDES OÍR?';
      case SenseType.smell:
        return '¿Qué PUEDES OLER?';
      case SenseType.taste:
        return '¿Qué PUEDES SABOREAR?';
    }
  }

  int get requiredAnswers {
    switch (this) {
      case SenseType.sight:
        return 5;
      case SenseType.touch:
        return 4;
      case SenseType.sound:
        return 3;
      case SenseType.smell:
        return 2;
      case SenseType.taste:
        return 1;
    }
  }

  String get hint {
    switch (this) {
      case SenseType.sight:
        return 'Mira a tu alrededor... ¿Ves algo de un color en particular?';
      case SenseType.touch:
        return 'Toca tu ropa, tu silla... ¿Es suave o áspera?';
      case SenseType.sound:
        return 'Cierra los ojos... ¿Qué sonidos escuchas cerca o lejos?';
      case SenseType.smell:
        return '¿Hay algún aroma en el aire? Puede ser sutil...';
      case SenseType.taste:
        return '¿Qué sabor tienes en la boca ahora mismo?';
    }
  }
}

/// Estados del Quest Map
abstract class QuestMapState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial (pantalla de bienvenida)
class QuestMapInitial extends QuestMapState {}

/// Estado cuando se está explorando un sentido
class ExploringSense extends QuestMapState {
  final SenseType currentSense;
  final List<String> currentAnswers;
  final List<String> sightAnswers;
  final List<String> touchAnswers;
  final List<String> soundAnswers;
  final List<String> smellAnswers;
  final List<String> tasteAnswers;
  final DateTime startTime;

  ExploringSense({
    required this.currentSense,
    required this.currentAnswers,
    required this.sightAnswers,
    required this.touchAnswers,
    required this.soundAnswers,
    required this.smellAnswers,
    required this.tasteAnswers,
    required this.startTime,
  });

  /// Progreso del sentido actual (0.0 a 1.0)
  double get progress {
    return currentAnswers.length / currentSense.requiredAnswers;
  }

  /// Verifica si el sentido actual está completo
  bool get isCurrentSenseComplete {
    return currentAnswers.length >= currentSense.requiredAnswers;
  }

  @override
  List<Object?> get props => [
        currentSense,
        currentAnswers,
        sightAnswers,
        touchAnswers,
        soundAnswers,
        smellAnswers,
        tasteAnswers,
        startTime,
      ];
}

/// Estado de pausa de respiración entre sentidos
class BreathingPause extends QuestMapState {
  final SenseType justCompletedSense;
  final SenseType nextSense;
  final List<String> sightAnswers;
  final List<String> touchAnswers;
  final List<String> soundAnswers;
  final List<String> smellAnswers;
  final List<String> tasteAnswers;
  final DateTime startTime;

  BreathingPause({
    required this.justCompletedSense,
    required this.nextSense,
    required this.sightAnswers,
    required this.touchAnswers,
    required this.soundAnswers,
    required this.smellAnswers,
    required this.tasteAnswers,
    required this.startTime,
  });

  @override
  List<Object?> get props => [
        justCompletedSense,
        nextSense,
        sightAnswers,
        touchAnswers,
        soundAnswers,
        smellAnswers,
        tasteAnswers,
        startTime,
      ];
}

/// Estado de guardando sesión
class SavingQuestMapSession extends QuestMapState {}

/// Estado de sesión guardada (pantalla de resumen)
class QuestMapSessionSaved extends QuestMapState {
  final List<String> sightAnswers;
  final List<String> touchAnswers;
  final List<String> soundAnswers;
  final List<String> smellAnswers;
  final List<String> tasteAnswers;
  final int durationSeconds;

  QuestMapSessionSaved({
    required this.sightAnswers,
    required this.touchAnswers,
    required this.soundAnswers,
    required this.smellAnswers,
    required this.tasteAnswers,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [
        sightAnswers,
        touchAnswers,
        soundAnswers,
        smellAnswers,
        tasteAnswers,
        durationSeconds,
      ];
}

/// Estado de error
class QuestMapError extends QuestMapState {
  final String message;

  QuestMapError(this.message);

  @override
  List<Object?> get props => [message];
}
