import 'package:equatable/equatable.dart';
import 'stop_session_entity.dart';

/// Reporte semanal de sesiones de STOP
class WeeklyStopReportEntity extends Equatable {
  final List<StopSessionEntity> sessions;
  final DateTime weekStart;
  final DateTime weekEnd;

  const WeeklyStopReportEntity({
    required this.sessions,
    required this.weekStart,
    required this.weekEnd,
  });

  /// Número total de sesiones en la semana
  int get totalSessions => sessions.length;

  /// Promedio de éxitos en respiración
  double get averageBreathSuccesses {
    if (sessions.isEmpty) return 0.0;
    final total = sessions.fold<int>(0, (sum, s) => sum + s.breathSuccesses);
    return total / sessions.length;
  }

  /// Total de minutos de práctica en la semana
  int get totalMinutes {
    return sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds) ~/ 60;
  }

  /// Emoción más identificada
  String get mostIdentifiedEmotion {
    if (sessions.isEmpty) return 'N/A';

    final emotionCounts = <String, int>{};
    for (final session in sessions) {
      emotionCounts[session.emotion] = (emotionCounts[session.emotion] ?? 0) + 1;
    }

    return emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Acción más elegida
  String get mostChosenAction {
    if (sessions.isEmpty) return 'N/A';

    final actionCounts = <String, int>{};
    for (final session in sessions) {
      actionCounts[session.action] = (actionCounts[session.action] ?? 0) + 1;
    }

    return actionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Porcentaje de sesiones exitosas (2+ éxitos en respiración)
  double get successfulSessionsPercentage {
    if (sessions.isEmpty) return 0.0;
    final successful = sessions.where((s) => s.isSuccessful).length;
    return (successful / sessions.length) * 100;
  }

  @override
  List<Object?> get props => [sessions, weekStart, weekEnd];
}
