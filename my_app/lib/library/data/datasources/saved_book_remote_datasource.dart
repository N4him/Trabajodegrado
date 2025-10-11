import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saved_book_model.dart';

abstract class SavedBookRemoteDataSource {
  Future<void> saveBook(SavedBookModel book, String userId);
  Future<List<SavedBookModel>> getUserSavedBooks(String userId);
  Future<SavedBookModel?> getSavedBook(String bookId, String userId);
  Future<void> deleteSavedBook(String bookId, String userId);
  Future<bool> isBookSaved(String bookId, String userId);
}

class SavedBookRemoteDataSourceImpl implements SavedBookRemoteDataSource {
  final FirebaseFirestore firestore;

  SavedBookRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> saveBook(SavedBookModel book, String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('saved_books')
          .doc(book.id)
          .set(book.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Error al guardar el libro: ${e.message}');
    }
  }

  @override
  Future<List<SavedBookModel>> getUserSavedBooks(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('saved_books')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SavedBookModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al cargar los libros guardados: ${e.message}');
    }
  }

  @override
  Future<SavedBookModel?> getSavedBook(String bookId, String userId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('saved_books')
          .doc(bookId)
          .get();

      if (!doc.exists) return null;
      return SavedBookModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener el libro: ${e.message}');
    }
  }

  @override
  Future<void> deleteSavedBook(String bookId, String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('saved_books')
          .doc(bookId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Error al eliminar el libro: ${e.message}');
    }
  }

  @override
  Future<bool> isBookSaved(String bookId, String userId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('saved_books')
          .doc(bookId)
          .get();

      return doc.exists;
    } on FirebaseException catch (e) {
      throw Exception('Error al verificar el libro: ${e.message}');
    }
  }
}