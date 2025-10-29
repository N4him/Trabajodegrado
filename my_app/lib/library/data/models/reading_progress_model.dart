import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reading_progress_entity.dart';

class ReadingProgressModel extends ReadingProgressEntity {
  const ReadingProgressModel({
    required super.bookId,
    required super.userId,
    required super.currentPage,
    required super.totalPages,
    required super.progressPercentage,
    required super.lastReadAt,
    required super.isCompleted,
    super.completedAt,
  });

  factory ReadingProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReadingProgressModel(
      bookId: data['bookId'] ?? '',
      userId: data['userId'] ?? '',
      currentPage: data['currentPage'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      lastReadAt: (data['lastReadAt'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'userId': userId,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'progressPercentage': progressPercentage,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'isCompleted': isCompleted,
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!) 
          : null,
    };
  }

  // Método para crear una nueva instancia con valores actualizados
  ReadingProgressModel copyWith({
    String? bookId,
    String? userId,
    int? currentPage,
    int? totalPages,
    double? progressPercentage,
    DateTime? lastReadAt,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ReadingProgressModel(
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}