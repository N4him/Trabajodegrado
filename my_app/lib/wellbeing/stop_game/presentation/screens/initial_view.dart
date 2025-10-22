import 'package:flutter/material.dart';

/// Vista inicial con el botón STOP
class InitialView extends StatelessWidget {
  final VoidCallback onStart;

  const InitialView({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.psychology,
                  size: 64,
                  color: Colors.purple[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Técnica STOP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Detente, respira, observa y procede',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Explicación de los pasos
          _buildStepCard(
            icon: Icons.stop_circle,
            title: 'S - Stop (Detente)',
            description: 'Pausa lo que estás haciendo',
            color: Colors.red,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            icon: Icons.air,
            title: 'T - Take a breath (Respira)',
            description: '4 rondas de respiración consciente',
            color: Colors.blue,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            icon: Icons.visibility,
            title: 'O - Observe (Observa)',
            description: 'Identifica tus emociones actuales',
            color: Colors.orange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            icon: Icons.play_arrow,
            title: 'P - Proceed (Procede)',
            description: 'Elige una acción consciente',
            color: Colors.green,
            isDark: isDark,
          ),

          const SizedBox(height: 32),

          // Botón STOP grande
          Container(
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 8,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stop, size: 64),
                  SizedBox(height: 8),
                  Text(
                    'STOP',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Presiona el botón para comenzar',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}