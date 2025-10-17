import 'habit_entity.dart';

/// Clase que representa el progreso calculado de un hábito
/// NOTA: Estos datos NO se guardan en la base de datos, se calculan en tiempo real
class HabitProgress {
  final HabitEntity habit;

  // --- CONTADORES SEMANALES ---
  final int completedThisWeek; // Cuántos días completó esta semana
  final int expectedThisWeek; // Cuántos días debería completar (según frequencyDays)

  // --- PORCENTAJES ---
  final double weeklyCompletionRate; // % completado esta semana (0-100)
  final double overallSuccessRate; // % completado total (0-100)

  // --- RACHAS ---
  final int currentStreak; // Días/semanas consecutivas actuales
  final int bestStreak; // Mejor racha histórica

  // --- ESTADO ACTUAL ---
  final bool isTodayCompleted; // ¿Completó hoy? true/false
  final bool canCompleteToday; // ¿Puede completar hoy según la frecuencia?

  // --- ESTADO SEMANAL ---
  final WeeklyStatus weeklyStatus; // Estado de la semana actual

  // --- TENDENCIA MENSUAL (para gráfico) ---
  final List<WeeklyProgress> monthlyTrend; // Progreso de las últimas 4 semanas

  HabitProgress({
    required this.habit,
    required this.completedThisWeek,
    required this.expectedThisWeek,
    required this.weeklyCompletionRate,
    required this.overallSuccessRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.isTodayCompleted,
    required this.canCompleteToday,
    required this.weeklyStatus,
    required this.monthlyTrend,
  });

  /// Obtiene el texto formateado de la frecuencia
  String get frequencyText {
    switch (habit.frequencyDays) {
      case 7:
        return 'Diario';
      case 5:
        return '5 veces/semana';
      case 3:
        return '3 veces/semana';
      case 2:
        return '2 veces/semana';
      case 1:
        return '1 vez/semana';
      default:
        return '${habit.frequencyDays} veces/semana';
    }
  }

  /// Obtiene el ícono del emoji según el progreso semanal
  String get progressEmoji {
    if (weeklyCompletionRate >= 100) return '🏆';
    if (weeklyCompletionRate >= 80) return '🔥';
    if (weeklyCompletionRate >= 50) return '💪';
    if (weeklyCompletionRate >= 25) return '🌱';
    return '😴';
  }

  /// Obtiene el texto del estado semanal
  String get weeklyStatusText {
    switch (weeklyStatus) {
      case WeeklyStatus.onTrack:
        return 'Cumpliendo meta';
      case WeeklyStatus.atRisk:
        return 'En riesgo';
      case WeeklyStatus.behind:
        return 'Por debajo';
    }
  }
}

/// Estado semanal del hábito
enum WeeklyStatus {
  onTrack, // Cumpliendo meta (verde) - ya alcanzó la frecuencia
  atRisk, // En riesgo (amarillo) - puede cumplir pero queda poco tiempo
  behind, // Por debajo (rojo) - ya no puede cumplir esta semana
}

/// Progreso de una semana específica (para el gráfico de tendencia)
class WeeklyProgress {
  final DateTime weekStart; // Lunes de esa semana
  final int completed; // Días completados
  final int expected; // Días esperados según frecuencia
  final double completionRate; // Porcentaje (0-100)

  WeeklyProgress({
    required this.weekStart,
    required this.completed,
    required this.expected,
    required this.completionRate,
  });

  /// Obtiene el texto de la semana (ej: "Sem 1", "Sem 2")
  String getWeekLabel(int weekIndex) => 'S${weekIndex + 1}';
}
