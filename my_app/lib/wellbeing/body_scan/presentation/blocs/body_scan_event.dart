import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de Body Scan (Viaje Sensorial)
abstract class BodyScanEvent extends Equatable {
  const BodyScanEvent();

  @override
  List<Object> get props => [];
}

/// Inicia el escaneo corporal desde la primera zona.
class StartScan extends BodyScanEvent {}

/// Avanza a la siguiente zona del cuerpo.
class NextStep extends BodyScanEvent {}

/// Reporta la emoción del usuario en el autoinforme: relajado (true) o tenso (false).
class ReportEmotion extends BodyScanEvent {
  final bool relaxed;

  const ReportEmotion(this.relaxed);

  @override
  List<Object> get props => [relaxed];
}

/// Envía la calificación final de la sesión (1-5).
class SubmitRating extends BodyScanEvent {
  final int rating;

  const SubmitRating(this.rating);

  @override
  List<Object> get props => [rating];
}

/// Reinicia el escaneo para empezar de nuevo.
class ResetScan extends BodyScanEvent {}
