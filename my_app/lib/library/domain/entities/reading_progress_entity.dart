import 'package:equatable/equatable.dart';

class ReadingProgressEntity extends Equatable {
  final String bookId;
  final String userId;
  final int currentPage;
  final int totalPages;
  final double progressPercentage;
  final DateTime lastReadAt;
  final bool isCompleted;
  final DateTime? completedAt;

  const ReadingProgressEntity({
    required this.bookId,
    required this.userId,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
    required this.lastReadAt,
    required this.isCompleted,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        bookId,
        userId,
        currentPage,
        totalPages,
        progressPercentage,
        lastReadAt,
        isCompleted,
        completedAt,
      ];
}