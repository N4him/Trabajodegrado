import 'package:equatable/equatable.dart';

/// Estados para el BLoC de Body Scan (Viaje Sensorial)
abstract class BodyScanState extends Equatable {
  const BodyScanState();

  @override
  List<Object> get props => [];
}

/// Estado inicial antes de comenzar.
class ScanInitial extends BodyScanState {}

/// Estado durante el recorrido activo.
/// [index]: índice de la zona actual.
/// [emotions]: lista de respuestas de autoinforme hasta el momento.
/// [startTime]: momento en que inició la sesión.
class ScanInProgress extends BodyScanState {
  final int index;
  final List<bool> emotions;
  final DateTime startTime;

  const ScanInProgress(this.index, this.emotions, this.startTime);

  @override
  List<Object> get props => [index, emotions, startTime];
}

/// Estado que indica que se debe mostrar el autoinforme.
/// sucede después de cada zona.
class ScanNeedsEmotionReport extends BodyScanState {
  final int index;
  final List<bool> emotions;
  final DateTime startTime;

  const ScanNeedsEmotionReport(this.index, this.emotions, this.startTime);

  @override
  List<Object> get props => [index, emotions, startTime];
}

/// Estado que solicita la calificación del 1 al 5.
class ScanNeedsRating extends BodyScanState {
  final List<bool> emotions;
  final DateTime startTime;

  const ScanNeedsRating(this.emotions, this.startTime);

  @override
  List<Object> get props => [emotions, startTime];
}

/// Estado mientras se guarda en Firebase.
class ScanSaving extends BodyScanState {}

/// Estado cuando se guardó exitosamente.
class ScanSaved extends BodyScanState {
  final List<bool> emotions;
  final int rating;
  final int durationSeconds;

  const ScanSaved(this.emotions, this.rating, this.durationSeconds);

  @override
  List<Object> get props => [emotions, rating, durationSeconds];
}

/// Estado de error al guardar.
class ScanError extends BodyScanState {
  final String message;

  const ScanError(this.message);

  @override
  List<Object> get props => [message];
}
