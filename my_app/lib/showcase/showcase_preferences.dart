import 'package:shared_preferences/shared_preferences.dart';

/// Clase para manejar la persistencia del estado de todos los showcases
class ShowCasePreferences {
  // Keys para cada showcase
  static const String _keyHomeShowCaseSeen = 'home_showcase_seen';
  static const String _keyLibraryShowCaseSeen = 'library_showcase_seen';
  static const String _keySavedBooksShowCaseSeen = 'saved_books_showcase_seen';
  static const String _keyForumShowCaseSeen = 'forum_showcase_seen';
  static const String _keyHabitsShowCaseSeen = 'habits_showcase_seen';
  static const String _keyMentalBalanceShowCaseSeen =
      'mental_balance_showcase_seen';
  static const String _keyProfileShowCaseSeen = 'profile_showcase_seen';
  static const String _keyAllShowCasesSeen = 'all_showcases_completed';

  // ==================== MÉTODOS DE COMPATIBILIDAD ====================

  /// Método legacy - redirige a hasSeenHomeShowCase()
  @Deprecated('Usa hasSeenHomeShowCase() en su lugar')
  static Future<bool> hasSeenShowCase() async {
    return hasSeenHomeShowCase();
  }

  /// Método legacy - redirige a setHomeShowCaseSeen()
  @Deprecated('Usa setHomeShowCaseSeen() en su lugar')
  static Future<void> setShowCaseSeen() async {
    await setHomeShowCaseSeen();
  }

  // ==================== HOME SHOWCASE ====================

  /// Verifica si el usuario ya vio el tutorial de Home
  static Future<bool> hasSeenHomeShowCase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHomeShowCaseSeen) ?? false;
  }

  /// Marca el tutorial de Home como visto
  static Future<void> setHomeShowCaseSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHomeShowCaseSeen, true);
    await _checkAllShowCasesCompleted();
  }

  // ==================== LIBRARY SHOWCASE ====================

  /// Verifica si el usuario ya vio el tutorial de Biblioteca
  static Future<bool> hasSeenLibraryShowCase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLibraryShowCaseSeen) ?? false;
  }

  /// Marca el tutorial de Biblioteca como visto
  static Future<void> setLibraryShowCaseSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLibraryShowCaseSeen, true);
    await _checkAllShowCasesCompleted();
  }

  // ==================== SAVED BOOKS SHOWCASE ====================

  /// Verifica si el usuario ya vio el tutorial de Libros Guardados
  static Future<bool> hasSeenSavedBooksShowCase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySavedBooksShowCaseSeen) ?? false;
  }

  /// Marca el tutorial de Libros Guardados como visto
  static Future<void> setSavedBooksShowCaseSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySavedBooksShowCaseSeen, true);
    await _checkAllShowCasesCompleted();
  }

  // ==================== FORUM SHOWCASE ====================

  /// Verifica si el usuario ya vio el tutorial del Foro
  static Future<bool> hasSeenForumShowCase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyForumShowCaseSeen) ?? false;
  }

  /// Marca el tutorial del Foro como visto
  static Future<void> setForumShowCaseSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyForumShowCaseSeen, true);
    await _checkAllShowCasesCompleted();
  }

  // ==================== HABITS SHOWCASE ====================

  /// Verifica si el usuario ya vio el tutorial de Hábitos
  static Future<bool> hasSeenHabitsShowCase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHabitsShowCaseSeen) ?? false;
  }

  /// Marca el tutorial de Hábitos como visto
  static Future<void> setHabitsShowCaseSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHabitsShowCaseSeen, true);
    await _checkAllShowCasesCompleted();
  }

  // ==================== MENTAL BALANCE SHOWCASE ====================

  /// Verifica si el usuario ya vio el tutorial de Equilibrio Mental
  static Future<bool> hasSeenMentalBalanceShowCase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMentalBalanceShowCaseSeen) ?? false;
  }

  /// Marca el tutorial de Equilibrio Mental como visto
  static Future<void> setMentalBalanceShowCaseSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMentalBalanceShowCaseSeen, true);
    await _checkAllShowCasesCompleted();
  }

  // ==================== PROFILE SHOWCASE ====================

  /// Verifica si el usuario ya vio el tutorial de Perfil
  static Future<bool> hasSeenProfileShowCase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyProfileShowCaseSeen) ?? false;
  }

  /// Marca el tutorial de Perfil como visto
  static Future<void> setProfileShowCaseSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProfileShowCaseSeen, true);
    await _checkAllShowCasesCompleted();
  }

  // ==================== GESTIÓN GLOBAL ====================

  /// Verifica si todos los showcases están completos
  static Future<void> _checkAllShowCasesCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    final homeCompleted = prefs.getBool(_keyHomeShowCaseSeen) ?? false;
    final libraryCompleted = prefs.getBool(_keyLibraryShowCaseSeen) ?? false;
    final savedBooksCompleted =
        prefs.getBool(_keySavedBooksShowCaseSeen) ?? false;
    final forumCompleted = prefs.getBool(_keyForumShowCaseSeen) ?? false;
    final habitsCompleted = prefs.getBool(_keyHabitsShowCaseSeen) ?? false;
    final mentalBalanceCompleted =
        prefs.getBool(_keyMentalBalanceShowCaseSeen) ?? false;
    final profileCompleted = prefs.getBool(_keyProfileShowCaseSeen) ?? false;

    if (homeCompleted &&
        libraryCompleted &&
        savedBooksCompleted &&
        forumCompleted &&
        habitsCompleted &&
        mentalBalanceCompleted &&
        profileCompleted) {
      await prefs.setBool(_keyAllShowCasesSeen, true);
    }
  }

  /// Verifica si el usuario completó todos los showcases
  static Future<bool> hasCompletedAllShowCases() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAllShowCasesSeen) ?? false;
  }

  /// Obtiene el siguiente showcase pendiente según el orden recomendado
  /// Retorna el identificador del showcase o null si todos están completos
  static Future<String?> getNextPendingShowCase() async {
    // Orden recomendado de showcases
    if (!await hasSeenHomeShowCase()) return 'home';
    if (!await hasSeenLibraryShowCase()) return 'library';
    if (!await hasSeenSavedBooksShowCase()) return 'saved_books';
    if (!await hasSeenForumShowCase()) return 'forum';
    if (!await hasSeenHabitsShowCase()) return 'habits';
    if (!await hasSeenMentalBalanceShowCase()) return 'mental_balance';
    if (!await hasSeenProfileShowCase()) return 'profile';

    return null; // Todos completados
  }

  /// Obtiene el progreso de showcases completados (0.0 a 1.0)
  static Future<double> getShowCaseProgress() async {
    int completed = 0;
    const int total = 7; // Total de showcases (incluye saved_books)

    if (await hasSeenHomeShowCase()) completed++;
    if (await hasSeenLibraryShowCase()) completed++;
    if (await hasSeenSavedBooksShowCase()) completed++;
    if (await hasSeenForumShowCase()) completed++;
    if (await hasSeenHabitsShowCase()) completed++;
    if (await hasSeenMentalBalanceShowCase()) completed++;
    if (await hasSeenProfileShowCase()) completed++;

    return completed / total;
  }

  /// Obtiene el número de showcases completados
  static Future<int> getCompletedShowCasesCount() async {
    int completed = 0;

    if (await hasSeenHomeShowCase()) completed++;
    if (await hasSeenLibraryShowCase()) completed++;
    if (await hasSeenSavedBooksShowCase()) completed++;
    if (await hasSeenForumShowCase()) completed++;
    if (await hasSeenHabitsShowCase()) completed++;
    if (await hasSeenMentalBalanceShowCase()) completed++;
    if (await hasSeenProfileShowCase()) completed++;

    return completed;
  }

  /// Obtiene un mapa con el estado de todos los showcases
  static Future<Map<String, bool>> getAllShowCaseStatus() async {
    return {
      'home': await hasSeenHomeShowCase(),
      'library': await hasSeenLibraryShowCase(),
      'saved_books': await hasSeenSavedBooksShowCase(),
      'forum': await hasSeenForumShowCase(),
      'habits': await hasSeenHabitsShowCase(),
      'mental_balance': await hasSeenMentalBalanceShowCase(),
      'profile': await hasSeenProfileShowCase(),
      'all_completed': await hasCompletedAllShowCases(),
    };
  }

  /// Obtiene información detallada del progreso
  static Future<Map<String, dynamic>> getProgressInfo() async {
    final completed = await getCompletedShowCasesCount();
    const total = 7;
    final progress = await getShowCaseProgress();
    final nextShowCase = await getNextPendingShowCase();

    return {
      'completed': completed,
      'total': total,
      'progress': progress,
      'percentage': (progress * 100).toInt(),
      'next_showcase': nextShowCase,
      'is_completed': completed == total,
    };
  }

  // ==================== UTILIDADES ====================

  /// Resetea todos los showcases (útil para pruebas o configuración)
  static Future<void> resetAllShowCases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHomeShowCaseSeen);
    await prefs.remove(_keyLibraryShowCaseSeen);
    await prefs.remove(_keySavedBooksShowCaseSeen);
    await prefs.remove(_keyForumShowCaseSeen);
    await prefs.remove(_keyHabitsShowCaseSeen);
    await prefs.remove(_keyMentalBalanceShowCaseSeen);
    await prefs.remove(_keyProfileShowCaseSeen);
    await prefs.remove(_keyAllShowCasesSeen);
  }

  /// Resetea un showcase específico
  static Future<void> resetShowCase(String showcaseId) async {
    final prefs = await SharedPreferences.getInstance();

    switch (showcaseId) {
      case 'home':
        await prefs.remove(_keyHomeShowCaseSeen);
        break;
      case 'library':
        await prefs.remove(_keyLibraryShowCaseSeen);
        break;
      case 'saved_books':
        await prefs.remove(_keySavedBooksShowCaseSeen);
        break;
      case 'forum':
        await prefs.remove(_keyForumShowCaseSeen);
        break;
      case 'habits':
        await prefs.remove(_keyHabitsShowCaseSeen);
        break;
      case 'mental_balance':
        await prefs.remove(_keyMentalBalanceShowCaseSeen);
        break;
      case 'profile':
        await prefs.remove(_keyProfileShowCaseSeen);
        break;
    }

    await prefs.remove(_keyAllShowCasesSeen);
  }

  /// Marca todos los showcases como vistos
  static Future<void> markAllShowCasesAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHomeShowCaseSeen, true);
    await prefs.setBool(_keyLibraryShowCaseSeen, true);
    await prefs.setBool(_keySavedBooksShowCaseSeen, true);
    await prefs.setBool(_keyForumShowCaseSeen, true);
    await prefs.setBool(_keyHabitsShowCaseSeen, true);
    await prefs.setBool(_keyMentalBalanceShowCaseSeen, true);
    await prefs.setBool(_keyProfileShowCaseSeen, true);
    await prefs.setBool(_keyAllShowCasesSeen, true);
  }
}
