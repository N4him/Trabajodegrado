import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_bloc.dart';
import 'package:my_app/profile/presentation/bloc/profile_state.dart';
import 'package:my_app/profile/presentation/bloc/profile_event.dart';
import 'package:my_app/widgets/edit_profile_dialog.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
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
            _buildProfileHeader(profile, isUpdating),
            const SizedBox(height: 16),
            _buildTabSection(profile),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final completer = Completer<void>();

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

    return completer.future;
  }

  Widget _buildProfileHeader(dynamic profile, bool isUpdating) {
    final userName = profile.name ?? '';
    final level = profile.level ?? 1;
    final points = profile.points ?? 0;
    final photoUrl = profile.photoUrl ?? '';
    final gender = profile.gender ?? 'boy';

    return Stack(
      children: [
        // Contenedor exterior con sombra interna (efecto hundido)
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 235, 233, 243),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(70),
              bottomRight: Radius.circular(70),
            ),
            boxShadow: [
              // Sombra interior oscura (arriba-izquierda)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              // Sombra interior clara (abajo-derecha) - efecto hundido
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: const Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(56),
                bottomRight: Radius.circular(56),
              ),
              boxShadow: [
                // Sombra interna adicional para profundidad
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(2, 2),
                  blurRadius: 6,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  offset: const Offset(-2, -2),
                  blurRadius: 6,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildProfileAvatar(photoUrl, userName, isUpdating, gender),
                  const SizedBox(height: 16),
                  _buildProfileInfo(userName, gender),
                  const SizedBox(height: 24),
                  _buildProgressBar(level, points),
                ],
              ),
            ),
          ),
        ),
        if (isUpdating) _buildUpdatingOverlay(),
      ],
    );
  }

  Widget _buildProfileAvatar(String photoUrl, String userName, bool isUpdating, String gender) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                : null,
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
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: isUpdating ? null : () => _showEditDialog(userName, photoUrl, gender),
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

  Widget _buildProfileInfo(String userName, String gender) {
    return Column(
      children: [
        Text(
          userName.isNotEmpty ? userName : 'Usuario',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildProgressBar(int level, int points) {
    final progress = (points % 100) / 100;

    return Row(
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
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildUpdatingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
        ),
        child: const Center(
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
    );
  }

  Widget _buildTabSection(dynamic profile) {
    final points = profile.points ?? 0;
    final level = profile.level ?? 1;
    final gender = profile.gender ?? 'boy';

    return SizedBox(
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
                _buildStatsTab(points, level, gender),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(int points, int level, String gender) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [],
      ),
    );
  }
}