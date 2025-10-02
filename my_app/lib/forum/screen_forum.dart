import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/forum/domain/entities/forum_entity.dart';
import 'package:my_app/forum/presentation/bloc/forum_bloc.dart';
import 'package:my_app/forum/presentation/bloc/forum_state.dart';

import '../forum/presentation/bloc/forum_event.dart' as forum_event;

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);
  

  @override
  State<ForumScreen> createState() => _ForumScreenState();
  
}

class _ForumScreenState extends State<ForumScreen> {
    final user = FirebaseAuth.instance.currentUser;
    

  @override
  void initState() {
    super.initState();
    context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro'),
        elevation: 0,
      ),
      body: BlocConsumer<ForumBloc, ForumState>(
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ForumLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text('No hay posts en el foro'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ForumBloc>().add(forum_event.LoadForumPostsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return ForumPostCard(post: post);
                },
              ),
            );
          }

          return const Center(
            child: Text('Cargando...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(Icons.add),
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
      title: const Text('Crear Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(value: 'Ayuda', child: Text('Ayuda')),
                DropdownMenuItem(value: 'Discusión', child: Text('Discusión')),
                DropdownMenuItem(value: 'Anuncio', child: Text('Anuncio')),
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
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (titleController.text.isNotEmpty &&
                contentController.text.isNotEmpty &&
                user != null) {

              // 🔥 Obtener datos del usuario desde Firestore
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();

              final userData = userDoc.data();
              final displayName = userData?['displayName'] ?? 'Usuario Anónimo';
              final photoUrl = userData?['photoUrl'];

              // Crear el post usando los datos de Firestore
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
          child: const Text('Crear'),
        ),
      ],
    ),
  );
}


  String _getCategoryColor(String category) {
    switch (category) {
      case 'General':
        return '#2196F3';
      case 'Ayuda':
        return '#4CAF50';
      case 'Discusión':
        return '#FF9800';
      case 'Anuncio':
        return '#F44336';
      default:
        return '#2196F3';
    }
  }
}

class ForumPostCard extends StatelessWidget {
  final ForumEntity post;

  const ForumPostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(
      int.parse(post.categoryColor.replaceFirst('#', '0xFF')),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPostDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: post.authorPhotoUrl != null
                        ? NetworkImage(post.authorPhotoUrl!)
                        : null,
                    child: post.authorPhotoUrl == null
                        ? Text(post.authorName[0].toUpperCase())
                        : null,
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
                          ),
                        ),
                        Text(
                          _formatDate(post.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.category,
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${post.likes}'),
                  const SizedBox(width: 16),
                  Icon(Icons.comment_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${post.replies}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

void _showPostDetails(BuildContext context) {
  final replyController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalles del Post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: post.authorPhotoUrl != null
                            ? NetworkImage(post.authorPhotoUrl!)
                            : null,
                        child: post.authorPhotoUrl == null
                            ? Text(post.authorName[0].toUpperCase())
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(post.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(post.content),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          context.read<ForumBloc>().add(
                                forum_event.LikeForumPostEvent(
                                  forumId: post.id,
                                  userId: user!.uid,
                                  isLiked: false, // TODO: Verificar estado
                                ),
                              );
                        },
                      ),
                      Text('${post.likes}'),
                      const SizedBox(width: 16),
                      Icon(Icons.comment, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${post.replies}'),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Respuestas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🔥 Aquí reemplazamos el texto hardcodeado por StreamBuilder
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
  .collection('forums')
  .doc(post.id)
  .collection('replies')
  .orderBy('createdAt', descending: true)

                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('No hay respuestas aún');
                      }

                      final replies = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          final reply = replies[index].data() as Map<String, dynamic>;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: reply['authorPhotoUrl'] != null
                                  ? NetworkImage(reply['authorPhotoUrl'])
                                  : null,
                              child: reply['authorPhotoUrl'] == null
                                  ? Text((reply['authorName'] ?? 'U')[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(reply['authorName'] ?? 'Usuario'),
                            subtitle: Text(reply['content'] ?? ''),
                            trailing: Text(
                              _formatDate((reply['createdAt'] as Timestamp).toDate()),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una respuesta...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
  IconButton(
  icon: const Icon(Icons.send),
  onPressed: () async {
    if (replyController.text.isNotEmpty && user != null) {
      // 🔥 Obtener datos del usuario desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final displayName = userData?['displayName'] ?? 'Usuario Anónimo';
      final photoUrl = userData?['photoUrl'];

      // 🔥 Print para depurar permisos
      print('UID Auth: ${user.uid}');
      print('UID que se enviará en authorId: ${user.uid}'); // aquí normalmente sería el mismo
      print('DisplayName: $displayName');
      print('PhotoURL: $photoUrl');

      // Crear reply usando datos de Firestore
      context.read<ForumBloc>().add(
            forum_event.ReplyToForumPostEvent(
              forumId: post.id,
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


              ],
            ),
          ],
        ),
      ),
    ),
  );
}


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}