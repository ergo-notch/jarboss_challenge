import 'package:jarboss_challenge/core/core.dart';

abstract class UseCase<Result, Params> {
  Future<Either<GraphQLErrorException, Result>> call(Params params);
}

abstract class NoParams {}

abstract class NoResults {}
