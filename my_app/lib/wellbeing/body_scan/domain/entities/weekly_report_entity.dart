import 'package:equatable/equatable.dart';
import 'body_scan_session_entity.dart';

/// Entidad que representa un reporte semanal de sesiones de Escaneo Corporal
class WeeklyReportEntity extends Equatable {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<BodyScanSessionEntity> sessions;

  const WeeklyReportEntity({
    required this.weekStart,
    required this.weekEnd,
    required this.sessions,
  });

  /// Cantidad total de sesiones en la semana
  int get totalSessions => sessions.length;

  /// Promedio de calificación de la semana
  double get averageRating {
    if (sessions.isEmpty) return 0.0;
    final sum = sessions.fold<double>(0, (sum, session) => sum + session.rating);
    return sum / sessions.length;
  }

  /// Promedio de relajación de la semana
  double get averageRelaxation {
    if (sessions.isEmpty) return 0.0;
    final sum = sessions.fold<double>(
      0,
      (sum, session) => sum + session.relaxationPercentage,
    );
    return sum / sessions.length;
  }

  /// Total de minutos practicados en la semana
  int get totalMinutes {
    return sessions.fold<int>(
      0,
      (sum, session) => sum + (session.durationSeconds ~/ 60),
    );
  }

  /// Identifica la parte del cuerpo con más tensión en la semana
  /// Retorna el índice de la parte (0-7)
  int? get mostTensePart {
    if (sessions.isEmpty) return null;

    // Array para contar tensión por cada parte (8 partes)
    final tensionCounts = List<int>.filled(8, 0);

    // Contar tensión por cada parte en todas las sesiones
    for (final session in sessions) {
      for (int i = 0; i < session.emotionReports.length; i++) {
        if (!session.emotionReports[i]) {
          // false = tenso
          tensionCounts[i]++;
        }
      }
    }

    // Encontrar el índice con mayor tensión
    int maxIndex = 0;
    int maxValue = tensionCounts[0];
    for (int i = 1; i < tensionCounts.length; i++) {
      if (tensionCounts[i] > maxValue) {
        maxValue = tensionCounts[i];
        maxIndex = i;
      }
    }

    return maxValue > 0 ? maxIndex : null;
  }

  /// Mejora de la semana (comparando primera vs última sesión)
  double? get weeklyImprovement {
    if (sessions.length < 2) return null;
    final firstSession = sessions.first;
    final lastSession = sessions.last;
    return lastSession.relaxationPercentage - firstSession.relaxationPercentage;
  }

  @override
  List<Object?> get props => [weekStart, weekEnd, sessions];
}
