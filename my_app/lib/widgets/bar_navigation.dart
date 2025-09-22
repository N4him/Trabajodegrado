import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../configuration/configuration_screen.dart';
import '../profile/profile_screen.dart';

class CustomNavigationBar extends StatefulWidget {
  final int initialIndex;
  final Function(int, Widget) onTap;

  const CustomNavigationBar({
    super.key,
    this.initialIndex = 1,
    required this.onTap,
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

  void _handleTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onTap(index, _screens[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: _currentIndex,
        height: 70.0,
        items: const [
          Icon(Icons.settings, size: 35, color: Colors.white),
          Icon(Icons.home_rounded, size: 35, color: Colors.white),
          Icon(Icons.person, size: 35, color: Colors.white),
        ],
        color: Colors.black,
        backgroundColor: Colors.grey[100]!,
        buttonBackgroundColor: Color(0xFF4ECDC4),
        animationCurve: Curves.easeOutQuad,
        animationDuration: const Duration(milliseconds: 350),
        onTap: _handleTap,
      ),
    );
  }
}


