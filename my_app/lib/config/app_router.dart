import 'package:flutter/material.dart';
import 'package:my_app/forum/presentation/screen_forum.dart';
import 'package:my_app/library/presentation/book_detail_page.dart';
import 'package:my_app/library/presentation/saved_book.dart';

import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../login/presentation/pages/login_screen.dart';
import '../register/presentation/register_screen.dart';
import '../home/home_screen.dart';
import '../library/presentation/library_screen.dart';
import '../habits/presentation/screens/habits_home_screen.dart';
import '../habits/presentation/screens/habit_creation_screen.dart';
import '../wellbeing/presentation/screens/wellbeing_home_screen.dart';
import '../wellbeing/body_scan/presentation/screens/body_scan_screen.dart';
import '../wellbeing/breathing_game/presentation/screens/breathing_game_screen.dart';
import '../wellbeing/quest_map/presentation/screens/quest_map_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String library = '/library';
  static const String savedBooks = '/saved-books';
  static const String foro = '/foro';
  static const String bookDetail = '/book-detail';
  static const String habitsHome = '/habits';
  static const String habitCreation = '/habit-creation';
  static const String wellbeingHome = '/wellbeing';
  static const String bodyScan = '/wellbeing/body-scan';
  static const String breathingGame = '/wellbeing/breathing-game';
  static const String questMap = '/wellbeing/quest-map';


  static Map<String, WidgetBuilder> routes = {
    splash: (_) => SplashScreen(),
    onboarding: (_) => OnboardingScreen(),
    login: (_) => LoginScreen(),
    register: (_) => RegisterScreen(),
    home: (_) => HomeScreen(),
    library: (_) => LibraryPage(),
    savedBooks: (_) => const SavedBooksPage(),
    foro: (_) => ForumScreen(),
    habitsHome: (_) => const HabitsHomeScreen(),
    habitCreation: (_) => HabitCreationScreen(),
    wellbeingHome: (_) => const WellbeingHomeScreen(),
    bodyScan: (_) => const BodyScanScreen(),
    breathingGame: (_) => const BreathingGameScreen(),
    questMap: (_) => const QuestMapScreen(),
    bookDetail: (context) {
      final bookId = ModalRoute.of(context)!.settings.arguments as String;
      return BookDetailPage(bookId: bookId);
    },
  };
}