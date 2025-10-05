import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_model.dart';
import '../models/reply_model.dart';

abstract class ForumRemoteDataSource {
  Future<String> createForumPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String category,
    required String categoryColor,
  });

  Future<List<ForumModel>> getForumPosts();
  Future<List<ForumModel>> searchForumPostsByTitle(String query);
  Future<List<ForumModel>> getUserForumPosts(String userId);

  Future<void> likeForumPost({
    required String forumId,
    required String userId,
  });

  Future<void> unlikeForumPost({
    required String forumId,
    required String userId,
  });

  Future<String> replyForumPost({
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  });

  Future<List<ReplyModel>> getForumReplies(String forumId);
  Future<void> deleteForumPost(String forumId);
}

class ForumRemoteDataSourceImpl implements ForumRemoteDataSource {
  final FirebaseFirestore firestore;

  ForumRemoteDataSourceImpl({required this.firestore});

  @override
  Future<String> createForumPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String category,
    required String categoryColor,
  }) async {
    final docRef = await firestore.collection('forums').add({
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'category': category,
      'categoryColor': categoryColor,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'likes': 0,
      'replies': 0,
    });
    return docRef.id;
  }

  @override
  Future<List<ForumModel>> getForumPosts() async {
    final querySnapshot = await firestore
        .collection('forums')  // 👈 CAMBIADO
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ForumModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<ForumModel>> searchForumPostsByTitle(String query) async {
    final queryLower = query.toLowerCase();
    
    final querySnapshot = await firestore
        .collection('forums')  // 👈 CAMBIADO
        .orderBy('createdAt', descending: true)
        .get();

    // Filtrar en el cliente por el título
    return querySnapshot.docs
        .map((doc) => ForumModel.fromFirestore(doc))
        .where((post) => post.title.toLowerCase().contains(queryLower))
        .toList();
  }

  @override
  Future<List<ForumModel>> getUserForumPosts(String userId) async {
    final querySnapshot = await firestore
        .collection('forums')  // 👈 CAMBIADO
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ForumModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> likeForumPost({
    required String forumId,
    required String userId,
  }) async {
    await firestore.runTransaction((transaction) async {
      final forumRef = firestore.collection('forums').doc(forumId);  // 👈 CAMBIADO
      final likeRef = forumRef.collection('likes').doc(userId);

      transaction.set(likeRef, {'userId': userId, 'createdAt': FieldValue.serverTimestamp()});
      transaction.update(forumRef, {'likes': FieldValue.increment(1)});
    });
  }

  @override
  Future<void> unlikeForumPost({
    required String forumId,
    required String userId,
  }) async {
    await firestore.runTransaction((transaction) async {
      final forumRef = firestore.collection('forums').doc(forumId);  // 👈 CAMBIADO
      final likeRef = forumRef.collection('likes').doc(userId);

      transaction.delete(likeRef);
      transaction.update(forumRef, {'likes': FieldValue.increment(-1)});
    });
  }

  @override
  Future<String> replyForumPost({
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    final docRef = await firestore
        .collection('forums')  // 👈 CAMBIADO
        .doc(forumId)
        .collection('replies')
        .add({
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': Timestamp.now(),
    });

    await firestore.collection('forums').doc(forumId).update({  // 👈 CAMBIADO
      'replies': FieldValue.increment(1),
    });

    return docRef.id;
  }

  @override
  Future<List<ReplyModel>> getForumReplies(String forumId) async {
    final querySnapshot = await firestore
        .collection('forums')  // 👈 CAMBIADO
        .doc(forumId)
        .collection('replies')
        .orderBy('createdAt', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => ReplyModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> deleteForumPost(String forumId) async {
    await firestore.collection('forums').doc(forumId).delete();  // 👈 CAMBIADO
  }
}