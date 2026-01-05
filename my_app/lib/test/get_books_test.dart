import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import 'package:my_app/core/usescases/usecase.dart';
import 'package:my_app/library/domain/entities/book_entity.dart';
import 'package:my_app/library/domain/repositories/library_repository.dart';
import 'package:my_app/library/domain/usescases/get_books.dart';

// Importa tus archivos reales
// import 'package:my_app/domain/usecases/get_books.dart';
// import 'package:my_app/domain/repositories/library_repository.dart';
// import 'package:my_app/domain/entities/book_entity.dart';
// import 'package:my_app/core/failures/failures.dart';
// import 'package:my_app/core/usescases/usecase.dart';

// Mocks
class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late MockLibraryRepository mockRepository;
  late GetBooks useCase;

  setUp(() {
    mockRepository = MockLibraryRepository();
    useCase = GetBooks(mockRepository);
  });

  group('GetBooks', () {
    // Datos de prueba
    final tBooksList = [
      BookEntity(
        id: '1',
        title: 'Clean Code',
        author: 'Robert C. Martin',
        coverUrl: 'https://example.com/cover1.jpg',
        description: 'A Handbook of Agile Software Craftsmanship',
        category: 'Programming',
        publicationDate: DateTime(2008, 8, 1),
        pages: 464,
        pdfUrl: 'https://example.com/cleancode.pdf',
        available: true,
      ),
      BookEntity(
        id: '2',
        title: 'The Pragmatic Programmer',
        author: 'Andrew Hunt',
        coverUrl: 'https://example.com/cover2.jpg',
        description: 'Your Journey to Mastery',
        category: 'Programming',
        publicationDate: DateTime(1999, 10, 20),
        pages: 352,
        pdfUrl: 'https://example.com/pragmatic.pdf',
        available: true,
      ),
      BookEntity(
        id: '3',
        title: 'Design Patterns',
        author: 'Gang of Four',
        coverUrl: 'https://example.com/cover3.jpg',
        description: 'Elements of Reusable Object-Oriented Software',
        category: 'Software Engineering',
        publicationDate: DateTime(1994, 10, 21),
        pages: 395,
        pdfUrl: 'https://example.com/patterns.pdf',
        available: false,
      ),
    ];

    test('debe retornar una lista de libros cuando el repository responde exitosamente', () async {
      // Arrange
      when(() => mockRepository.getBooks())
          .thenAnswer((_) async => Right(tBooksList));

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result, equals(Right(tBooksList)));
      verify(() => mockRepository.getBooks()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('debe retornar una lista vacía cuando no hay libros', () async {
      // Arrange
      final emptyList = <BookEntity>[];
      when(() => mockRepository.getBooks())
          .thenAnswer((_) async => Right(emptyList));

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result, equals(Right(emptyList)));
      result.fold(
        (failure) => fail('Se esperaba Right pero se obtuvo Left'),
        (books) => expect(books.isEmpty, true),
      );
      verify(() => mockRepository.getBooks()).called(1);
    });

    test('debe retornar ServerFailure cuando hay un error del servidor', () async {
      // Arrange
      final tServerFailure = ServerFailure('Error del servidor');
      when(() => mockRepository.getBooks())
          .thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result, equals(Left(tServerFailure)));
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (books) => fail('Se esperaba Left pero se obtuvo Right'),
      );
      verify(() => mockRepository.getBooks()).called(1);
    });

    test('debe retornar CacheFailure cuando hay un error de caché', () async {
      // Arrange
      final tCacheFailure = CacheFailure('Error al leer el caché');
      when(() => mockRepository.getBooks())
          .thenAnswer((_) async => Left(tCacheFailure));

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result, equals(Left(tCacheFailure)));
      verify(() => mockRepository.getBooks()).called(1);
    });

    test('debe llamar al repository solo una vez por invocación', () async {
      // Arrange
      when(() => mockRepository.getBooks())
          .thenAnswer((_) async => Right(tBooksList));

      // Act
      await useCase.call(NoParams());
      await useCase.call(NoParams());
      await useCase.call(NoParams());

      // Assert
      verify(() => mockRepository.getBooks()).called(3);
    });

    test('debe manejar correctamente múltiples llamadas consecutivas', () async {
      // Arrange
      when(() => mockRepository.getBooks())
          .thenAnswer((_) async => Right(tBooksList));

      // Act
      final result1 = await useCase.call(NoParams());
      final result2 = await useCase.call(NoParams());

      // Assert
      expect(result1, equals(result2));
      verify(() => mockRepository.getBooks()).called(2);
    });

    test('debe preservar el orden de los libros retornados por el repository', () async {
      // Arrange
      when(() => mockRepository.getBooks())
          .thenAnswer((_) async => Right(tBooksList));

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Se esperaba Right pero se obtuvo Left'),
        (books) {
          expect(books.length, equals(3));
          expect(books[0].id, equals('1'));
          expect(books[1].id, equals('2'));
          expect(books[2].id, equals('3'));
        },
      );
    });
  });
}