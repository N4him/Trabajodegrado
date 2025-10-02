import 'package:equatable/equatable.dart';

class ForumEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String category;
  final String categoryColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int replies;

  const ForumEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.category,
    required this.categoryColor,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    required this.replies,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorId,
        authorName,
        authorPhotoUrl,
        category,
        categoryColor,
        createdAt,
        updatedAt,
        likes,
        replies,
      ];
}