import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_book_entity.dart';

abstract class SavedBookState extends Equatable {
  const SavedBookState();

  @override
  List<Object?> get props => [];
}

class SavedBookInitial extends SavedBookState {
  const SavedBookInitial();
}

class SavedBookLoading extends SavedBookState {
  const SavedBookLoading();
}

class SavedBooksLoaded extends SavedBookState {
  final List<SavedBookEntity> books;

  const SavedBooksLoaded(this.books);

  @override
  List<Object?> get props => [books];
}

class BookSaveStatusChecked extends SavedBookState {
  final bool isSaved;

  const BookSaveStatusChecked(this.isSaved);

  @override
  List<Object?> get props => [isSaved];
}

class SavedBookUpdating extends SavedBookState {
  final List<SavedBookEntity> books;

  const SavedBookUpdating(this.books);

  @override
  List<Object?> get props => [books];
}

class SavedBookError extends SavedBookState {
  final String message;

  const SavedBookError(this.message);

  @override
  List<Object?> get props => [message];
}