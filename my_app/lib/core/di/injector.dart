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
// HABITS
// ==============================================
import 'package:my_app/habits/data/datasources/habit_remote_datasource.dart';
import 'package:my_app/habits/data/repositories/habit_repository_impl.dart';
import 'package:my_app/habits/domain/repositories/habit_repository.dart';
import 'package:my_app/habits/domain/usecases/create_habit_usecase.dart';
import 'package:my_app/habits/domain/usecases/register_completion_usecase.dart';
import 'package:my_app/habits/domain/usecases/get_habits_by_user_usecase.dart';
import 'package:my_app/habits/domain/usecases/get_habit_progress_usecase.dart';
import 'package:my_app/habits/presentation/blocs/habit_bloc.dart';

// ==============================================
// BODY SCAN (WELLBEING)
// ==============================================
import 'package:my_app/wellbeing/body_scan/data/datasources/body_scan_remote_datasource.dart';
import 'package:my_app/wellbeing/body_scan/data/repositories/body_scan_repository_impl.dart';
import 'package:my_app/wellbeing/body_scan/domain/repositories/body_scan_repository.dart';
import 'package:my_app/wellbeing/body_scan/domain/usecases/save_body_scan_session_usecase.dart';
import 'package:my_app/wellbeing/body_scan/domain/usecases/get_weekly_sessions_usecase.dart';
import 'package:my_app/wellbeing/body_scan/presentation/blocs/body_scan_bloc.dart';

// ==============================================
// WELLBEING POINTS (SHARED)
// ==============================================
import 'package:my_app/wellbeing/shared/data/datasources/wellbeing_points_remote_datasource.dart';
import 'package:my_app/wellbeing/shared/data/repositories/wellbeing_points_repository_impl.dart';
import 'package:my_app/wellbeing/shared/domain/repositories/wellbeing_points_repository.dart';
import 'package:my_app/wellbeing/shared/domain/usecases/get_wellbeing_points_usecase.dart';
import 'package:my_app/wellbeing/shared/domain/usecases/increment_wellbeing_points_usecase.dart';
import 'package:my_app/wellbeing/presentation/blocs/wellbeing_points_bloc.dart';

// ==============================================
// BREATHING GAME (WELLBEING)
// ==============================================
import 'package:my_app/wellbeing/breathing_game/data/datasources/breathing_game_remote_datasource.dart';
import 'package:my_app/wellbeing/breathing_game/data/repositories/breathing_game_repository_impl.dart';
import 'package:my_app/wellbeing/breathing_game/domain/repositories/breathing_game_repository.dart';
import 'package:my_app/wellbeing/breathing_game/domain/usecases/save_breathing_session_usecase.dart';
import 'package:my_app/wellbeing/breathing_game/domain/usecases/get_weekly_breathing_sessions_usecase.dart';
import 'package:my_app/wellbeing/breathing_game/presentation/blocs/breathing_game_bloc.dart';

// ==============================================
// STOP GAME (WELLBEING)
// ==============================================
import 'package:my_app/wellbeing/stop_game/data/datasources/stop_game_remote_datasource.dart';
import 'package:my_app/wellbeing/stop_game/data/repositories/stop_game_repository_impl.dart';
import 'package:my_app/wellbeing/stop_game/domain/repositories/stop_game_repository.dart';
import 'package:my_app/wellbeing/stop_game/domain/usecases/save_stop_session_usecase.dart';
import 'package:my_app/wellbeing/stop_game/domain/usecases/get_weekly_stop_sessions_usecase.dart';
import 'package:my_app/wellbeing/stop_game/presentation/blocs/stop_game_bloc.dart';

// ==============================================
// LIBRARY
// ==============================================
import 'package:my_app/library/data/datasources/library_remote_datasource.dart';
import 'package:my_app/library/data/datasources/library_remote_datasource_impl.dart';
import 'package:my_app/library/data/repositories/library_repository_impl.dart';
import 'package:my_app/library/domain/repositories/library_repository.dart';
import 'package:my_app/library/domain/usescases/get_book_by_id.dart';
import 'package:my_app/library/domain/usescases/get_books.dart';
import 'package:my_app/library/domain/usescases/get_books_by_category.dart';
import 'package:my_app/library/domain/usescases/search_books.dart';
import 'package:my_app/library/presentation/blocs/library_bloc.dart';

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


  getIt.registerLazySingleton<HabitDataSource>(
    () => HabitFirestoreDataSource(firestore: getIt()),
  );

  getIt.registerLazySingleton<BodyScanDataSource>(
    () => BodyScanFirestoreDataSource(firestore: getIt()),
  );

  getIt.registerLazySingleton<WellbeingPointsDataSource>(
    () => WellbeingPointsFirestoreDataSource(firestore: getIt()),
  );

  getIt.registerLazySingleton<BreathingGameDataSource>(
    () => BreathingGameFirestoreDataSource(firestore: getIt()),
  );

  getIt.registerLazySingleton<StopGameDataSource>(
    () => StopGameFirestoreDataSource(firestore: getIt()),
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

  getIt.registerLazySingleton<HabitRepository>(
  () => HabitRepositoryImpl(dataSource: getIt()), // 🔑 CORREGIDO: Usar 'dataSource: '
);

  getIt.registerLazySingleton<BodyScanRepository>(
    () => BodyScanRepositoryImpl(dataSource: getIt()),
  );

  getIt.registerLazySingleton<WellbeingPointsRepository>(
    () => WellbeingPointsRepositoryImpl(dataSource: getIt()),
  );

  getIt.registerLazySingleton<BreathingGameRepository>(
    () => BreathingGameRepositoryImpl(dataSource: getIt()),
  );

  getIt.registerLazySingleton<StopGameRepository>(
    () => StopGameRepositoryImpl(dataSource: getIt()),
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

getIt.registerLazySingleton<CreateHabitUseCase>(
  () => CreateHabitUseCase(repository: getIt()),
);

getIt.registerLazySingleton<RegisterCompletionUseCase>(
  () => RegisterCompletionUseCase(getIt()),
);

getIt.registerLazySingleton<GetHabitsByUserUseCase>(
  () => GetHabitsByUserUseCase(repository: getIt()),
);

getIt.registerLazySingleton<GetHabitProgressUseCase>(
  () => GetHabitProgressUseCase(repository: getIt()),
);

// Body Scan Use Cases
getIt.registerLazySingleton<SaveBodyScanSessionUseCase>(
  () => SaveBodyScanSessionUseCase(repository: getIt()),
);

getIt.registerLazySingleton<GetWeeklySessionsUseCase>(
  () => GetWeeklySessionsUseCase(repository: getIt()),
);

// Wellbeing Points Use Cases
getIt.registerLazySingleton<GetWellbeingPointsUseCase>(
  () => GetWellbeingPointsUseCase(repository: getIt()),
);

getIt.registerLazySingleton<IncrementWellbeingPointsUseCase>(
  () => IncrementWellbeingPointsUseCase(repository: getIt()),
);

// Breathing Game Use Cases
getIt.registerLazySingleton<SaveBreathingSessionUseCase>(
  () => SaveBreathingSessionUseCase(repository: getIt()),
);

getIt.registerLazySingleton<GetWeeklyBreathingSessionsUseCase>(
  () => GetWeeklyBreathingSessionsUseCase(repository: getIt()),
);

// STOP Game Use Cases
getIt.registerLazySingleton<SaveStopSessionUseCase>(
  () => SaveStopSessionUseCase(repository: getIt()),
);

getIt.registerLazySingleton<GetWeeklyStopSessionsUseCase>(
  () => GetWeeklyStopSessionsUseCase(repository: getIt()),
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

  getIt.registerFactory<HabitBloc>(
    () => HabitBloc(
      createHabitUseCase: getIt(),
      registerCompletionUseCase: getIt(),
      getHabitsByUserUseCase: getIt(),
      getHabitProgressUseCase: getIt(),
    ),
  );

  getIt.registerFactory<BodyScanBloc>(
    () => BodyScanBloc(
      saveSessionUseCase: getIt(),
      incrementPointsUseCase: getIt(),
    ),
  );

  getIt.registerFactory<WellbeingPointsBloc>(
    () => WellbeingPointsBloc(getPointsUseCase: getIt()),
  );

  getIt.registerFactory<BreathingGameBloc>(
    () => BreathingGameBloc(
      saveSessionUseCase: getIt(),
      incrementPointsUseCase: getIt(),
    ),
  );

  getIt.registerFactory<StopGameBloc>(
    () => StopGameBloc(
      saveSessionUseCase: getIt(),
      incrementPointsUseCase: getIt(),
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
ForumBloc getForumBloc() => getIt<ForumBloc>();
HabitBloc getHabitBloc() => getIt<HabitBloc>(); 

// ==============================================
// FUNCIÓN PARA LIMPIAR DEPENDENCIAS (OPCIONAL)
// ==============================================
Future<void> resetDI() async {
  await getIt.reset();
}
