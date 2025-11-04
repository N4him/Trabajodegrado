import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../blocs/body_scan_bloc.dart';
import '../blocs/body_scan_event.dart';
import '../blocs/body_scan_state.dart';
import '../../domain/models/scan_steps_data.dart';
import '../widgets/body_scan_gradient_background.dart';
import 'scan_step_view.dart';
import 'emotion_sheet.dart';
import 'rating_view.dart';
import 'success_view.dart';

/// Pantalla raíz que controla el flujo del Viaje Sensorial.
class BodyScanScreen extends StatelessWidget {
  const BodyScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BodyScanBloc>()..add(StartScan()),
      child: BlocBuilder<BodyScanBloc, BodyScanState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Viaje Sensorial'),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            extendBodyBehindAppBar: false,
            floatingActionButton: state is ScanInProgress
                ? FloatingActionButton.extended(
                    onPressed: () =>
                        context.read<BodyScanBloc>().add(NextStep()),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Siguiente'),
                  )
                : null,
            body: BodyScanGradientBackground(
              child: BlocConsumer<BodyScanBloc, BodyScanState>(
              listener: (context, state) {
                if (state is ScanNeedsEmotionReport) {
                  EmotionSheet.show(
                    context,
                    onSelect: (relaxed) =>
                        context.read<BodyScanBloc>().add(ReportEmotion(relaxed)),
                  );
                } else if (state is ScanError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: const Color(0xFFFF6B6B),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ScanInProgress) {
                  return ScanStepView(
                    step: scanSteps[state.index],
                    index: state.index,
                    total: scanSteps.length,
                    emotionsReported: state.emotions.length,
                    onNext: () => context.read<BodyScanBloc>().add(NextStep()),
                  );
                } else if (state is ScanNeedsRating) {
                  return RatingView(emotions: state.emotions);
                } else if (state is ScanSaving) {
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
                } else if (state is ScanSaved) {
                  return SuccessView(
                    emotions: state.emotions,
                    rating: state.rating,
                    durationSeconds: state.durationSeconds,
                  );
                } else if (state is ScanInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ScanError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF6B6B)),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFFF6B6B)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Volver'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              ),
            ),
          );
        },
      ),
    );
  }
}
