  import 'package:flutter/material.dart';
  import 'package:my_app/gamification/domain/entities/modulo_progreso.dart';

  class ModuloProgressCard extends StatelessWidget {
    final String moduloNombre;
    final ModuloProgreso progreso;
    final Color? accentColor;
    final VoidCallback? onTap;

    const ModuloProgressCard({
      Key? key,
      required this.moduloNombre,
      required this.progreso,
      this.accentColor,
      this.onTap,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      final color = accentColor ?? Theme.of(context).primaryColor;
      
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        moduloNombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${progreso.puntosObtenidos} pts',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Barras de progreso
                _buildProgressBar(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Días cumplidos',
                  current: progreso.diasCumplidos,
                  max: 30,
                  color: color,
                ),
                const SizedBox(height: 16),
                
                _buildProgressBar(
                  context,
                  icon: Icons.local_fire_department,
                  label: 'Racha actual',
                  current: progreso.rachaActual,
                  max: 15,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                
                _buildProgressBar(
                  context,
                  icon: Icons.article,
                  label: 'Lecturas completadas',
                  current: progreso.lecturas,
                  max: 20,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                
                _buildProgressBar(
                  context,
                  icon: Icons.check_circle,
                  label: 'Tests aprobados',
                  current: progreso.testsAprobados,
                  max: 10,
                  color: Colors.green,
                ),
                
                // Stats adicionales
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      icon: Icons.assignment,
                      label: 'Sesiones',
                      value: progreso.sesionesCompletadas.toString(),
                      color: Colors.purple,
                    ),
                    _buildStatChip(
                      icon: Icons.publish,
                      label: 'Publicaciones',
                      value: progreso.publicaciones.toString(),
                      color: Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildProgressBar(
      BuildContext context, {
      required IconData icon,
      required String label,
      required int current,
      required int max,
      required Color color,
    }) {
      final progress = (current / max).clamp(0.0, 1.0);
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$current/$max',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      );
    }

    Widget _buildStatChip({
      required IconData icon,
      required String label,
      required String value,
      required Color color,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  // Widget de ejemplo de uso con múltiples módulos
  class ModulosProgressList extends StatelessWidget {
    final Map<String, ModuloProgreso> modulos;
    final Function(String)? onModuloTap;

    const ModulosProgressList({
      Key? key,
      required this.modulos,
      this.onModuloTap,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      final modulosColors = {
        'modulo1': Colors.purple,
        'modulo2': Colors.blue,
        'modulo3': Colors.teal,
        'modulo4': Colors.orange,
      };

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: modulos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final entry = modulos.entries.elementAt(index);
          final moduloKey = entry.key;
          final progreso = entry.value;
          
          return ModuloProgressCard(
            moduloNombre: _getModuloNombre(moduloKey),
            progreso: progreso,
            accentColor: modulosColors[moduloKey],
            onTap: () => onModuloTap?.call(moduloKey),
          );
        },
      );
    }

    String _getModuloNombre(String key) {
      final nombres = {
        'modulo1': 'Módulo 1: Fundamentos',
        'modulo2': 'Módulo 2: Desarrollo',
        'modulo3': 'Módulo 3: Avanzado',
        'modulo4': 'Módulo 4: Especialización',
      };
      return nombres[key] ?? key;
    }
  }