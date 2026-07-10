import '../../core.dart';

final repositoryProvider = Provider<IRepository>(
  (ref) => RepositoryImpl(dataSource: ref.read(dataSourceProvider)),
);

abstract class IRepository {
  Future<Either<AppException, CharactersListEntity>> getCharacters({
    num page = 1,
    String? name,
    CharacterStatus? filterStatus,
  });

  Future<Either<AppException, PaginatedListEntity<LocationEntity>>> getLocations({
    num page = 1,
    String? name,
  });

  Future<Either<AppException, PaginatedListEntity<EpisodeEntity>>> getEpisodes({
    num page = 1,
    String? name,
  });

  Future<Either<AppException, DetailsEntity>> getCharacterDetails({
    String? characterId,
  });
}
