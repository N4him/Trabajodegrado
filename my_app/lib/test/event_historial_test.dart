import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/gamification/domain/repositories/gamificacion_repository.dart';
import 'package:my_app/gamification/domain/usecases/add_event_to_historial.dart';

// Importa tus archivos reales
// import 'package:tu_app/domain/usecases/add_event_to_historial.dart';
// import 'package:tu_app/domain/repositories/gamificacion_repository.dart';

// Mock del repository
class MockGamificacionRepository extends Mock implements GamificacionRepository {}

void main() {
  late MockGamificacionRepository mockRepository;
  late AddEventToHistorial useCase;

  setUp(() {
    mockRepository = MockGamificacionRepository();
    useCase = AddEventToHistorial(repository: mockRepository);
  });

  group('AddEventToHistorial', () {
    const userId = 'test_user_123';

    test('debe convertir la fecha correctamente a formato yyyymmdd y llamar al repository', () async {
      // Arrange
      final fecha = DateTime(2024, 3, 15);
      const eventoEsperado = 20240315;
      
      when(() => mockRepository.addEventToHistorial(any(), any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(userId: userId, fecha: fecha);

      // Assert
      verify(() => mockRepository.addEventToHistorial(userId, eventoEsperado)).called(1);
    });

    test('debe formatear correctamente fechas con mes y día de un solo dígito', () async {
      // Arrange
      final fecha = DateTime(2024, 1, 5); // Enero 5
      const eventoEsperado = 20240105;
      
      when(() => mockRepository.addEventToHistorial(any(), any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(userId: userId, fecha: fecha);

      // Assert
      verify(() => mockRepository.addEventToHistorial(userId, eventoEsperado)).called(1);
    });

    test('debe manejar correctamente el último día del año', () async {
      // Arrange
      final fecha = DateTime(2024, 12, 31);
      const eventoEsperado = 20241231;
      
      when(() => mockRepository.addEventToHistorial(any(), any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(userId: userId, fecha: fecha);

      // Assert
      verify(() => mockRepository.addEventToHistorial(userId, eventoEsperado)).called(1);
    });

    test('debe manejar correctamente el primer día del año', () async {
      // Arrange
      final fecha = DateTime(2024, 1, 1);
      const eventoEsperado = 20240101;
      
      when(() => mockRepository.addEventToHistorial(any(), any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(userId: userId, fecha: fecha);

      // Assert
      verify(() => mockRepository.addEventToHistorial(userId, eventoEsperado)).called(1);
    });

    test('debe propagar excepciones del repository', () async {
      // Arrange
      final fecha = DateTime(2024, 3, 15);
      final exception = Exception('Error al guardar evento');
      
      when(() => mockRepository.addEventToHistorial(any(), any()))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase.call(userId: userId, fecha: fecha),
        throwsA(isA<Exception>()),
      );
      
      verify(() => mockRepository.addEventToHistorial(userId, 20240315)).called(1);
    });

    test('debe pasar el userId correcto al repository', () async {
      // Arrange
      const otroUserId = 'otro_user_456';
      final fecha = DateTime(2024, 6, 20);
      
      when(() => mockRepository.addEventToHistorial(any(), any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(userId: otroUserId, fecha: fecha);

      // Assert
      verify(() => mockRepository.addEventToHistorial(otroUserId, 20240620)).called(1);
    });

    test('debe manejar fechas de años diferentes', () async {
      // Arrange
      final fecha = DateTime(2025, 7, 8);
      const eventoEsperado = 20250708;
      
      when(() => mockRepository.addEventToHistorial(any(), any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(userId: userId, fecha: fecha);

      // Assert
      verify(() => mockRepository.addEventToHistorial(userId, eventoEsperado)).called(1);
    });
  });
}