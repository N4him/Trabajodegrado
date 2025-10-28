import 'package:flutter/material.dart';

/// Vista de introducción del Quest Map con instrucciones
class IntroView extends StatelessWidget {
  final VoidCallback onStart;

  const IntroView({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Icono principal
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa,
                size: 50,
                color: Colors.purple[600],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título
          Text(
            'Técnica 5-4-3-2-1',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'Grounding Sensorial',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Descripción
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600]),
                      const SizedBox(width: 12),
                      Text(
                        '¿Qué es esta técnica?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Esta técnica te ayuda a calmarte y conectarte con el momento presente usando tus 5 sentidos. Es especialmente útil cuando sientes ansiedad o estrés.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pasos
          Text(
            'Explorarás tus sentidos en este orden:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),

          const SizedBox(height: 16),

          _buildSenseStep(1, '5 cosas que PUEDAS VER', Colors.blue, Icons.visibility),
          _buildSenseStep(2, '4 cosas que PUEDAS TOCAR', Colors.green, Icons.touch_app),
          _buildSenseStep(3, '3 cosas que PUEDAS OÍR', Colors.orange, Icons.hearing),
          _buildSenseStep(4, '2 cosas que PUEDAS OLER', Colors.purple, Icons.air),
          _buildSenseStep(5, '1 cosa que PUEDAS SABOREAR', Colors.pink, Icons.restaurant),

          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Habrá pausas de respiración entre cada sentido para ayudarte a relajarte.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.amber[200] : Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Botón de inicio
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Comenzar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSenseStep(int number, String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
