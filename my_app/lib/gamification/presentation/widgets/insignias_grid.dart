import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/gamification/domain/entities/insignia.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_bloc.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_event.dart';

/// Widget que muestra un grid de insignias con diseño hexagonal
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
  bool _hasCheckedInsignias = false;

  @override
  void initState() {
    super.initState();
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
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemCount: insigniasFiltradas.length,
          itemBuilder: (context, index) {
            final insignia = insigniasFiltradas[index];
            return GestureDetector(
              onTap: () => _showInsigniaDetails(context, insignia),
              child: _HexagonalBadge(insignia: insignia),
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
                // Imagen grande de insignia
                SizedBox(
                  width: 140,
                  height: 140,
                  child: _HexagonalBadge(
                    insignia: insignia,
                    size: 140,
                    showLabel: false,
                  ),
                ),
                const SizedBox(height: 20),
                // Nombre
                Text(
                  insignia.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        size: 18,
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
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                // Requisito
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getRequisitoIcon(insignia.requisito.tipo),
                        size: 24,
                        color: color,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _getRequisitoText(insignia.requisito),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Puntos otorgados
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, color: color, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '+${insignia.puntosOtorgados} puntos',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
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

/// Widget de insignia - Solo muestra la imagen
class _HexagonalBadge extends StatelessWidget {
  final Insignia insignia;
  final double size;
  final bool showLabel;

  const _HexagonalBadge({
    required this.insignia,
    this.size = 100,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Solo la imagen, sin hexágono ni círculo
        SizedBox(
          width: size,
          height: size,
          child: insignia.desbloqueada
              ? _buildInsigniaIcon(insignia.icono, size)
              : Opacity(
                  opacity: 0.3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildInsigniaIcon(insignia.icono, size),
                      Icon(
                        Icons.lock,
                        size: size * 0.4,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          // Nombre de la insignia
          Text(
            insignia.nombre,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: insignia.desbloqueada
                  ? Colors.black87
                  : Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  /// Construye el widget de imagen de la insignia
  /// Usa el campo 'icono' de la insignia como ruta completa de la imagen
  Widget _buildInsigniaIcon(String iconPath, double size) {
    return Image(
      image: AssetImage(iconPath),
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Si falla la carga, muestra un placeholder
        debugPrint('Error cargando imagen: $iconPath - $error');
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.image_not_supported,
            size: size * 0.5,
            color: Colors.grey[500],
          ),
        );
      },
    );
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
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: insigniasDesbloqueadas.length,
            itemBuilder: (context, index) {
              final insignia = insigniasDesbloqueadas[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _HexagonalBadge(
                  insignia: insignia,
                  size: 70,
                  showLabel: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}