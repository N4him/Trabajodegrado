import 'package:flutter/material.dart';
import 'package:my_app/gamification/domain/entities/modulo_progreso.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ModulosProgressList extends StatelessWidget {
  final Map<String, ModuloProgreso> modulos;
  final Function(String)? onModuloTap;

  const ModulosProgressList({
    Key? key,
    required this.modulos,
    this.onModuloTap,
  }) : super(key: key);

  static const Map<String, Color> modulosColors = {
    'biblioteca': Color(0xFFa65f59),
    'foro': Color(0xFF5a65ad),
    'habitos': Color(0xFFcdb390),
    'equilibrio': Color(0xFFafb89b),
  };

  static const Map<String, IconData> modulosIcons = {
    'biblioteca': Icons.library_books,
    'foro': Icons.forum,
    'habitos': Icons.event_repeat,
    'equilibrio': Icons.self_improvement,
  };

  @override
  Widget build(BuildContext context) {
    final emptyProgreso = ModuloProgreso(
      puntosObtenidos: 0,
      diasCumplidos: 0,
      rachaActual: 0,
      lecturas: 0,
      testsAprobados: 0,
      sesionesCompletadas: 0,
      publicaciones: 0,
    );
    
    final biblioteca = modulos['biblioteca'] ?? emptyProgreso;
    final foro = modulos['foro'] ?? emptyProgreso;
    final habitos = modulos['habitos'] ?? emptyProgreso;
    final equilibrio = modulos['equilibrio'] ?? emptyProgreso;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Fila superior: Columna de cards + Gráfica (50/50)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda con 2 cards apiladas (50%)
              Expanded(
                child: Column(
                  children: [
                    _ModuloCompactCard(
                      moduloKey: 'biblioteca',
                      progreso: biblioteca,
                      color: modulosColors['biblioteca']!,
                      icon: modulosIcons['biblioteca']!,
                      onTap: () => _showModuloDialog(context, 'biblioteca', biblioteca, modulosColors['biblioteca']!, modulos),
                    ),
                    const SizedBox(height: 12),
                    _ModuloCompactCard(
                      moduloKey: 'foro',
                      progreso: foro,
                      color: modulosColors['foro']!,
                      icon: modulosIcons['foro']!,
                      onTap: () => _showModuloDialog(context, 'foro', foro, modulosColors['foro']!, modulos),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Gráfica grande a la derecha (50%)
              Expanded(
                child: _buildRadialChart(context, modulos, modulosColors),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Fila inferior: 2 cards con misma altura
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: _ModuloCompactCard(
                    moduloKey: 'habitos',
                    progreso: habitos,
                    color: modulosColors['habitos']!,
                    icon: modulosIcons['habitos']!,
                    onTap: () => _showModuloDialog(context, 'habitos', habitos, modulosColors['habitos']!, modulos),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _ModuloCompactCard(
                    moduloKey: 'equilibrio',
                    progreso: equilibrio,
                    color: modulosColors['equilibrio']!,
                    icon: modulosIcons['equilibrio']!,
                    onTap: () => _showModuloDialog(context, 'equilibrio', equilibrio, modulosColors['equilibrio']!, modulos),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadialChart(
    BuildContext context,
    Map<String, ModuloProgreso> modulos,
    Map<String, Color> colores,
  ) {
    final chartData = modulos.entries.map((entry) {
      return _ChartData(
        _getModuloNombreCorto(entry.key),
        entry.value.puntosObtenidos.toDouble(),
        colores[entry.key] ?? const Color(0xFF666666),
      );
    }).toList();

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribución de Puntos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: false,
                ),
                series: <CircularSeries>[
                  RadialBarSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.moduloNombre,
                    yValueMapper: (_ChartData data, _) => data.puntos,
                    pointColorMapper: (_ChartData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    maximumValue: 1000,
                    radius: '100%',
                    gap: '10%',
                    innerRadius: '30%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModuloDialog(
    BuildContext context,
    String moduloKey,
    ModuloProgreso progreso,
    Color color,
    Map<String, ModuloProgreso> todosModulos,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getModuloIcon(moduloKey),
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getModuloNombre(moduloKey),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${progreso.puntosObtenidos} pts',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogProgressBar(
                        icon: Icons.calendar_today,
                        label: 'Días cumplidos',
                        current: progreso.diasCumplidos,
                        max: 30,
                        color: color,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildDialogProgressBar(
                        icon: Icons.local_fire_department,
                        label: 'Racha actual',
                        current: progreso.rachaActual,
                        max: 15,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildDialogProgressBar(
                        icon: Icons.article,
                        label: 'Lecturas completadas',
                        current: progreso.lecturas,
                        max: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildDialogProgressBar(
                        icon: Icons.check_circle,
                        label: 'Tests aprobados',
                        current: progreso.testsAprobados,
                        max: 10,
                        color: Colors.green,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.assignment,
                              label: 'Sesiones',
                              value: progreso.sesionesCompletadas.toString(),
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.publish,
                              label: 'Publicaciones',
                              value: progreso.publicaciones.toString(),
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogProgressBar({
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
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$current/$max',
              style: TextStyle(
                fontSize: 14,
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
            minHeight: 10,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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
    );
  }

  String _getModuloNombre(String key) {
    final nombres = {
      'biblioteca': 'Biblioteca',
      'foro': 'Foro',
      'habitos': 'Hábitos',
      'equilibrio': 'Equilibrio',
    };
    return nombres[key] ?? key;
  }

  String _getModuloNombreCorto(String key) {
    final nombres = {
      'biblioteca': 'Biblioteca',
      'foro': 'Foro',
      'habitos': 'Hábitos',
      'equilibrio': 'Equilibrio',
    };
    return nombres[key] ?? key;
  }

  IconData _getModuloIcon(String key) {
    final iconos = {
      'biblioteca': Icons.library_books,
      'foro': Icons.forum,
      'habitos': Icons.event_repeat,
      'equilibrio': Icons.self_improvement,
    };
    return iconos[key] ?? Icons.book;
  }
}

class _ModuloCompactCard extends StatelessWidget {
  final String moduloKey;
  final ModuloProgreso progreso;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHorizontal;

  const _ModuloCompactCard({
    required this.moduloKey,
    required this.progreso,
    required this.color,
    required this.icon,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (progreso.puntosObtenidos / 1000).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: isHorizontal ? _buildHorizontalLayout(progress) : _buildVerticalLayout(progress),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(double progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        
        Text(
          _getModuloNombreCorto(moduloKey),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 6),
        
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${progreso.puntosObtenidos} pts',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(double progress) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getModuloNombreCorto(moduloKey),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${progreso.puntosObtenidos}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _getModuloNombreCorto(String key) {
    final nombres = {
      'biblioteca': 'Biblioteca',
      'foro': 'Foro',
      'habitos': 'Hábitos',
      'equilibrio': 'Equilibrio',
    };
    return nombres[key] ?? key;
  }
}

class _ChartData {
  final String moduloNombre;
  final double puntos;
  final Color color;

  _ChartData(this.moduloNombre, this.puntos, this.color);
}