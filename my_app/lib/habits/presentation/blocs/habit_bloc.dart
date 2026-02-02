// habits/presentation/blocs/habit_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/gamification/domain/usecases/get_gamificacion_data.dart';
import 'package:my_app/gamification/domain/usecases/update_estado_general.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_bloc.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_event.dart';
import 'habit_event.dart';
import 'habit_state.dart';
// Importa tus Use Cases
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/register_completion_usecase.dart';
import '../../domain/usecases/get_habits_by_user_usecase.dart';
import '../../domain/usecases/get_habit_progress_usecase.dart';
import '../../domain/usecases/delete_habit_usecase.dart';
import '../../domain/entities/habit_entity.dart';
import '../../../services/notification_service.dart';
import '../../../gamification/domain/usecases/update_modulo_progress.dart';
import '../../../gamification/domain/entities/modulo_progreso.dart';


class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final CreateHabitUseCase createHabitUseCase;
  final RegisterCompletionUseCase registerCompletionUseCase;
  final GetHabitsByUserUseCase getHabitsByUserUseCase;
  final GetHabitProgressUseCase getHabitProgressUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final NotificationService? notificationService;
  final UpdateModuloProgress updateModuloProgress;
  final UpdateEstadoGeneral updateEstadoGeneral;
  final GetGamificacionData getGamificacionData;
  final GamificacionBloc gamificacionBloc;  // <-- agregar esto

  HabitBloc({
    required this.createHabitUseCase,
    required this.registerCompletionUseCase,
    required this.getHabitsByUserUseCase,
    required this.getHabitProgressUseCase,
    required this.deleteHabitUseCase,
    this.notificationService,
    required this.updateModuloProgress,
    required this.updateEstadoGeneral,
    required this.getGamificacionData,
    required this.gamificacionBloc,  // <-- agregar esto

  }) : super(HabitInitial()) {

    // Configuración de los handlers de eventos
    on<CreateHabitStarted>(_onCreateHabit);
    on<RegisterCompletionStarted>(_onRegisterCompletion);
    on<FetchHabitsStarted>(_onFetchHabits);
    on<FetchHabitsProgressStarted>(_onFetchHabitsProgress);
    on<DeleteHabitStarted>(_onDeleteHabit);
  }

  // --- Handlers de Eventos (Lógica Pendiente) ---

  Future<void> _onCreateHabit(
    CreateHabitStarted event,
    Emitter<HabitState> emit,
) async {
    print('>>> 3. BLoC Handler RECIBIDO: Evento CreateHabitStarted para ${event.name}');

    emit(HabitLoading());

    try {
        // 1. CONSTRUIR LA ENTIDAD con todos los datos del evento
        final newHabit = HabitEntity(
            id: '',
            name: event.name,
            frequencyDays: event.frequencyDays,
            userId: event.userId,
            startDate: event.startDate,
            reminderTime: event.reminderTime,
        );

        print('>>> 4. BLoC LLAMANDO al CreateHabitUseCase...');

        await createHabitUseCase.call(newHabit);

        // 3. Emitir Éxito REAL después de que el Use Case retorne
        print('>>> 5. BLoC ÉXITO. Hábito guardado en DB.');

        // DIAGNÓSTICO: Verificar notificaciones pendientes
        if (notificationService != null) {
          final pending = await notificationService!.getPendingNotifications();
          print('>>> 🔔 DIAGNÓSTICO: ${pending.length} notificaciones programadas');
          for (var n in pending) {
            print('    - ${n.title} (ID: ${n.id})');
          }
        }

        emit(HabitActionSuccess(message: 'Hábito "${event.name}" guardado exitosamente.'));

    } catch (e) {
        // 4. Emitir Fallo si el Use Case o Firestore fallan
        print('>>> ❌ FALLO en BLoC/Use Case: $e');
        emit(HabitFailure(error: 'Fallo al guardar: ${e.toString()}'));
    }
}

Future<void> _onRegisterCompletion(
  RegisterCompletionStarted event,
  Emitter<HabitState> emit,
) async {
  print('>>> [HABITOS] Registrando completitud para hábito ${event.habitId}');
  emit(HabitLoading());

  try {
    final now = DateTime.now();

    // Registrar la completitud del hábito
    await registerCompletionUseCase.call(
      habitId: event.habitId,
      userId: event.userId,
      date: now,
    );

    // 1. Obtener datos actuales de gamificación ANTES de actualizar
    final gamificacion = await getGamificacionData.call(event.userId);
    
    print('🔍 DEBUG gamificacion.modulos: ${gamificacion.modulos.keys}');
    print('🔍 DEBUG tiene habitos?: ${gamificacion.modulos.containsKey('habitos')}');
    
    final moduloHabitos = gamificacion.modulos['habitos'];
    print('🔍 DEBUG moduloHabitos: $moduloHabitos');
    print('🔍 DEBUG moduloHabitos es null?: ${moduloHabitos == null}');
    
    if (moduloHabitos != null) {
      print('🔍 DEBUG ultimaActividad: ${moduloHabitos.ultimaActividad}');
      print('🔍 DEBUG ultimaActividad es null?: ${moduloHabitos.ultimaActividad == null}');
    }
    
    final estadoActual = gamificacion.estadoGeneral;

    // 2. VERIFICAR Y AJUSTAR SALUD según actividad previa
    if (moduloHabitos?.ultimaActividad != null) {
      print('✅ ENTRANDO a verificación de días');
      
      final ultimaActividad = moduloHabitos!.ultimaActividad!;
      final ultimaDia = DateTime(
        ultimaActividad.year,
        ultimaActividad.month,
        ultimaActividad.day,
      );
      final hoy = DateTime(now.year, now.month, now.day);
      
      // Calcular cuántos días pasaron desde la última actividad
      final diasSinActividad = hoy.difference(ultimaDia).inDays;
      
      print('>>> [HABITOS] 📊 Última actividad: $ultimaDia');
      print('>>> [HABITOS] 📊 Hoy: $hoy');
      print('>>> [HABITOS] 📊 Días sin actividad: $diasSinActividad');
      
      // Si pasó más de 1 día sin actividad, penalizar
      if (diasSinActividad > 1) {
        final diasPerdidos = diasSinActividad - 1; // Excluir hoy
        final penalizacion = diasPerdidos * 10;
        final nuevaSalud = (estadoActual.salud - penalizacion).clamp(0, 100);
        
        print('>>> [HABITOS] ⚠️ Penalización: $diasPerdidos días × 10 = -$penalizacion puntos');
        print('>>> [HABITOS] 📉 Salud: ${estadoActual.salud} → $nuevaSalud');
        
        await updateEstadoGeneral.call(
          userId: event.userId,
          estadoGeneral: estadoActual.copyWith(
            salud: nuevaSalud,
            plantaValor: estadoActual.plantaValor + 1,
            ultimaPenalizacion: now,
            ultimaActualizacion: now,
          ),
        );
      } else {
        print('>>> [HABITOS] ℹ️ Sin penalización (diasSinActividad: $diasSinActividad)');
        
        // No hubo días perdidos, solo actualizar plantaValor y recuperar salud
        final recuperacionSalud = estadoActual.salud < 100 ? 5 : 0;
        final nuevaSalud = (estadoActual.salud + recuperacionSalud).clamp(0, 100);
        
        if (recuperacionSalud > 0) {
          print('>>> [HABITOS] 💚 Recuperación de salud: ${estadoActual.salud} → $nuevaSalud');
        }
        
        await updateEstadoGeneral.call(
          userId: event.userId,
          estadoGeneral: estadoActual.copyWith(
            salud: nuevaSalud,
            plantaValor: estadoActual.plantaValor + 1,
            ultimaActualizacion: now,
          ),
        );
      }
    } else {
      // Primera vez que completa un hábito
      print('>>> [HABITOS] 🌱 Primera actividad registrada');
      await updateEstadoGeneral.call(
        userId: event.userId,
        estadoGeneral: estadoActual.copyWith(
          plantaValor: estadoActual.plantaValor + 1,
          ultimaActualizacion: now,
        ),
      );
    }

    // 3. Actualizar progreso del módulo (esto actualiza ultimaActividad)
    try {
      await updateModuloProgress.call(
        userId: event.userId,
        moduloKey: 'habitos',
        progreso: const ModuloProgreso(
          sesionesCompletadas: 1,
          diasCumplidos: 1,
          puntosObtenidos: 1,
        ),
      );
      print('>>> [HABITOS] ✅ Progreso del módulo actualizado');
    } catch (e) {
      print('>>> [HABITOS] ⚠️ Error al actualizar progreso del módulo: $e');
    }

    // 4. Agregar evento al historial de gamificación
    try {
      gamificacionBloc.add(AddEventToHistorialEvent(
        userId: event.userId,
        fecha: now,
      ));
      print('>>> [HABITOS] 📅 Evento agregado al historial');
    } catch (e) {
      print('>>> [HABITOS] ⚠️ Error al agregar evento al historial: $e');
    }

    emit(HabitActionSuccess(message: 'Hábito marcado como completado'));
  } catch (e) {
    print('>>> ❌ BLoC: Error al registrar completitud: $e');
    emit(HabitFailure(error: 'Error al marcar hábito: ${e.toString()}'));
  }
}

  Future<void> _onFetchHabits(
    FetchHabitsStarted event,
    Emitter<HabitState> emit,
  ) async {
    print('>>> BLoC: Obteniendo hábitos para usuario ${event.userId}');
    emit(HabitLoading());

    try {
      final habits = await getHabitsByUserUseCase.call(event.userId);
      print('>>> BLoC: ${habits.length} hábitos cargados exitosamente');

      // Sincronizar notificaciones con los hábitos cargados
      if (notificationService != null && habits.isNotEmpty) {
        await notificationService!.syncAllNotifications(habits);
        print('>>> BLoC: Notificaciones sincronizadas para ${habits.length} hábitos');
      }

      emit(HabitsLoaded(habits: habits));
    } catch (e) {
      print('>>> ❌ BLoC: Error al obtener hábitos: $e');
      emit(HabitFailure(error: 'Error al cargar hábitos: ${e.toString()}'));
    }
  }
Future<void> _onFetchHabitsProgress(
  FetchHabitsProgressStarted event,
  Emitter<HabitState> emit,
) async {
  emit(HabitLoading());

  try {
    final habitsProgress = await getHabitProgressUseCase.getAllHabitsProgress(
      userId: event.userId,
    );

    emit(HabitsProgressLoaded(habitsProgress: habitsProgress));
  } catch (e) {
    emit(HabitFailure(error: 'Error al cargar progreso: ${e.toString()}'));
  }
}

  Future<void> _onDeleteHabit(
    DeleteHabitStarted event,
    Emitter<HabitState> emit,
  ) async {
    print('>>> [HABITOS] Eliminando hábito ${event.habitId}');
    emit(HabitLoading());

    try {
      // Cancelar notificación si existe
      if (notificationService != null) {
        await notificationService!.cancelNotification(event.habitId);
        print('>>> [HABITOS] Notificación cancelada');
      }

      // Eliminar hábito del repositorio
      await deleteHabitUseCase.call(
        habitId: event.habitId,
        userId: event.userId,
      );

      print('>>> [HABITOS] ✅ Hábito eliminado exitosamente');
      emit(HabitActionSuccess(message: 'Hábito eliminado correctamente'));
    } catch (e) {
      print('>>> ❌ BLoC: Error al eliminar hábito: $e');
      emit(HabitFailure(error: 'Error al eliminar hábito: ${e.toString()}'));
    }
  }
}