import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/stop_session_entity.dart';
import '../../domain/usecases/save_stop_session_usecase.dart';
import '../../../shared/domain/usecases/increment_wellbeing_points_usecase.dart';
import 'stop_game_event.dart';
import 'stop_game_state.dart';

class StopGameBloc extends Bloc<StopGameEvent, StopGameState> {
  final SaveStopSessionUseCase saveSessionUseCase;
  final IncrementWellbeingPointsUseCase incrementPointsUseCase;

  int _breathSuccesses = 0;
  String _selectedEmotion = '';
  DateTime? _startTime;

  static const List<String> _emotions = [
    'Ansiedad',
    'Ira',
    'Tristeza',
    'Alegría',
    'Calma',
  ];

  static const List<String> _actions = [
    'Escribir en diario',
    'Hablar con alguien',
    'Respirar de nuevo',
    'Tomar un descanso',
  ];

  StopGameBloc({
    required this.saveSessionUseCase,
    required this.incrementPointsUseCase,
  }) : super(StopInitial()) {
    on<StartStopGame>(_onStartStopGame);
    on<StopPressed>(_onStopPressed);
    on<BreatheTapped>(_onBreatheTapped);
    on<EmotionIdentified>(_onEmotionIdentified);
    on<ActionChosen>(_onActionChosen);
    on<ResetStopGame>(_onResetStopGame);
  }

  void _onStartStopGame(StartStopGame event, Emitter<StopGameState> emit) {
    _breathSuccesses = 0;
    _selectedEmotion = '';
    _startTime = null;
    emit(StopInitial());
  }

  void _onStopPressed(StopPressed event, Emitter<StopGameState> emit) {
    _breathSuccesses = 0;
    _startTime = DateTime.now();
    emit(BreathingState(
      round: 1,
      successes: 0,
      startTime: _startTime!,
    ));
  }

  void _onBreatheTapped(BreatheTapped event, Emitter<StopGameState> emit) {
    if (event.success) _breathSuccesses++;

    final current = state;
    int nextRound = 1;
    if (current is BreathingState) {
      nextRound = current.round + 1;
    }

    // Si aún quedan rondas
    if (nextRound <= 4) {
      emit(BreathingState(
        round: nextRound,
        successes: _breathSuccesses,
        startTime: _startTime!,
      ));
    } else {
      // Tras la última ronda, pasar a identificar emoción
      emit(EmotionState(
        availableEmotions: _emotions,
        selected: null,
        breathSuccesses: _breathSuccesses,
        startTime: _startTime!,
      ));
    }
  }

  void _onEmotionIdentified(EmotionIdentified event, Emitter<StopGameState> emit) {
    _selectedEmotion = event.emotion;

    // Avanzar a elegir acción
    emit(ActionState(
      options: _actions,
      chosen: null,
      emotion: _selectedEmotion,
      breathSuccesses: _breathSuccesses,
      startTime: _startTime!,
    ));
  }

  void _onActionChosen(ActionChosen event, Emitter<StopGameState> emit) async {
    // Guardar sesión
    await _saveSession(emit, event.action);
  }

  Future<void> _saveSession(Emitter<StopGameState> emit, String action) async {
    emit(SavingSession());

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(StopGameError('Usuario no autenticado'));
      return;
    }

    final endTime = DateTime.now();
    final durationSeconds = endTime.difference(_startTime!).inSeconds;

    final session = StopSessionEntity(
      id: '',
      userId: userId,
      completedAt: endTime,
      breathSuccesses: _breathSuccesses,
      emotion: _selectedEmotion,
      action: action,
      durationSeconds: durationSeconds,
    );

    final result = await saveSessionUseCase.call(session);

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null);
      emit(StopGameError('Error al guardar: ${failure?.message ?? "Error desconocido"}'));
      return;
    }

    // Sesión guardada exitosamente, incrementar puntos
    await incrementPointsUseCase.call(
      IncrementPointsParams(
        userId: userId,
        activityKey: 'stop_game',
      ),
    );

    if (!emit.isDone) {
      emit(SessionSaved(
        breathSuccesses: _breathSuccesses,
        emotion: _selectedEmotion,
        action: action,
        durationSeconds: durationSeconds,
      ));
    }
  }

  void _onResetStopGame(ResetStopGame event, Emitter<StopGameState> emit) {
    _breathSuccesses = 0;
    _selectedEmotion = '';
    _startTime = null;
    emit(StopInitial());
  }
}
