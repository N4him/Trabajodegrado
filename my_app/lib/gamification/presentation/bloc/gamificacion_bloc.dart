import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/gamification/domain/entities/gamificacion.dart';
import 'package:my_app/gamification/domain/usecases/get_gamificacion_data.dart';
import 'package:my_app/gamification/domain/usecases/update_modulo_progress.dart';
import 'package:my_app/gamification/domain/usecases/add_event_to_historial.dart';
import 'package:my_app/gamification/domain/usecases/check_and_unlock_insignias.dart';
import 'package:my_app/gamification/domain/usecases/get_user_insignias.dart';
import 'gamificacion_event.dart';
import 'gamificacion_state.dart';

class GamificacionBloc extends Bloc<GamificacionEvent, GamificacionState> {
  final GetGamificacionData getGamificacionData;
  final UpdateModuloProgress updateModuloProgress;
  final AddEventToHistorial addEventToHistorial;
  final CheckAndUnlockInsignias checkAndUnlockInsignias;
  final GetUserInsignias getUserInsignias;

  GamificacionBloc({
    required this.getGamificacionData,
    required this.updateModuloProgress,
    required this.addEventToHistorial,
    required this.checkAndUnlockInsignias,
    required this.getUserInsignias,
  }) : super(const GamificacionInitial()) {
    on<LoadGamificacionData>(_onLoadGamificacionData);
    on<UpdateModuloProgressEvent>(_onUpdateModuloProgress);
    on<AddEventToHistorialEvent>(_onAddEventToHistorial);
    on<CheckAndUnlockInsigniasEvent>(_onCheckAndUnlockInsignias);
    on<LoadUserInsignias>(_onLoadUserInsignias);
    on<RefreshGamificacionData>(_onRefreshGamificacionData);
  }

  Future<void> _onLoadGamificacionData(
    LoadGamificacionData event,
    Emitter<GamificacionState> emit,
  ) async {
    emit(const GamificacionLoading());

    try {
      final gamificacion = await getGamificacionData(event.userId);
      final insignias = await getUserInsignias(event.userId);

      emit(GamificacionLoaded(
        gamificacion: gamificacion,
        insignias: insignias,
      ));
    } catch (e) {
      emit(GamificacionError(
        message: 'Error al cargar datos de gamificación: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateModuloProgress(
    UpdateModuloProgressEvent event,
    Emitter<GamificacionState> emit,
  ) async {
    final currentState = state;
    
    // Mantener datos actuales mientras actualiza
    if (currentState is GamificacionLoaded) {
      emit(GamificacionUpdating(
        gamificacion: currentState.gamificacion,
        insignias: currentState.insignias,
      ));
    }

    try {
      await updateModuloProgress(
        userId: event.userId,
        moduloKey: event.moduloKey,
        progreso: event.progreso,
      );

      // Recargar datos actualizados
      final gamificacion = await getGamificacionData(event.userId);
      
      if (currentState is GamificacionLoaded) {
        emit(currentState.copyWith(gamificacion: gamificacion));
      } else {
        final insignias = await getUserInsignias(event.userId);
        emit(GamificacionLoaded(
          gamificacion: gamificacion,
          insignias: insignias,
        ));
      }

      // Verificar automáticamente si se desbloquearon nuevas insignias
      add(CheckAndUnlockInsigniasEvent(userId: event.userId));
    } catch (e) {
      final previousData = currentState is GamificacionLoaded
          ? currentState.gamificacion
          : null;
      final previousInsignias = currentState is GamificacionLoaded
          ? currentState.insignias
          : null;

      emit(GamificacionError(
        message: 'Error al actualizar progreso: ${e.toString()}',
        previousGamificacion: previousData,
        previousInsignias: previousInsignias,
      ));
    }
  }

  Future<void> _onAddEventToHistorial(
    AddEventToHistorialEvent event,
    Emitter<GamificacionState> emit,
  ) async {
    final currentState = state;

    try {
      await addEventToHistorial(
        userId: event.userId,
        fecha: event.fecha,
      );

      // Recargar datos actualizados
      final gamificacion = await getGamificacionData(event.userId);

      if (currentState is GamificacionLoaded) {
        emit(currentState.copyWith(gamificacion: gamificacion));
      } else {
        final insignias = await getUserInsignias(event.userId);
        emit(GamificacionLoaded(
          gamificacion: gamificacion,
          insignias: insignias,
        ));
      }
    } catch (e) {
      final previousData = currentState is GamificacionLoaded
          ? currentState.gamificacion
          : null;
      final previousInsignias = currentState is GamificacionLoaded
          ? currentState.insignias
          : null;

      emit(GamificacionError(
        message: 'Error al agregar evento al historial: ${e.toString()}',
        previousGamificacion: previousData,
        previousInsignias: previousInsignias,
      ));
    }
  }

  Future<void> _onCheckAndUnlockInsignias(
    CheckAndUnlockInsigniasEvent event,
    Emitter<GamificacionState> emit,
  ) async {
    final currentState = state;

    if (currentState is! GamificacionLoaded) {
      return;
    }

    try {
      final insigniasDesbloqueadas = await checkAndUnlockInsignias(
        userId: event.userId,
        gamificacion: currentState.gamificacion,
      );

      if (insigniasDesbloqueadas.isNotEmpty) {
        // Recargar datos actualizados
        final gamificacion = await getGamificacionData(event.userId);
        final todasInsignias = await getUserInsignias(event.userId);

        emit(currentState.copyWith(
          gamificacion: gamificacion,
          insignias: todasInsignias,
          insigniasRecienDesbloqueadas: insigniasDesbloqueadas,
        ));
      }
    } catch (e) {
      // No emitir error aquí, solo mantener el estado actual
      // para que la verificación de insignias no interrumpa el flujo
      print('Error al verificar insignias: $e');
    }
  }

  Future<void> _onLoadUserInsignias(
    LoadUserInsignias event,
    Emitter<GamificacionState> emit,
  ) async {
    final currentState = state;

    try {
      final insignias = await getUserInsignias(event.userId);

      if (currentState is GamificacionLoaded) {
        emit(currentState.copyWith(insignias: insignias));
      } else {
        // Si no hay datos cargados, cargar todo
        add(LoadGamificacionData(userId: event.userId));
      }
    } catch (e) {
      final previousData = currentState is GamificacionLoaded
          ? currentState.gamificacion
          : null;
      final previousInsignias = currentState is GamificacionLoaded
          ? currentState.insignias
          : null;

      emit(GamificacionError(
        message: 'Error al cargar insignias: ${e.toString()}',
        previousGamificacion: previousData,
        previousInsignias: previousInsignias,
      ));
    }
  }

  Future<void> _onRefreshGamificacionData(
    RefreshGamificacionData event,
    Emitter<GamificacionState> emit,
  ) async {
    final currentState = state;

    // Mantener datos actuales mientras refresca
    if (currentState is GamificacionLoaded) {
      emit(GamificacionUpdating(
        gamificacion: currentState.gamificacion,
        insignias: currentState.insignias,
      ));
    }

    try {
      final gamificacion = await getGamificacionData(event.userId);
      final insignias = await getUserInsignias(event.userId);

      emit(GamificacionLoaded(
        gamificacion: gamificacion,
        insignias: insignias,
      ));
    } catch (e) {
      final previousData = currentState is GamificacionLoaded
          ? currentState.gamificacion
          : null;
      final previousInsignias = currentState is GamificacionLoaded
          ? currentState.insignias
          : null;

      emit(GamificacionError(
        message: 'Error al refrescar datos: ${e.toString()}',
        previousGamificacion: previousData,
        previousInsignias: previousInsignias,
      ));
    }
  }
}