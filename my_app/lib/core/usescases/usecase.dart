

// ignore_for_file: avoid_types_as_parameter_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}