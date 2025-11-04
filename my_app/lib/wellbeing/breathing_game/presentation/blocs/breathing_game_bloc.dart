import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/breathing_session_entity.dart';
import '../../domain/models/breathing_mode.dart';
import '../../domain/usecases/save_breathing_session_usecase.dart';
import '../../../../gamification/domain/usecases/update_modulo_progress.dart';
import '../../../../gamification/domain/entities/modulo_progreso.dart';
import 'breathing_game_event.dart';
import 'breathing_game_state.dart';

class BreathingGameBloc extends Bloc<BreathingEvent, BreathingGameState> {
  final SaveBreathingSessionUseCase saveSessionUseCase;
  final UpdateModuloProgress updateModuloProgress;

  Timer? _timer;
  int _phaseIndex = 0;
  int _cycleCount = 0;
  int _particlesCollected = 0;
  int _totalParticles = 0;
  double _elapsed = 0.0;
  DateTime? _startTime;

  static const int _ticks = 20;

  late BreathingSettings _settings;
  late BreathingMode _currentMode;
  late List<BreathingPhase> _phases;
  late List<Duration> _durations;

  BreathingGameBloc({
    required this.saveSessionUseCase,
    required this.updateModuloProgress,
  }) : super(BreathingInitial()) {
    on<StartBreathingGame>(_onStartBreathingGame);
    on<PhaseTick>(_onPhaseTick);
    on<CollectParticle>(_onCollectParticle);
    on<PhaseComplete>(_onPhaseComplete);
    on<ResetBreathingGame>(_onResetBreathingGame);
  }

  void _onStartBreathingGame(StartBreathingGame event, Emitter<BreathingGameState> emit) {
    _currentMode = event.mode;
    _settings = breathingModes[event.mode]!;
    _initializeSession();
    _runPhase(emit);
  }

  void _initializeSession() {
    _phaseIndex = 0;
    _cycleCount = 0;
    _particlesCollected = 0;
    _totalParticles = 0;
    _elapsed = 0.0;
    _startTime = DateTime.now();
    _phases = _generatePhases();
    _durations = _generateDurations();
  }

  List<BreathingPhase> _generatePhases() => [
        BreathingPhase.inhale,
        if (_settings.hasDoubleInhale) BreathingPhase.secondInhale,
        if (_settings.hold > 0) BreathingPhase.hold,
        BreathingPhase.exhale,
        if (_settings.holdEmpty > 0) BreathingPhase.holdEmpty,
      ];

  List<Duration> _generateDurations() {
    final durations = <Duration>[Duration(seconds: _settings.inhale)];
    if (_settings.hasDoubleInhale) durations.add(Duration(seconds: _settings.secondInhale!));
    if (_settings.hold > 0) durations.add(Duration(seconds: _settings.hold));
    durations.add(Duration(seconds: _settings.exhale));
    if (_settings.holdEmpty > 0) durations.add(Duration(seconds: _settings.holdEmpty));
    return durations;
  }

  void _runPhase(Emitter<BreathingGameState> emit) {
    final dur = _durations[_phaseIndex];
    final interval = Duration(milliseconds: dur.inMilliseconds ~/ _ticks);
    _timer?.cancel();
    _timer = Timer.periodic(interval, (timer) {
      _elapsed += 1 / _ticks;
      if (_elapsed >= 1.0) {
        timer.cancel();
        add(PhaseComplete());
      } else {
        add(PhaseTick(_elapsed));
      }
    });

    emit(PhaseInProgress(
      phase: _phases[_phaseIndex],
      elapsed: _elapsed,
      cycleCount: _cycleCount,
      particlesCollected: _particlesCollected,
      totalParticles: _totalParticles,
      startTime: _startTime!,
    ));
  }

  void _onPhaseTick(PhaseTick event, Emitter<BreathingGameState> emit) {
    if (state is PhaseInProgress) {
      final current = state as PhaseInProgress;
      emit(PhaseInProgress(
        phase: current.phase,
        elapsed: event.elapsed,
        cycleCount: current.cycleCount,
        particlesCollected: current.particlesCollected,
        totalParticles: current.totalParticles,
        startTime: current.startTime,
      ));
    }
  }

  void _onCollectParticle(CollectParticle event, Emitter<BreathingGameState> emit) {
    _particlesCollected++;
    HapticFeedback.lightImpact();

    if (state is PhaseInProgress) {
      final current = state as PhaseInProgress;
      emit(PhaseInProgress(
        phase: current.phase,
        elapsed: current.elapsed,
        cycleCount: current.cycleCount,
        particlesCollected: _particlesCollected,
        totalParticles: current.totalParticles,
        startTime: current.startTime,
      ));
    }
  }

  void incrementTotalParticles() {
    _totalParticles++;
  }

  void _onPhaseComplete(PhaseComplete event, Emitter<BreathingGameState> emit) async {
    _phaseIndex = (_phaseIndex + 1) % _phases.length;
    if (_phaseIndex == 0) _cycleCount++;

    if (_cycleCount >= _settings.cycles) {
      // Sesión completada, guardar en Firebase
      final endTime = DateTime.now();
      final durationSeconds = endTime.difference(_startTime!).inSeconds;

      emit(SessionCompleted(
        mode: _currentMode,
        particlesCollected: _particlesCollected,
        totalParticles: _totalParticles,
        cyclesCompleted: _settings.cycles,
        durationSeconds: durationSeconds,
      ));

      // Guardar sesión
      await _saveSession(emit, endTime, durationSeconds);
    } else {
      _elapsed = 0.0;
      _runPhase(emit);
    }
  }

  Future<void> _saveSession(
    Emitter<BreathingGameState> emit,
    DateTime endTime,
    int durationSeconds,
  ) async {
    emit(SavingSession());

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(BreathingError('Usuario no autenticado'));
      return;
    }

    final session = BreathingSessionEntity(
      id: '',
      userId: userId,
      completedAt: endTime,
      mode: breathingModeToString(_currentMode),
      particlesCollected: _particlesCollected,
      totalParticles: _totalParticles,
      cyclesCompleted: _settings.cycles,
      durationSeconds: durationSeconds,
    );

    final result = await saveSessionUseCase.call(session);

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null);
      emit(BreathingError('Error al guardar: ${failure?.message ?? "Error desconocido"}'));
      return;
    }

    // Sesión guardada exitosamente, actualizar gamificación
    await updateModuloProgress.call(
      userId: userId,
      moduloKey: 'equilibrio',
      progreso: const ModuloProgreso(
        sesionesCompletadas: 1,
        diasCumplidos: 1,
        puntosObtenidos: 1,
      ),
    );

    if (!emit.isDone) {
      emit(SessionSaved(
        mode: _currentMode,
        particlesCollected: _particlesCollected,
        totalParticles: _totalParticles,
        cyclesCompleted: _settings.cycles,
        durationSeconds: durationSeconds,
      ));
    }
  }

  void _onResetBreathingGame(ResetBreathingGame event, Emitter<BreathingGameState> emit) {
    _timer?.cancel();
    emit(BreathingInitial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
