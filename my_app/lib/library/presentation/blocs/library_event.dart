import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object> get props => [];
}

class GetBooksEvent extends LibraryEvent {}

class GetBooksByCategoryEvent extends LibraryEvent {
  final String category;

  const GetBooksByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class SearchBooksEvent extends LibraryEvent {
  final String query;

  const SearchBooksEvent(this.query);

  @override
  List<Object> get props => [query];
}