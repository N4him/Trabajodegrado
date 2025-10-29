import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget que muestra el nivel del usuario basado en puntos totales
/// Calcula el nivel automáticamente: nivel = sqrt(puntos / 100)
class NivelIndicator extends StatelessWidget {
  final int puntosTotales;
  final bool showProgressBar;
  final double size;

  const NivelIndicator({
    super.key,
    required this.puntosTotales,
    this.showProgressBar = true,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final nivelData = _calculateNivel(puntosTotales);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicador circular del nivel
        _buildCircularLevel(nivelData),
        if (showProgressBar) ...[
          const SizedBox(height: 16),
          _buildProgressBar(nivelData),
        ],
      ],
    );
  }

  Widget _buildCircularLevel(_NivelData data) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Anillo de progreso
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: data.progressToNextLevel,
            strokeWidth: size * 0.08,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getLevelColor(data.nivel),
            ),
          ),
        ),
        // Contenido central
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Niveel',
              style: TextStyle(
                fontSize: size * 0.12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${data.nivel}',
              style: TextStyle(
                fontSize: size * 0.32,
                fontWeight: FontWeight.bold,
                color: _getLevelColor(data.nivel),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(_NivelData data) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel ${data.nivel}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Nivel ${data.nivel + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: data.progressToNextLevel,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLevelColor(data.nivel),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.puntosParaProximoNivel} puntos para nivel ${data.nivel + 1}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  _NivelData _calculateNivel(int puntos) {
    // Fórmula: nivel = sqrt(puntos / 100)
    final nivel = (math.sqrt(puntos / 100)).floor();
    
    // Puntos requeridos para el nivel actual y siguiente
    final puntosNivelActual = nivel * nivel * 100;
    final puntosNivelSiguiente = (nivel + 1) * (nivel + 1) * 100;
    
    // Progreso hacia el siguiente nivel
    final puntosProgreso = puntos - puntosNivelActual;
    final puntosNecesarios = puntosNivelSiguiente - puntosNivelActual;
    final progreso = puntosProgreso / puntosNecesarios;
    
    final puntosRestantes = puntosNivelSiguiente - puntos;

    return _NivelData(
      nivel: nivel,
      progressToNextLevel: progreso.clamp(0.0, 1.0),
      puntosParaProximoNivel: puntosRestantes,
      puntosNivelActual: puntosNivelActual,
      puntosNivelSiguiente: puntosNivelSiguiente,
    );
  }

  Color _getLevelColor(int nivel) {
    if (nivel >= 50) {
      return const Color(0xFFD32F2F); // Rojo legendario
    } else if (nivel >= 40) {
      return const Color(0xFFE91E63); // Rosa épico
    } else if (nivel >= 30) {
      return const Color(0xFF9C27B0); // Morado maestro
    } else if (nivel >= 20) {
      return const Color(0xFF2196F3); // Azul experto
    } else if (nivel >= 10) {
      return const Color(0xFF4CAF50); // Verde avanzado
    } else {
      return const Color(0xFFFF9800); // Naranja principiante
    }
  }
}

class _NivelData {
  final int nivel;
  final double progressToNextLevel;
  final int puntosParaProximoNivel;
  final int puntosNivelActual;
  final int puntosNivelSiguiente;

  _NivelData({
    required this.nivel,
    required this.progressToNextLevel,
    required this.puntosParaProximoNivel,
    required this.puntosNivelActual,
    required this.puntosNivelSiguiente,
  });
}

/// Widget compacto de nivel para usar en headers
class NivelCompact extends StatelessWidget {
  final int puntosTotales;

  const NivelCompact({
    super.key,
    required this.puntosTotales,
  });

  @override
  Widget build(BuildContext context) {
    final nivel = (math.sqrt(puntosTotales / 100)).floor();
    final color = _getLevelColor(nivel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getLevelIcon(nivel),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Nivel $nivel',
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

  Color _getLevelColor(int nivel) {
    if (nivel >= 50) {
      return const Color(0xFFD32F2F);
    } else if (nivel >= 40) {
      return const Color(0xFFE91E63);
    } else if (nivel >= 30) {
      return const Color(0xFF9C27B0);
    } else if (nivel >= 20) {
      return const Color(0xFF2196F3);
    } else if (nivel >= 10) {
      return const Color(0xFF4CAF50);
    } else {
      return const Color(0xFFFF9800);
    }
  }

  IconData _getLevelIcon(int nivel) {
    if (nivel >= 50) {
      return Icons.workspace_premium;
    } else if (nivel >= 40) {
      return Icons.military_tech;
    } else if (nivel >= 30) {
      return Icons.stars;
    } else if (nivel >= 20) {
      return Icons.emoji_events;
    } else if (nivel >= 10) {
      return Icons.grade;
    } else {
      return Icons.trending_up;
    }
  }
}

/// Card detallada con información del nivel
class NivelDetailCard extends StatelessWidget {
  final int puntosTotales;

  const NivelDetailCard({
    super.key,
    required this.puntosTotales,
  });

  @override
  Widget build(BuildContext context) {
    final nivel = (math.sqrt(puntosTotales / 100)).floor();
    final nivelData = _calculateNivel(puntosTotales);
    final color = _getLevelColor(nivel);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getLevelIcon(nivel),
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLevelTitle(nivel),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Nivel $nivel',
                        style: TextStyle(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: nivelData.progressToNextLevel,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$puntosTotales / ${nivelData.puntosNivelSiguiente}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(nivelData.progressToNextLevel * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${nivelData.puntosParaProximoNivel} puntos para alcanzar nivel ${nivel + 1}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _NivelData _calculateNivel(int puntos) {
    final nivel = (math.sqrt(puntos / 100)).floor();
    final puntosNivelActual = nivel * nivel * 100;
    final puntosNivelSiguiente = (nivel + 1) * (nivel + 1) * 100;
    final puntosProgreso = puntos - puntosNivelActual;
    final puntosNecesarios = puntosNivelSiguiente - puntosNivelActual;
    final progreso = puntosProgreso / puntosNecesarios;
    final puntosRestantes = puntosNivelSiguiente - puntos;

    return _NivelData(
      nivel: nivel,
      progressToNextLevel: progreso.clamp(0.0, 1.0),
      puntosParaProximoNivel: puntosRestantes,
      puntosNivelActual: puntosNivelActual,
      puntosNivelSiguiente: puntosNivelSiguiente,
    );
  }

  Color _getLevelColor(int nivel) {
    if (nivel >= 50) {
      return const Color(0xFFD32F2F);
    } else if (nivel >= 40) {
      return const Color(0xFFE91E63);
    } else if (nivel >= 30) {
      return const Color(0xFF9C27B0);
    } else if (nivel >= 20) {
      return const Color(0xFF2196F3);
    } else if (nivel >= 10) {
      return const Color(0xFF4CAF50);
    } else {
      return const Color(0xFFFF9800);
    }
  }

  IconData _getLevelIcon(int nivel) {
    if (nivel >= 50) {
      return Icons.workspace_premium;
    } else if (nivel >= 40) {
      return Icons.military_tech;
    } else if (nivel >= 30) {
      return Icons.stars;
    } else if (nivel >= 20) {
      return Icons.emoji_events;
    } else if (nivel >= 10) {
      return Icons.grade;
    } else {
      return Icons.trending_up;
    }
  }

  String _getLevelTitle(int nivel) {
    if (nivel >= 50) {
      return 'Legendario';
    } else if (nivel >= 40) {
      return 'Épico';
    } else if (nivel >= 30) {
      return 'Maestro';
    } else if (nivel >= 20) {
      return 'Experto';
    } else if (nivel >= 10) {
      return 'Avanzado';
    } else {
      return 'Principiante';
    }
  }
}