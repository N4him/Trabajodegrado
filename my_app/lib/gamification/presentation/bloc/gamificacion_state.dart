import 'package:equatable/equatable.dart';
import 'package:my_app/gamification/domain/entities/gamificacion.dart';
import 'package:my_app/gamification/domain/entities/insignia.dart';

abstract class GamificacionState extends Equatable {
  const GamificacionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class GamificacionInitial extends GamificacionState {
  const GamificacionInitial();
}

/// Estado de carga
class GamificacionLoading extends GamificacionState {
  const GamificacionLoading();
}

/// Estado de datos cargados exitosamente
class GamificacionLoaded extends GamificacionState {
  final Gamificacion gamificacion;
  final List<Insignia>? insignias;
  final List<Insignia>? insigniasRecienDesbloqueadas;

  const GamificacionLoaded({
    required this.gamificacion,
    this.insignias,
    this.insigniasRecienDesbloqueadas,
  });

  @override
  List<Object?> get props => [
        gamificacion,
        insignias,
        insigniasRecienDesbloqueadas,
      ];

  GamificacionLoaded copyWith({
    Gamificacion? gamificacion,
    List<Insignia>? insignias,
    List<Insignia>? insigniasRecienDesbloqueadas,
    bool clearRecienDesbloqueadas = false,
  }) {
    return GamificacionLoaded(
      gamificacion: gamificacion ?? this.gamificacion,
      insignias: insignias ?? this.insignias,
      insigniasRecienDesbloqueadas: clearRecienDesbloqueadas
          ? null
          : (insigniasRecienDesbloqueadas ?? this.insigniasRecienDesbloqueadas),
    );
  }
}

/// Estado de actualización en progreso (mantiene datos anteriores)
class GamificacionUpdating extends GamificacionState {
  final Gamificacion gamificacion;
  final List<Insignia>? insignias;

  const GamificacionUpdating({
    required this.gamificacion,
    this.insignias,
  });

  @override
  List<Object?> get props => [gamificacion, insignias];
}

/// Estado de error
class GamificacionError extends GamificacionState {
  final String message;
  final Gamificacion? previousGamificacion;
  final List<Insignia>? previousInsignias;

  const GamificacionError({
    required this.message,
    this.previousGamificacion,
    this.previousInsignias,
  });

  @override
  List<Object?> get props => [message, previousGamificacion, previousInsignias];
}

/// Estado de insignias desbloqueadas
class InsigniasUnlocked extends GamificacionState {
  final List<Insignia> insigniasDesbloqueadas;
  final Gamificacion gamificacion;

  const InsigniasUnlocked({
    required this.insigniasDesbloqueadas,
    required this.gamificacion,
  });

  @override
  List<Object?> get props => [insigniasDesbloqueadas, gamificacion];
}