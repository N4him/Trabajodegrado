import 'package:flutter/material.dart';
import 'package:my_app/onboarding/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> 
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'assets/images/onboard1 (1).png',
      title: "Bienvenido a nuestra App",
      description: "Descubre una nueva forma de gestionar tu día a día de manera simple y eficiente.",
      backgroundColor: Color.fromARGB(255, 172, 187, 160),
      cardColor: Color.fromARGB(255, 172, 187, 160),
    ),
    OnboardingData(
      imagePath: 'assets/images/board-2 (2).png',
      title: "Seguridad Garantizada",
      description: "Tus datos están protegidos con la mejor tecnología Firebase de Google.",
      backgroundColor: Color.fromARGB(255, 172, 187, 160),
      cardColor: Color.fromARGB(255, 172, 187, 160),
    ),
    OnboardingData(
      imagePath: 'assets/images/board-3 (2).png',
      title: "Rápido y Fácil",
      description: "Interfaz intuitiva diseñada para que puedas empezar a usar la app inmediatamente.",
      backgroundColor: Color.fromARGB(255, 172, 187, 160),
      cardColor: Color.fromARGB(255, 172, 187, 160),
    ),
    OnboardingData(
      imagePath: 'assets/images/board-4 (1).png',
      title: "Rápido y Fácil",
      description: "Interfaz intuitiva diseñada para que puedas empezar a usar la app inmediatamente.",
      backgroundColor: Color.fromARGB(255, 172, 187, 160),
      cardColor: Color.fromARGB(255, 172, 187, 160),
    ),
    OnboardingData(
      imagePath: 'assets/images/board-5.png',
      title: "Rápido y Fácil",
      description: "Interfaz intuitiva diseñada para que puedas empezar a usar la app inmediatamente.",
      backgroundColor: Color.fromARGB(255, 172, 187, 160),
      cardColor: Color.fromARGB(255, 172, 187, 160),
    ),
    OnboardingData(
      imagePath: 'assets/images/board-6.png',
      title: "Rápido y Fácil",
      description: "Interfaz intuitiva diseñada para que puedas empezar a usar la app inmediatamente.",
      backgroundColor: Color.fromARGB(255, 172, 187, 160),
      cardColor: Color.fromARGB(255, 172, 187, 160),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() async {
    await OnboardingService.setOnboardingSeen();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Scaffold(
      backgroundColor: _pages[_currentPage].backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Botón Saltar
                if (_currentPage < _pages.length - 1)
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.0,
                      right: size.width * 0.06,
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _goToLogin,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 79, 95, 74),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Saltar',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                // PageView content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                      _fadeController.reset();
                      _fadeController.forward();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(
                        _pages[index], 
                        constraints,
                        isSmallScreen,
                      );
                    },
                  ),
                ),

                // Indicadores y botones
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: isSmallScreen ? 16.0 : 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dots indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _buildDot(index, isSmallScreen),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      
                      // Botón siguiente/comenzar
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 48 : 50,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 79, 95, 74),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 
                                ? 'Comenzar'
                                : 'Siguiente',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    OnboardingData data, 
    BoxConstraints constraints,
    bool isSmallScreen,
  ) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.06;
    
    final availableHeight = constraints.maxHeight * 0.6;
    final availableWidth = size.width - (horizontalPadding * 2);
    final imageSize = availableHeight < availableWidth 
        ? availableHeight 
        : availableWidth;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isSmallScreen ? 8.0 : 16.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: isSmallScreen ? 8 : 16),
            
            // Imagen con animación de fade y scale
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _fadeController,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Container(
                  height: imageSize,
                  width: imageSize,
                  constraints: BoxConstraints(
                    maxHeight: 550,
                    maxWidth: 550,
                  ),
                  decoration: BoxDecoration(
                    color: data.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      data.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image,
                            size: imageSize * 0.2,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),

            // Título con SlideTransition
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _fadeController,
                    curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: Text(
                  data.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Descripción con FadeTransition retrasada
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _fadeController,
                curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _fadeController,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.02,
                  ),
                  child: Text(
                    data.description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index, bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
      height: isSmallScreen ? 7 : 8,
      width: _currentPage == index 
          ? (isSmallScreen ? 20 : 24) 
          : (isSmallScreen ? 7 : 8),
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? const Color.fromARGB(255, 79, 95, 74)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String imagePath;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color cardColor;

  OnboardingData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.cardColor,
  });
}