import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reading_progress_model.dart';

abstract class ReadingProgressRemoteDataSource {
  Future<void> saveProgress(ReadingProgressModel progress);
  Future<ReadingProgressModel?> getProgress(String bookId, String userId);
  Future<List<ReadingProgressModel>> getUserReadingProgress(String userId);
  Future<List<ReadingProgressModel>> getBooksInProgress(String userId);
  Future<List<ReadingProgressModel>> getCompletedBooks(String userId);
  Future<void> deleteProgress(String bookId, String userId);
  Stream<ReadingProgressModel?> watchProgress(String bookId, String userId);
}

class ReadingProgressRemoteDataSourceImpl implements ReadingProgressRemoteDataSource {
  final FirebaseFirestore firestore;

  ReadingProgressRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> saveProgress(ReadingProgressModel progress) async {
    try {
      await firestore
          .collection('users')
          .doc(progress.userId)
          .collection('reading_progress')
          .doc(progress.bookId)
          .set(progress.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Error al guardar el progreso: ${e.message}');
    }
  }

  @override
  Future<ReadingProgressModel?> getProgress(String bookId, String userId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('reading_progress')
          .doc(bookId)
          .get();

      if (!doc.exists) return null;
      return ReadingProgressModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener el progreso: ${e.message}');
    }
  }

  @override
  Future<List<ReadingProgressModel>> getUserReadingProgress(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('reading_progress')
          .orderBy('lastReadAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReadingProgressModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al cargar el progreso de lectura: ${e.message}');
    }
  }

  @override
  Future<List<ReadingProgressModel>> getBooksInProgress(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('reading_progress')
          .where('isCompleted', isEqualTo: false)
          .orderBy('lastReadAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReadingProgressModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al cargar libros en progreso: ${e.message}');
    }
  }

  @override
  Future<List<ReadingProgressModel>> getCompletedBooks(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('reading_progress')
          .where('isCompleted', isEqualTo: true)
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReadingProgressModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al cargar libros completados: ${e.message}');
    }
  }

  @override
  Future<void> deleteProgress(String bookId, String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('reading_progress')
          .doc(bookId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Error al eliminar el progreso: ${e.message}');
    }
  }

  @override
  Stream<ReadingProgressModel?> watchProgress(String bookId, String userId) {
    try {
      return firestore
          .collection('users')
          .doc(userId)
          .collection('reading_progress')
          .doc(bookId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            return ReadingProgressModel.fromFirestore(doc);
          });
    } on FirebaseException catch (e) {
      throw Exception('Error al escuchar el progreso: ${e.message}');
    }
  }
}