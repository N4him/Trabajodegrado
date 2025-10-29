import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:my_app/configuration/configuration_screen.dart';
import 'package:my_app/home/home_screen.dart';
import 'package:my_app/profile/presentation/profile_screen.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomNavigationBar extends StatefulWidget {
  final int initialIndex;
  final Function(int, Widget) onTap;
  final GlobalKey? settingsKey;
  final GlobalKey? homeKey;
  final GlobalKey? profileKey;

  const CustomNavigationBar({
    super.key,
    this.initialIndex = 1,
    required this.onTap,
    this.settingsKey,
    this.homeKey,
    this.profileKey,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const SettingsScreen(),
    const HomeContent(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _handleTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onTap(index, _screens[index]);
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: _currentIndex,
      height: 70.0,
      items: [
        _buildNavButton(
          icon: Icons.settings,
          showcaseKey: widget.settingsKey,
          showcaseTitle: 'Configuración',
          showcaseDescription: 'Personaliza tu experiencia, ajusta notificaciones y gestiona la privacidad de tu cuenta',
        ),
        _buildNavButton(
          icon: Icons.home_rounded,
          showcaseKey: widget.homeKey,
          showcaseTitle: 'Inicio',
          showcaseDescription: 'Tu página principal con acceso rápido a todas las funcionalidades de bienestar',
        ),
        _buildNavButton(
          icon: Icons.person,
          showcaseKey: widget.profileKey,
          showcaseTitle: 'Perfil',
          showcaseDescription: 'Revisa tu progreso, estadísticas personales y gestiona tu información',
        ),
      ],
      color: const Color.fromARGB(255, 19, 18, 18),
      backgroundColor: const Color.fromARGB(255, 235, 233, 243),
      buttonBackgroundColor: const Color.fromARGB(255, 24, 23, 23),
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: const Duration(milliseconds: 350),
      onTap: _handleTap,
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    GlobalKey? showcaseKey,
    String? showcaseTitle,
    String? showcaseDescription,
  }) {
    final iconWidget = Icon(
      icon,
      size: 35,
      color: const Color.fromARGB(255, 235, 233, 243),
    );

    if (showcaseKey != null && showcaseTitle != null && showcaseDescription != null) {
      return Showcase(
        key: showcaseKey,
        title: showcaseTitle,
        description: showcaseDescription,
        targetBorderRadius: BorderRadius.circular(35),
        tooltipBackgroundColor: const Color.fromARGB(255, 24, 23, 23),
        textColor: const Color.fromARGB(255, 235, 233, 243),
        overlayOpacity: 0.7,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}