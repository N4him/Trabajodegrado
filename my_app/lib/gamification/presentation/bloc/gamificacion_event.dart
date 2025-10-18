import 'package:equatable/equatable.dart';
import 'package:my_app/gamification/domain/entities/modulo_progreso.dart';

abstract class GamificacionEvent extends Equatable {
  const GamificacionEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar los datos de gamificación del usuario
class LoadGamificacionData extends GamificacionEvent {
  final String userId;

  const LoadGamificacionData({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para actualizar el progreso de un módulo específico
class UpdateModuloProgressEvent extends GamificacionEvent {
  final String userId;
  final String moduloKey;
  final ModuloProgreso progreso;

  const UpdateModuloProgressEvent({
    required this.userId,
    required this.moduloKey,
    required this.progreso,
  });

  @override
  List<Object?> get props => [userId, moduloKey, progreso];
}

/// Evento para agregar un evento al historial (heatmap)
class AddEventToHistorialEvent extends GamificacionEvent {
  final String userId;
  final DateTime fecha;

  const AddEventToHistorialEvent({
    required this.userId,
    required this.fecha,
  });

  @override
  List<Object?> get props => [userId, fecha];
}

/// Evento para verificar y desbloquear nuevas insignias
class CheckAndUnlockInsigniasEvent extends GamificacionEvent {
  final String userId;

  const CheckAndUnlockInsigniasEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para cargar las insignias del usuario
class LoadUserInsignias extends GamificacionEvent {
  final String userId;

  const LoadUserInsignias({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para refrescar todos los datos
class RefreshGamificacionData extends GamificacionEvent {
  final String userId;

  const RefreshGamificacionData({required this.userId});

  @override
  List<Object?> get props => [userId];
}