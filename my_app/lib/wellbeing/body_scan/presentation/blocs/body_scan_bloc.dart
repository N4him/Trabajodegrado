import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/scan_steps_data.dart';
import '../../domain/entities/body_scan_session_entity.dart';
import '../../domain/usecases/save_body_scan_session_usecase.dart';
import '../../../shared/domain/usecases/increment_wellbeing_points_usecase.dart';
import 'body_scan_event.dart';
import 'body_scan_state.dart';

/// BLoC que gestiona el flujo del Viaje Sensorial (Escaneo Corporal).
class BodyScanBloc extends Bloc<BodyScanEvent, BodyScanState> {
  final SaveBodyScanSessionUseCase saveSessionUseCase;
  final IncrementWellbeingPointsUseCase incrementPointsUseCase;

  BodyScanBloc({
    required this.saveSessionUseCase,
    required this.incrementPointsUseCase,
  }) : super(ScanInitial()) {
    on<StartScan>(_onStartScan);
    on<NextStep>(_onNextStep);
    on<ReportEmotion>(_onReportEmotion);
    on<SubmitRating>(_onSubmitRating);
    on<ResetScan>(_onResetScan);
  }

  void _onStartScan(StartScan event, Emitter<BodyScanState> emit) {
    // Comienza en la primera zona, sin emociones registradas, registrando tiempo de inicio
    emit(ScanInProgress(0, const [], DateTime.now()));
  }

  void _onNextStep(NextStep event, Emitter<BodyScanState> emit) {
    final state = this.state;
    if (state is ScanInProgress) {
      // Después de ver cada paso, pedimos el reporte emocional
      emit(ScanNeedsEmotionReport(state.index, state.emotions, state.startTime));
    }
  }

  void _onReportEmotion(ReportEmotion event, Emitter<BodyScanState> emit) {
    final state = this.state;
    if (state is ScanNeedsEmotionReport) {
      final updatedEmotions = List<bool>.from(state.emotions)..add(event.relaxed);

      // Verificar si ya completamos todas las zonas
      if (updatedEmotions.length >= scanSteps.length) {
        // Todas las zonas completadas, pedir calificación
        emit(ScanNeedsRating(updatedEmotions, state.startTime));
      } else {
        // Continuar al siguiente paso
        final nextIndex = updatedEmotions.length;
        emit(ScanInProgress(nextIndex, updatedEmotions, state.startTime));
      }
    }
  }

  void _onSubmitRating(SubmitRating event, Emitter<BodyScanState> emit) async {
    final state = this.state;
    if (state is ScanNeedsRating) {
      emit(ScanSaving());

      // Calcular duración
      final endTime = DateTime.now();
      final durationSeconds = endTime.difference(state.startTime).inSeconds;

      // Obtener userId
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(const ScanError('Usuario no autenticado'));
        return;
      }

      // Crear sesión
      final session = BodyScanSessionEntity(
        id: '', // Firestore generará el ID
        userId: userId,
        completedAt: endTime,
        emotionReports: state.emotions,
        rating: event.rating,
        durationSeconds: durationSeconds,
      );

      // Guardar en Firebase
      final result = await saveSessionUseCase.call(session);

      // Manejar el resultado
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        emit(ScanError('Error al guardar: ${failure?.message ?? "Error desconocido"}'));
        return;
      }

      // Sesión guardada exitosamente, ahora incrementar puntos
      await incrementPointsUseCase.call(
        IncrementPointsParams(
          userId: userId,
          activityKey: 'body_scan',
        ),
      );

      // Emitir estado de éxito (independiente si los puntos se guardaron o no)
      if (!emit.isDone) {
        emit(ScanSaved(state.emotions, event.rating, durationSeconds));
      }
    }
  }

  void _onResetScan(ResetScan event, Emitter<BodyScanState> emit) {
    emit(ScanInitial());
  }
}
