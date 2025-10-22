import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/domain/usecases/get_wellbeing_points_usecase.dart';
import 'wellbeing_points_event.dart';
import 'wellbeing_points_state.dart';

/// BLoC que gestiona los puntos de bienestar en la pantalla principal
class WellbeingPointsBloc
    extends Bloc<WellbeingPointsEvent, WellbeingPointsState> {
  final GetWellbeingPointsUseCase getPointsUseCase;

  WellbeingPointsBloc({required this.getPointsUseCase})
      : super(WellbeingPointsInitial()) {
    on<LoadWellbeingPoints>(_onLoadPoints);
    on<RefreshWellbeingPoints>(_onRefreshPoints);
  }

  Future<void> _onLoadPoints(
    LoadWellbeingPoints event,
    Emitter<WellbeingPointsState> emit,
  ) async {
    emit(WellbeingPointsLoading());
    await _fetchPoints(event.userId, emit);
  }

  Future<void> _onRefreshPoints(
    RefreshWellbeingPoints event,
    Emitter<WellbeingPointsState> emit,
  ) async {
    // No mostrar loading en refresh, solo actualizar datos
    await _fetchPoints(event.userId, emit);
  }

  Future<void> _fetchPoints(
    String userId,
    Emitter<WellbeingPointsState> emit,
  ) async {
    final result = await getPointsUseCase.call(userId);

    result.fold(
      (failure) => emit(WellbeingPointsError(failure.message)),
      (points) => emit(WellbeingPointsLoaded(points)),
    );
  }
}
