import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final DateTime publicationDate;
  final String pdfUrl;
  final String coverUrl;
  final int pages;
  final bool available;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.publicationDate,
    required this.pdfUrl,
    required this.coverUrl,
    required this.pages,
    required this.available,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        description,
        category,
        publicationDate,
        pdfUrl,
        coverUrl,
        pages,
        available,
      ];
}