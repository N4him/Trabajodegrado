import '../entities/insignia.dart';

abstract class InsigniaRepository {
  Future<List<Insignia>> getAllInsignias();
  Future<List<Insignia>> getUserInsignias(String userId);
  Future<List<Insignia>> getAllInsigniasWithUserStatus(String userId);
}