import 'package:flutter/material.dart';

/// Widget que muestra los puntos totales del usuario
/// Obtiene los datos del estado GamificacionLoaded
class PuntosBadge extends StatelessWidget {
  final int puntosTotales;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;

  const PuntosBadge({
    super.key,
    required this.puntosTotales,
    this.backgroundColor,
    this.textColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final badgeSize = size ?? 80.0;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColor != null
              ? [backgroundColor!, backgroundColor!.withOpacity(0.8)]
              : [
                  const Color(0xFF6C63FF),
                  const Color(0xFF4CAF50),
                ],
        ),
        borderRadius: BorderRadius.circular(badgeSize / 2),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? const Color(0xFF6C63FF))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatPuntos(puntosTotales),
            style: TextStyle(
              fontSize: badgeSize * 0.28,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
              height: 1.0,
            ),
          ),
          SizedBox(height: badgeSize * 0.05),
          Text(
            'puntos',
            style: TextStyle(
              fontSize: badgeSize * 0.14,
              fontWeight: FontWeight.w500,
              color: (textColor ?? Colors.white).withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea los puntos para mostrar K, M, etc.
  String _formatPuntos(int puntos) {
    if (puntos >= 1000000) {
      return '${(puntos / 1000000).toStringAsFixed(1)}M';
    } else if (puntos >= 1000) {
      return '${(puntos / 1000).toStringAsFixed(1)}K';
    }
    return puntos.toString();
  }
}

/// Versión compacta del badge de puntos
class PuntosBadgeCompact extends StatelessWidget {
  final int puntosTotales;
  final IconData icon;

  const PuntosBadgeCompact({
    super.key,
    required this.puntosTotales,
    this.icon = Icons.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _formatPuntos(puntosTotales),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPuntos(int puntos) {
    if (puntos >= 1000000) {
      return '${(puntos / 1000000).toStringAsFixed(1)}M';
    } else if (puntos >= 1000) {
      return '${(puntos / 1000).toStringAsFixed(1)}K';
    }
    return puntos.toString();
  }
}