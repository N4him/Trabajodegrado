import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.description,
    required super.category,
    required super.publicationDate,
    required super.pdfUrl,
    required super.coverUrl,
    required super.pages,
    required super.available,
  });

  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      publicationDate: (data['publicationDate'] as Timestamp).toDate(),
      pdfUrl: data['pdfUrl'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      pages: data['pages'] ?? 0,
      available: data['available'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'publicationDate': Timestamp.fromDate(publicationDate),
      'pdfUrl': pdfUrl,
      'coverUrl': coverUrl,
      'pages': pages,
      'available': available,
    };
  }
}