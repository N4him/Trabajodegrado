import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../domain/models/breathing_mode.dart';
import '../blocs/breathing_game_bloc.dart';
import '../blocs/breathing_game_event.dart';
import '../blocs/breathing_game_state.dart';
import 'mode_selection_view.dart';
import 'breathing_phase_view.dart';
import 'success_view.dart';

/// Pantalla principal del juego de respiración
class BreathingGameScreen extends StatelessWidget {
  const BreathingGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BreathingGameBloc>(),
      child: const _BreathingGameContent(),
    );
  }
}

class _BreathingGameContent extends StatelessWidget {
  const _BreathingGameContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicio de Respiración'),
        centerTitle: true,
      ),
      body: BlocConsumer<BreathingGameBloc, BreathingGameState>(
        listener: (context, state) {
          if (state is BreathingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BreathingInitial) {
            return ModeSelectionView(
              onModeSelected: (mode) {
                context.read<BreathingGameBloc>().add(StartBreathingGame(mode));
              },
            );
          }

          if (state is PhaseInProgress) {
            return BreathingPhaseView(state: state);
          }

          if (state is SessionCompleted || state is SessionSaved) {
            final mode = state is SessionCompleted
                ? state.mode
                : (state as SessionSaved).mode;
            final successes = state is SessionCompleted
                ? state.successes
                : (state as SessionSaved).successes;
            final comboCount = state is SessionCompleted
                ? state.comboCount
                : (state as SessionSaved).comboCount;
            final cyclesCompleted = state is SessionCompleted
                ? state.cyclesCompleted
                : (state as SessionSaved).cyclesCompleted;
            final durationSeconds = state is SessionCompleted
                ? state.durationSeconds
                : (state as SessionSaved).durationSeconds;

            return SuccessView(
              mode: mode,
              successes: successes,
              comboCount: comboCount,
              cyclesCompleted: cyclesCompleted,
              durationSeconds: durationSeconds,
              onFinish: () => Navigator.of(context).pop(),
            );
          }

          if (state is SavingSession) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Guardando sesión...'),
                ],
              ),
            );
          }

          return const Center(child: Text('Estado desconocido'));
        },
      ),
    );
  }
}
