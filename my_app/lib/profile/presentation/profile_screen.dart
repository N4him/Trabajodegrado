import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/gamification/presentation/widgets/heatmap_habitos_widget.dart';
import 'package:my_app/gamification/presentation/widgets/insignias_grid.dart';
import 'package:my_app/gamification/presentation/widgets/planta_animation_widget.dart';
import 'package:my_app/profile/presentation/bloc/profile_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_state.dart';
import 'package:my_app/profile/presentation/bloc/profile_event.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_bloc.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_state.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_event.dart';
import 'package:my_app/widgets/edit_profile_dialog.dart';
import 'dart:async';
import 'package:my_app/widgets/profile_avatar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<GamificacionBloc>().add(LoadGamificacionData(userId: userId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleProfileUpdate(String name, String? password, String photoUrl) {
    context.read<ProfileBloc>().add(UpdateProfile(
          name: name,
          password: password,
          photoUrl: photoUrl,
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 233, 243),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C4DFF),
              ),
            );
          }

          if (state is ProfileError) {
            return _buildErrorState(state.message);
          }

          if (state is ProfileLoaded || state is ProfileUpdating) {
            return _buildProfileContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, ProfileState state) {
    if (state is ProfileError) {
      _showErrorSnackBar(state.message);
    }

    if (state is ProfileLoaded) {
      final previousState = context.read<ProfileBloc>().state;
      if (previousState is ProfileUpdating) {
        _showSuccessSnackBar('Perfil actualizado correctamente');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF7C4DFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProfileBloc>().add(LoadProfile()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(ProfileState state) {
    final profile = state is ProfileLoaded
        ? state.profile
        : (state as ProfileUpdating).profile;

    final isUpdating = state is ProfileUpdating;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF7C4DFF),
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactProfileHeader(profile, isUpdating),
            _buildTabSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final completer = Completer<void>();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    late StreamSubscription subscription;
    subscription = context.read<ProfileBloc>().stream.listen((state) {
      if (state is ProfileLoaded || state is ProfileError) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        subscription.cancel();
      }
    });

    context.read<ProfileBloc>().add(LoadProfile());
    
    if (userId != null) {
      context.read<GamificacionBloc>().add(RefreshGamificacionData(userId: userId));
    }

    return completer.future;
  }

  Widget _buildCompactProfileHeader(dynamic profile, bool isUpdating) {
    final userName = profile.name ?? '';
    final photoUrl = profile.photoUrl ?? '';
    final gender = profile.gender ?? 'boy';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileAvatar(photoUrl, userName, isUpdating, gender),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      userName.isNotEmpty ? userName : 'Usuario',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildLevelProgressBar(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGamificationStatsCompact(),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar() {
    return BlocBuilder<GamificacionBloc, GamificacionState>(
      buildWhen: (previous, current) =>
          previous is! GamificacionLoaded || current is! GamificacionLoaded ||
          _calculatePoints(previous) != _calculatePoints(current),
      builder: (context, state) {
        if (state is GamificacionLoaded) {
          final puntosTotales = state.gamificacion.modulos.values
              .fold<int>(0, (sum, modulo) => sum + (modulo.puntosObtenidos));
          
          final nivelActual = (puntosTotales ~/ 1000) + 1;
          final puntosEnNivel = puntosTotales % 1000;
          final porcentaje = puntosEnNivel / 1000;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level $nivelActual',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: porcentaje,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF7C4DFF),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  int _calculatePoints(GamificacionState state) {
    if (state is GamificacionLoaded) {
      return state.gamificacion.modulos.values
          .fold<int>(0, (sum, modulo) => sum + (modulo.puntosObtenidos));
    }
    return 0;
  }

  Widget _buildGamificationStatsCompact() {
    return BlocBuilder<GamificacionBloc, GamificacionState>(
      buildWhen: (previous, current) =>
          previous is! GamificacionLoaded || current is! GamificacionLoaded ||
          previous.gamificacion.insigniasUsuario.length !=
              current.gamificacion.insigniasUsuario.length,
      builder: (context, state) {
        if (state is GamificacionLoaded) {
          final insigniasCount = state.gamificacion.insigniasUsuario.length;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                size: 16,
                color: const Color(0xFF7C4DFF),
              ),
              const SizedBox(width: 4),
              Text(
                'rachaActual',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.emoji_events,
                size: 16,
                color: const Color(0xFFFFB800),
              ),
              const SizedBox(width: 4),
              Text(
                '$insigniasCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

Widget _buildProfileAvatar(String photoUrl, String userName, bool isUpdating, String gender) {
  return SizedBox(
    width: 100,
    height: 100,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Reemplaza el CircleAvatar con ProfileAvatarWidget
        ProfileAvatarWidget(
          photoUrl: photoUrl.isNotEmpty ? photoUrl : null,
          radius: 50,
        ),
        if (isUpdating) _buildAvatarLoadingOverlay(),
        _buildEditButton(userName, photoUrl, isUpdating, gender),
      ],
    ),
  );
}

  Widget _buildAvatarLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Center(
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
    );
  }

  Widget _buildEditButton(String userName, String photoUrl, bool isUpdating, String gender) {
    return Positioned(
      bottom: -4,
      right: -4,
      child: GestureDetector(
        onTap: isUpdating ? null : () => _showEditDialog(userName, photoUrl, gender),
        child: Container(
          decoration: BoxDecoration(
            color: isUpdating ? Colors.grey[300] : const Color(0xFF7C4DFF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.edit,
            size: 16,
            color: isUpdating ? Colors.grey[500] : Colors.white,
          ),
        ),
      ),
    );
  }

  void _showEditDialog(String userName, String photoUrl, String gender) {
    EditProfileDialog.show(
      context,
      currentName: userName,
      currentPhotoUrl: photoUrl,
      gender: gender,
      onSave: _handleProfileUpdate,
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          color: const Color.fromARGB(255, 235, 233, 243),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4CAF50),
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: const Color(0xFF7C4DFF),
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.zero,
            isScrollable: false,
            tabs: [

              Tab(
                icon: Icon(
                  Icons.local_activity_sharp,
                  color: const Color(0xFF2196F3),
                ),
              ),
                            Tab(
                icon: Icon(
                  CupertinoIcons.tree,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.emoji_events,
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: TabBarView(
            controller: _tabController,
            children: [
              _KeepAliveWrapper(child: _buildActividadTab()),
                            _KeepAliveWrapper(child: _buildPlantaTab()),

              _KeepAliveWrapper(child: _buildInsigniasTab()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlantaTab() {
    return BlocBuilder<GamificacionBloc, GamificacionState>(
      buildWhen: (previous, current) {
        if (current is! GamificacionLoaded || previous is! GamificacionLoaded) {
          return true;
        }
        final prevEstado = previous.gamificacion.estadoGeneral;
        final currEstado = current.gamificacion.estadoGeneral;
        return prevEstado.plantaValor != currEstado.plantaValor ||
               prevEstado.salud != currEstado.salud ||
               prevEstado.etapa != currEstado.etapa;
      },
      builder: (context, state) {
        if (state is GamificacionLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
          );
        }

        if (state is GamificacionLoaded) {
          final estadoGeneral = state.gamificacion.estadoGeneral;

          return Column(
            children: [
              Expanded(
                child: PlantaAnimationWidget(
                  plantaValor: estadoGeneral.plantaValor,
                  salud: estadoGeneral.salud,
                  etapa: estadoGeneral.etapa,
                  size: 200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: PlantaInfoCard(
                  etapa: estadoGeneral.etapa,
                  salud: estadoGeneral.salud,
                  plantaValor: estadoGeneral.plantaValor,
                ),
              ),
            ],
          );
        }

        return Center(
          child: Text(
            'No se pudieron cargar los datos',
            style: TextStyle(color: Colors.grey[600]),
          ),
        );
      },
    );
  }

  Widget _buildActividadTab() {
    return BlocBuilder<GamificacionBloc, GamificacionState>(
      buildWhen: (previous, current) {
        if (current is! GamificacionLoaded || previous is! GamificacionLoaded) {
          return true;
        }
        return previous.gamificacion.historialEventos !=
            current.gamificacion.historialEventos;
      },
      builder: (context, state) {
        if (state is GamificacionLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
          );
        }

        if (state is GamificacionLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendario de Actividad',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7C4DFF),
                  ),
                ),
                const SizedBox(height: 16),
                HeatmapHabitosWidget(
                  historialEventos: state.gamificacion.historialEventos,
                ),
              ],
            ),
          );
        }

        return Center(
          child: Text(
            'No se pudieron cargar los datos',
            style: TextStyle(color: Colors.grey[600]),
          ),
        );
      },
    );
  }

  Widget _buildInsigniasTab() {
    return BlocBuilder<GamificacionBloc, GamificacionState>(
      buildWhen: (previous, current) {
        if (current is! GamificacionLoaded || previous is! GamificacionLoaded) {
          return true;
        }
        return previous.insignias != current.insignias ||
            previous.insigniasRecienDesbloqueadas !=
                current.insigniasRecienDesbloqueadas;
      },
      builder: (context, state) {
        if (state is GamificacionLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
          );
        }

        if (state is GamificacionLoaded) {
          final insignias = state.insignias ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                if (state.insigniasRecienDesbloqueadas != null &&
                    state.insigniasRecienDesbloqueadas!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.celebration, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¡${state.insigniasRecienDesbloqueadas!.length} nueva(s) insignia(s) desbloqueada(s)!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                InsigniasRecentesWidget(
                  insignias: insignias,
                  maxToShow: 5,
                ),
                const SizedBox(height: 16),
                InsigniasGrid(
                  insignias: insignias,
                  crossAxisCount: 3,
                  showOnlyUnlocked: false,
                ),
              ],
            ),
          );
        }

        return Center(
          child: Text(
            'No se pudieron cargar las insignias',
            style: TextStyle(color: Colors.grey[600]),
          ),
        );
      },
    );
  }
}

// Widget para mantener el estado de los tabs
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}