import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/forum/domain/usescases/create_forum_post.dart';
import 'package:my_app/forum/domain/usescases/delete_forum_post.dart';
import 'package:my_app/forum/domain/usescases/get_forum_posts.dart';
import 'package:my_app/forum/domain/usescases/get_user_forum_posts.dart';
import 'package:my_app/forum/domain/usescases/like_forum_post.dart';
import 'package:my_app/forum/domain/usescases/reply_forum_post.dart';
import 'package:my_app/forum/domain/usescases/search_forum_posts.dart';

// ==============================================
// LIBRARY
// ==============================================
import 'package:my_app/library/data/datasources/library_remote_datasource.dart';
import 'package:my_app/library/data/datasources/library_remote_datasource_impl.dart';
import 'package:my_app/library/data/datasources/saved_book_remote_datasource.dart';
import 'package:my_app/library/data/datasources/saved_book_repository_impl.dart';
import 'package:my_app/library/data/repositories/library_repository_impl.dart';
import 'package:my_app/library/domain/repositories/library_repository.dart';
import 'package:my_app/library/domain/repositories/saved_book_entity.dart';
import 'package:my_app/library/domain/usescases/check_book_saved_usecase.dart';
import 'package:my_app/library/domain/usescases/delete_saved_book_usecase.dart';
import 'package:my_app/library/domain/usescases/get_book_by_id.dart';
import 'package:my_app/library/domain/usescases/get_books.dart';
import 'package:my_app/library/domain/usescases/get_books_by_category.dart';
import 'package:my_app/library/domain/usescases/get_user_saved_books_usecase.dart';
import 'package:my_app/library/domain/usescases/save_book_usecase.dart';
import 'package:my_app/library/domain/usescases/search_books.dart';
import 'package:my_app/library/presentation/blocs/library_bloc.dart';

// ==============================================
// SAVED BOOKS (Libros Guardados)
// ==============================================
import 'package:my_app/library/presentation/blocs/saved_book_bloc.dart';

// ==============================================
// LOGIN
// ==============================================
import '../../login/data/datasources/login_remote_datasource.dart';
import '../../login/data/repositories/login_repository_impl.dart';
import '../../login/domain/repositories/login_repository.dart';
import '../../login/domain/usecases/login_user.dart';
import '../../login/presentation/blocs/login_bloc.dart';

// ==============================================
// REGISTER
// ==============================================
import '../../register/data/datasources/register_remote_datasource.dart';
import '../../register/data/repositories/register_repository_impl.dart';
import '../../register/domain/repositories/register_repository.dart';
import '../../register/domain/usecases/register_user.dart';
import '../../register/presentation/blocs/register_bloc.dart';

// ==============================================
// PROFILE
// ==============================================
import '../../profile/data/repositories/profile_repository_impl.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../../profile/presentation/bloc/profile_bloc.dart';

// ==============================================
// FORUM
// ==============================================
import 'package:my_app/forum/data/datasources/forum_remote_data_source.dart';
import 'package:my_app/forum/data/repositories/forum_repository_impl.dart';
import 'package:my_app/forum/domain/repositories/forum_repository.dart';
import 'package:my_app/forum/presentation/bloc/forum_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // ==============================================
  // FIREBASE INSTANCES
  // ==============================================
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ==============================================
  // DATA SOURCES
  // ==============================================
  getIt.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(firebaseAuth: getIt()),
  );

  getIt.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(firestore: getIt()),
  );

  getIt.registerLazySingleton<RegisterRemoteDataSource>(
    () => RegisterRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      firestore: getIt(),
    ),
  );

  getIt.registerLazySingleton<ForumRemoteDataSource>(
    () => ForumRemoteDataSourceImpl(firestore: getIt()),
  );

  // Saved Books DataSource
  getIt.registerLazySingleton<SavedBookRemoteDataSource>(
    () => SavedBookRemoteDataSourceImpl(getIt()),
  );

  // ==============================================
  // REPOSITORIES
  // ==============================================
  getIt.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(remoteDataSource: getIt()),
  );
  
  getIt.registerLazySingleton<RegisterRepository>(
    () => RegisterRepositoryImpl(remoteDataSource: getIt()),
  );
  
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<ForumRepository>(
    () => ForumRepositoryImpl(remoteDataSource: getIt()),
  );

  // Saved Books Repository
  getIt.registerLazySingleton<SavedBookRepository>(
    () => SavedBookRepositoryImpl(getIt()),
  );

  // ==============================================
  // USE CASES
  // ==============================================
  getIt.registerLazySingleton<LoginUser>(
    () => LoginUser(getIt()),
  );
  
  getIt.registerLazySingleton<RegisterUser>(
    () => RegisterUser(getIt()),
  );

  // Library Use Cases
  getIt.registerLazySingleton<GetBooks>(
    () => GetBooks(getIt()),
  );

  getIt.registerLazySingleton<GetBookById>(
    () => GetBookById(getIt()),
  );

  getIt.registerLazySingleton<GetBooksByCategory>(
    () => GetBooksByCategory(getIt()),
  );

  getIt.registerLazySingleton<SearchBooks>(
    () => SearchBooks(getIt()),
  );

  // Saved Books Use Cases
  getIt.registerLazySingleton<SaveBookUseCase>(
    () => SaveBookUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetUserSavedBooksUseCase>(
    () => GetUserSavedBooksUseCase(getIt()),
  );

  getIt.registerLazySingleton<DeleteSavedBookUseCase>(
    () => DeleteSavedBookUseCase(getIt()),
  );

  getIt.registerLazySingleton<CheckBookSavedUseCase>(
    () => CheckBookSavedUseCase(getIt()),
  );

  // Forum Use Cases
  getIt.registerLazySingleton<GetForumPosts>(
    () => GetForumPosts(getIt()),
  );
  getIt.registerLazySingleton<CreateForumPost>(
    () => CreateForumPost(getIt()),
  );
  getIt.registerLazySingleton<LikeForumPost>(
    () => LikeForumPost(getIt()),
  );
  getIt.registerLazySingleton<ReplyForumPost>(
    () => ReplyForumPost(getIt()),
  );
  getIt.registerLazySingleton<DeleteForumPost>(
    () => DeleteForumPost(getIt()),
  );
  getIt.registerLazySingleton<SearchForumPosts>(
    () => SearchForumPosts(getIt()),
  );
  getIt.registerLazySingleton<GetUserForumPosts>(
    () => GetUserForumPosts(getIt()),
  );

  // ==============================================
  // BLOCS - FACTORY REGISTRATION
  // ==============================================
  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(loginUser: getIt()),
  );
  
  getIt.registerFactory<RegisterBloc>(
    () => RegisterBloc(registerUser: getIt()),
  );
  
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(profileRepository: getIt()),
  );

  getIt.registerFactory<LibraryBloc>(
    () => LibraryBloc(
      getBooks: getIt<GetBooks>(),
      getBooksByCategory: getIt<GetBooksByCategory>(),
      searchBooks: getIt<SearchBooks>(),
    ),
  );

  // Saved Books BLoC
  getIt.registerFactory<SavedBookBloc>(
    () => SavedBookBloc(
      saveBookUseCase: getIt<SaveBookUseCase>(),
      getUserSavedBooksUseCase: getIt<GetUserSavedBooksUseCase>(),
      deleteSavedBookUseCase: getIt<DeleteSavedBookUseCase>(),
      checkBookSavedUseCase: getIt<CheckBookSavedUseCase>(),
      repository: getIt<SavedBookRepository>(),
    ),
  );

  getIt.registerFactory<ForumBloc>(
    () => ForumBloc(
      getForumPostsUseCase: getIt<GetForumPosts>(),
      createForumPostUseCase: getIt<CreateForumPost>(),
      likeForumPostUseCase: getIt<LikeForumPost>(),
      replyForumPostUseCase: getIt<ReplyForumPost>(),
      deleteForumPostUseCase: getIt<DeleteForumPost>(),
      searchForumPostsUseCase: getIt<SearchForumPosts>(),
      getUserForumPostsUseCase: getIt<GetUserForumPosts>(),
    ),
  );
}

// ==============================================
// HELPER FUNCTIONS PARA OBTENER BLOCS
// ==============================================
LoginBloc getLoginBloc() => getIt<LoginBloc>();
RegisterBloc getRegisterBloc() => getIt<RegisterBloc>();
ProfileBloc getProfileBloc() => getIt<ProfileBloc>();
LibraryBloc getLibraryBloc() => getIt<LibraryBloc>();
SavedBookBloc getSavedBookBloc() => getIt<SavedBookBloc>();
ForumBloc getForumBloc() => getIt<ForumBloc>();

// ==============================================
// FUNCIÓN PARA LIMPIAR DEPENDENCIAS (OPCIONAL)
// ==============================================
Future<void> resetDI() async {
  await getIt.reset();
}