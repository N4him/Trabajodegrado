import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_bloc.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_event.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_state.dart';

/// Widget que muestra el heatmap con datos del BLoC
class HeatmapHabitosPage extends StatelessWidget {
  final String userId;

  const HeatmapHabitosPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<GamificacionBloc, GamificacionState>(
      listener: (context, state) {
        if (state is GamificacionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Actividad'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<GamificacionBloc>().add(
                      RefreshGamificacionData(userId: userId),
                    );
              },
            ),
          ],
        ),
        body: BlocBuilder<GamificacionBloc, GamificacionState>(
          builder: (context, state) {
            if (state is GamificacionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GamificacionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GamificacionBloc>().add(
                              LoadGamificacionData(userId: userId),
                            );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is GamificacionLoaded) {
              final historialEventos = state.gamificacion.historialEventos;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            // Fila 1: Heatmap grande
                            HeatmapHabitosWidget(
                              historialEventos: historialEventos,
                            ),
                            const SizedBox(height: 12),
                            
                            // Fila 2: Dos cards lado a lado
                            SizedBox(
                              height: 130,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MostProductiveDaysWidget(
                                      historialEventos: historialEventos,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: PeriodComparisonWidget(
                                      historialEventos: historialEventos,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(child: Text('Sin datos'));
          },
        ),
      ),
    );
  }
}

/// Widget que muestra el heatmap
class HeatmapHabitosWidget extends StatelessWidget {
  final List<int> historialEventos;

  const HeatmapHabitosWidget({
    super.key,
    required this.historialEventos,
  });

  @override
  Widget build(BuildContext context) {
    final calendarData = _processCalendarData();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: HeatMapCalendar(
          initDate: DateTime.now(),
          datasets: calendarData,
          colorsets: const {
            1: Color(0xFFffcccc),
            2: Color(0xFFffaa99),
            3: Color(0xFFff8877),
            4: Color(0xFFf26854),
          },
          colorMode: ColorMode.color,
          defaultColor: Colors.grey[200]!,
          textColor: Colors.black,
          size: 11,
          fontSize: 10,
          monthFontSize: 11,
          weekFontSize: 10,
          weekTextColor: Colors.grey[600]!,
          margin: const EdgeInsets.all(2),
          borderRadius: 20,
          flexible: true,
          showColorTip: true,
          colorTipHelper: [
            Text(
              'Menos',
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
            Text(
              'Más',
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
          colorTipCount: 5,
          colorTipSize: 8,
          onClick: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Actividad: $value'),
                duration: const Duration(milliseconds: 800),
              ),
            );
          },
        ),
      ),
    );
  }

  Map<DateTime, int> _processCalendarData() {
    final calendarData = <DateTime, int>{};

    for (final evento in historialEventos) {
      final eventoStr = evento.toString();
      if (eventoStr.length != 8) continue;

      final year = int.parse(eventoStr.substring(0, 4));
      final month = int.parse(eventoStr.substring(4, 6));
      final day = int.parse(eventoStr.substring(6, 8));

      final date = DateTime(year, month, day);
      calendarData[date] = (calendarData[date] ?? 0) + 1;
    }

    return calendarData;
  }
}

/// Widget de estadísticas básicas
class HeatmapStatsCompact extends StatelessWidget {
  final List<int> historialEventos;

  const HeatmapStatsCompact({
    super.key,
    required this.historialEventos,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.calendar_today,
              label: 'Semana',
              value: '${stats['thisWeek']}',
              color: const Color(0xFFf26854),
            ),
            Container(
              width: 1,
              height: 35,
              color: Colors.grey[300],
            ),
            _buildStatItem(
              icon: Icons.date_range,
              label: 'Mes',
              value: '${stats['thisMonth']}',
              color: const Color(0xFFf26854),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
            _buildStatItem(
              icon: Icons.trending_up,
              label: 'Total',
              value: '${stats['total']}',
              color: const Color(0xFFf26854),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calcular el inicio de la semana actual (lunes)
    final currentWeekday = today.weekday; // 1 = lunes, 7 = domingo
    final startOfWeek = today.subtract(Duration(days: currentWeekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    // Calcular el inicio del mes actual
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    int thisWeek = 0;
    int thisMonth = 0;

    // Debug: imprimir fecha actual y rangos
    print('=== CÁLCULO DE ESTADÍSTICAS ===');
    print('Fecha actual: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
    print('Inicio de semana (Lunes): ${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}');
    print('Fin de semana (Domingo): ${endOfWeek.year}-${endOfWeek.month.toString().padLeft(2, '0')}-${endOfWeek.day.toString().padLeft(2, '0')}');
    print('Inicio de mes: ${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-${startOfMonth.day.toString().padLeft(2, '0')}');
    print('---');

    for (final evento in historialEventos) {
      final eventoStr = evento.toString();
      if (eventoStr.length != 8) continue;

      final year = int.parse(eventoStr.substring(0, 4));
      final month = int.parse(eventoStr.substring(4, 6));
      final day = int.parse(eventoStr.substring(6, 8));

      final date = DateTime(year, month, day);

      // Debug: imprimir cada evento
      print('Evento: $eventoStr -> Fecha: $year-$month-$day');

      // Esta semana: desde el lunes hasta el domingo de la semana actual
      if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        thisWeek++;
        print('  ✓ Cuenta para esta semana');
      }
      
      // Este mes: desde el día 1 del mes actual hasta hoy
      if (date.isAfter(startOfMonth.subtract(const Duration(days: 1))) && 
          date.isBefore(today.add(const Duration(days: 1)))) {
        thisMonth++;
        print('  ✓ Cuenta para este mes');
      }
    }

    print('---');
    print('Resultados - Esta semana: $thisWeek, Este mes: $thisMonth, Total: ${historialEventos.length}');
    print('===============================\n');

    return {
      'thisWeek': thisWeek,
      'thisMonth': thisMonth,
      'total': historialEventos.length,
    };
  }
}

/// Widget que muestra los días más productivos
class MostProductiveDaysWidget extends StatelessWidget {
  final List<int> historialEventos;

  const MostProductiveDaysWidget({
    super.key,
    required this.historialEventos,
  });

  @override
  Widget build(BuildContext context) {
    final dayStats = _calculateDayStats();
    final sortedDays = dayStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFf26854), size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Días productivos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: sortedDays.isEmpty
                  ? const Center(
                      child: Text(
                        'Sin datos',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: sortedDays.take(3).map((entry) {
                        final percentage = historialEventos.isEmpty
                            ? 0.0
                            : (entry.value / historialEventos.length * 100);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text(
                                  _getDayNameShort(entry.key),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFf26854),
                                  ),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFFf26854),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, int> _calculateDayStats() {
    final dayStats = <int, int>{
      1: 0, // Lunes
      2: 0, // Martes
      3: 0, // Miércoles
      4: 0, // Jueves
      5: 0, // Viernes
      6: 0, // Sábado
      7: 0, // Domingo
    };

    for (final evento in historialEventos) {
      final eventoStr = evento.toString();
      if (eventoStr.length != 8) continue;

      final year = int.parse(eventoStr.substring(0, 4));
      final month = int.parse(eventoStr.substring(4, 6));
      final day = int.parse(eventoStr.substring(6, 8));

      final date = DateTime(year, month, day);
      final weekday = date.weekday;
      dayStats[weekday] = (dayStats[weekday] ?? 0) + 1;
    }

    return dayStats;
  }

  String _getDayNameShort(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mié';
      case 4:
        return 'Jue';
      case 5:
        return 'Vie';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }
}

/// Widget que compara períodos
class PeriodComparisonWidget extends StatelessWidget {
  final List<int> historialEventos;

  const PeriodComparisonWidget({
    super.key,
    required this.historialEventos,
  });

  @override
  Widget build(BuildContext context) {
    final comparison = _calculateComparison();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.compare_arrows, color: Color(0xFFf26854), size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Comparación',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildComparisonRow(
                    label: 'Semana',
                    current: comparison['currentWeek']!,
                    previous: comparison['previousWeek']!,
                  ),
                  Divider(height: 8, color: Colors.grey[300]),
                  _buildComparisonRow(
                    label: 'Mes',
                    current: comparison['currentMonth']!,
                    previous: comparison['previousMonth']!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required int current,
    required int previous,
  }) {
    final difference = current - previous;
    final isPositive = difference >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$current',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFf26854).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: const Color(0xFFf26854),
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                '${difference.abs()}',
                style: const TextStyle(
                  color: Color(0xFFf26854),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateComparison() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calcular el inicio de la semana actual (lunes)
    final currentWeekday = today.weekday; // 1 = lunes, 7 = domingo
    final startOfCurrentWeek = today.subtract(Duration(days: currentWeekday - 1));
    final endOfCurrentWeek = startOfCurrentWeek.add(const Duration(days: 6));
    
    // Calcular la semana anterior
    final startOfPreviousWeek = startOfCurrentWeek.subtract(const Duration(days: 7));
    final endOfPreviousWeek = startOfPreviousWeek.add(const Duration(days: 6));
    
    // Calcular el mes actual (desde el día 1 hasta hoy)
    final startOfCurrentMonth = DateTime(now.year, now.month, 1);
    
    // Calcular el mes anterior (mismo día del mes pasado, 30 días hacia atrás)
    final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPreviousMonth = DateTime(now.year, now.month, 0); // Último día del mes anterior
    
    int currentWeek = 0;
    int previousWeek = 0;
    int currentMonth = 0;
    int previousMonth = 0;

    for (final evento in historialEventos) {
      final eventoStr = evento.toString();
      if (eventoStr.length != 8) continue;

      final year = int.parse(eventoStr.substring(0, 4));
      final month = int.parse(eventoStr.substring(4, 6));
      final day = int.parse(eventoStr.substring(6, 8));

      final date = DateTime(year, month, day);

      // Semana actual (lunes a domingo de esta semana)
      if (date.isAfter(startOfCurrentWeek.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfCurrentWeek.add(const Duration(days: 1)))) {
        currentWeek++;
      }
      
      // Semana anterior (lunes a domingo de la semana pasada)
      if (date.isAfter(startOfPreviousWeek.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfPreviousWeek.add(const Duration(days: 1)))) {
        previousWeek++;
      }

      // Mes actual (del día 1 hasta hoy)
      if (date.isAfter(startOfCurrentMonth.subtract(const Duration(days: 1))) && 
          date.isBefore(today.add(const Duration(days: 1)))) {
        currentMonth++;
      }
      
      // Mes anterior (todo el mes anterior completo)
      if (date.isAfter(startOfPreviousMonth.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfPreviousMonth.add(const Duration(days: 1)))) {
        previousMonth++;
      }
    }

    return {
      'currentWeek': currentWeek,
      'previousWeek': previousWeek,
      'currentMonth': currentMonth,
      'previousMonth': previousMonth,
    };
  }
}