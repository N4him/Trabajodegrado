import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/body_scan_bloc.dart';
import '../blocs/body_scan_event.dart';

/// Vista de resumen que muestra las respuestas del usuario y ofrece repetir o salir.
class SummaryView extends StatelessWidget {
  final List<bool> emotions;

  const SummaryView({super.key, required this.emotions});

  @override
  Widget build(BuildContext context) {
    final relaxedCount = emotions.where((e) => e).length;
    final totalReports = emotions.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Viaje completado!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccionaste 😌 en $relaxedCount de $totalReports autoinformes.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<BodyScanBloc>().add(ResetScan()),
              child: const Text('Repetir'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Salir'),
            ),
          ],
        ),
      ),
    );
  }
}
