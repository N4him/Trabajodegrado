import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/usescases/usecase.dart';
import 'package:my_app/library/domain/usescases/get_books.dart';
import 'package:my_app/library/domain/usescases/get_books_by_category.dart';
import 'package:my_app/library/domain/usescases/search_books.dart';

import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetBooks getBooks;
  final GetBooksByCategory getBooksByCategory;
  final SearchBooks searchBooks;

  LibraryBloc({
    required this.getBooks,
    required this.getBooksByCategory,
    required this.searchBooks,
  }) : super(LibraryInitial()) {
    on<GetBooksEvent>(_onGetBooks);
    on<GetBooksByCategoryEvent>(_onGetBooksByCategory);
    on<SearchBooksEvent>(_onSearchBooks);
  }

  void _onGetBooks(GetBooksEvent event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    final result = await getBooks(NoParams());

    result.fold(
      (failure) {
        emit(LibraryError(message: failure.message));
      },
      (books) {
        emit(LibraryLoaded(books: books));
      },
    );
  }

  void _onGetBooksByCategory(
      GetBooksByCategoryEvent event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    
    final result = await getBooksByCategory(event.category);
    
    result.fold(
      (failure) {
        emit(LibraryError(message: failure.message));
      },
      (books) {
        emit(LibraryLoaded(books: books));
      },
    );
  }

  void _onSearchBooks(SearchBooksEvent event, Emitter<LibraryState> emit) async {
    final query = event.query.trim();
    
    
    if (query.isEmpty) {
      add(GetBooksEvent());
      return;
    }
    
    emit(LibraryLoading());
    
    final result = await searchBooks(query);
    
    result.fold(
      (failure) {
        emit(LibraryError(message: failure.message));
      },
      (books) {
        
        if (books.isEmpty) {
          emit(const LibraryError(message: "No se encontraron libros que coincidan con tu búsqueda"));
        } else {
          emit(LibraryLoaded(books: books));
        }
      },
    );
  }
}