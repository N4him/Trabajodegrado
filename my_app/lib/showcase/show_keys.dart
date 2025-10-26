import 'package:flutter/material.dart';

/// Clase que contiene todas las GlobalKeys para los showcases de la aplicación
class ShowCaseKeys {
  // ==================== HOME SHOWCASE KEYS ====================

  /// Key para el saludo personalizado y avatar del usuario
  static final GlobalKey greetingKey = GlobalKey();

  /// Key para el carrusel de anuncios
  static final GlobalKey carouselKey = GlobalKey();

  /// Key para la tarjeta de Biblioteca Digital
  static final GlobalKey libraryKey = GlobalKey();

  /// Key para la tarjeta de Equilibrio Mental
  static final GlobalKey mentalBalanceKey = GlobalKey();

  /// Key para la tarjeta de Hábitos
  static final GlobalKey habitsKey = GlobalKey();

  /// Key para la tarjeta del Foro
  static final GlobalKey forumKey = GlobalKey();

  /// Lista de todas las keys del Home (en orden de presentación)
  static List<GlobalKey> get allKeys => [
        greetingKey,
        carouselKey,
        libraryKey,
        mentalBalanceKey,
        habitsKey,
        forumKey,
      ];

  // ==================== LIBRARY SHOWCASE KEYS ====================

  /// Key para el banner principal de la biblioteca
  static final GlobalKey libraryBannerKey = GlobalKey();

  /// Key para la barra de búsqueda
  static final GlobalKey librarySearchKey = GlobalKey();

  /// Key para las categorías de libros
  static final GlobalKey libraryCategoriesKey = GlobalKey();

  /// Key para la tarjeta de libro (ejemplo)
  static final GlobalKey libraryBookCardKey = GlobalKey();

  /// Key para el botón de libros guardados
  static final GlobalKey librarySavedBooksKey = GlobalKey();

  /// Lista de todas las keys de Library (en orden de presentación)
  static List<GlobalKey> get libraryKeys => [
        libraryBannerKey,
        librarySearchKey,
        libraryCategoriesKey,
        libraryBookCardKey,
        librarySavedBooksKey,
      ];

  // ==================== SAVED BOOKS SHOWCASE KEYS ====================

  /// Key para el header de libros guardados
  static final GlobalKey savedBooksHeaderKey = GlobalKey();

  /// Key para la lista de libros guardados
  static final GlobalKey savedBooksListKey = GlobalKey();

  /// Key para el botón de eliminar libro
  static final GlobalKey savedBooksDeleteKey = GlobalKey();

  /// Key para el botón de leer libro
  static final GlobalKey savedBooksReadKey = GlobalKey();

  /// Lista de todas las keys de Saved Books (en orden de presentación)
  static List<GlobalKey> get savedBooksKeys => [
        savedBooksHeaderKey,
        savedBooksListKey,
        savedBooksDeleteKey,
        savedBooksReadKey,
      ];

  // ==================== FORUM SHOWCASE KEYS ====================

  /// Key para el header del foro
  static final GlobalKey forumHeaderKey = GlobalKey();

  /// Key para el botón de crear publicación
  static final GlobalKey forumCreatePostKey = GlobalKey();

  /// Key para las categorías del foro
  static final GlobalKey forumCategoriesKey = GlobalKey();

  /// Key para una tarjeta de publicación
  static final GlobalKey forumPostCardKey = GlobalKey();

  /// Key para los filtros/búsqueda del foro
  static final GlobalKey forumSearchKey = GlobalKey();

  /// Lista de todas las keys del Foro (en orden de presentación)
  static List<GlobalKey> get forumKeys => [
        forumHeaderKey,
        forumCreatePostKey,
        forumCategoriesKey,
        forumPostCardKey,
        forumSearchKey,
      ];

  // ==================== HABITS SHOWCASE KEYS ====================

  /// Key para el header de hábitos
  static final GlobalKey habitsHeaderKey = GlobalKey();

  /// Key para el botón de agregar hábito
  static final GlobalKey habitsAddButtonKey = GlobalKey();

  /// Key para la lista de hábitos
  static final GlobalKey habitsListKey = GlobalKey();

  /// Key para el progreso/estadísticas
  static final GlobalKey habitsProgressKey = GlobalKey();

  /// Lista de todas las keys de Hábitos (en orden de presentación)
  static List<GlobalKey> get habitsKeys => [
        habitsHeaderKey,
        habitsAddButtonKey,
        habitsListKey,
        habitsProgressKey,
      ];

  // ==================== MENTAL BALANCE SHOWCASE KEYS ====================

  /// Key para el header de equilibrio mental
  static final GlobalKey mentalBalanceHeaderKey = GlobalKey();

  /// Key para las actividades/ejercicios
  static final GlobalKey mentalBalanceActivitiesKey = GlobalKey();

  /// Key para el tracking de estado de ánimo
  static final GlobalKey mentalBalanceMoodTrackerKey = GlobalKey();

  /// Key para recursos/consejos
  static final GlobalKey mentalBalanceResourcesKey = GlobalKey();

  /// Lista de todas las keys de Equilibrio Mental (en orden de presentación)
  static List<GlobalKey> get mentalBalanceKeys => [
        mentalBalanceHeaderKey,
        mentalBalanceActivitiesKey,
        mentalBalanceMoodTrackerKey,
        mentalBalanceResourcesKey,
      ];

  // ==================== PROFILE SHOWCASE KEYS ====================

  /// Key para la foto de perfil
  static final GlobalKey profilePhotoKey = GlobalKey();

  /// Key para la información personal
  static final GlobalKey profileInfoKey = GlobalKey();

  /// Key para las estadísticas del usuario
  static final GlobalKey profileStatsKey = GlobalKey();

  /// Key para la configuración
  static final GlobalKey profileSettingsKey = GlobalKey();

  /// Lista de todas las keys de Perfil (en orden de presentación)
  static List<GlobalKey> get profileKeys => [
        profilePhotoKey,
        profileInfoKey,
        profileStatsKey,
        profileSettingsKey,
      ];

  // ==================== UTILIDADES ====================

  /// Obtiene todas las keys de un showcase específico
  static List<GlobalKey> getKeysForShowcase(String showcaseId) {
    switch (showcaseId) {
      case 'home':
        return allKeys;
      case 'library':
        return libraryKeys;
      case 'saved_books':
        return savedBooksKeys;
      case 'forum':
        return forumKeys;
      case 'habits':
        return habitsKeys;
      case 'mental_balance':
        return mentalBalanceKeys;
      case 'profile':
        return profileKeys;
      default:
        return [];
    }
  }

  /// Obtiene el número total de showcases disponibles
  static int get totalShowcases => 7;

  /// Obtiene el número total de keys en todos los showcases
  static int get totalKeys =>
      allKeys.length +
      libraryKeys.length +
      savedBooksKeys.length +
      forumKeys.length +
      habitsKeys.length +
      mentalBalanceKeys.length +
      profileKeys.length;
}
