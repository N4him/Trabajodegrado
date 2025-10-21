import 'package:equatable/equatable.dart';

class SavedBookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final String coverUrl;
  final int pages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SavedBookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.coverUrl,
    required this.pages,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, author, createdAt];
}