import '../../domain/entities/insignia.dart';
import '../../domain/repositories/insignia_repository.dart';
import '../datasources/insignias_remote_data_source.dart';
class InsigniaRepositoryImpl implements InsigniaRepository {
  final InsigniasRemoteDataSource remoteDataSource;

  InsigniaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Insignia>> getAllInsignias() async {
    return await remoteDataSource.getAllInsignias();
  }

  @override
  Future<List<Insignia>> getUserInsignias(String userId) async {
    return await remoteDataSource.getUserInsignias(userId);
  }

  @override
  Future<List<Insignia>> getAllInsigniasWithUserStatus(String userId) async {
    return await remoteDataSource.getAllInsigniasWithUserStatus(userId);
  }
}