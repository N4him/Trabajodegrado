import 'package:equatable/equatable.dart';
import '../../shared/domain/entities/wellbeing_points_entity.dart';

/// Estados para el BLoC de puntos de bienestar
abstract class WellbeingPointsState extends Equatable {
  const WellbeingPointsState();

  @override
  List<Object> get props => [];
}

/// Estado inicial
class WellbeingPointsInitial extends WellbeingPointsState {}

/// Estado de carga
class WellbeingPointsLoading extends WellbeingPointsState {}

/// Estado con puntos cargados
class WellbeingPointsLoaded extends WellbeingPointsState {
  final WellbeingPointsEntity points;

  const WellbeingPointsLoaded(this.points);

  @override
  List<Object> get props => [points];
}

/// Estado de error
class WellbeingPointsError extends WellbeingPointsState {
  final String message;

  const WellbeingPointsError(this.message);

  @override
  List<Object> get props => [message];
}
