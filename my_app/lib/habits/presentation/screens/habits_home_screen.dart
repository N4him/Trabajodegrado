import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/config/app_router.dart';
import '../blocs/habit_bloc.dart';
import '../blocs/habit_event.dart';
import '../blocs/habit_state.dart';
import '../widgets/habit_progress_card.dart';
import 'habit_detail_screen.dart';

class HabitsHomeScreen extends StatefulWidget {
  const HabitsHomeScreen({super.key});

  @override
  State<HabitsHomeScreen> createState() => _HabitsHomeScreenState();
}

class _HabitsHomeScreenState extends State<HabitsHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Cargar progreso en lugar de solo hábitos
      context.read<HabitBloc>().add(FetchHabitsProgressStarted(userId: userId));
    }
  }

  void _markAsCompleted(String habitId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<HabitBloc>().add(
        RegisterCompletionStarted(habitId: habitId, userId: userId),
      );

      // Esperar un momento y recargar el progreso
      await Future.delayed(const Duration(milliseconds: 500));
      _loadHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Hábitos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHabits,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: BlocConsumer<HabitBloc, HabitState>(
        listener: (context, state) {
          // Mostrar mensajes de éxito o error
          if (state is HabitActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is HabitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HabitLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HabitFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadHabits,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is HabitsProgressLoaded) {
            if (state.habitsProgress.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.self_improvement,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes hábitos registrados',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primer hábito para comenzar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.habitCreation);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Hábito'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadHabits();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.habitsProgress.length,
                itemBuilder: (context, index) {
                  final progress = state.habitsProgress[index];
                  return HabitProgressCard(
                    progress: progress,
                    onTap: () async {
                      // Navegar a la pantalla de detalle
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(progress: progress),
                        ),
                      );
                      // Recargar progreso al volver
                      _loadHabits();
                    },
                    onComplete: () => _markAsCompleted(progress.habit.id),
                  );
                },
              ),
            );
          }

          // Estado inicial u otro estado desconocido
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRouter.habitCreation);
          // Recargar hábitos después de volver de la pantalla de creación
          _loadHabits();
        },
        icon: const Icon(Icons.add),
        label: const Text('Crear Hábito'),
      ),
    );
  }
}
