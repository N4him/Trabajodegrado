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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienestar'),
        centerTitle: true,
        actions: [
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
                      title: 'Técnica STOP',
                      description: 'Detente, respira, observa y procede',
                      icon: Icons.psychology,
                      color: Colors.purple,
                      onTap: () async {
                        await Navigator.pushNamed(context, AppRouter.stopGame);
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
