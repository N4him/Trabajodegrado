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
              final historialEventos =
                  state.gamificacion.historialEventos;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      HeatmapHabitosWidget(
                        historialEventos: historialEventos,
                      ),
                      const SizedBox(height: 20),
                      HeatmapStatsCompact(
                        historialEventos: historialEventos,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<GamificacionBloc>().add(
                                AddEventToHistorialEvent(
                                  userId: userId,
                                  fecha: DateTime.now(),
                                ),
                              );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Registrar Actividad Hoy'),
                      ),
                    ],
                  ),
                ),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

              ],
            ),
            HeatMapCalendar(
              initDate: DateTime.now(),
              datasets: calendarData,
              colorsets: const {
                1: Color.fromARGB(255, 245, 245, 161),
                2: Color(0xFFffda95),
                3: Color(0xFFf89d5e),
                4: Color(0xFFf26854),
              },
              colorMode: ColorMode.color,
              defaultColor: Colors.grey[200]!,
              textColor: Colors.black,
              size: 16,
              fontSize: 15,
              monthFontSize: 15,
              weekFontSize: 15,
              weekTextColor: Colors.grey[600]!,
              margin: const EdgeInsets.all(4),
              borderRadius: 40,
              flexible: true,
              showColorTip: true,
              colorTipHelper: [
                Text(
                  'Menos',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  'Más',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
              colorTipCount: 5,
              colorTipSize: 12,
              onClick: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Actividad: $value')),
                );
              },

            ),
          ],
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

/// Widget de estadísticas
class HeatmapStatsCompact extends StatelessWidget {
  final List<int> historialEventos;

  const HeatmapStatsCompact({
    super.key,
    required this.historialEventos,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.calendar_today,
          label: 'Esta semana',
          value: '${stats['thisWeek']}',
          color: const Color(0xFF4CAF50),
        ),
        _buildStatItem(
          icon: Icons.date_range,
          label: 'Este mes',
          value: '${stats['thisMonth']}',
          color: const Color(0xFF2196F3),
        ),
        _buildStatItem(
          icon: Icons.trending_up,
          label: 'Total',
          value: '${stats['total']}',
          color: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
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
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    final now = DateTime.now();
    int thisWeek = 0;
    int thisMonth = 0;

    for (final evento in historialEventos) {
      final eventoStr = evento.toString();
      if (eventoStr.length != 8) continue;

      final year = int.parse(eventoStr.substring(0, 4));
      final month = int.parse(eventoStr.substring(4, 6));
      final day = int.parse(eventoStr.substring(6, 8));

      final date = DateTime(year, month, day);
      final diff = now.difference(date).inDays;

      if (diff <= 7) thisWeek++;
      if (diff <= 30) thisMonth++;
    }

    return {
      'thisWeek': thisWeek,
      'thisMonth': thisMonth,
      'total': historialEventos.length,
    };
  }
}