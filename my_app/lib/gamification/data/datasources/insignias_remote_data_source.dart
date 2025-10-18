import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/insignia_model.dart';

abstract class InsigniasRemoteDataSource {
  Future<List<InsigniaModel>> getAllInsignias();
  Future<List<InsigniaModel>> getUserInsignias(String userId);
  // Nuevo método que combina ambos
  Future<List<InsigniaModel>> getAllInsigniasWithUserStatus(String userId);
}

class InsigniasRemoteDataSourceImpl implements InsigniasRemoteDataSource {
  final FirebaseFirestore firestore;

  InsigniasRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<InsigniaModel>> getAllInsignias() async {
    try {
      final querySnapshot = await firestore.collection('insignias').get();

      return querySnapshot.docs
          .map((doc) => InsigniaModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener todas las insignias: $e');
    }
  }

  @override
  Future<List<InsigniaModel>> getUserInsignias(String userId) async {
    try {
      final gamificacionDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('gamificacion')
          .doc('data')
          .get();

      final insigniasIds = List<String>.from(
        gamificacionDoc.data()?['insignias_usuario'] ?? [],
      );

      if (insigniasIds.isEmpty) {
        return [];
      }

      final List<InsigniaModel> insignias = [];
      
      for (final id in insigniasIds) {
        final insigniaDoc = await firestore.collection('insignias').doc(id).get();
        if (insigniaDoc.exists) {
          insignias.add(InsigniaModel.fromFirestore(insigniaDoc).copyWith(
            desbloqueada: true,
          ) as InsigniaModel);
        }
      }

      return insignias;
    } catch (e) {
      throw Exception('Error al obtener insignias del usuario: $e');
    }
  }

  @override
  Future<List<InsigniaModel>> getAllInsigniasWithUserStatus(String userId) async {
    try {
      // 1. Obtener todas las insignias disponibles
      final todasInsignias = await getAllInsignias();
      
      // 2. Obtener los IDs de las insignias del usuario
      final gamificacionDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('gamificacion')
          .doc('data')
          .get();

      final insigniasIdsUsuario = Set<String>.from(
        gamificacionDoc.data()?['insignias_usuario'] ?? [],
      );

      // 3. Marcar como desbloqueadas las que el usuario tiene
      return todasInsignias.map((insignia) {
        final estaDesbloqueada = insigniasIdsUsuario.contains(insignia.id);
        return insignia.copyWith(desbloqueada: estaDesbloqueada) as InsigniaModel;
      }).toList();
      
    } catch (e) {
      throw Exception('Error al obtener insignias con estado del usuario: $e');
    }
  }
}