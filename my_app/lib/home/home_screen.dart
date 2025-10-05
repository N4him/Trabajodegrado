import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_event.dart';
import 'package:my_app/profile/presentation/bloc/profile_state.dart';
import '../widgets/bar_navigation.dart';
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
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 1
    
    return Scaffold(
      backgroundColor: colorScheme.background, // 👈 CAMBIO 2 (era Colors.grey[100])
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

  static const List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'Continúa aprendiendo',
      'subtitle': 'Tienes 3 lecciones pendientes',
      'icon': Icons.library_books,
      'color': Color(0xFF4ECDC4),
    },
    {
      'title': 'Practica vocabulario',
      'subtitle': '15 palabras nuevas esperándote',
      'icon': Icons.quiz,
      'color': Color(0xFFFF6B6B),
    },
    {
      'title': 'Completa tu racha',
      'subtitle': '¡Llevas 7 días consecutivos!',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFFFBE0B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      if (_currentCarouselIndex < _carouselItems.length - 1) {
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
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _buildHomeContent(state);
      },
    );
  }

  Widget _buildHomeContent(ProfileLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(state),
          _buildMainContentSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ProfileLoaded state) {
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 3
    final isDark = Theme.of(context).brightness == Brightness.dark; // 👈 CAMBIO 4
    
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface, // 👈 CAMBIO 5 (era Colors.white)
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark // 👈 CAMBIO 6
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfile(state),
          const SizedBox(height: 20),
          _buildCarousel(),
        ],
      ),
    );
  }

  Widget _buildUserProfile(ProfileLoaded state) {
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 7
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: state.profile.photoUrl?.isNotEmpty == true
              ? NetworkImage(state.profile.photoUrl!)
              : null,
          child: state.profile.photoUrl?.isEmpty != false
              ? const Icon(Icons.person, size: 40, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 21),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola,',
              style: TextStyle(
                fontSize: 25,
                color: colorScheme.onSurface.withOpacity(0.6), // 👈 CAMBIO 8 (era Colors.grey[600])
              ),
            ),
            Text(
              state.profile.name,
              style: TextStyle( // 👈 CAMBIO 9
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, // (era Colors.black87)
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      width: double.infinity,
      height: 170,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) =>
                _buildCarouselItem(_carouselItems[index]),
          ),
          _buildCarouselIndicators(),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(Map<String, dynamic> item) {
    final isDark = Theme.of(context).brightness == Brightness.dark; // 👈 CAMBIO 10
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item['color'] as Color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDark // 👈 CAMBIO 11
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item['subtitle'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _carouselItems.asMap().entries.map((entry) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentCarouselIndex == entry.key
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: _buildCard(
        height: 320,
        color: const Color(0xFFFF6B6B),
        icon: Icons.book,
        title: 'Biblioteca',
        subtitle: '12 nuevas',
        onTap: () => Navigator.of(context).pushNamed('/library'),
      ),
    );
  }

  Widget _buildRightColumn() {
    return Expanded(
      child: Column(
        children: [
          _buildCard(
            height: 160,
            color: const Color(0xFFFFBE0B),
            icon: Icons.timeline,
            title: 'Progresosssss',
            subtitle: '65% com',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildCard(
            height: 150,
            color: const Color(0xFF4ECDC4),
            icon: Icons.star,
            title: 'Retos diariosss',
            subtitle: '3 disponibles',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildForumCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark; // 👈 CAMBIO 12
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/foro');
      },
      child: Container(
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark // 👈 CAMBIO 13
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Foro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Únete a grupos de estudio',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required double height,
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark; // 👈 CAMBIO 14
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark // 👈 CAMBIO 15
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}