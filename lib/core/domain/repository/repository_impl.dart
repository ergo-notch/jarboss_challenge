import 'package:jarboss_challenge/core/core.dart';

class RepositoryImpl extends IRepository {
  final IDataSource dataSource;

  RepositoryImpl({required this.dataSource});

  @override
  Future<Either<GraphQLErrorException, CharactersListEntity>> getCharacters({
    num page = 1,
  }) async {
    try {
      final result = await dataSource.getCharacters(page: page);
      return Right(CharactersListEntity.fromModel(result));
    } on GraphQLErrorException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<GraphQLErrorException, DetailsEntity>> getCharacterDetails({
    String? characterId,
  }) async {
    try {
      final result = await dataSource.getCharacterDetails(
        characterId: characterId,
      );
      return Right(DetailsEntity.fromModel(result));
    } on GraphQLErrorException catch (e) {
      return Left(e);
    }
  }
}
