// ignore_for_file: use_build_context_synchronously

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/forum/domain/entities/forum_entity.dart';
import 'package:my_app/forum/presentation/bloc/forum_bloc.dart';
import 'package:my_app/forum/presentation/bloc/forum_state.dart';
import 'package:my_app/gamification/domain/entities/modulo_progreso.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_bloc.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_event.dart';
import 'package:my_app/widgets/cache_avatar_forum.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'bloc/forum_event.dart' as forum_event;

const Color primaryColor = Color(0xFF5A65AD);
const Color accentColor = Color(0xFF6E7CC0);
const Color backgroundColor = Color(0xFFF8F9FD);

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _loadedPostIds = {};
  final Set<String> _loadingPostIds = {};
  final Set<String> _deletedPostIds = {};
  bool _showCategoryFilter = false;
  bool _showMyPosts = false;

  static const List<String> categories = [
    'Popular',
    'General',
    'Help',
    'Discussion',
    'Announcement',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      selectedCategory = category;
      _searchController.clear();
      _loadedPostIds.clear();
      _loadingPostIds.clear();
      _deletedPostIds.clear();
      _showMyPosts = false;
    });

    if (category == 'Popular') {
      context.read<ForumBloc>().add(const forum_event.LoadPopularForumPostsEvent());
    } else if (category != null) {
      context.read<ForumBloc>().add(forum_event.LoadForumPostsByCategoryEvent(category));
    } else {
      context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
    }
  }

  void _preloadVisibleAvatars(List<ForumEntity> posts) {
    final urls = posts
        .take(10)
        .map((post) => post.authorPhotoUrl)
        .toList();
    
    AvatarPreloader.preloadAvatars(urls);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _loadedPostIds.clear();
      _loadingPostIds.clear();
      _deletedPostIds.clear();
    });

    if (query.isEmpty) {
      if (_showMyPosts && user != null) {
        context.read<ForumBloc>().add(forum_event.LoadUserForumPostsEvent(user!.uid));
      } else if (selectedCategory == 'Popular') {
        context.read<ForumBloc>().add(const forum_event.LoadPopularForumPostsEvent());
      } else if (selectedCategory != null) {
        context.read<ForumBloc>().add(forum_event.LoadForumPostsByCategoryEvent(selectedCategory!));
      } else {
        context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
      }
    } else {
      context.read<ForumBloc>().add(forum_event.SearchForumPostsEvent(query));
    }
  }

  void _toggleMyPosts() {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.login_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Debes iniciar sesión para ver tus posts'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _showMyPosts = !_showMyPosts;
      _loadedPostIds.clear();
      _loadingPostIds.clear();
      _deletedPostIds.clear();
      _searchController.clear();
      selectedCategory = null;
    });

    if (_showMyPosts) {
      context.read<ForumBloc>().add(forum_event.LoadUserForumPostsEvent(user!.uid));
    } else {
      context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTitleBar(),
            Expanded(
              child: BlocConsumer<ForumBloc, ForumState>(
                listener: (context, state) {
                  if (state is ForumError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                  if (state is ForumPostCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post creado exitosamente')),
                    );
                  }
                  if (state is ForumPostDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post eliminado')),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ForumLoading) {
                    return const Center(child: CircularProgressIndicator(color: primaryColor));
                  }

                  if (state is ForumLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _preloadVisibleAvatars(state.posts);
                    });

                    final visiblePosts = state.posts.where((post) => !_deletedPostIds.contains(post.id)).toList();

                    if (visiblePosts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.forum_outlined,
                                size: 60,
                                color: primaryColor.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No se encontraron resultados'
                                  : _showMyPosts
                                      ? 'No tienes posts aún'
                                      : selectedCategory != null
                                          ? 'No hay posts en esta categoría'
                                          : 'No hay posts aún',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Intenta con otras palabras clave'
                                  : _showMyPosts
                                      ? 'Crea tu primer post'
                                      : selectedCategory != null
                                          ? 'Prueba con otra categoría'
                                          : 'Sé el primero en iniciar una discusión',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _loadedPostIds.clear();
                        _loadingPostIds.clear();
                        _deletedPostIds.clear();
                        if (_showMyPosts && user != null) {
                          context.read<ForumBloc>().add(
                            forum_event.LoadUserForumPostsEvent(user!.uid),
                          );
                        } else if (selectedCategory == 'Popular') {
                          context.read<ForumBloc>().add(
                            const forum_event.LoadPopularForumPostsEvent(),
                          );
                        } else if (selectedCategory != null) {
                          context.read<ForumBloc>().add(
                            forum_event.LoadForumPostsByCategoryEvent(selectedCategory!),
                          );
                        } else {
                          context.read<ForumBloc>().add(
                             forum_event.LoadForumPostsEvent(),
                          );
                        }
                      },
                      color: primaryColor,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          const SizedBox(height: 16),
                          ...visiblePosts.asMap().entries.map((entry) {
                            final post = entry.value;
                            
                            if (_showMyPosts && user != null && post.authorId == user?.uid) {
                              return Dismissible(
                                key: Key(post.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF5252).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.warning_rounded,
                                                color: Color(0xFFFF5252),
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              '¿Eliminar post?',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          'Esta acción no se puede deshacer. El post y todas sus respuestas serán eliminados permanentemente.',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(dialogContext).pop(false),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                            ),
                                            child: Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(dialogContext).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFF5252),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onDismissed: (direction) {
                                  setState(() {
                                    _deletedPostIds.add(post.id);
                                    _loadedPostIds.remove(post.id);
                                    _loadingPostIds.remove(post.id);
                                  });
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Post eliminado correctamente',
                                              style: TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFFFF5252),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    if (mounted) {
                                      context.read<ForumBloc>().add(
                                        forum_event.DeleteForumPostEvent(post.id),
                                      );
                                    }
                                  });
                                },
                                child: LazyForumPostCard(
                                  key: ValueKey(post.id),
                                  post: post,
                                  postId: post.id,
                                  isLoaded: _loadedPostIds.contains(post.id),
                                  onVisibilityChanged: (isVisible) {
                                    if (isVisible && 
                                        !_loadedPostIds.contains(post.id) && 
                                        !_loadingPostIds.contains(post.id)) {
                                      setState(() {
                                        _loadingPostIds.add(post.id);
                                      });
                                      Future.delayed(const Duration(milliseconds: 50), () {
                                        if (mounted) {
                                          setState(() {
                                            _loadedPostIds.add(post.id);
                                            _loadingPostIds.remove(post.id);
                                          });
                                        }
                                      });
                                    }
                                  },
                                ),
                              );
                            }
                            
                            return LazyForumPostCard(
                              key: ValueKey(post.id),
                              post: post,
                              postId: post.id,
                              isLoaded: _loadedPostIds.contains(post.id),
                              onVisibilityChanged: (isVisible) {
                                if (isVisible && 
                                    !_loadedPostIds.contains(post.id) && 
                                    !_loadingPostIds.contains(post.id)) {
                                  setState(() {
                                    _loadingPostIds.add(post.id);
                                  });
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    if (mounted) {
                                      setState(() {
                                        _loadedPostIds.add(post.id);
                                        _loadingPostIds.remove(post.id);
                                      });
                                    }
                                  });
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  }

                  return const Center(child: Text('Cargando...'));
                },
              ),
            ),
          ],
        ),
      ),
floatingActionButton: Container(
  decoration: BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(40),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.4),
        blurRadius: 10,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: FloatingActionButton(
    onPressed: () => _showCreatePostDialog(context),
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: const Icon(Icons.add_rounded, size: 32),
  ),
),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/foros_card5 (6).jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ' Tu Foro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Comunitario',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.0,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar post por titulo...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: primaryColor.withOpacity(1)),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _showCategoryFilter
                                ? primaryColor.withOpacity(0.2)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.filter_list_rounded,
                            color: _showCategoryFilter ? primaryColor : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showCategoryFilter = !_showCategoryFilter;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_showCategoryFilter)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...categories.map((category) {
                        final isSelected = selectedCategory == category;
                        final categoryColor = _getCategoryColorFromString(category);
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _onCategoryChanged(category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? categoryColor.withOpacity(0.2)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? categoryColor
                                      : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    size: 14,
                                    color: isSelected ? categoryColor : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected ? categoryColor : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Posts',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D2E),
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleMyPosts,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _showMyPosts ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showMyPosts ? primaryColor : Colors.grey[300]!,
                  width: 2,
                ),
                boxShadow: _showMyPosts
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: _showMyPosts ? Colors.white : primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mis Posts',
                    style: TextStyle(
                      color: _showMyPosts ? Colors.white : primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.2,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Popular':
        return Icons.trending_up_rounded;
      case 'General':
        return Icons.chat_bubble_rounded;
      case 'Help':
        return Icons.help_rounded;
      case 'Discussion':
        return Icons.forum_rounded;
      case 'Announcement':
        return Icons.campaign_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColorFromString(String category) {
    switch (category) {
      case 'Popular':
        return const Color(0xFFE91E63);
      case 'General':
        return const Color(0xFF5A65AD);
      case 'Help':
        return const Color(0xFF4CAF50);
      case 'Discussion':
        return const Color(0xFFFF9800);
      case 'Announcement':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF5A65AD);
    }
  }

void _showCreatePostDialog(BuildContext context) {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String selectedCategory = 'General';
  String categoryColor = '#5A65AD';
  final user = FirebaseAuth.instance.currentUser;
  final formKey = GlobalKey<FormState>();

  showModal(
    context: context,
    configuration: FadeScaleTransitionConfiguration(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: false,
    ),
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 50,
                offset: const Offset(0, 20),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.create_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crear Publicación',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Comparte tus ideas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Título', Icons.title_rounded, true),
                        const SizedBox(height: 10),
                        _buildTextField(titleController, 'Ej: ¿Cómo mejorar mi productividad?', 100, false),
                        const SizedBox(height: 24),
                        _buildFieldLabel('Categoría', Icons.category_rounded, true),
                        const SizedBox(height: 10),
                        _buildCategoryDropdown((value) {
                          setState(() {
                            selectedCategory = value;
                            categoryColor = _getCategoryColorFromValue(value);
                          });
                        }, selectedCategory),
                        const SizedBox(height: 24),
                        _buildFieldLabel('Descripción', Icons.description_rounded, true),
                        const SizedBox(height: 10),
                        _buildTextField(contentController, 'Describe tu publicación de manera detallada...', 500, true),
                      ],
                    ),
                  ),
                ),
              ),
              _buildDialogButtons(titleController, contentController, selectedCategory, categoryColor, user, formKey, dialogContext, context),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTextField(TextEditingController controller, String hint, int maxLength, bool isMultiline) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryColor.withOpacity(0.15),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: isMultiline ? 8 : 1,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1D2E),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
          counterStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return isMultiline ? 'Por favor ingresa el contenido' : 'Por favor ingresa un título';
          }
          if (value.trim().length < (isMultiline ? 10 : 5)) {
            return isMultiline
                ? 'El contenido debe tener al menos 10 caracteres'
                : 'El título debe tener al menos 5 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(Function(String) onChanged, String selectedValue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryColor.withOpacity(0.15),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D2E),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: [
            _buildCategoryItem('General', Icons.chat_bubble_rounded, const Color(0xFF5A65AD)),
            _buildCategoryItem('Ayuda', Icons.help_rounded, const Color(0xFF4CAF50)),
            _buildCategoryItem('Discusión', Icons.forum_rounded, const Color(0xFFFF9800)),
            _buildCategoryItem('Anuncio', Icons.campaign_rounded, const Color(0xFFF44336)),
          ],
          onChanged: (value) => onChanged(value!),
        ),
      ),
    );
  }

  Widget _buildDialogButtons(
    TextEditingController titleController,
    TextEditingController contentController,
    String selectedCategory,
    String categoryColor,
    User? user,
    GlobalKey<FormState> formKey,
    BuildContext dialogContext,
    BuildContext screenContext,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: Colors.grey[300]!, width: 2),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && user != null) {
                  showDialog(
                    context: screenContext,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );

                  try {
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    final userData = userDoc.data();
                    final displayName = userData?['displayName'] ?? 'Usuario Anónimo';
                    final photoUrl = userData?['photoUrl'];

                    screenContext.read<ForumBloc>().add(
                          forum_event.CreateForumPostEvent(
                            title: titleController.text.trim(),
                            content: contentController.text.trim(),
                            authorId: user.uid,
                            authorName: displayName,
                            authorPhotoUrl: photoUrl,
                            category: selectedCategory,
                            categoryColor: categoryColor,
                          ),
                        );

                    screenContext.read<GamificacionBloc>().add(
                          UpdateModuloProgressEvent(
                            userId: user.uid,
                            moduloKey: 'foro',
                            progreso: ModuloProgreso(
                              publicaciones: 1,
                            ),
                          ),
                        );

                    Navigator.pop(screenContext);
                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '¡Publicación creada exitosamente!',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(screenContext);
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Publicar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text, IconData icon, bool required) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primaryColor.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D2E),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text('*', style: TextStyle(color: Color(0xFFF44336), fontSize: 14)),
        ],
      ],
    );
  }

  DropdownMenuItem<String> _buildCategoryItem(String value, IconData icon, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getCategoryColorFromValue(String category) {
    switch (category) {
      case 'General':
        return '#5A65AD';
      case 'Ayuda':
        return '#4CAF50';
      case 'Discusión':
        return '#FF9800';
      case 'Anuncio':
        return '#F44336';
      default:
        return '#5A65AD';
    }
  }
}

// Widget con Lazy Loading Optimizado
class LazyForumPostCard extends StatefulWidget {
  final ForumEntity post;
  final String postId;
  final bool isLoaded;
  final Function(bool) onVisibilityChanged;

  const LazyForumPostCard({
    super.key,
    required this.post,
    required this.postId,
    required this.isLoaded,
    required this.onVisibilityChanged,
  });

  @override
  State<LazyForumPostCard> createState() => _LazyForumPostCardState();
}

class _LazyForumPostCardState extends State<LazyForumPostCard> {
  late int localLikes;
  bool? hasLiked;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    localLikes = widget.post.likes;
    if (widget.isLoaded) {
      _checkIfLiked();
    }
  }

  @override
  void didUpdateWidget(LazyForumPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLoaded && widget.isLoaded && hasLiked == null) {
      _checkIfLiked();
    }
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          hasLiked = false;
          isLoading = false;
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('forums')
          .doc(widget.post.id)
          .collection('likes')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          hasLiked = doc.exists;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasLiked = false;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || hasLiked == null) return;

    setState(() {
      if (hasLiked!) {
        localLikes = (localLikes > 0) ? localLikes - 1 : 0;
        hasLiked = false;
      } else {
        localLikes = localLikes + 1;
        hasLiked = true;
      }
    });

    try {
      if (hasLiked!) {
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.post.id)
            .collection('likes')
            .doc(user.uid)
            .set({'userId': user.uid, 'createdAt': FieldValue.serverTimestamp()});

        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.post.id)
            .update({'likes': FieldValue.increment(1)});
      } else {
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.post.id)
            .collection('likes')
            .doc(user.uid)
            .delete();

        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.post.id)
            .update({'likes': FieldValue.increment(-1)});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (hasLiked!) {
            localLikes = localLikes + 1;
            hasLiked = false;
          } else {
            localLikes = (localLikes > 0) ? localLikes - 1 : 0;
            hasLiked = true;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.postId),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3) {
          widget.onVisibilityChanged(true);
        }
      },
      child: widget.isLoaded
          ? ModernForumPostCard(
              post: widget.post,
              localLikes: localLikes,
              hasLiked: hasLiked,
              isLoading: isLoading,
              onLikeTap: _handleLike,
            )
          : _buildLoadingPlaceholder(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernForumPostCard extends StatelessWidget {
  final ForumEntity post;
  final int localLikes;
  final bool? hasLiked;
  final bool isLoading;
  final VoidCallback onLikeTap;

  const ModernForumPostCard({
    super.key,
    required this.post,
    required this.localLikes,
    required this.hasLiked,
    required this.isLoading,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(int.parse(post.categoryColor.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPostDetails(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OptimizedCachedAvatar(
                      photoUrl: post.authorPhotoUrl,
                      fallbackText: post.authorName,
                      radius: 24,
                      backgroundColor: categoryColor.withOpacity(0.2),
                      textColor: categoryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1D2E),
                            ),
                          ),
                          Text(
                            _formatDate(post.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: categoryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        post.category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: isLoading ? null : onLikeTap,
                        child: Row(
                          children: [
                            Icon(
                              hasLiked == true ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18,
                              color: hasLiked == true ? primaryColor : Colors.grey[400],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$localLikes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.chat_bubble_rounded, size: 18, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        '${post.replies}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPostDetails(BuildContext context) {
    final replyController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    final categoryColor = Color(int.parse(post.categoryColor.replaceFirst('#', '0xFF')));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: primaryColor, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Detalles',
              style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag_rounded, color: Colors.red, size: 20),
                ),
                onPressed: () => _showReportDialog(context, post),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                OptimizedCachedAvatar(
                                  photoUrl: post.authorPhotoUrl,
                                  fallbackText: post.authorName,
                                  radius: 22,
                                  backgroundColor: categoryColor.withOpacity(0.2),
                                  textColor: categoryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        _formatDate(post.createdAt),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: categoryColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    post.category,
                                    style: TextStyle(
                                      color: categoryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              post.content,
                              style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        hasLiked == true ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text('$localLikes', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.chat_bubble_rounded, size: 16, color: primaryColor),
                                      const SizedBox(width: 6),
                                      Text('${post.replies}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.comment_rounded, size: 20, color: primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Respuestas (${post.replies})',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('forums')
                                  .doc(post.id)
                                  .collection('replies')
                                  .orderBy('createdAt', descending: false)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text('No hay respuestas', style: TextStyle(color: Colors.grey[500])),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.docs.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final reply = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          OptimizedCachedAvatar(
                                            photoUrl: reply['authorPhotoUrl'],
                                            fallbackText: reply['authorName'] ?? 'Usuario',
                                            radius: 18,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  reply['authorName'] ?? 'Usuario',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  reply['content'] ?? '',
                                                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        decoration: InputDecoration(
                          hintText: 'Escribe tu comentario...',
                          filled: true,
                          fillColor: backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: () async {
                          if (replyController.text.isNotEmpty && user != null) {
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get();

                            final userData = userDoc.data();
                            context.read<ForumBloc>().add(
                                  forum_event.ReplyToForumPostEvent(
                                    forumId: post.id,
                                    authorId: user.uid,
                                    authorName: userData?['displayName'] ?? 'Usuario',
                                    authorPhotoUrl: userData?['photoUrl'],
                                    content: replyController.text,
                                  ),
                                );
                            replyController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d atrás';
    if (diff.inHours > 0) return '${diff.inHours}h atrás';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m atrás';
    return 'Ahora';
  }

  void _showReportDialog(BuildContext context, ForumEntity post) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.login_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Debes iniciar sesión para reportar'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    String? selectedReason;
    final reasons = [
      'Contenido inapropiado',
      'Spam o publicidad',
      'Acoso o intimidación',
      'Información falsa',
      'Contenido ofensivo',
      'Otro',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag_rounded, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Reportar publicación',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Por qué deseas reportar esta publicación?',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: reasons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final reason = entry.value;
                    final isSelected = selectedReason == reason;
                    
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => selectedReason = reason),
                          borderRadius: BorderRadius.vertical(
                            top: index == 0 ? const Radius.circular(16) : Radius.zero,
                            bottom: index == reasons.length - 1 ? const Radius.circular(16) : Radius.zero,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red.withOpacity(0.05) : Colors.transparent,
                              borderRadius: BorderRadius.vertical(
                                top: index == 0 ? const Radius.circular(16) : Radius.zero,
                                bottom: index == reasons.length - 1 ? const Radius.circular(16) : Radius.zero,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  color: isSelected ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? Colors.red : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index < reasons.length - 1)
                          Divider(height: 1, color: Colors.grey[200]),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () async {
                      Navigator.of(dialogContext).pop();
                      
                      try {
                        await FirebaseFirestore.instance.collection('reports').add({
                          'postId': post.id,
                          'postTitle': post.title,
                          'reportedBy': user.uid,
                          'reporterName': user.displayName ?? 'Usuario',
                          'reason': selectedReason,
                          'createdAt': FieldValue.serverTimestamp(),
                          'status': 'pending',
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Reporte enviado. Lo revisaremos pronto.',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF4CAF50),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al enviar reporte: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                'Enviar reporte',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}