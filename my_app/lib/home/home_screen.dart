import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
  String userName = ""; // valor por defecto
  String? photo; // valor por defecto

  // Lista de cards del carousel
  final List<Map<String, dynamic>> _carouselItems = [
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
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_currentCarouselIndex < _carouselItems.length - 1) {
        _currentCarouselIndex++;
      } else {
        _currentCarouselIndex = 0;
      }

      _pageController.animateToPage(
        _currentCarouselIndex,
        duration: Duration(milliseconds: 300),
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
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoaded) {
                  userName = state.profile.name;
                  photo = state.profile.photoUrl;
                  // ProfileEntity
                }

                return Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // alinea a la izquierda
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // centra verticalmente
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(photo ?? ''),
                    ),
                    SizedBox(width: 21), // espacio entre avatar y texto
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola,',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            // Carousel Container
            SizedBox(
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
                    itemBuilder: (context, index) {
                      final item = _carouselItems[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item['icon'],
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item['subtitle'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Indicadores de página
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _carouselItems.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentCarouselIndex == entry.key
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda con Lecciones y Comunidad
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/library');
                    },
                    borderRadius: BorderRadius.circular(
                        20), // Para que el ripple se vea bien
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Container(
                        height: 320,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Biblioteca',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '12 nuevas',
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
                  ),
                ),
                SizedBox(width: 16),
                // Columna derecha con Progreso y Retos
                Expanded(
                  child: Column(
                    children: [
                      // Cuadrado de Progreso
                      GestureDetector(
                        onTap: () {
                          // Acción para progreso
                        },
                        child: Container(
                          height: 160,
                          padding: EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFBE0B),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.timeline,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Progreso',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '65% completado',
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
                      SizedBox(height: 16),
                      // Rectángulo de Retos diarios
                      GestureDetector(
                        onTap: () {
                          // Acción para retos diarios
                        },
                        child: Container(
                          height: 150,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Retos diarios',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '3 disponibles',
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
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Rectángulo de Comunidad (ancho completo)
            GestureDetector(
              onTap: () {
                // Acción para comunidad
              },
              child: Container(
                width: double.infinity,
                height: 120,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.groups,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
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
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]));
  }
}
