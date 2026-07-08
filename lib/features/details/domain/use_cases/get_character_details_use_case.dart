import 'package:jarboss_challenge/core/core.dart';

final getCharacterDetailsUseCaseProvider = Provider<GetCharacterDetailsUseCase>(
  (ref) => GetCharacterDetailsUseCase(repository: ref.read(repositoryProvider)),
);

class GetCharacterDetailsUseCase extends UseCase<DetailsEntity, String?> {
  final IRepository repository;

  GetCharacterDetailsUseCase({required this.repository});

  @override
  Future<Either<GraphQLErrorException, DetailsEntity>> call(
    String? characterId,
  ) async {
    return await repository.getCharacterDetails(characterId: characterId);
  }
}
