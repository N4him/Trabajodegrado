// lib/core/utils/date_utils.dart

/// Permite inyectar la fecha actual para testing
/// En producción usa DateTime.now(), en tests puedes cambiarla
class DateUtils {
  static DateTime Function() nowFactory = () => DateTime.now();

  static DateTime get now => nowFactory();
}