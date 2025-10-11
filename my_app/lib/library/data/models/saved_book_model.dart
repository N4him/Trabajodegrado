import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/saved_book_entity.dart';

class SavedBookModel extends SavedBookEntity {
  const SavedBookModel({
    required String id,
    required String title,
    required String author,
    required String description,
    required String category,
    required String coverUrl,
    required int pages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
    id: id,
    title: title,
    author: author,
    description: description,
    category: category,
    coverUrl: coverUrl,
    pages: pages,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory SavedBookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedBookModel(
      id: doc.id,
      title: data['title'] as String,
      author: data['author'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      coverUrl: data['coverUrl'] as String,
      pages: data['pages'] as int,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'coverUrl': coverUrl,
      'pages': pages,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}