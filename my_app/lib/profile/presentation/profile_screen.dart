import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_state.dart';
import 'package:my_app/profile/presentation/bloc/profile_event.dart';
import 'package:my_app/widgets/edit_profile_dialog.dart';

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
    // Cargar el perfil al inicializar
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleProfileUpdate(String name, String? password, String photoUrl) {
    // Aquí está la conexión que faltaba
    context.read<ProfileBloc>().add(UpdateProfile(
      name: name,
      password: password,
      photoUrl: photoUrl,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          // Mostrar mensaje de éxito cuando se actualice
          if (state is ProfileLoaded) {
            // Solo mostrar si venimos de un estado de actualización
            final previousState = context.read<ProfileBloc>().state;
            if (previousState is ProfileUpdating) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Perfil actualizado correctamente'),
                  backgroundColor: Color(0xFF7C4DFF),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(LoadProfile());
                    },
                    child: Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7C4DFF),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProfileLoaded || state is ProfileUpdating) {
            // Obtener el perfil del estado actual
            final profile = state is ProfileLoaded 
                ? state.profile 
                : (state as ProfileUpdating).profile;
            
            final userName = profile.name;
            final level = profile.level ?? 1;
            final points = profile.points ?? 0;
            final photoUrl = profile.photoUrl ?? '';
            final isUpdating = state is ProfileUpdating;

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
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage: photoUrl.isNotEmpty 
                                          ? NetworkImage(photoUrl)
                                          : null,
                                      child: photoUrl.isEmpty
                                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                                          : null,
                                    ),
                                    // Indicador de actualización
                                    if (isUpdating)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Botón de editar
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: isUpdating ? null : () {
                                          EditProfileDialog.show(
                                            context,
                                            currentName: userName,
                                            currentPhotoUrl: photoUrl,
                                            onSave: _handleProfileUpdate, // ← AQUÍ ESTÁ LA CONEXIÓN
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isUpdating ? Colors.grey[300] : Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: isUpdating ? Colors.grey[500] : Colors.black,
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
                                        value: (points % 100) / 100,
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
                      // Overlay de actualización
                      if (isUpdating)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(60),
                                bottomRight: Radius.circular(60),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFF7C4DFF),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Actualizando perfil...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF7C4DFF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                              _buildStatsTab(points, level),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Tarjeta de puntos
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Color(0xFF7C4DFF),
                    size: 30,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Puntos Totales',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$points',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Tarjeta de nivel
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Color(0xFF7C4DFF),
                    size: 30,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nivel Actual',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Nivel $level',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Progreso al siguiente nivel
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        color: Color(0xFF7C4DFF),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Progreso al Nivel ${level + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (points % 100) / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${points % 100}/100 puntos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}