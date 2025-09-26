// lib/core/di/error/firebase_error_mapper.dart
class FirebaseErrorMapper {
  static String toMessage(String errorCode) {
    switch (errorCode) {
      // Errores de autenticación
      case 'user-not-found':
        return 'No existe una cuenta con este email';
      
      case 'wrong-password':
        return 'Contraseña incorrecta';
      
      case 'invalid-email':
        return 'El formato del email no es válido';
      
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde';
      
      case 'invalid-credential':
        return 'Las credenciales proporcionadas son inválidas';
      
      // Errores de registro
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email';
      
      case 'weak-password':
        return 'La contraseña es muy débil';
      
      case 'operation-not-allowed':
        return 'Operación no permitida';
      
      // Errores de red
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      
      case 'timeout':
        return 'La operación tardó demasiado tiempo';
      
      // Errores generales
      case 'internal-error':
        return 'Error interno del servidor';
      
      case 'invalid-api-key':
        return 'Error de configuración de la aplicación';
      
      case 'app-not-authorized':
        return 'La aplicación no está autorizada';
      
      // Error por defecto
      default:
        return 'Ha ocurrido un error inesperado. Intenta nuevamente';
    }
  }
  
  // Método adicional para obtener sugerencias según el error
  static String? getSuggestion(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Verifica tu email o regístrate si no tienes cuenta';
      
      case 'wrong-password':
        return 'Verifica tu contraseña o usa "Olvidé mi contraseña"';
      
      case 'too-many-requests':
        return 'Espera unos minutos antes de intentar nuevamente';
      
      case 'network-request-failed':
        return 'Verifica tu conexión a internet';
      
      default:
        return null;
    }
  }
}