import 'package:jarboss_challenge/core/core.dart';

class RepositoryImpl extends IRepository {
  final IDataSource dataSource;

  RepositoryImpl({required this.dataSource});

  @override
  Future<Either<AppException, CharactersListEntity>> getCharacters({
    num page = 1,
    String? name,
    CharacterStatus? filterStatus,
  }) async {
    try {
      final result = await dataSource.getCharacters(
        page: page,
        name: name,
        filterStatus: filterStatus,
      );
      return Right(CharactersListEntity.fromModel(result));
    } on ApiException catch (error) {
      return Left(error);
    } on GeneralException catch (error) {
      return Left(error);
    } catch (error) {
      return Left(GeneralException.unexpected(error));
    }
  }

  @override
  Future<Either<AppException, PaginatedListEntity<LocationEntity>>>
  getLocations({num page = 1, String? name}) async {
    try {
      final result = await dataSource.getLocations(page: page, name: name);
      return Right(
        PaginatedListEntity.fromModel(result, LocationEntity.fromModel),
      );
    } on ApiException catch (error) {
      return Left(error);
    } on GeneralException catch (error) {
      return Left(error);
    } catch (error) {
      return Left(GeneralException.unexpected(error));
    }
  }

  @override
  Future<Either<AppException, PaginatedListEntity<EpisodeEntity>>> getEpisodes({
    num page = 1,
    String? name,
  }) async {
    try {
      final result = await dataSource.getEpisodes(page: page, name: name);
      return Right(
        PaginatedListEntity.fromModel(result, EpisodeEntity.fromModel),
      );
    } on ApiException catch (error) {
      return Left(error);
    } on GeneralException catch (error) {
      return Left(error);
    } catch (error) {
      return Left(GeneralException.unexpected(error));
    }
  }

  @override
  Future<Either<AppException, DetailsEntity>> getCharacterDetails({
    String? characterId,
  }) async {
    try {
      final result = await dataSource.getCharacterDetails(
        characterId: characterId,
      );
      return Right(DetailsEntity.fromModel(result));
    } on ApiException catch (error) {
      return Left(error);
    } on GeneralException catch (error) {
      return Left(error);
    } catch (error) {
      return Left(GeneralException.unexpected(error));
    }
  }
}
