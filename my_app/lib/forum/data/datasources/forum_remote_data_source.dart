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
    final now = DateTime.now();
    final docRef = await firestore.collection('forums').add({
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'category': category,
      'categoryColor': categoryColor,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'likes': 0,
      'replies': 0,
    });
    return docRef.id;
  }

  @override
  Future<List<ForumModel>> getForumPosts() async {
    final snapshot = await firestore
        .collection('forums')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => ForumModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> likeForumPost({
    required String forumId,
    required String userId,
  }) async {
    final batch = firestore.batch();

    final likeRef = firestore
        .collection('forums')
        .doc(forumId)
        .collection('likes')
        .doc(userId);

    final forumRef = firestore.collection('forums').doc(forumId);

    batch.set(likeRef, {
      'likedAt': Timestamp.now(),
    });

    batch.update(forumRef, {
      'likes': FieldValue.increment(1),
    });

    await batch.commit();
  }

  @override
  Future<void> unlikeForumPost({
    required String forumId,
    required String userId,
  }) async {
    final batch = firestore.batch();

    final likeRef = firestore
        .collection('forums')
        .doc(forumId)
        .collection('likes')
        .doc(userId);

    final forumRef = firestore.collection('forums').doc(forumId);

    batch.delete(likeRef);

    batch.update(forumRef, {
      'likes': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  @override
  Future<String> replyForumPost({
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    final batch = firestore.batch();

    final replyRef = firestore
        .collection('forums')
        .doc(forumId)
        .collection('replies')
        .doc();

    final forumRef = firestore.collection('forums').doc(forumId);

    batch.set(replyRef, {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': Timestamp.now(),
      'likes': 0,
    });

    batch.update(forumRef, {
      'replies': FieldValue.increment(1),
      'updatedAt': Timestamp.now(),
    });

    await batch.commit();
    return replyRef.id;
  }

  @override
  Future<List<ReplyModel>> getForumReplies(String forumId) async {
    final snapshot = await firestore
        .collection('forums')
        .doc(forumId)
        .collection('replies')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) => ReplyModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> deleteForumPost(String forumId) async {
    final batch = firestore.batch();

    // Eliminar subcolección de likes
    final likesSnapshot = await firestore
        .collection('forums')
        .doc(forumId)
        .collection('likes')
        .get();

    for (final doc in likesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Eliminar subcolección de replies
    final repliesSnapshot = await firestore
        .collection('forums')
        .doc(forumId)
        .collection('replies')
        .get();

    for (final doc in repliesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Eliminar el post principal
    final forumRef = firestore.collection('forums').doc(forumId);
    batch.delete(forumRef);

    await batch.commit();
  }
}