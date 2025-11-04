import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quest_map_event.dart';
import 'quest_map_state.dart';
import '../../domain/entities/quest_map_session_entity.dart';
import '../../domain/usecases/save_quest_map_session_usecase.dart';
import '../../../../gamification/domain/usecases/update_modulo_progress.dart';
import '../../../../gamification/domain/entities/modulo_progreso.dart';

/// BLoC para el Quest Map (técnica 5-4-3-2-1)
class QuestMapBloc extends Bloc<QuestMapEvent, QuestMapState> {
  final SaveQuestMapSessionUseCase saveSessionUseCase;
  final UpdateModuloProgress updateModuloProgress;

  QuestMapBloc({
    required this.saveSessionUseCase,
    required this.updateModuloProgress,
  }) : super(QuestMapInitial()) {
    on<StartQuestMap>(_onStartQuestMap);
    on<AddAnswer>(_onAddAnswer);
    on<RemoveAnswer>(_onRemoveAnswer);
    on<CompleteSense>(_onCompleteSense);
    on<CompleteBreathingPause>(_onCompleteBreathingPause);
    on<ResetQuestMap>(_onResetQuestMap);
  }

  void _onStartQuestMap(StartQuestMap event, Emitter<QuestMapState> emit) {
    emit(ExploringSense(
      currentSense: SenseType.sight,
      currentAnswers: [],
      sightAnswers: [],
      touchAnswers: [],
      soundAnswers: [],
      smellAnswers: [],
      tasteAnswers: [],
      startTime: DateTime.now(),
    ));
  }

  void _onAddAnswer(AddAnswer event, Emitter<QuestMapState> emit) {
    if (state is! ExploringSense) return;

    final currentState = state as ExploringSense;
    final updatedAnswers = List<String>.from(currentState.currentAnswers)
      ..add(event.answer);

    // No permitir más respuestas del límite
    if (updatedAnswers.length > currentState.currentSense.requiredAnswers) {
      return;
    }

    emit(ExploringSense(
      currentSense: currentState.currentSense,
      currentAnswers: updatedAnswers,
      sightAnswers: currentState.sightAnswers,
      touchAnswers: currentState.touchAnswers,
      soundAnswers: currentState.soundAnswers,
      smellAnswers: currentState.smellAnswers,
      tasteAnswers: currentState.tasteAnswers,
      startTime: currentState.startTime,
    ));
  }

  void _onRemoveAnswer(RemoveAnswer event, Emitter<QuestMapState> emit) {
    if (state is! ExploringSense) return;

    final currentState = state as ExploringSense;
    final updatedAnswers = List<String>.from(currentState.currentAnswers)
      ..removeAt(event.index);

    emit(ExploringSense(
      currentSense: currentState.currentSense,
      currentAnswers: updatedAnswers,
      sightAnswers: currentState.sightAnswers,
      touchAnswers: currentState.touchAnswers,
      soundAnswers: currentState.soundAnswers,
      smellAnswers: currentState.smellAnswers,
      tasteAnswers: currentState.tasteAnswers,
      startTime: currentState.startTime,
    ));
  }

  void _onCompleteSense(CompleteSense event, Emitter<QuestMapState> emit) async {
    if (state is! ExploringSense) return;

    final currentState = state as ExploringSense;

    // Guardar las respuestas del sentido actual
    List<String> updatedSightAnswers = currentState.sightAnswers;
    List<String> updatedTouchAnswers = currentState.touchAnswers;
    List<String> updatedSoundAnswers = currentState.soundAnswers;
    List<String> updatedSmellAnswers = currentState.smellAnswers;
    List<String> updatedTasteAnswers = currentState.tasteAnswers;

    switch (currentState.currentSense) {
      case SenseType.sight:
        updatedSightAnswers = currentState.currentAnswers;
        break;
      case SenseType.touch:
        updatedTouchAnswers = currentState.currentAnswers;
        break;
      case SenseType.sound:
        updatedSoundAnswers = currentState.currentAnswers;
        break;
      case SenseType.smell:
        updatedSmellAnswers = currentState.currentAnswers;
        break;
      case SenseType.taste:
        updatedTasteAnswers = currentState.currentAnswers;
        break;
    }

    // Determinar el siguiente sentido
    final nextSense = _getNextSense(currentState.currentSense);

    if (nextSense == null) {
      // Última etapa completada, guardar sesión
      await _saveSession(
        emit,
        updatedSightAnswers,
        updatedTouchAnswers,
        updatedSoundAnswers,
        updatedSmellAnswers,
        updatedTasteAnswers,
        currentState.startTime,
      );
    } else {
      // Ir a pausa de respiración
      emit(BreathingPause(
        justCompletedSense: currentState.currentSense,
        nextSense: nextSense,
        sightAnswers: updatedSightAnswers,
        touchAnswers: updatedTouchAnswers,
        soundAnswers: updatedSoundAnswers,
        smellAnswers: updatedSmellAnswers,
        tasteAnswers: updatedTasteAnswers,
        startTime: currentState.startTime,
      ));
    }
  }

  void _onCompleteBreathingPause(
      CompleteBreathingPause event, Emitter<QuestMapState> emit) {
    if (state is! BreathingPause) return;

    final currentState = state as BreathingPause;

    emit(ExploringSense(
      currentSense: currentState.nextSense,
      currentAnswers: [],
      sightAnswers: currentState.sightAnswers,
      touchAnswers: currentState.touchAnswers,
      soundAnswers: currentState.soundAnswers,
      smellAnswers: currentState.smellAnswers,
      tasteAnswers: currentState.tasteAnswers,
      startTime: currentState.startTime,
    ));
  }

  void _onResetQuestMap(ResetQuestMap event, Emitter<QuestMapState> emit) {
    emit(QuestMapInitial());
  }

  SenseType? _getNextSense(SenseType current) {
    switch (current) {
      case SenseType.sight:
        return SenseType.touch;
      case SenseType.touch:
        return SenseType.sound;
      case SenseType.sound:
        return SenseType.smell;
      case SenseType.smell:
        return SenseType.taste;
      case SenseType.taste:
        return null; // Última etapa
    }
  }

  Future<void> _saveSession(
    Emitter<QuestMapState> emit,
    List<String> sightAnswers,
    List<String> touchAnswers,
    List<String> soundAnswers,
    List<String> smellAnswers,
    List<String> tasteAnswers,
    DateTime startTime,
  ) async {
    emit(SavingQuestMapSession());

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(QuestMapError('Usuario no autenticado'));
      return;
    }

    final duration = DateTime.now().difference(startTime).inSeconds;

    final session = QuestMapSessionEntity(
      userId: userId,
      completedAt: DateTime.now(),
      sightAnswers: sightAnswers,
      touchAnswers: touchAnswers,
      soundAnswers: soundAnswers,
      smellAnswers: smellAnswers,
      tasteAnswers: tasteAnswers,
      durationSeconds: duration,
    );

    final result = await saveSessionUseCase.call(session);

    if (result.isLeft()) {
      emit(QuestMapError('Error al guardar la sesión'));
      return;
    }

    // Verificar si emit ya fue cerrado
    if (emit.isDone) return;

    // Actualizar gamificación después de guardar
    await updateModuloProgress.call(
      userId: userId,
      moduloKey: 'equilibrio',
      progreso: const ModuloProgreso(
        sesionesCompletadas: 1,
        diasCumplidos: 1,
        puntosObtenidos: 1,
      ),
    );

    emit(QuestMapSessionSaved(
      sightAnswers: sightAnswers,
      touchAnswers: touchAnswers,
      soundAnswers: soundAnswers,
      smellAnswers: smellAnswers,
      tasteAnswers: tasteAnswers,
      durationSeconds: duration,
    ));
  }
}
