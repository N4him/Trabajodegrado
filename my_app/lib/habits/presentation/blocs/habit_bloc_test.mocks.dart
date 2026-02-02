// Mocks generated manually for habit_bloc_test.dart
// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:mockito/mockito.dart' as _i1;
import 'package:my_app/habits/domain/entities/habit_entity.dart' as _i2;
import 'package:my_app/habits/domain/entities/habit_progress.dart' as _i3;
import 'package:my_app/habits/domain/usecases/create_habit_usecase.dart' as _i4;
import 'package:my_app/habits/domain/usecases/register_completion_usecase.dart' as _i5;
import 'package:my_app/habits/domain/usecases/get_habits_by_user_usecase.dart' as _i6;
import 'package:my_app/habits/domain/usecases/get_habit_progress_usecase.dart' as _i7;
import 'package:my_app/habits/domain/usecases/delete_habit_usecase.dart' as _i8;
import 'package:my_app/gamification/domain/usecases/update_modulo_progress.dart' as _i9;
import 'package:my_app/gamification/domain/usecases/update_estado_general.dart' as _i10;
import 'package:my_app/gamification/domain/usecases/get_gamificacion_data.dart' as _i11;
import 'package:my_app/gamification/domain/entities/gamificacion.dart' as _i12;
import 'package:my_app/gamification/domain/entities/modulo_progreso.dart' as _i13;
import 'package:my_app/services/notification_service.dart' as _i14;

// Mock classes
class MockCreateHabitUseCase extends _i1.Mock implements _i4.CreateHabitUseCase {}

class MockRegisterCompletionUseCase extends _i1.Mock implements _i5.RegisterCompletionUseCase {}

class MockGetHabitsByUserUseCase extends _i1.Mock implements _i6.GetHabitsByUserUseCase {}

class MockGetHabitProgressUseCase extends _i1.Mock implements _i7.GetHabitProgressUseCase {}

class MockDeleteHabitUseCase extends _i1.Mock implements _i8.DeleteHabitUseCase {}

class MockUpdateModuloProgress extends _i1.Mock implements _i9.UpdateModuloProgress {}

class MockUpdateEstadoGeneral extends _i1.Mock implements _i10.UpdateEstadoGeneral {}

class MockGetGamificacionData extends _i1.Mock implements _i11.GetGamificacionData {}

class MockNotificationService extends _i1.Mock implements _i14.NotificationService {}