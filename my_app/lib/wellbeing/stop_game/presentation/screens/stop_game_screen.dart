import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../blocs/stop_game_bloc.dart';
import '../blocs/stop_game_event.dart';
import '../blocs/stop_game_state.dart';
import 'initial_view.dart';
import 'breathing_view.dart';
import 'emotion_selection_view.dart';
import 'action_selection_view.dart';
import 'success_view.dart';

/// Pantalla principal del STOP game
class StopGameScreen extends StatelessWidget {
  const StopGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StopGameBloc>(),
      child: const _StopGameContent(),
    );
  }
}

class _StopGameContent extends StatelessWidget {
  const _StopGameContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Técnica STOP'),
        centerTitle: true,
      ),
      body: BlocConsumer<StopGameBloc, StopGameState>(
        listener: (context, state) {
          if (state is StopGameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StopInitial) {
            return InitialView(
              onStart: () {
                context.read<StopGameBloc>().add(StopPressed());
              },
            );
          }

          if (state is BreathingState) {
            return BreathingView(state: state);
          }

          if (state is EmotionState) {
            return EmotionSelectionView(state: state);
          }

          if (state is ActionState) {
            return ActionSelectionView(state: state);
          }

          if (state is SessionSaved) {
            return SuccessView(state: state);
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
