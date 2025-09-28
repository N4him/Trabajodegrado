import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/usescases/usecase.dart';
import 'package:my_app/library/domain/usescases/get_books.dart';

import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetBooks getBooks;

  LibraryBloc({required this.getBooks}) : super(LibraryInitial()) {
    on<GetBooksEvent>(_onGetBooks);
    on<GetBooksByCategoryEvent>(_onGetBooksByCategory);
    on<SearchBooksEvent>(_onSearchBooks);
  }

void _onGetBooks(GetBooksEvent event, Emitter<LibraryState> emit) async {
  emit(LibraryLoading());
  final result = await getBooks(NoParams());

  result.fold(
    (failure) {
      print("❌ Error al obtener libros: ${failure.message}");
      emit(LibraryError(message: failure.message));
    },
    (books) {
      print("✅ Se obtuvieron ${books.length} libros desde Firestore");
      for (var b in books) {
        print("📖 Libro: ${b.title} - Autor: ${b.author}");
      }
      emit(LibraryLoaded(books: books));
    },
  );
}


  void _onGetBooksByCategory(
      GetBooksByCategoryEvent event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    // Implementar lógica para obtener libros por categoría
  }

  void _onSearchBooks(SearchBooksEvent event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    // Implementar lógica para buscar libros
  }
}