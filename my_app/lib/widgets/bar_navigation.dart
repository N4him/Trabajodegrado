import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../configuration/configuration_screen.dart';
import '../profile/presentation/profile_screen.dart';

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
   ProfileScreen(), // Bloc ya provisto en MultiBlocProvider
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

      ),
      child: CurvedNavigationBar(
        index: _currentIndex,
        height: 70.0,
        items: const [
          Icon(Icons.settings, size: 35, color: Color.fromARGB(255, 235, 233, 243)),
          Icon(Icons.home_rounded, size: 35, color: Color.fromARGB(255, 235, 233, 243)),
          Icon(Icons.person, size: 35, color: Color.fromARGB(255, 235, 233, 243)),
        ],
        color: const Color.fromARGB(255, 19, 18, 18),
backgroundColor:  const Color.fromARGB(255, 235, 233, 243),
        buttonBackgroundColor: Color.fromARGB(255, 24, 23, 23),
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: const Duration(milliseconds: 350),
        onTap: _handleTap,
      ),
    );
  }
}


