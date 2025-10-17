import '../entities/habit_entity.dart';
import '../entities/completion_record_entity.dart';
import '../entities/habit_progress.dart';

/// Servicio que calcula el progreso de un hábito basado en sus registros de completitud
class HabitProgressCalculator {
  /// Calcula el progreso completo de un hábito
  static HabitProgress calculate({
    required HabitEntity habit,
    required List<CompletionRecordEntity> completionRecords,
  }) {
    final now = DateTime.now();

    // Calcular métricas semanales
    final weeklyData = _calculateWeeklyData(habit, completionRecords, now);

    // Calcular tasa de cumplimiento global
    final overallRate = _calculateOverallSuccessRate(habit, completionRecords, now);

    // Calcular rachas
    final streakData = _calculateStreaks(habit, completionRecords, now);

    // Calcular tendencia mensual (últimas 4 semanas)
    final monthlyTrend = _calculateMonthlyTrend(habit, completionRecords, now);

    // Determinar estado semanal
    final weeklyStatus = _determineWeeklyStatus(
      weeklyData['completed'] as int,
      weeklyData['expected'] as int,
      now,
    );

    return HabitProgress(
      habit: habit,
      completedThisWeek: weeklyData['completed'] as int,
      expectedThisWeek: weeklyData['expected'] as int,
      weeklyCompletionRate: weeklyData['rate'] as double,
      overallSuccessRate: overallRate,
      currentStreak: streakData['current'] as int,
      bestStreak: streakData['best'] as int,
      isTodayCompleted: weeklyData['todayCompleted'] as bool,
      canCompleteToday: true, // Siempre puede completar (sistema flexible)
      weeklyStatus: weeklyStatus,
      monthlyTrend: monthlyTrend,
    );
  }

  /// Calcula los datos de la semana actual
  static Map<String, dynamic> _calculateWeeklyData(
    HabitEntity habit,
    List<CompletionRecordEntity> records,
    DateTime now,
  ) {
    // Obtener el inicio de la semana (lunes)
    final weekStart = _getWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Filtrar registros de esta semana
    final weekRecords = records.where((record) {
      return record.isCompleted &&
          record.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          record.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    final completedThisWeek = weekRecords.length;
    final expectedThisWeek = habit.frequencyDays;

    // Verificar si completó hoy
    final today = DateTime(now.year, now.month, now.day);
    final todayCompleted = weekRecords.any((record) {
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      return recordDate.isAtSameMomentAs(today);
    });

    // Calcular porcentaje
    final rate = expectedThisWeek > 0
        ? (completedThisWeek / expectedThisWeek * 100).clamp(0, 100)
        : 0.0;

    return {
      'completed': completedThisWeek,
      'expected': expectedThisWeek,
      'rate': rate,
      'todayCompleted': todayCompleted,
    };
  }

  /// Calcula la tasa de cumplimiento global desde el inicio del hábito
  static double _calculateOverallSuccessRate(
    HabitEntity habit,
    List<CompletionRecordEntity> records,
    DateTime now,
  ) {
    // Calcular días desde el inicio
    final daysSinceStart = now.difference(habit.startDate).inDays + 1;

    // Calcular días esperados totales
    final weeksCompleted = (daysSinceStart / 7).floor();
    final daysInCurrentWeek = daysSinceStart % 7;

    int totalExpected;
    if (habit.frequencyDays == 7) {
      // Hábito diario
      totalExpected = daysSinceStart;
    } else {
      // Hábito semanal
      totalExpected = weeksCompleted * habit.frequencyDays;
      // Agregar proporción de la semana actual
      final proportionOfWeek = daysInCurrentWeek / 7;
      totalExpected += (habit.frequencyDays * proportionOfWeek).ceil();
    }

    // Contar registros completados
    final totalCompleted = records.where((r) => r.isCompleted).length;

    // Calcular porcentaje
    return totalExpected > 0
        ? (totalCompleted / totalExpected * 100).clamp(0, 100)
        : 0.0;
  }

  /// Calcula la racha actual y la mejor racha
  static Map<String, int> _calculateStreaks(
    HabitEntity habit,
    List<CompletionRecordEntity> records,
    DateTime now,
  ) {
    if (records.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    // Ordenar registros por fecha descendente (más reciente primero)
    final sortedRecords = records
        .where((r) => r.isCompleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    int bestStreak = 0;

    if (habit.frequencyDays == 7) {
      // Para hábitos diarios, contar días consecutivos
      currentStreak = _calculateDailyStreak(sortedRecords, now);
      bestStreak = _calculateBestDailyStreak(sortedRecords);
    } else {
      // Para hábitos semanales, contar semanas donde cumplió la frecuencia
      currentStreak = _calculateWeeklyStreak(habit, sortedRecords, now);
      bestStreak = _calculateBestWeeklyStreak(habit, sortedRecords);
    }

    return {'current': currentStreak, 'best': bestStreak};
  }

  /// Calcula la racha diaria actual
  static int _calculateDailyStreak(List<CompletionRecordEntity> records, DateTime now) {
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < records.length; i++) {
      final recordDate = DateTime(
        records[i].date.year,
        records[i].date.month,
        records[i].date.day,
      );

      if (recordDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (recordDate.isBefore(checkDate)) {
        // Hay un día faltante, se rompe la racha
        break;
      }
    }

    return streak;
  }

  /// Calcula la mejor racha diaria histórica
  static int _calculateBestDailyStreak(List<CompletionRecordEntity> records) {
    if (records.isEmpty) return 0;

    int bestStreak = 1;
    int currentStreak = 1;

    for (int i = 0; i < records.length - 1; i++) {
      final currentDate = DateTime(
        records[i].date.year,
        records[i].date.month,
        records[i].date.day,
      );
      final nextDate = DateTime(
        records[i + 1].date.year,
        records[i + 1].date.month,
        records[i + 1].date.day,
      );

      final difference = currentDate.difference(nextDate).inDays;

      if (difference == 1) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return bestStreak;
  }

  /// Calcula la racha semanal actual (semanas consecutivas cumpliendo la frecuencia)
  static int _calculateWeeklyStreak(
    HabitEntity habit,
    List<CompletionRecordEntity> records,
    DateTime now,
  ) {
    int streak = 0;
    DateTime weekStart = _getWeekStart(now);

    while (true) {
      final weekEnd = weekStart.add(const Duration(days: 6));

      // Contar completados en esta semana
      final completedInWeek = records.where((record) {
        return record.isCompleted &&
            record.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            record.date.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;

      // Si cumplió la frecuencia, continúa la racha
      if (completedInWeek >= habit.frequencyDays) {
        streak++;
        weekStart = weekStart.subtract(const Duration(days: 7));
      } else {
        break;
      }

      // Evitar ir antes del inicio del hábito
      if (weekStart.isBefore(habit.startDate)) {
        break;
      }
    }

    return streak;
  }

  /// Calcula la mejor racha semanal histórica
  static int _calculateBestWeeklyStreak(
    HabitEntity habit,
    List<CompletionRecordEntity> records,
  ) {
    if (records.isEmpty) return 0;

    // Agrupar registros por semana
    final weeklyCompletions = <DateTime, int>{};

    for (var record in records) {
      if (record.isCompleted) {
        final weekStart = _getWeekStart(record.date);
        weeklyCompletions[weekStart] = (weeklyCompletions[weekStart] ?? 0) + 1;
      }
    }

    // Encontrar la mejor racha
    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastWeek;

    final sortedWeeks = weeklyCompletions.keys.toList()..sort();

    for (var week in sortedWeeks) {
      final completions = weeklyCompletions[week]!;

      if (completions >= habit.frequencyDays) {
        if (lastWeek == null ||
            week.difference(lastWeek).inDays == 7) {
          currentStreak++;
          if (currentStreak > bestStreak) {
            bestStreak = currentStreak;
          }
        } else {
          currentStreak = 1;
        }
        lastWeek = week;
      } else {
        currentStreak = 0;
        lastWeek = null;
      }
    }

    return bestStreak;
  }

  /// Calcula la tendencia mensual (últimas 4 semanas)
  static List<WeeklyProgress> _calculateMonthlyTrend(
    HabitEntity habit,
    List<CompletionRecordEntity> records,
    DateTime now,
  ) {
    final trend = <WeeklyProgress>[];
    DateTime weekStart = _getWeekStart(now);

    for (int i = 0; i < 4; i++) {
      final weekEnd = weekStart.add(const Duration(days: 6));

      // Contar completados en esta semana
      final completedInWeek = records.where((record) {
        return record.isCompleted &&
            record.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            record.date.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;

      final expected = habit.frequencyDays;
      final rate = expected > 0
          ? (completedInWeek / expected * 100).clamp(0.0, 100.0)
          : 0.0;

      trend.insert(
        0,
        WeeklyProgress(
          weekStart: weekStart,
          completed: completedInWeek,
          expected: expected,
          completionRate: rate,
        ),
      );

      weekStart = weekStart.subtract(const Duration(days: 7));
    }

    return trend;
  }

  /// Determina el estado semanal según el progreso
  static WeeklyStatus _determineWeeklyStatus(
    int completed,
    int expected,
    DateTime now,
  ) {
    if (completed >= expected) {
      return WeeklyStatus.onTrack;
    }

    // Calcular cuántos días quedan en la semana
    final weekStart = _getWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final daysLeft = weekEnd.difference(now).inDays + 1;

    final remaining = expected - completed;

    if (remaining <= daysLeft) {
      return WeeklyStatus.atRisk; // Aún puede cumplir
    } else {
      return WeeklyStatus.behind; // Ya no puede cumplir
    }
  }

  /// Obtiene el inicio de la semana (lunes) para una fecha dada
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: weekday - 1));
  }
}
