import 'package:jarboss_challenge/core/core.dart';

abstract class UseCase<Type, Params> {
  Future<Either<AppException, Type>> call(Params params);
}

class NoParams {}

class NoResults {}
