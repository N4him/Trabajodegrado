import 'package:flutter/material.dart';
import 'package:my_app/forum/screen_forum.dart';
import 'package:my_app/library/presentation/book_detail_page.dart';

import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../login/presentation/pages/login_screen.dart';
import '../register/presentation/register_screen.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String library = '/library';
  static const String foro = '/foro';
    static const String bookDetail = '/book-detail'; // 👈 nueva ruta


  static Map<String, WidgetBuilder> routes = {
    splash: (_) => SplashScreen(),
    onboarding: (_) => OnboardingScreen(),
    login: (_) => LoginScreen(),
    register: (_) => RegisterScreen(),
    home: (_) => HomeScreen(),
    library: (_) => LibraryPage(),
    foro: (_) => ForumsScreen(), // Placeholder for ForoScreen
     bookDetail: (context) {
      final bookId = ModalRoute.of(context)!.settings.arguments as String;
      return BookDetailPage(bookId: bookId);
    },
  };
}
