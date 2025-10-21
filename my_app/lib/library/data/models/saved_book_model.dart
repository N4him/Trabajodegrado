import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/saved_book_entity.dart';

class SavedBookModel extends SavedBookEntity {
  const SavedBookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.description,
    required super.category,
    required super.coverUrl,
    required super.pages,
    super.createdAt,
    super.updatedAt,
  });

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