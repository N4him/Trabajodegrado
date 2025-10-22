import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de puntos de bienestar
abstract class WellbeingPointsEvent extends Equatable {
  const WellbeingPointsEvent();

  @override
  List<Object> get props => [];
}

/// Carga los puntos del usuario
class LoadWellbeingPoints extends WellbeingPointsEvent {
  final String userId;

  const LoadWellbeingPoints(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Recarga los puntos del usuario
class RefreshWellbeingPoints extends WellbeingPointsEvent {
  final String userId;

  const RefreshWellbeingPoints(this.userId);

  @override
  List<Object> get props => [userId];
}
