import 'package:flutter/material.dart';
import '../../domain/models/scan_step.dart';
import '../widgets/body_part_highlight_view.dart';

/// Vista de un paso individual del Viaje Sensorial con UI mejorada
class ScanStepView extends StatelessWidget {
  final ScanStep step;
  final int index;
  final int total;
  final int emotionsReported;
  final VoidCallback onNext;

  /// Claves que corresponden a los archivos de imágenes PNG en assets/images/
  static const partKeys = [
    'Pies',
    'Tobillos y pantorrillas',
    'Rodillas y muslos',
    'Cadera y pelvis',
    'Abdomen y espalda baja',
    'Pecho y hombros',
    'Brazos y manos',
    'Cuello, mandíbula y cabeza',
  ];

  const ScanStepView({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.emotionsReported,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final partKey = partKeys[index];
    final progress = (index + 1) / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Barra de progreso superior con contador
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2e1a1f).withOpacity(0.9)
                : const Color(0xFFFFE8E8).withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9999).withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Zona ${index + 1} de $total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFFB6B6)
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9999).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF9999).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Color(0xFFFF6B6B)),
                        const SizedBox(width: 4),
                        Text(
                          '$emotionsReported registros',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? const Color(0xFFFF9999).withOpacity(0.2)
                      : const Color(0xFFFFB6B6).withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                ),
              ),
            ],
          ),
        ),

        // Cuerpo principal
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Card con la silueta y ajolote maestro
                Card(
                  elevation: 8,
                  shadowColor: const Color(0xFFFF9999).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: isDark
                      ? Colors.grey[850]?.withOpacity(0.8)
                      : Colors.white.withOpacity(0.9),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFFFF9999).withOpacity(0.05),
                                const Color(0xFFFFAA88).withOpacity(0.05),
                              ]
                            : [
                                const Color(0xFFFFB6B6).withOpacity(0.05),
                                const Color(0xFFFFCC99).withOpacity(0.05),
                              ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Título decorativo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFFFF6B6B),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Zona de enfoque',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Silueta del cuerpo con highlight y ajolote
                        SizedBox(
                          height: 450,
                          child: BodyPartHighlightView(partKey),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Card con instrucciones mejorada
                Card(
                  elevation: 6,
                  shadowColor: const Color(0xFFFFAA88).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: isDark
                      ? Colors.grey[850]?.withOpacity(0.8)
                      : Colors.white.withOpacity(0.9),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFFFFAA88).withOpacity(0.05),
                                const Color(0xFFFFBB99).withOpacity(0.05),
                              ]
                            : [
                                const Color(0xFFFFCC99).withOpacity(0.05),
                                const Color(0xFFFFDDCC).withOpacity(0.05),
                              ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de la zona
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF9999).withOpacity(0.25),
                                    const Color(0xFFFFAA88).withOpacity(0.25),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.spa,
                                color: Color(0xFFFF6B6B),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Instrucción con mejor diseño
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(0xFFFF9999).withOpacity(0.12),
                                      const Color(0xFFFFAA88).withOpacity(0.12),
                                    ]
                                  : [
                                      const Color(0xFFFFB6B6).withOpacity(0.08),
                                      const Color(0xFFFFCC99).withOpacity(0.08),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFFFF9999).withOpacity(0.4)
                                  : const Color(0xFFFF9999).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber[700],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  step.instruction,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.grey[800],
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Espacio para el botón flotante
              ],
            ),
          ),
        ),
      ],
    );
  }
}
