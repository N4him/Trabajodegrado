// lib/widgets/custom_snackbar.dart
import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final colors = _getColors(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionPressed ?? () {},
              )
            : null,
      ),
    );
  }

  // Métodos de conveniencia para cada tipo
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  // Método para cerrar el SnackBar actual
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // Obtener colores según el tipo
  static _SnackBarColors _getColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarColors(
          backgroundColor: const Color(0xFF4CAF50), // Verde
        );
      case SnackBarType.error:
        return _SnackBarColors(
          backgroundColor: const Color(0xFFE53E3E), // Rojo
        );
      case SnackBarType.warning:
        return _SnackBarColors(
          backgroundColor: const Color(0xFFFF9800), // Naranja
        );
      case SnackBarType.info:
        return _SnackBarColors(
          backgroundColor: const Color(0xFF7C4DFF), // Morado (tu color principal)
        );
    }
  }

  // Obtener icono según el tipo
  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_outlined;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }
}

// Clase auxiliar para colores
class _SnackBarColors {
  final Color backgroundColor;

  _SnackBarColors({
    required this.backgroundColor,
  });
}

// Widget alternativo si prefieres usar un Widget en lugar de métodos estáticos
class CustomSnackBarWidget extends StatelessWidget {
  final String message;
  final SnackBarType type;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const CustomSnackBarWidget({
    super.key,
    required this.message,
    this.type = SnackBarType.info,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = CustomSnackBar._getColors(type);
    final icon = CustomSnackBar._getIcon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}