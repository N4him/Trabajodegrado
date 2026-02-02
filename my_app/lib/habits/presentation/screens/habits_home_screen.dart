import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/config/app_router.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_bloc.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_event.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_state.dart';
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

void _markAsCompleted(String habitId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    context.read<HabitBloc>().add(
      RegisterCompletionStarted(habitId: habitId, userId: userId),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDB290),
      appBar: AppBar(
        title: const Text('Mis Hábitos'),
        backgroundColor: const Color(0xFFCDB290),
        elevation: 0,
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
  if (state is HabitActionSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: const Color(0xFFFFAA88),
        duration: const Duration(seconds: 2),
      ),
    );
    _loadHabits(); // <-- se agrega aquí
  } else if (state is HabitFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.error),
        backgroundColor: const Color(0xFFFF6B6B),
        duration: const Duration(seconds: 3),
      ),
    );
  }
},
        builder: (context, state) {
          if (state is HabitLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (state is HabitFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF6B6B)),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFFF6B6B)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadHabits,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFCDB290),
                    ),
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
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes hábitos registrados',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primer hábito para comenzar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),

                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadHabits();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: Colors.white,
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
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFCDB290),
      ),
    );
  }
}