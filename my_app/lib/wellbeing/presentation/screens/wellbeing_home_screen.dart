import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/app_router.dart';
import '../blocs/wellbeing_points_bloc.dart';
import '../blocs/wellbeing_points_event.dart';
import '../blocs/wellbeing_points_state.dart';

/// Pantalla principal del módulo de Bienestar
/// Muestra las diferentes actividades de mindfulness disponibles y los puntos acumulados
class WellbeingHomeScreen extends StatefulWidget {
  const WellbeingHomeScreen({super.key});

  @override
  State<WellbeingHomeScreen> createState() => _WellbeingHomeScreenState();
}

class _WellbeingHomeScreenState extends State<WellbeingHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  void _loadPoints() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<WellbeingPointsBloc>().add(LoadWellbeingPoints(userId));
    }
  }

  void _refreshPoints() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<WellbeingPointsBloc>().add(RefreshWellbeingPoints(userId));
    }
  }

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
                          'Gana 1 punto por completar cada actividad (una vez al día)',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showActivitiesInfo,
            tooltip: 'Información de actividades',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPoints,
            tooltip: 'Actualizar puntos',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de puntos
              BlocBuilder<WellbeingPointsBloc, WellbeingPointsState>(
                builder: (context, state) {
                  if (state is WellbeingPointsLoaded) {
                    return _buildPointsCard(state.points.totalPoints);
                  } else if (state is WellbeingPointsLoading) {
                    return _buildPointsCard(0, loading: true);
                  } else {
                    return _buildPointsCard(0);
                  }
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Actividades de Mindfulness',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Elige una actividad para comenzar tu práctica',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
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
                      color: Colors.blue,
                      onTap: () async {
                        await Navigator.pushNamed(context, AppRouter.bodyScan);
                        // Recargar puntos al volver
                        _refreshPoints();
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActivityCard(
                      context,
                      title: 'Juego de Respiración',
                      description: 'Ejercicios de respiración guiada',
                      icon: Icons.air,
                      color: Colors.teal,
                      onTap: () async {
                        await Navigator.pushNamed(context, AppRouter.breathingGame);
                        // Recargar puntos al volver
                        _refreshPoints();
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActivityCard(
                      context,
                      title: 'Técnica 5-4-3-2-1',
                      description: 'Grounding sensorial para calmar la ansiedad',
                      icon: Icons.spa,
                      color: Colors.indigo,
                      onTap: () async {
                        await Navigator.pushNamed(context, AppRouter.questMap);
                        // Recargar puntos al volver
                        _refreshPoints();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard(int points, {bool loading = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[400]!, Colors.purple[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.stars,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Puntos de Bienestar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '$points ${points == 1 ? 'punto' : 'puntos'}',
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '+1 por día',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
