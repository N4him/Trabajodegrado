// ignore_for_file: empty_catches, unused_local_variable

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
      
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }
      
      final books = <BookModel>[];
      for (var doc in querySnapshot.docs) {
        try {
          final book = BookModel.fromFirestore(doc);
          books.add(book);
        } catch (e) {
          continue;
        }
      }
      
      return books;
      
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
      
      if (query.trim().isEmpty) {
        return [];
      }
      
      final Set<String> foundIds = <String>{};
      final List<BookModel> results = <BookModel>[];
      
      // Búsqueda por título con query original (minúsculas)
      final lowercaseQuery = query.toLowerCase().trim();
      await _searchTitleByQuery(lowercaseQuery, foundIds, results);
      
      // Búsqueda por título con primera letra en mayúscula
      if (query.isNotEmpty) {
        final capitalizedQuery = query[0].toUpperCase() + query.substring(1).toLowerCase();
        await _searchTitleByQuery(capitalizedQuery, foundIds, results);
      }
      
      // Si no encuentra resultados suficientes, busca localmente por coincidencias parciales en título
      if (results.length < 5) {
        await _performLocalTitleSearch(query.toLowerCase().trim(), foundIds, results);
      }
      
      // Ordenar resultados alfabéticamente por título
      results.sort((a, b) => a.title.compareTo(b.title));
      
      return results;
      
    } catch (e) {
      throw ServerException();
    }
  }
  
  Future<void> _searchTitleByQuery(
    String query,
    Set<String> foundIds,
    List<BookModel> results,
  ) async {
    try {
      
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .orderBy('title')
          .limit(20)
          .get();
      
      _addUniqueResults(querySnapshot, foundIds, results);
      
    } catch (e) {
    }
  }
  
  Future<void> _performLocalTitleSearch(
    String query,
    Set<String> foundIds,
    List<BookModel> results,
  ) async {
    try {
      
      final allBooksSnapshot = await firestore
          .collection(collectionName)
          .orderBy('title')
          .limit(50) // Limitar para mejor rendimiento
          .get();
      
      int localMatches = 0;
      for (var doc in allBooksSnapshot.docs) {
        if (foundIds.contains(doc.id)) continue;
        
        try {
          final book = BookModel.fromFirestore(doc);
          
          // Solo buscar coincidencias en el título
          if (book.title.toLowerCase().contains(query)) {
            foundIds.add(doc.id);
            results.add(book);
            localMatches++;
            
            if (results.length >= 20) break; // Limitar resultados totales
          }
        } catch (e) {
        }
      }
      
      
    } catch (e) {
    }
  }
  
  void _addUniqueResults(
    QuerySnapshot querySnapshot,
    Set<String> foundIds,
    List<BookModel> results,
  ) {
    for (var doc in querySnapshot.docs) {
      if (!foundIds.contains(doc.id)) {
        try {
          foundIds.add(doc.id);
          final book = BookModel.fromFirestore(doc);
          results.add(book);
        } catch (e) {
        }
      }
    }
  }
}