import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../blocs/quest_map_bloc.dart';
import '../blocs/quest_map_event.dart';
import '../blocs/quest_map_state.dart';
import 'intro_view.dart';
import 'sense_input_view.dart';
import 'breathing_pause_view.dart';
import 'summary_view.dart';

/// Pantalla principal del Quest Map (técnica 5-4-3-2-1)
class QuestMapScreen extends StatelessWidget {
  const QuestMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuestMapBloc>(),
      child: const _QuestMapContent(),
    );
  }
}

class _QuestMapContent extends StatelessWidget {
  const _QuestMapContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Técnica 5-4-3-2-1'),
        centerTitle: true,
      ),
      body: BlocConsumer<QuestMapBloc, QuestMapState>(
        listener: (context, state) {
          if (state is QuestMapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuestMapInitial) {
            return IntroView(
              onStart: () {
                context.read<QuestMapBloc>().add(StartQuestMap());
              },
            );
          }

          if (state is ExploringSense) {
            return SenseInputView(state: state);
          }

          if (state is BreathingPause) {
            return BreathingPauseView(state: state);
          }

          if (state is QuestMapSessionSaved) {
            return SummaryView(state: state);
          }

          if (state is SavingQuestMapSession) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Guardando tu sesión...'),
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
