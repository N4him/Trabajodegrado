import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'bloc/splash_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToOnboarding) {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          } else if (state is SplashNavigateToLogin) {
            Navigator.of(context).pushReplacementNamed('/login');
          } else if (state is SplashNavigateToHome) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 235, 233, 243),
              ),
              child: Stack(
                children: [
                  // Contenido central
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo_app.png',
                          width: 680,
                          height: 680,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 24),
                        
                        // Nombre de la app: FlowNest debajo del logo
                        Text(
                          'FlowNest',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Estado de Firebase y Auth
                  if (state is SplashLoading)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FutureBuilder(
                          future: _checkFirebaseAndAuth(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {

                        
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _checkFirebaseAndAuth() async {
    try {
      Firebase.app();
      final user = FirebaseAuth.instance.currentUser;
      return {
        'connected': true,
        'hasUser': user != null,
      };
    } catch (e) {
      return {
        'connected': false,
        'hasUser': false,
      };
    }
  }
}