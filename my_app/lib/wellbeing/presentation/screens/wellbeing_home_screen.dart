import 'package:flutter/material.dart';
import '../../../config/app_router.dart';
import '../widgets/gradient_background.dart';

/// Pantalla principal del módulo de Bienestar
/// Muestra las diferentes actividades de mindfulness disponibles
class WellbeingHomeScreen extends StatefulWidget {
  const WellbeingHomeScreen({super.key});

  @override
  State<WellbeingHomeScreen> createState() => _WellbeingHomeScreenState();
}

class _WellbeingHomeScreenState extends State<WellbeingHomeScreen> {

  void _showActivitiesInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.purple),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Actividades de Mindfulness',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  icon: Icons.accessibility_new,
                  color: Colors.blue,
                  title: 'Escaneo Corporal',
                  description: 'Una práctica de atención plena que te guía a través de diferentes partes de tu cuerpo, ayudándote a desarrollar consciencia corporal y liberar tensiones.',
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  icon: Icons.air,
                  color: Colors.teal,
                  title: 'Juego de Respiración',
                  description: 'Ejercicios de respiración consciente basados en técnicas de mindfulness. Incluye suspiro cíclico, respiración cuadrada y respiración energizante. Las partículas flotantes hacen la práctica más amena.',
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  icon: Icons.spa,
                  color: Colors.indigo,
                  title: 'Técnica 5-4-3-2-1',
                  description: 'Ejercicio de grounding que te ayuda a conectar con el momento presente a través de tus cinco sentidos. Identifica 5 cosas que ves, 4 que tocas, 3 que escuchas, 2 que hueles y 1 que saboreas.',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Las actividades completadas contribuyen a tu progreso general de bienestar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienestar'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showActivitiesInfo,
            tooltip: 'Información de actividades',
          ),
        ],
      ),
      extendBodyBehindAppBar: false,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actividades de Mindfulness',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige una actividad para comenzar tu práctica',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildActivityCard(
                        context,
                        title: 'Escaneo Corporal',
                        description: 'Viaje sensorial a través de tu cuerpo',
                        icon: Icons.accessibility_new,
                        color: const Color(0xFFFF9999),
                        onTap: () => Navigator.pushNamed(context, AppRouter.bodyScan),
                      ),
                      const SizedBox(height: 16),
                      _buildActivityCard(
                        context,
                        title: 'Juego de Respiración',
                        description: 'Ejercicios de respiración guiada',
                        icon: Icons.air,
                        color: const Color(0xFFFFAA88),
                        onTap: () => Navigator.pushNamed(context, AppRouter.breathingGame),
                      ),
                      const SizedBox(height: 16),
                      _buildActivityCard(
                        context,
                        title: 'Técnica 5-4-3-2-1',
                        description: 'Grounding sensorial para calmar la ansiedad',
                        icon: Icons.spa,
                        color: const Color(0xFFFFBB99),
                        onTap: () => Navigator.pushNamed(context, AppRouter.questMap),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark
          ? Colors.grey[900]?.withOpacity(0.7)
          : Colors.white.withOpacity(0.85),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
