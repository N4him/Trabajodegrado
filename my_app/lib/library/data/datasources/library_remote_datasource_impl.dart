import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/core/di/error/exceptions.dart';
import '../models/book_model.dart';
import './library_remote_datasource.dart';

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String collectionName = 'books';

  LibraryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<BookModel>> getBooks() async {
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .orderBy('title')
          .get();
      
      return querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<BookModel>> getBooksByCategory(String category) async {
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('category', isEqualTo: category)
          .orderBy('title')
          .get();
      
      return querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<BookModel> getBookById(String id) async {
    try {
      final doc = await firestore
          .collection(collectionName)
          .doc(id)
          .get();
      
      if (!doc.exists) {
        throw ServerException();
      }
      
      return BookModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get();
      
      return querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }
}