import '../../core.dart';

final repositoryProvider = Provider<IRepository>(
  (ref) => RepositoryImpl(dataSource: ref.read(dataSourceProvider)),
);

abstract class IRepository {
  Future<Either<GraphQLErrorException, CharactersListEntity>> getCharacters({
    num page = 1,
  });

  Future<Either<GraphQLErrorException, DetailsEntity>> getCharacterDetails({
    String? characterId,
  });
}
