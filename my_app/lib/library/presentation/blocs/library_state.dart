import 'package:equatable/equatable.dart';
import '../../domain/entities/book_entity.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<BookEntity> books;

  const LibraryLoaded({required this.books});

  @override
  List<Object> get props => [books];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError({required this.message});

  @override
  List<Object> get props => [message];
}