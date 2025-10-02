import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/forum_entity.dart';

class ForumModel extends ForumEntity {
  const ForumModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.authorName,
    super.authorPhotoUrl,
    required super.category,
    required super.categoryColor,
    required super.createdAt,
    required super.updatedAt,
    required super.likes,
    required super.replies,
  });

  factory ForumModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      category: data['category'] ?? '',
      categoryColor: data['categoryColor'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      replies: data['replies'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'category': category,
      'categoryColor': categoryColor,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likes': likes,
      'replies': replies,
    };
  }
}