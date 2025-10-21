import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/library/domain/repositories/saved_book_repository.dart';
import 'package:my_app/library/domain/usescases/check_book_saved_usecase.dart';
import 'package:my_app/library/domain/usescases/delete_saved_book_usecase.dart';
import 'package:my_app/library/domain/usescases/get_user_saved_books_usecase.dart';
import 'package:my_app/library/domain/usescases/save_book_usecase.dart';
import 'saved_book_event.dart';
import 'saved_book_state.dart';

class SavedBookBloc extends Bloc<SavedBookEvent, SavedBookState> {
  final SaveBookUseCase saveBookUseCase;
  final GetUserSavedBooksUseCase getUserSavedBooksUseCase;
  final DeleteSavedBookUseCase deleteSavedBookUseCase;
  final CheckBookSavedUseCase checkBookSavedUseCase;
  final SavedBookRepository repository;

  SavedBookBloc({
    required this.saveBookUseCase,
    required this.getUserSavedBooksUseCase,
    required this.deleteSavedBookUseCase,
    required this.checkBookSavedUseCase,
    required this.repository,
  }) : super(const SavedBookInitial()) {
    on<GetUserSavedBooksEvent>(_onGetUserSavedBooks);
    on<SaveBookEvent>(_onSaveBook);
    on<DeleteSavedBookEvent>(_onDeleteSavedBook);
    on<CheckBookSavedEvent>(_onCheckBookSaved);
    on<RefreshSavedBooksEvent>(_onRefreshSavedBooks);
  }

  Future<void> _onGetUserSavedBooks(
      GetUserSavedBooksEvent event, Emitter<SavedBookState> emit) async {
    try {
      emit(const SavedBookLoading());
      final books = await getUserSavedBooksUseCase(event.userId);
      emit(SavedBooksLoaded(books));
    } catch (e) {
      emit(SavedBookError('Error al cargar los libros guardados: ${e.toString()}'));
    }
  }

  Future<void> _onSaveBook(
      SaveBookEvent event, Emitter<SavedBookState> emit) async {
    try {
      emit(const SavedBookLoading());
      await saveBookUseCase(event.book, event.userId);
      final books = await getUserSavedBooksUseCase(event.userId);
      emit(SavedBooksLoaded(books));
    } catch (e) {
      emit(SavedBookError('Error al guardar el libro: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteSavedBook(
      DeleteSavedBookEvent event, Emitter<SavedBookState> emit) async {
    try {
      if (state is SavedBooksLoaded) {
        final currentBooks = (state as SavedBooksLoaded).books;
        emit(SavedBookUpdating(currentBooks));
      }

      await deleteSavedBookUseCase(event.bookId, event.userId);
      final books = await getUserSavedBooksUseCase(event.userId);
      emit(SavedBooksLoaded(books));
    } catch (e) {
      emit(SavedBookError('Error al eliminar el libro: ${e.toString()}'));
    }
  }

  Future<void> _onCheckBookSaved(
      CheckBookSavedEvent event, Emitter<SavedBookState> emit) async {
    try {
      final isSaved = await checkBookSavedUseCase(event.bookId, event.userId);
      emit(BookSaveStatusChecked(isSaved));
    } catch (e) {
      emit(SavedBookError('Error al verificar el libro: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshSavedBooks(
      RefreshSavedBooksEvent event, Emitter<SavedBookState> emit) async {
    try {
      final books = await getUserSavedBooksUseCase(event.userId);
      emit(SavedBooksLoaded(books));
    } catch (e) {
      emit(SavedBookError('Error al actualizar los libros: ${e.toString()}'));
    }
  }
}