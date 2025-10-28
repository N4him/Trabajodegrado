import 'package:equatable/equatable.dart';

/// Eventos del Quest Map (técnica 5-4-3-2-1)
abstract class QuestMapEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Evento para iniciar el Quest Map
class StartQuestMap extends QuestMapEvent {}

/// Evento cuando se agrega una respuesta
class AddAnswer extends QuestMapEvent {
  final String answer;

  AddAnswer(this.answer);

  @override
  List<Object?> get props => [answer];
}

/// Evento cuando se elimina una respuesta
class RemoveAnswer extends QuestMapEvent {
  final int index;

  RemoveAnswer(this.index);

  @override
  List<Object?> get props => [index];
}

/// Evento cuando se completa un sentido y se pasa al siguiente
class CompleteSense extends QuestMapEvent {}

/// Evento cuando se completa la pausa de respiración
class CompleteBreathingPause extends QuestMapEvent {}

/// Evento para reiniciar el Quest Map
class ResetQuestMap extends QuestMapEvent {}
