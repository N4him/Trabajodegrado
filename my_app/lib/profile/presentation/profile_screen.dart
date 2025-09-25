import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    // Cargar datos cuando se inicia la pantalla
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(child: Text(state.message));
          } else if (state is ProfileLoaded) {
            final profile = state.profile; // ahora es ProfileEntity
            final userName = profile.name;
            final level = profile.level;
            final points = profile.points;
            final photoUrl = profile.photoUrl ?? '';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Card(
                        elevation: 4,
                        margin: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(60),
                            bottomRight: Radius.circular(60),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              // Reemplaza tu SizedBox de la imagen por esto:
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage: NetworkImage(photoUrl),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Acción de editar foto de perfil
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title:
                                                  const Text('Editar perfil'),
                                              content: const Text(
                                                  'Aquí va la edición de perfil'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cerrar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              Text(
                                userName,
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Experto',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lv. $level',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: 10 /
                                            100, // Ejemplo: 60 de 100 puntos
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Color(0xFF7C4DFF)),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // PopupMenuButton en la parte superior derecha
                      Positioned(
                        right: 0,
                        top: 16,
                        child: PopupMenuButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.black),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context); // Cerrar el popup
                                  // Navegar a editar perfil o mostrar card
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Editar perfil'),
                                      content: const Text(
                                          'Aquí va la edición de perfil'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Editar perfil'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 500,
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: const Color(0xFF7C4DFF),
                          unselectedLabelColor: Colors.grey[600],
                          indicatorColor: const Color(0xFF7C4DFF),
                          indicatorWeight: 3,
                          tabs: const [Tab(text: 'Stats')],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildStatsTab(points!, level!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsTab(int points, int level) {
    return Center(
      child: Text(
        'Puntos: $points\nNivel: $level',
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }
}
