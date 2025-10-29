import 'package:equatable/equatable.dart';
import 'breathing_session_entity.dart';

/// Reporte semanal de sesiones de respiración
class WeeklyBreathingReportEntity extends Equatable {
  final List<BreathingSessionEntity> sessions;
  final DateTime weekStart;
  final DateTime weekEnd;

  const WeeklyBreathingReportEntity({
    required this.sessions,
    required this.weekStart,
    required this.weekEnd,
  });

  /// Número total de sesiones en la semana
  int get totalSessions => sessions.length;

  /// Promedio de partículas recolectadas por sesión
  double get averageParticlesCollected {
    if (sessions.isEmpty) return 0.0;
    final total = sessions.fold<int>(0, (sum, s) => sum + s.particlesCollected);
    return total / sessions.length;
  }

  /// Promedio de tasa de recolección (%)
  double get averageCollectionRate {
    if (sessions.isEmpty) return 0.0;
    final totalRate = sessions.fold<double>(0, (sum, s) => sum + s.collectionRate);
    return totalRate / sessions.length;
  }

  /// Total de minutos de práctica en la semana
  int get totalMinutes {
    return sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds) ~/ 60;
  }

  /// Promedio de puntaje de sesión (0-100)
  double get averageScore {
    if (sessions.isEmpty) return 0.0;
    final totalScore = sessions.fold<int>(0, (sum, s) => sum + s.sessionScore);
    return totalScore / sessions.length;
  }

  /// Modo más practicado
  String get mostPracticedMode {
    if (sessions.isEmpty) return 'N/A';

    final modeCounts = <String, int>{};
    for (final session in sessions) {
      modeCounts[session.mode] = (modeCounts[session.mode] ?? 0) + 1;
    }

    return modeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Mejora semanal (comparando primera mitad vs segunda mitad)
  double get weeklyImprovement {
    if (sessions.length < 2) return 0.0;

    final mid = sessions.length ~/ 2;
    final firstHalf = sessions.sublist(0, mid);
    final secondHalf = sessions.sublist(mid);

    final firstAvg = firstHalf.fold<int>(0, (sum, s) => sum + s.sessionScore) / firstHalf.length;
    final secondAvg = secondHalf.fold<int>(0, (sum, s) => sum + s.sessionScore) / secondHalf.length;

    return secondAvg - firstAvg;
  }

  @override
  List<Object?> get props => [sessions, weekStart, weekEnd];
}
