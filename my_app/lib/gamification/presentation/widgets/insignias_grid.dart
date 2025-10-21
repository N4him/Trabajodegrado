import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/gamification/domain/entities/insignia.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_bloc.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_event.dart';

/// Widget que muestra un grid de insignias
/// Obtiene los datos de la lista de insignias del estado
class InsigniasGrid extends StatefulWidget {
  final List<Insignia> insignias;
  final int crossAxisCount;
  final bool showOnlyUnlocked;

  const InsigniasGrid({
    super.key,
    required this.insignias,
    this.crossAxisCount = 3,
    this.showOnlyUnlocked = false,
  });

  @override
  State<InsigniasGrid> createState() => _InsigniasGridState();
}

class _InsigniasGridState extends State<InsigniasGrid> {
  bool _hasCheckedInsignias = false; // ← Flag para verificar solo una vez

  @override
  void initState() {
    super.initState();
    // Verificar insignias solo la primera vez que se monta el widget
    if (!_hasCheckedInsignias) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null && mounted) {
          context.read<GamificacionBloc>().add(
            CheckAndUnlockInsigniasEvent(userId: userId),
          );
          setState(() {
            _hasCheckedInsignias = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final insigniasFiltradas = widget.showOnlyUnlocked
        ? widget.insignias.where((i) => i.desbloqueada).toList()
        : widget.insignias;

    if (insigniasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              widget.showOnlyUnlocked
                  ? 'Aún no has desbloqueado insignias'
                  : 'No hay insignias disponibles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Insignias',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${insigniasFiltradas.where((i) => i.desbloqueada).length}/${widget.insignias.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: insigniasFiltradas.length,
          itemBuilder: (context, index) {
            final insignia = insigniasFiltradas[index];
            return GestureDetector(
              onTap: () => _showInsigniaDetails(context, insignia),
              child: Container(
                decoration: BoxDecoration(
                  color: insignia.desbloqueada
                      ? Colors.white
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: insignia.desbloqueada
                      ? [
                          BoxShadow(
                            color: _getInsigniaColor(insignia.requisito.tipo)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                  border: Border.all(
                    color: insignia.desbloqueada
                        ? _getInsigniaColor(insignia.requisito.tipo).withOpacity(0.5)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono de la insignia
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (insignia.desbloqueada)
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _getInsigniaColor(insignia.requisito.tipo)
                                        .withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          Text(
                            insignia.icono,
                            style: TextStyle(
                              fontSize: 32,
                              color: insignia.desbloqueada ? null : Colors.grey[400],
                            ),
                          ),
                          if (!insignia.desbloqueada)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Nombre de la insignia
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            insignia.nombre,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: insignia.desbloqueada
                                  ? Colors.black87
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Puntos
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: insignia.desbloqueada
                              ? _getInsigniaColor(insignia.requisito.tipo)
                                  .withOpacity(0.15)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 11,
                              color: insignia.desbloqueada
                                  ? _getInsigniaColor(insignia.requisito.tipo)
                                  : Colors.grey[500],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${insignia.puntosOtorgados}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: insignia.desbloqueada
                                    ? _getInsigniaColor(insignia.requisito.tipo)
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showInsigniaDetails(BuildContext context, Insignia insignia) {
    final color = _getInsigniaColor(insignia.requisito.tipo);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono grande
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: insignia.desbloqueada
                        ? RadialGradient(
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.05),
                            ],
                          )
                        : null,
                    color: insignia.desbloqueada ? null : Colors.grey[200],
                    border: Border.all(
                      color: insignia.desbloqueada ? color : Colors.grey[400]!,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      insignia.icono,
                      style: TextStyle(
                        fontSize: 48,
                        color: insignia.desbloqueada ? null : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre
                Text(
                  insignia.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: insignia.desbloqueada
                        ? color.withOpacity(0.15)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        insignia.desbloqueada ? Icons.check_circle : Icons.lock,
                        size: 16,
                        color: insignia.desbloqueada ? color : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        insignia.desbloqueada ? 'Desbloqueada' : 'Bloqueada',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: insignia.desbloqueada ? color : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Descripción
                Text(
                  insignia.descripcion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                // Requisito
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getRequisitoIcon(insignia.requisito.tipo),
                        size: 20,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _getRequisitoText(insignia.requisito),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Puntos otorgados
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars, color: color, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '+${insignia.puntosOtorgados} puntos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getInsigniaColor(String tipo) {
    switch (tipo) {
      case 'habitos':
        return const Color(0xFF4CAF50);
      case 'foro':
        return const Color(0xFF2196F3);
      case 'biblioteca':
        return const Color(0xFFFF9800);
      case 'equilibrio':
        return const Color(0xFF9C27B0);
      case 'racha':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getRequisitoIcon(String tipo) {
    switch (tipo) {
      case 'habitos':
        return Icons.task_alt;
      case 'foro':
        return Icons.forum;
      case 'biblioteca':
        return Icons.menu_book;
      case 'equilibrio':
        return Icons.self_improvement;
      case 'racha':
        return Icons.local_fire_department;
      default:
        return Icons.info;
    }
  }

  String _getRequisitoText(Requisito requisito) {
    switch (requisito.tipo) {
      case 'habitos':
        return 'Completa ${requisito.valor} días de hábitos';
      case 'foro':
        return 'Realiza ${requisito.valor} publicaciones';
      case 'biblioteca':
        return 'Lee ${requisito.valor} libros';
      case 'equilibrio':
        return 'Completa ${requisito.valor} sesiones';
      case 'racha':
        return 'Mantén una racha de ${requisito.valor} días';
      default:
        return 'Requisito: ${requisito.valor}';
    }
  }
}

/// Widget compacto para mostrar insignias recientes
class InsigniasRecentesWidget extends StatelessWidget {
  final List<Insignia> insignias;
  final int maxToShow;

  const InsigniasRecentesWidget({
    super.key,
    required this.insignias,
    this.maxToShow = 5,
  });

  @override
  Widget build(BuildContext context) {
    final insigniasDesbloqueadas = insignias
        .where((i) => i.desbloqueada)
        .take(maxToShow)
        .toList();

    if (insigniasDesbloqueadas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Insignias Recientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: insigniasDesbloqueadas.length,
            itemBuilder: (context, index) {
              final insignia = insigniasDesbloqueadas[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _getInsigniaColor(insignia.requisito.tipo)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          insignia.icono,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 50,
                      child: Text(
                        insignia.nombre,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getInsigniaColor(String tipo) {
    switch (tipo) {
      case 'habitos':
        return const Color(0xFF4CAF50);
      case 'foro':
        return const Color(0xFF2196F3);
      case 'biblioteca':
        return const Color(0xFFFF9800);
      case 'equilibrio':
        return const Color(0xFF9C27B0);
      case 'racha':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF607D8B);
    }
  }
}