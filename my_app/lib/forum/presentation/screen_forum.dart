// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/forum/domain/entities/forum_entity.dart';
import 'package:my_app/forum/presentation/bloc/forum_bloc.dart';
import 'package:my_app/forum/presentation/bloc/forum_state.dart';

import 'bloc/forum_event.dart' as forum_event;

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String selectedTab = 'Popular';
  final TextEditingController _searchController = TextEditingController();

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

  void _onTabChanged(String tab) {
    setState(() {
      selectedTab = tab;
      _searchController.clear();
    });

    if (tab == 'Popular') {
      context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
    } else if (tab == 'Mis posts' && user != null) {
      context.read<ForumBloc>().add(forum_event.LoadUserForumPostsEvent(user!.uid));
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      if (selectedTab == 'Popular') {
        context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
      } else if (selectedTab == 'Mis posts' && user != null) {
        context.read<ForumBloc>().add(forum_event.LoadUserForumPostsEvent(user!.uid));
      }
    } else {
      context.read<ForumBloc>().add(forum_event.SearchForumPostsEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
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
                      const SnackBar(content: Text('Post created successfully')),
                    );
                  }
                  if (state is ForumPostDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post deleted')),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ForumLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ForumLoaded) {
                    if (state.posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No results found'
                                  : selectedTab == 'Mis posts'
                                      ? 'No posts yet'
                                      : 'No posts yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Try searching with different keywords'
                                  : selectedTab == 'Mis posts'
                                      ? 'Create your first post'
                                      : 'Be the first to start a discussion',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (selectedTab == 'Popular') {
                          context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
                        } else if (user != null) {
                          context.read<ForumBloc>().add(forum_event.LoadUserForumPostsEvent(user!.uid));
                        }
                      },
                      color: const Color(0xFF667EEA),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          const SizedBox(height: 16),
                          ...state.posts.map((post) => ModernForumPostCard(post: post)),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Loading...'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.5),
              blurRadius: 20,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${user?.displayName ?? 'User'}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome back to the forum',
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search posts by title...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[400]),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('Popular', selectedTab == 'Popular')),
          Expanded(child: _buildTab('Mis posts', selectedTab == 'Mis posts')),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => _onTabChanged(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'General';
    String categoryColor = '#2196F3';
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Create Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Help', child: Text('Help')),
                  DropdownMenuItem(value: 'Discussion', child: Text('Discussion')),
                  DropdownMenuItem(value: 'Announcement', child: Text('Announcement')),
                ],
                onChanged: (value) {
                  selectedCategory = value!;
                  categoryColor = _getCategoryColor(value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty &&
                  user != null) {
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();

                final userData = userDoc.data();
                final displayName = userData?['displayName'] ?? 'Anonymous User';
                final photoUrl = userData?['photoUrl'];

                context.read<ForumBloc>().add(
                      forum_event.CreateForumPostEvent(
                        title: titleController.text,
                        content: contentController.text,
                        authorId: user.uid,
                        authorName: displayName,
                        authorPhotoUrl: photoUrl,
                        category: selectedCategory,
                        categoryColor: categoryColor,
                      ),
                    );

                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getCategoryColor(String category) {
    switch (category) {
      case 'General':
        return '#2196F3';
      case 'Help':
        return '#4CAF50';
      case 'Discussion':
        return '#FF9800';
      case 'Announcement':
        return '#F44336';
      default:
        return '#2196F3';
    }
  }
}

// Updated ModernForumPostCard as StatefulWidget
class ModernForumPostCard extends StatefulWidget {
  final ForumEntity post;

  const ModernForumPostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<ModernForumPostCard> createState() => _ModernForumPostCardState();
}

class _ModernForumPostCardState extends State<ModernForumPostCard> {
  late int localLikes;
  bool? hasLiked;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    localLikes = widget.post.likes;
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        hasLiked = false;
        isLoading = false;
      });
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

    // Optimistic update
    setState(() {
      if (hasLiked!) {
        localLikes = (localLikes > 0) ? localLikes - 1 : 0;
        hasLiked = false;
      } else {
        localLikes = localLikes + 1;
        hasLiked = true;
      }
    });

    // Perform backend update
    try {
      if (hasLiked!) {
        // Add like
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.post.id)
            .collection('likes')
            .doc(user.uid)
            .set({
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.post.id)
            .update({
          'likes': FieldValue.increment(1),
        });
      } else {
        // Remove like
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.post.id)
            .collection('likes')
            .doc(user.uid)
            .delete();
        
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.post.id)
            .update({
          'likes': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      // Revert optimistic update on error
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update like: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(
      int.parse(widget.post.categoryColor.replaceFirst('#', '0xFF')),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withOpacity(0.3),
                            categoryColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: widget.post.authorPhotoUrl != null
                            ? NetworkImage(widget.post.authorPhotoUrl!)
                            : null,
                        backgroundColor: Colors.transparent,
                        child: widget.post.authorPhotoUrl == null
                            ? Text(
                               widget.post.authorName.isNotEmpty 
    ? widget.post.authorName[0].toUpperCase() 
    : 'U',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1D2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(widget.post.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.post.category,
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
                  widget.post.title,
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
                  widget.post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: isLoading ? null : _handleLike,
                        child: _buildStatItem(
                          hasLiked == true 
                              ? Icons.favorite_rounded 
                              : Icons.favorite_border_rounded,
                          '$localLikes',
                          const Color(0xFFFF6B9D),
                        ),
                      ),
                      const SizedBox(width: 20),
                      _buildStatItem(
                        Icons.chat_bubble_rounded,
                        '${widget.post.replies}',
                        const Color(0xFF667EEA),
                      ),
                      const Spacer(),
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

  Widget _buildStatItem(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          count,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showPostDetails(BuildContext context) {
    final replyController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    final categoryColor = Color(
      int.parse(widget.post.categoryColor.replaceFirst('#', '0xFF')),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF1A1D2E), size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Post Details',
              style: TextStyle(
                color: Color(0xFF1A1D2E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
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
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        categoryColor.withOpacity(0.3),
                                        categoryColor.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundImage: widget.post.authorPhotoUrl != null
                                        ? NetworkImage(widget.post.authorPhotoUrl!)
                                        : null,
                                    backgroundColor: Colors.transparent,
                                    child: widget.post.authorPhotoUrl == null
                                        ? Text(
                                         widget.post.authorName.isNotEmpty 
    ? widget.post.authorName[0].toUpperCase() 
    : 'U',
                                            style: TextStyle(
                                              color: categoryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.post.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(widget.post.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: categoryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    widget.post.category,
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
                              widget.post.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D2E),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.post.content,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildStatChip(
                                  hasLiked == true 
                                      ? Icons.favorite_rounded 
                                      : Icons.favorite_border_rounded,
                                  '$localLikes',
                                  const Color(0xFFFF6B9D),
                                ),
                                const SizedBox(width: 12),
                                _buildStatChip(
                                  Icons.chat_bubble_rounded,
                                  '${widget.post.replies}',
                                  const Color(0xFF667EEA),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
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
                                const Icon(Icons.comment_rounded, size: 20, color: Color(0xFF667EEA)),
                                const SizedBox(width: 8),
                                Text(
                                  'Replies (${widget.post.replies})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1D2E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('forums')
                                  .doc(widget.post.id)
                                  .collection('replies')
                                  .orderBy('createdAt', descending: false)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.chat_bubble_outline, 
                                            size: 48, 
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No replies yet',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Be the first to comment',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final replies = snapshot.data!.docs;

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: replies.length,
                                  separatorBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(
                                      color: Colors.grey[200],
                                      height: 1,
                                    ),
                                  ),
                                  itemBuilder: (context, index) {
                                    final reply = replies[index].data() as Map<String, dynamic>;
                                    final replyColor = categoryColor;

                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  replyColor.withOpacity(0.2),
                                                  replyColor.withOpacity(0.05),
                                                ],
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundImage: reply['authorPhotoUrl'] != null
                                                  ? NetworkImage(reply['authorPhotoUrl'])
                                                  : null,
                                              backgroundColor: Colors.transparent,
                                              child: reply['authorPhotoUrl'] == null
                                                  ? Text(
                                                      (reply['authorName'] ?? 'U')[0].toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: replyColor,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      reply['authorName'] ?? 'User',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _formatDate(
                                                        (reply['createdAt'] as Timestamp).toDate(),
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  reply['content'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                    height: 1.4,
                                                  ),
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
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: replyController,
                            decoration: InputDecoration(
                              hintText: 'Write your comment...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(Icons.edit_outlined, 
                                color: Colors.grey[400],
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: () async {
                            if (replyController.text.isNotEmpty && user != null) {
                              final userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();

                              final userData = userDoc.data();
                              final displayName =
                                  userData?['displayName'] ?? 'Anonymous User';
                              final photoUrl = userData?['photoUrl'];

                              context.read<ForumBloc>().add(
                                    forum_event.ReplyToForumPostEvent(
                                      forumId: widget.post.id,
                                      authorId: user.uid,
                                      authorName: displayName,
                                      authorPhotoUrl: photoUrl,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }
}