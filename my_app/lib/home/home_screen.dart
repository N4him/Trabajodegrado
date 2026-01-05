import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/forum/presentation/screen_forum.dart';
import 'package:my_app/library/presentation/library_screen.dart';
import 'package:my_app/profile/presentation/bloc/profile_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_event.dart';
import 'package:my_app/profile/presentation/bloc/profile_state.dart';
import 'package:my_app/showcase/show_keys.dart';
import 'package:my_app/showcase/showcase_manager.dart';
import 'package:my_app/showcase/showcase_preferences.dart';
import 'package:my_app/widgets/profile_avatar_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:showcaseview/showcaseview.dart';
import '../widgets/bar_navigation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  late Widget _currentScreen;

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _currentScreen = const HomeContent();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  void _updateScreen(int index, Widget screen) {
    setState(() {
      _currentIndex = index;
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 233, 243),
      extendBody: true,
      bottomNavigationBar: CustomNavigationBar(
        initialIndex: _currentIndex,
        onTap: _updateScreen,
      ),
      body: _currentScreen,
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentCarouselIndex = 0;

  static const List<String> _carouselImages = [
    'assets/images/card_welcome (4).png',
    'assets/images/forum_cards.png',
    'assets/images/petapp_card.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _checkAndStartShowCase();
  }

  void _checkAndStartShowCase() async {
    // Esperar un momento para que la UI se renderice completamente
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    final hasSeenHome = await ShowCasePreferences.hasSeenHomeShowCase();

    print('🔍 DEBUG - Has visto Home showcase: $hasSeenHome');

    if (!hasSeenHome && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('🚀 Iniciando showcase de Home...');
          ShowCaseWidget.of(context).startShowCase(ShowCaseKeys.allKeys);
        }
      });
    }
  }

  Future<void> _onShowCaseFinish() async {
    print('✅ Procesando fin del Showcase de Home');
    await ShowCasePreferences.setHomeShowCaseSeen();

    if (!mounted) return;

    // Obtener el siguiente showcase pendiente
    final nextShowCase = await ShowCasePreferences.getNextPendingShowCase();
    print('📋 Siguiente showcase pendiente: $nextShowCase');

    // Si hay un siguiente showcase y no es 'home', mostrar diálogo
    if (nextShowCase != null && nextShowCase != 'home') {
      // Pequeño delay para que la UI se estabilice
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showContinueDialog(context, nextShowCase);
      }
    }
  }

  void _showContinueDialog(BuildContext context, String nextShowCase) {
    final showcaseInfo = _getShowCaseInfo(nextShowCase);
    final showcaseManager = ShowcaseManager(); // instancia global (singleton)

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('${showcaseInfo['emoji']} '),
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
            const Text(
              'Has completado el tutorial de la pantalla principal.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Te gustaría continuar con el tutorial de ${showcaseInfo['name']}?',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Guarda globalmente que el usuario rechazó continuar
              showcaseManager.markAsDeclined(nextShowCase);
              Navigator.pop(context);
            },
            child: const Text('Más tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Resetea el estado de rechazo (por si antes había declinado)
              showcaseManager.resetDeclinedState();
              Navigator.pop(context);
              _navigateToNextShowCase(nextShowCase);
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getShowCaseInfo(String showcaseId) {
    switch (showcaseId) {
      case 'library':
        return {'name': 'Biblioteca Digital', 'emoji': '📚'};
      case 'forum':
        return {'name': 'Foro de Comunidad', 'emoji': '💬'};
      case 'habits':
        return {'name': 'Hábitos Saludables', 'emoji': '✅'};
      case 'mental_balance':
        return {'name': 'Equilibrio Mental', 'emoji': '🧘'};
      case 'profile':
        return {'name': 'Perfil de Usuario', 'emoji': '👤'};
      default:
        return {'name': 'siguiente sección', 'emoji': '✨'};
    }
  }

  void _navigateToNextShowCase(String showcaseId) {
    switch (showcaseId) {
      case 'library':
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: const Duration(milliseconds: 500),
            reverseDuration: const Duration(milliseconds: 400),
            child: const LibraryPage(),
          ),
        );
        break;
      case 'forum':
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: const Duration(milliseconds: 500),
            reverseDuration: const Duration(milliseconds: 400),
            child: const ForumScreen(),
          ),
        );
        break;
      case 'habits':
        Navigator.of(context).pushNamed('/habits');
        break;
      case 'mental_balance':
        Navigator.of(context).pushNamed('/mental_balance');
        break;
      case 'profile':
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      if (_currentCarouselIndex < _carouselImages.length - 1) {
        _currentCarouselIndex++;
      } else {
        _currentCarouselIndex = 0;
      }

      _pageController.animateToPage(
        _currentCarouselIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        print('🎯 ShowCaseWidget onFinish llamado');
        _onShowCaseFinish();
      },
      builder: (context) => BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is! ProfileLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return _buildHomeContent(state);
        },
      ),
    );
  }

  Widget _buildHomeContent(ProfileLoaded state) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(state),
              _buildMainContentSection(),
            ],
          ),
        ),
        // Botón de debug - SOLO VISIBLE EN DEBUG MODE

      ],
    );
  }

  Widget _buildHeaderSection(ProfileLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 35, bottom: 0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A2E)
            : const Color.fromARGB(255, 235, 233, 243),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildUserProfile(state),
          const SizedBox(height: 10),
          _buildCarousel(),
        ],
      ),
    );
  }

  String _getGreeting() {
    final location = tz.getLocation('America/Bogota');
    final now = tz.TZDateTime.now(location);
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return 'Buenos días,';
    } else if (hour >= 12 && hour < 17) {
      return 'Buenas tardes,';
    } else {
      return 'Buenas noches,';
    }
  }

  Widget _buildUserProfile(ProfileLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Showcase(
      key: ShowCaseKeys.greetingKey,
      title: '¡Bienvenido a tu perfil!',
      description:
          'Aquí puedes ver tu saludo personalizado y acceder a tu perfil tocando tu avatar. El saludo cambia según la hora del día.',
      targetPadding: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 25,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  state.profile.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            ProfileAvatarWidget(
              photoUrl: state.profile.photoUrl,
              radius: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Showcase(
      key: ShowCaseKeys.carouselKey,
      title: 'Anuncios Semanales',
      description:
          'Este carrusel muestra anuncios y novedades importantes que se actualizan semanalmente. Desliza para ver más contenido o espera a que cambien automáticamente.',
      targetPadding: const EdgeInsets.all(8),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
              itemCount: _carouselImages.length,
              itemBuilder: (context, index) =>
                  _buildCarouselItem(_carouselImages[index]),
            ),
            _buildCarouselIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _carouselImages.asMap().entries.map((entry) {
          return Container(
            width: 10,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentCarouselIndex == entry.key
                  ? const Color.fromARGB(255, 39, 38, 38)
                  : const Color.fromARGB(255, 95, 91, 91).withOpacity(0.4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLibraryCard(),
              const SizedBox(width: 16),
              _buildRightColumn(),
            ],
          ),
          const SizedBox(height: 16),
          _buildForumCard(),
        ],
      ),
    );
  }

  Widget _buildLibraryCard() {
    return Showcase(
      key: ShowCaseKeys.libraryKey,
      title: '📚 Biblioteca Digital',
      description:
          'Accede a nuestra colección de libros digitales. Explora diferentes categorías, guarda tus libros favoritos y gestiona tu lista de lectura personal.',
      targetPadding: const EdgeInsets.all(8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 500),
                reverseDuration: const Duration(milliseconds: 400),
                child: const LibraryPage(),
              ),
            );
          },
          child: Container(
            height: 295,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFA66059),
                width: 3,
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/biblio.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA66059),
                  blurRadius: 0,
                  spreadRadius: 0,
                  offset: const Offset(6, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Biblioteca Digital',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightColumn() {
    return Expanded(
      child: Column(
        children: [
          _buildProgressCard(onTap: () => Navigator.of(context).pushNamed('/wellbeing')),
          const SizedBox(height: 20),
          _buildHabitsCard(onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                duration: const Duration(milliseconds: 350),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressCard({required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Showcase(
      key: ShowCaseKeys.mentalBalanceKey,
      title: '🧘 Equilibrio Mental',
      description:
          'Cuida tu salud mental con ejercicios de meditación, técnicas de relajación y recursos para mantener tu bienestar emocional en equilibrio.',
      targetPadding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFFFBE0B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFB0B89B),
              width: 3,
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/equilibrio (3).jpg'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB0B89B),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(6, 6),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            height: 140,
            padding: const EdgeInsets.all(10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Equilibrio\nMental',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsCard({required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Showcase(
      key: ShowCaseKeys.habitsKey,
      title: '✅ Hábitos Saludables',
      description:
          'Crea y mantén hábitos positivos. Establece metas diarias, sigue tu progreso y construye rutinas que mejoren tu calidad de vida día a día.',
      targetPadding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/habits'),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFCDB38F),
              width: 3,
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/habito (1).jpg'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCDB38F),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(6, 6),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Hábitos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForumCard() {
    return Showcase(
      key: ShowCaseKeys.forumKey,
      title: '💬 Foro de Comunidad',
      description:
          'Conecta con otros usuarios. Comparte experiencias, participa en discusiones, haz preguntas y forma parte de nuestra comunidad activa.',
      targetPadding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 400),
              child: const ForumScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF5A65AD),
              width: 3,
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/foros_card5.jpg'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 77, 85, 150),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(6, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(0),
                ),
                const Text(
                  '    Foro de \n Comunidad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
