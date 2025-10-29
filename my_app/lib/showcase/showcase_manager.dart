import 'package:flutter/material.dart';
import 'package:my_app/showcase/showcase_preferences.dart';

/// Gestor global de showcases que maneja el flujo completo de tutoriales
class ShowcaseManager {
  static final ShowcaseManager _instance = ShowcaseManager._internal();
  factory ShowcaseManager() => _instance;
  ShowcaseManager._internal();

  // Estado global para controlar si el usuario rechazó continuar
  bool _userDeclinedContinuation = false;
  String? _lastDeclinedShowcase;

  /// Verifica si el usuario declinó continuar con los tutoriales
  bool get hasDeclinedContinuation => _userDeclinedContinuation;

  /// Resetea el estado de rechazo (útil cuando el usuario cierra sesión o reinicia)
  void resetDeclinedState() {
    _userDeclinedContinuation = false;
    _lastDeclinedShowcase = null;
  }

  /// Marca que el usuario rechazó continuar desde un showcase específico
  void markAsDeclined(String showcaseId) {
    _userDeclinedContinuation = true;
    _lastDeclinedShowcase = showcaseId;
    print('❌ Usuario declinó continuar desde: $showcaseId');
  }

  /// Verifica si debe mostrar el showcase en la pantalla actual
  Future<bool> shouldShowShowcase(String showcaseId) async {
    // Si el usuario declinó continuar, no mostrar más showcases en esta sesión
    if (_userDeclinedContinuation) {
      print('⏭️ Showcase omitido por rechazo previo: $showcaseId');
      return false;
    }

    // Verificar si ya vio este showcase específico
    final hasSeenShowcase = await _hasSeenShowcase(showcaseId);
    if (hasSeenShowcase) {
      print('✅ Showcase ya visto: $showcaseId');
      return false;
    }

    // Verificar si es el siguiente en la secuencia
    final nextPending = await ShowCasePreferences.getNextPendingShowCase();
    final shouldShow = nextPending == showcaseId;

    print(
        '🔍 Verificando showcase $showcaseId: ${shouldShow ? "MOSTRAR" : "OMITIR"}');
    print('📋 Siguiente pendiente: $nextPending');

    return shouldShow;
  }

  /// Verifica si el usuario ya vio un showcase específico
  Future<bool> _hasSeenShowcase(String showcaseId) async {
    switch (showcaseId) {
      case 'home':
        return await ShowCasePreferences.hasSeenHomeShowCase();
      case 'library':
        return await ShowCasePreferences.hasSeenLibraryShowCase();
      case 'saved_books':
        return await ShowCasePreferences.hasSeenSavedBooksShowCase();
      case 'forum':
        return await ShowCasePreferences.hasSeenForumShowCase();
      case 'habits':
        return await ShowCasePreferences.hasSeenHabitsShowCase();
      case 'mental_balance':
        return await ShowCasePreferences.hasSeenMentalBalanceShowCase();
      case 'profile':
        return await ShowCasePreferences.hasSeenProfileShowCase();
      default:
        return false;
    }
  }

  /// Maneja la finalización de un showcase
  Future<void> onShowcaseComplete(
    BuildContext context,
    String showcaseId, {
    bool showDialog = true,
  }) async {
    print('✅ Showcase completado: $showcaseId');

    // Marcar como visto
    await _markShowcaseAsSeen(showcaseId);

    if (!context.mounted) return;

    // Obtener el siguiente showcase
    final nextShowcase = await ShowCasePreferences.getNextPendingShowCase();
    print('📋 Siguiente showcase pendiente: $nextShowcase');

    // Si hay siguiente showcase y el usuario no ha rechazado, mostrar diálogo
    if (showDialog && nextShowcase != null && !_userDeclinedContinuation) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        _showContinueDialog(context, showcaseId, nextShowcase);
      }
    }
  }

  /// Marca un showcase específico como visto
  Future<void> _markShowcaseAsSeen(String showcaseId) async {
    switch (showcaseId) {
      case 'home':
        await ShowCasePreferences.setHomeShowCaseSeen();
        break;
      case 'library':
        await ShowCasePreferences.setLibraryShowCaseSeen();
        break;
      case 'saved_books':
        await ShowCasePreferences.setSavedBooksShowCaseSeen();
        break;
      case 'forum':
        await ShowCasePreferences.setForumShowCaseSeen();
        break;
      case 'habits':
        await ShowCasePreferences.setHabitsShowCaseSeen();
        break;
      case 'mental_balance':
        await ShowCasePreferences.setMentalBalanceShowCaseSeen();
        break;
      case 'profile':
        await ShowCasePreferences.setProfileShowCaseSeen();
        break;
    }
  }

  /// Muestra el diálogo para continuar al siguiente showcase
  void _showContinueDialog(
    BuildContext context,
    String currentShowcase,
    String nextShowcase,
  ) {
    final currentInfo = _getShowcaseInfo(currentShowcase);
    final nextInfo = _getShowcaseInfo(nextShowcase);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Text('${currentInfo['emoji']} '),
            const Expanded(
              child: Text(
                '¡Tutorial completado!',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has completado el tutorial de ${currentInfo['name']}.',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Te gustaría continuar con el tutorial de ${nextInfo['name']}?',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              markAsDeclined(currentShowcase);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Más tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _navigateToShowcase(context, nextShowcase);
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  /// Navega al showcase especificado usando las rutas definidas en AppRouter
  void _navigateToShowcase(BuildContext context, String showcaseId) {
    print('🚀 Navegando a showcase: $showcaseId');

    switch (showcaseId) {
      case 'home':
        // Regresar a home
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
        break;

      case 'library':
        Navigator.of(context).pushNamed('/library');
        break;

      case 'saved_books':
        Navigator.of(context).pushNamed('/saved-books');
        break;

      case 'forum':
        Navigator.of(context).pushNamed('/foro');
        break;

      case 'habits':
        Navigator.of(context).pushNamed('/habits');
        break;

      case 'mental_balance':
        // TODO: Agregar ruta de mental balance en AppRouter
        // Navigator.of(context).pushNamed('/mental-balance');
        print('⚠️ Ruta /mental-balance no definida en AppRouter');
        break;

      case 'profile':
        // TODO: Agregar ruta de profile en AppRouter
        // Navigator.of(context).pushNamed('/profile');
        print('⚠️ Ruta /profile no definida en AppRouter');
        break;
    }
  }

  /// Obtiene información de un showcase
  Map<String, String> _getShowcaseInfo(String showcaseId) {
    switch (showcaseId) {
      case 'home':
        return {'name': 'Pantalla Principal', 'emoji': '🏠'};
      case 'library':
        return {'name': 'Biblioteca Digital', 'emoji': '📚'};
      case 'saved_books':
        return {'name': 'Libros Guardados', 'emoji': '📖'};
      case 'forum':
        return {'name': 'Foro de Comunidad', 'emoji': '💬'};
      case 'habits':
        return {'name': 'Hábitos Saludables', 'emoji': '✅'};
      case 'mental_balance':
        return {'name': 'Equilibrio Mental', 'emoji': '🧘'};
      case 'profile':
        return {'name': 'Perfil de Usuario', 'emoji': '👤'};
      default:
        return {'name': 'Sección', 'emoji': '✨'};
    }
  }

  /// Obtiene el progreso actual de los showcases
  Future<Map<String, dynamic>> getProgress() async {
    return await ShowCasePreferences.getProgressInfo();
  }

  /// Verifica si todos los showcases están completos
  Future<bool> areAllShowcasesComplete() async {
    return await ShowCasePreferences.hasCompletedAllShowCases();
  }

  /// Permite al usuario reiniciar todos los tutoriales
  Future<void> resetAllShowcases() async {
    await ShowCasePreferences.resetAllShowCases();
    resetDeclinedState();
    print('🔄 Todos los showcases reseteados');
  }

  /// Permite al usuario reiniciar un showcase específico
  Future<void> resetShowcase(String showcaseId) async {
    await ShowCasePreferences.resetShowCase(showcaseId);
    print('🔄 Showcase reseteado: $showcaseId');
  }
}
