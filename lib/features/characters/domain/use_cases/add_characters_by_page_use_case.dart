import 'package:jarboss_challenge/core/core.dart';

final addCharactersByPageUseCaseProvider = Provider<AddCharactersByPageUseCase>(
  (ref) => AddCharactersByPageUseCase(repository: ref.read(repositoryProvider)),
);

class AddCharactersByPageUseCase
    extends
        UseCase<
          AddCharactersByPageUseCaseResult,
          AddCharactersByPageUseCaseParams
        > {
  final IRepository repository;

  AddCharactersByPageUseCase({required this.repository});

  @override
  Future<Either<GraphQLErrorException, AddCharactersByPageUseCaseResult>> call(
    AddCharactersByPageUseCaseParams params,
  ) async {
    if (params.isLastPage) {
      return Right(
        AddCharactersByPageUseCaseResult(
          isLastPage: params.isLastPage,
          result: CharactersListEntity(
            count: params.characters.length,
            results: params.characters,
            next: null,
          ),
        ),
      );
    } else {
      final response = await repository.getCharacters(
        page: params.page,
        name: params.name,
        filterStatus: params.filterStatus,
      );
      return response.fold((error) => Left(error), (success) {
        List<CharacterEntity> results = List.unmodifiable([
          ...params.characters,
          ...success.results ?? [],
        ]);
        return Right(
          AddCharactersByPageUseCaseResult(
            isLastPage: results.length >= (success.count ?? 0),
            result: CharactersListEntity(
              count: success.count,
              results: results,
              next: success.next,
            ),
          ),
        );
      });
    }
  }
}

class AddCharactersByPageUseCaseParams {
  final num page;
  final List<CharacterEntity> characters;
  final bool isLastPage;
  final String? name;
  final CharacterStatus? filterStatus;

  AddCharactersByPageUseCaseParams({
    this.page = 1,
    this.characters = const [],
    this.isLastPage = false,
    this.name,
    this.filterStatus,
  });
}

class AddCharactersByPageUseCaseResult {
  final bool isLastPage;
  final CharactersListEntity result;

  AddCharactersByPageUseCaseResult({
    this.isLastPage = false,
    required this.result,
  });
}
