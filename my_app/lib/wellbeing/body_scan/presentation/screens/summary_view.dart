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
    
    // Color principal
    const primaryColor = Color(0xFFAFB99B);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono decorativo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa,
                size: 60,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              '¡Viaje completado!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccionaste 😌 en $relaxedCount de $totalReports autoinformes.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Botón principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.read<BodyScanBloc>().add(ResetScan()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Repetir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón secundario
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Salir',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}