import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/library/login/domain/entities/user_entity.dart';
import 'package:my_app/library/login/domain/repositories/login_repository.dart';
import 'package:my_app/library/login/domain/usecases/login_user.dart';

// Importa tus archivos reales
// import 'package:my_app/features/login/domain/usecases/login_user.dart';
// import 'package:my_app/features/login/domain/repositories/login_repository.dart';
// import 'package:my_app/features/login/domain/entities/user_entity.dart';

// Mocks
class MockLoginRepository extends Mock implements LoginRepository {}

void main() {
  late MockLoginRepository mockRepository;
  late LoginUser useCase;

  setUp(() {
    mockRepository = MockLoginRepository();
    useCase = LoginUser(mockRepository);
  });

  group('LoginUser', () {
    // Datos de prueba
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    
    final tUserEntity = UserEntity(
      uid: '123',
      email: tEmail,
    );

    test('debe retornar UserEntity cuando las credenciales son correctas', () async {
      // Arrange
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => tUserEntity);

      // Act
      final result = await useCase.call(email: tEmail, password: tPassword);

      // Assert
      expect(result, equals(tUserEntity));
      expect(result?.uid, equals('123'));
      expect(result?.email, equals(tEmail));
      verify(() => mockRepository.login(email: tEmail, password: tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('debe retornar null cuando las credenciales son incorrectas', () async {
      // Arrange
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.call(email: tEmail, password: tPassword);

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.login(email: tEmail, password: tPassword)).called(1);
    });

    test('debe pasar el email correcto al repository', () async {
      // Arrange
      const differentEmail = 'other@example.com';
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => tUserEntity);

      // Act
      await useCase.call(email: differentEmail, password: tPassword);

      // Assert
      verify(() => mockRepository.login(email: differentEmail, password: tPassword)).called(1);
    });

    test('debe pasar el password correcto al repository', () async {
      // Arrange
      const differentPassword = 'newPassword456';
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => tUserEntity);

      // Act
      await useCase.call(email: tEmail, password: differentPassword);

      // Assert
      verify(() => mockRepository.login(email: tEmail, password: differentPassword)).called(1);
    });

    test('debe manejar email vacío', () async {
      // Arrange
      const emptyEmail = '';
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.call(email: emptyEmail, password: tPassword);

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.login(email: emptyEmail, password: tPassword)).called(1);
    });

    test('debe manejar password vacío', () async {
      // Arrange
      const emptyPassword = '';
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.call(email: tEmail, password: emptyPassword);

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.login(email: tEmail, password: emptyPassword)).called(1);
    });

    test('debe propagar excepciones del repository', () async {
      // Arrange
      final exception = Exception('Error de conexión');
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase.call(email: tEmail, password: tPassword),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.login(email: tEmail, password: tPassword)).called(1);
    });

    test('debe manejar múltiples intentos de login', () async {
      // Arrange
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => tUserEntity);

      // Act
      final result1 = await useCase.call(email: tEmail, password: tPassword);
      final result2 = await useCase.call(email: tEmail, password: tPassword);
      final result3 = await useCase.call(email: tEmail, password: tPassword);

      // Assert
      expect(result1, equals(tUserEntity));
      expect(result2, equals(tUserEntity));
      expect(result3, equals(tUserEntity));
      verify(() => mockRepository.login(email: tEmail, password: tPassword)).called(3);
    });

    test('debe manejar email con espacios en blanco', () async {
      // Arrange
      const emailWithSpaces = '  test@example.com  ';
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.call(email: emailWithSpaces, password: tPassword);

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.login(email: emailWithSpaces, password: tPassword)).called(1);
    });

    test('debe manejar diferentes formatos de email', () async {
      // Arrange
      const emails = [
        'user@domain.com',
        'user.name@domain.co.uk',
        'user+tag@domain.com',
        'user_name@sub.domain.com',
      ];

      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => tUserEntity);

      // Act & Assert
      for (final email in emails) {
        final result = await useCase.call(email: email, password: tPassword);
        expect(result, equals(tUserEntity));
      }

      verify(() => mockRepository.login(email: any(named: 'email'), password: tPassword)).called(emails.length);
    });

    test('debe retornar diferentes usuarios para diferentes credenciales', () async {
      // Arrange
      const email1 = 'user1@example.com';
      const email2 = 'user2@example.com';
      
      final user1 = UserEntity(
        uid: '1',
        email: email1,

      );
      
      final user2 = UserEntity(
        uid: '2',
        email: email2,

      );

      when(() => mockRepository.login(email: email1, password: tPassword))
          .thenAnswer((_) async => user1);
      
      when(() => mockRepository.login(email: email2, password: tPassword))
          .thenAnswer((_) async => user2);

      // Act
      final result1 = await useCase.call(email: email1, password: tPassword);
      final result2 = await useCase.call(email: email2, password: tPassword);

      // Assert
      expect(result1?.uid, equals('1'));
      expect(result2?.uid, equals('2'));
      expect(result1?.email, equals(email1));
      expect(result2?.email, equals(email2));
    });
  });
}