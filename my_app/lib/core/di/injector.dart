import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/forum/domain/usescases/create_forum_post.dart';
import 'package:my_app/forum/domain/usescases/delete_forum_post.dart';
import 'package:my_app/forum/domain/usescases/get_forum_by_category.dart';
import 'package:my_app/forum/domain/usescases/get_forum_popular.dart';
import 'package:my_app/forum/domain/usescases/get_forum_posts.dart';
import 'package:my_app/forum/domain/usescases/get_user_forum_posts.dart';
import 'package:my_app/forum/domain/usescases/like_forum_post.dart';
import 'package:my_app/forum/domain/usescases/reply_forum_post.dart';
import 'package:my_app/forum/domain/usescases/search_forum_posts.dart';
import 'package:my_app/gamification/data/repositories/insignia_repository_impl.dart';

// ==============================================
// LIBRARY
// ==============================================
import 'package:my_app/library/data/datasources/library_remote_datasource.dart';
import 'package:my_app/library/data/datasources/library_remote_datasource_impl.dart';
import 'package:my_app/library/data/datasources/reading_progress_remote_datasource_impl.dart';
import 'package:my_app/library/data/datasources/saved_book_remote_datasource.dart';
import 'package:my_app/library/data/datasources/saved_book_repository_impl.dart';
import 'package:my_app/library/data/repositories/library_repository_impl.dart';
import 'package:my_app/library/domain/repositories/library_repository.dart';
import 'package:my_app/library/domain/repositories/saved_book_repository.dart';
import 'package:my_app/library/domain/usescases/check_book_saved_usecase.dart';
import 'package:my_app/library/domain/usescases/delete_progress_usecase.dart';
import 'package:my_app/library/domain/usescases/delete_saved_book_usecase.dart';
import 'package:my_app/library/domain/usescases/get_book_by_id.dart';
import 'package:my_app/library/domain/usescases/get_book_inprogress.dart';
import 'package:my_app/library/domain/usescases/get_books.dart';
import 'package:my_app/library/domain/usescases/get_books_by_category.dart';
import 'package:my_app/library/domain/usescases/get_progress_books_completed_usecase.dart';
import 'package:my_app/library/domain/usescases/get_user_saved_books_usecase.dart';
import 'package:my_app/library/domain/usescases/save_book_usecase.dart';
import 'package:my_app/library/domain/usescases/search_books.dart';
import 'package:my_app/library/presentation/blocs/library_bloc.dart';

// ==============================================
// SAVED BOOKS (Libros Guardados)
// ==============================================
import 'package:my_app/library/presentation/blocs/saved_book_bloc.dart';

// ==============================================
// READING PROGRESS (Progreso de Lectura) ⭐ NUEVO
// ==============================================
import 'package:my_app/library/data/datasources/reading_progress_remote_datasource.dart';
import 'package:my_app/library/domain/repositories/reading_progress_repository.dart';
import 'package:my_app/library/domain/usescases/save_reading_progress_usecase.dart';
import 'package:my_app/library/domain/usescases/get_reading_progress_usecase.dart';

import 'package:my_app/library/domain/usescases/watch_reading_progress_usecase.dart';

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

// ==============================================
// GAMIFICACIÓN
// ==============================================
import 'package:my_app/gamification/data/datasources/gamificacion_remote_data_source.dart';
import 'package:my_app/gamification/data/datasources/insignias_remote_data_source.dart';
import 'package:my_app/gamification/data/repositories/gamificacion_repository_impl.dart';
import 'package:my_app/gamification/domain/repositories/gamificacion_repository.dart';
import 'package:my_app/gamification/domain/repositories/insignia_repository.dart';
import 'package:my_app/gamification/domain/usecases/get_gamificacion_data.dart';
import 'package:my_app/gamification/domain/usecases/update_modulo_progress.dart';
import 'package:my_app/gamification/domain/usecases/add_event_to_historial.dart';
import 'package:my_app/gamification/domain/usecases/check_and_unlock_insignias.dart';
import 'package:my_app/gamification/domain/usecases/get_user_insignias.dart';
import 'package:my_app/gamification/presentation/bloc/gamificacion_bloc.dart';

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
    () => LoginRemoteDataSourceImpl(firebaseAuth: getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<RegisterRemoteDataSource>(
    () => RegisterRemoteDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<ForumRemoteDataSource>(
    () => ForumRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  // Saved Books DataSource
  getIt.registerLazySingleton<SavedBookRemoteDataSource>(
    () => SavedBookRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  // Reading Progress DataSource ⭐ NUEVO
  getIt.registerLazySingleton<ReadingProgressRemoteDataSource>(
    () => ReadingProgressRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  // Gamificación DataSources
  getIt.registerLazySingleton<GamificacionRemoteDataSource>(
    () => GamificacionRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<InsigniasRemoteDataSource>(
    () => InsigniasRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  // ==============================================
  // REPOSITORIES
  // ==============================================
  getIt.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(remoteDataSource: getIt<LoginRemoteDataSource>()),
  );

  getIt.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(remoteDataSource: getIt<LibraryRemoteDataSource>()),
  );
  
  getIt.registerLazySingleton<RegisterRepository>(
    () => RegisterRepositoryImpl(remoteDataSource: getIt<RegisterRemoteDataSource>()),
  );
  
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<ForumRepository>(
    () => ForumRepositoryImpl(remoteDataSource: getIt<ForumRemoteDataSource>()),
  );

  // Saved Books Repository
  getIt.registerLazySingleton<SavedBookRepository>(
    () => SavedBookRepositoryImpl(getIt<SavedBookRemoteDataSource>()),
  );

  // Reading Progress Repository ⭐ NUEVO
  getIt.registerLazySingleton<ReadingProgressRepository>(
    () => ReadingProgressRepositoryImpl(remoteDataSource: getIt<ReadingProgressRemoteDataSource>()),
  );

  // Gamificación Repositories
  getIt.registerLazySingleton<GamificacionRepository>(
    () => GamificacionRepositoryImpl(
      remoteDataSource: getIt<GamificacionRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<InsigniaRepository>(
    () => InsigniaRepositoryImpl(remoteDataSource: getIt<InsigniasRemoteDataSource>()),
  );

  // ==============================================
  // USE CASES
  // ==============================================
  getIt.registerLazySingleton<LoginUser>(
    () => LoginUser(getIt<LoginRepository>()),
  );
  
  getIt.registerLazySingleton<RegisterUser>(
    () => RegisterUser(getIt<RegisterRepository>()),
  );

  // Library Use Cases
  getIt.registerLazySingleton<GetBooks>(
    () => GetBooks(getIt<LibraryRepository>()),
  );

  getIt.registerLazySingleton<GetBookById>(
    () => GetBookById(getIt<LibraryRepository>()),
  );

  getIt.registerLazySingleton<GetBooksByCategory>(
    () => GetBooksByCategory(getIt<LibraryRepository>()),
  );

  getIt.registerLazySingleton<SearchBooks>(
    () => SearchBooks(getIt<LibraryRepository>()),
  );

  // Saved Books Use Cases
  getIt.registerLazySingleton<SaveBookUseCase>(
    () => SaveBookUseCase(getIt<SavedBookRepository>()),
  );

  getIt.registerLazySingleton<GetUserSavedBooksUseCase>(
    () => GetUserSavedBooksUseCase(getIt<SavedBookRepository>()),
  );

  getIt.registerLazySingleton<DeleteSavedBookUseCase>(
    () => DeleteSavedBookUseCase(getIt<SavedBookRepository>()),
  );

  getIt.registerLazySingleton<CheckBookSavedUseCase>(
    () => CheckBookSavedUseCase(getIt<SavedBookRepository>()),
  );

  // Reading Progress Use Cases ⭐ NUEVO
  getIt.registerLazySingleton<SaveReadingProgressUseCase>(
    () => SaveReadingProgressUseCase(getIt<ReadingProgressRepository>()),
  );

  getIt.registerLazySingleton<GetReadingProgressUseCase>(
    () => GetReadingProgressUseCase(getIt<ReadingProgressRepository>()),
  );

  getIt.registerLazySingleton<GetBooksInProgressUseCase>(
    () => GetBooksInProgressUseCase(getIt<ReadingProgressRepository>()),
  );

  getIt.registerLazySingleton<GetCompletedBooksUseCase>(
    () => GetCompletedBooksUseCase(getIt<ReadingProgressRepository>()),
  );

  getIt.registerLazySingleton<DeleteReadingProgressUseCase>(
    () => DeleteReadingProgressUseCase(getIt<ReadingProgressRepository>()),
  );

  getIt.registerLazySingleton<WatchReadingProgressUseCase>(
    () => WatchReadingProgressUseCase(getIt<ReadingProgressRepository>()),
  );
  
  // Forum Use Cases
  getIt.registerLazySingleton<GetForumPosts>(
    () => GetForumPosts(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<CreateForumPost>(
    () => CreateForumPost(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<LikeForumPost>(
    () => LikeForumPost(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<ReplyForumPost>(
    () => ReplyForumPost(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<DeleteForumPost>(
    () => DeleteForumPost(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<SearchForumPosts>(
    () => SearchForumPosts(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<GetUserForumPosts>(
    () => GetUserForumPosts(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<GetForumPostsByCategory>(
    () => GetForumPostsByCategory(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<GetPopularForumPosts>(
    () => GetPopularForumPosts(getIt<ForumRepository>()),
  );

  // Gamificación Use Cases
  getIt.registerLazySingleton<GetGamificacionData>(
    () => GetGamificacionData(repository: getIt<GamificacionRepository>()),
  );

  getIt.registerLazySingleton<UpdateModuloProgress>(
    () => UpdateModuloProgress(repository: getIt<GamificacionRepository>()),
  );

  getIt.registerLazySingleton<AddEventToHistorial>(
    () => AddEventToHistorial(repository: getIt<GamificacionRepository>()),
  );

  getIt.registerLazySingleton<CheckAndUnlockInsignias>(
    () => CheckAndUnlockInsignias(
      insigniaRepository: getIt<InsigniaRepository>(),
      gamificacionRepository: getIt<GamificacionRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetUserInsignias>(
    () => GetUserInsignias(repository: getIt<InsigniaRepository>()),
  );

  // ==============================================
  // BLOCS - FACTORY REGISTRATION
  // ==============================================
  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(loginUser: getIt<LoginUser>()),
  );
  
  getIt.registerFactory<RegisterBloc>(
    () => RegisterBloc(registerUser: getIt<RegisterUser>()),
  );
  
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(profileRepository: getIt<ProfileRepository>()),
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
      getForumPostsByCategoryUseCase: getIt<GetForumPostsByCategory>(),
      getPopularForumPostsUseCase: getIt<GetPopularForumPosts>(),
    ),
  );

  // Gamificación BLoC
  getIt.registerFactory<GamificacionBloc>(
    () => GamificacionBloc(
      getGamificacionData: getIt<GetGamificacionData>(),
      updateModuloProgress: getIt<UpdateModuloProgress>(),
      addEventToHistorial: getIt<AddEventToHistorial>(),
      checkAndUnlockInsignias: getIt<CheckAndUnlockInsignias>(),
      getUserInsignias: getIt<GetUserInsignias>(),
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
GamificacionBloc getGamificacionBloc() => getIt<GamificacionBloc>();

// ==============================================
// FUNCIÓN PARA LIMPIAR DEPENDENCIAS (OPCIONAL)
// ==============================================
Future<void> resetDI() async {
  await getIt.reset();
}