import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/forum/domain/repositories/forum_repository.dart';
import 'package:my_app/forum/domain/usescases/create_forum_post.dart';

// Importa tus archivos reales
// import 'package:tu_app/forum/domain/repositories/forum_repository.dart';
// import 'package:tu_app/forum/domain/usecases/create_forum_post.dart';

// Mock del repositorio
class MockForumRepository extends Mock implements ForumRepository {}

void main() {
  late CreateForumPost usecase;
  late MockForumRepository mockRepository;

  setUp(() {
    mockRepository = MockForumRepository();
    usecase = CreateForumPost(mockRepository);
  });

  group('CreateForumPost', () {
    const tTitle = 'Mi primer post';
    const tContent = 'Este es el contenido del post';
    const tAuthorId = 'user123';
    const tAuthorName = 'Juan Pérez';
    const tAuthorPhotoUrl = 'https://example.com/photo.jpg';
    const tCategory = 'General';
    const tCategoryColor = '#FF5733';
    const tPostId = 'post123';

    test('debe crear un post exitosamente cuando los datos son válidos', () async {
      // Arrange
      when(() => mockRepository.createForumPost(
            title: any(named: 'title'),
            content: any(named: 'content'),
            authorId: any(named: 'authorId'),
            authorName: any(named: 'authorName'),
            authorPhotoUrl: any(named: 'authorPhotoUrl'),
            category: any(named: 'category'),
            categoryColor: any(named: 'categoryColor'),
          )).thenAnswer((_) async => Right(tPostId));

      // Act
      final result = await usecase(
        title: tTitle,
        content: tContent,
        authorId: tAuthorId,
        authorName: tAuthorName,
        authorPhotoUrl: tAuthorPhotoUrl,
        category: tCategory,
        categoryColor: tCategoryColor,
      );

      // Assert
      expect(result, equals(Right(tPostId)));
      verify(() => mockRepository.createForumPost(
            title: tTitle,
            content: tContent,
            authorId: tAuthorId,
            authorName: tAuthorName,
            authorPhotoUrl: tAuthorPhotoUrl,
            category: tCategory,
            categoryColor: tCategoryColor,
          )).called(1);
    });

    test('debe retornar excepción cuando el repositorio falla', () async {
      // Arrange
      final exception = Exception('Error de red');
      when(() => mockRepository.createForumPost(
            title: any(named: 'title'),
            content: any(named: 'content'),
            authorId: any(named: 'authorId'),
            authorName: any(named: 'authorName'),
            authorPhotoUrl: any(named: 'authorPhotoUrl'),
            category: any(named: 'category'),
            categoryColor: any(named: 'categoryColor'),
          )).thenAnswer((_) async => Left(exception));

      // Act
      final result = await usecase(
        title: tTitle,
        content: tContent,
        authorId: tAuthorId,
        authorName: tAuthorName,
        category: tCategory,
        categoryColor: tCategoryColor,
      );

      // Assert
      expect(result, equals(Left(exception)));
      verify(() => mockRepository.createForumPost(
            title: tTitle,
            content: tContent,
            authorId: tAuthorId,
            authorName: tAuthorName,
            authorPhotoUrl: null,
            category: tCategory,
            categoryColor: tCategoryColor,
          )).called(1);
    });

    test('debe funcionar sin authorPhotoUrl (campo opcional)', () async {
      // Arrange
      when(() => mockRepository.createForumPost(
            title: any(named: 'title'),
            content: any(named: 'content'),
            authorId: any(named: 'authorId'),
            authorName: any(named: 'authorName'),
            authorPhotoUrl: any(named: 'authorPhotoUrl'),
            category: any(named: 'category'),
            categoryColor: any(named: 'categoryColor'),
          )).thenAnswer((_) async => Right(tPostId));

      // Act
      final result = await usecase(
        title: tTitle,
        content: tContent,
        authorId: tAuthorId,
        authorName: tAuthorName,
        category: tCategory,
        categoryColor: tCategoryColor,
      );

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.createForumPost(
            title: tTitle,
            content: tContent,
            authorId: tAuthorId,
            authorName: tAuthorName,
            authorPhotoUrl: null,
            category: tCategory,
            categoryColor: tCategoryColor,
          )).called(1);
    });
  });
}