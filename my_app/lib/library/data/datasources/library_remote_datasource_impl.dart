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
      print("🔍 Intentando obtener libros de Firestore...");
      
      final querySnapshot = await firestore
          .collection(collectionName)
          .orderBy('title')
          .get();
      
      print("📊 Documentos obtenidos: ${querySnapshot.docs.length}");
      
      if (querySnapshot.docs.isEmpty) {
        print("⚠️ No se encontraron documentos en la colección '$collectionName'");
        return [];
      }
      
      final books = <BookModel>[];
      for (var doc in querySnapshot.docs) {
        try {
          final book = BookModel.fromFirestore(doc);
          books.add(book);
        } catch (e) {
          print("❌ Error procesando documento ${doc.id}: $e");
          continue;
        }
      }
      
      print("🎉 Total de libros procesados: ${books.length}");
      return books;
      
    } catch (e) {
      print("💥 Error general en getBooks: $e");
      throw ServerException();
    }
  }

  @override
  Future<List<BookModel>> getBooksByCategory(String category) async {
    try {
      print("🔍 Buscando libros por categoría: $category");
      
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('category', isEqualTo: category)
          .orderBy('title')
          .get();
      
      print("📊 Libros encontrados en categoría '$category': ${querySnapshot.docs.length}");
      
      return querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("❌ Error en getBooksByCategory: $e");
      throw ServerException();
    }
  }

  @override
  Future<BookModel> getBookById(String id) async {
    try {
      print("🔍 Buscando libro por ID: $id");
      
      final doc = await firestore
          .collection(collectionName)
          .doc(id)
          .get();
      
      if (!doc.exists) {
        print("❌ Libro no encontrado: $id");
        throw ServerException();
      }
      
      return BookModel.fromFirestore(doc);
    } catch (e) {
      print("❌ Error en getBookById: $e");
      throw ServerException();
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      print("🔍 Buscando libros por título: '$query'");
      
      if (query.trim().isEmpty) {
        print("⚠️ Query vacía, retornando lista vacía");
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
      
      print("✅ Búsqueda por título completada. Resultados: ${results.length}");
      return results;
      
    } catch (e) {
      print("❌ Error en searchBooks: $e");
      throw ServerException();
    }
  }
  
  Future<void> _searchTitleByQuery(
    String query,
    Set<String> foundIds,
    List<BookModel> results,
  ) async {
    try {
      print("🔍 Buscando títulos que empiecen con: '$query'");
      
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .orderBy('title')
          .limit(20)
          .get();
      
      print("📊 Encontrados ${querySnapshot.docs.length} libros con query '$query'");
      _addUniqueResults(querySnapshot, foundIds, results);
      
    } catch (e) {
      print("⚠️ Error en búsqueda de título con query '$query': $e");
    }
  }
  
  Future<void> _performLocalTitleSearch(
    String query,
    Set<String> foundIds,
    List<BookModel> results,
  ) async {
    try {
      print("🔍 Realizando búsqueda local en títulos...");
      
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
          print("⚠️ Error procesando documento en búsqueda local: ${doc.id}");
        }
      }
      
      print("📊 Coincidencias locales encontradas en títulos: $localMatches");
      
    } catch (e) {
      print("⚠️ Error en búsqueda local de títulos: $e");
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
          print("📖 Agregado: ${book.title}");
        } catch (e) {
          print("⚠️ Error procesando resultado: ${doc.id}");
        }
      }
    }
  }
}