
import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_book_entity.dart';

abstract class SavedBookEvent extends Equatable {
  const SavedBookEvent();

  @override
  List<Object?> get props => [];
}

class GetUserSavedBooksEvent extends SavedBookEvent {
  final String userId;

  const GetUserSavedBooksEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SaveBookEvent extends SavedBookEvent {
  final SavedBookEntity book;
  final String userId;

  const SaveBookEvent(this.book, this.userId);

  @override
  List<Object?> get props => [book, userId];
}

class DeleteSavedBookEvent extends SavedBookEvent {
  final String bookId;
  final String userId;

  const DeleteSavedBookEvent(this.bookId, this.userId);

  @override
  List<Object?> get props => [bookId, userId];
}

class CheckBookSavedEvent extends SavedBookEvent {
  final String bookId;
  final String userId;

  const CheckBookSavedEvent(this.bookId, this.userId);

  @override
  List<Object?> get props => [bookId, userId];
}

class RefreshSavedBooksEvent extends SavedBookEvent {
  final String userId;

  const RefreshSavedBooksEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}