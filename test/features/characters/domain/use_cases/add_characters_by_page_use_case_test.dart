import 'package:flutter_test/flutter_test.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:jarboss_challenge/features/characters/domain/use_cases/add_characters_by_page_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockIRepository mockRepository;
  late AddCharactersByPageUseCase useCase;

  setUpAll(() {
    registerFallbackValue(AddCharactersByPageUseCaseParams());
  });

  setUp(() {
    mockRepository = MockIRepository();
    useCase = AddCharactersByPageUseCase(repository: mockRepository);
  });

  group('AddCharactersByPageUseCase', () {
    test('returns cached characters when already on last page', () async {
      final params = AddCharactersByPageUseCaseParams(
        page: 3,
        characters: [rickEntity],
        isLastPage: true,
      );

      final result = await useCase(params);

      verifyNever(
        () => mockRepository.getCharacters(
          page: any(named: 'page'),
          name: any(named: 'name'),
          filterStatus: any(named: 'filterStatus'),
        ),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (success) {
        expect(success.isLastPage, isTrue);
        expect(success.result.results, [rickEntity]);
      });
    });

    test('merges new page with existing characters', () async {
      when(
        () => mockRepository.getCharacters(
          page: 2,
          name: any(named: 'name'),
          filterStatus: any(named: 'filterStatus'),
        ),
      ).thenAnswer(
        (_) async => Right(
          charactersListEntity(
            count: 2,
            next: null,
            results: const [mortyEntity],
          ),
        ),
      );

      final params = AddCharactersByPageUseCaseParams(
        page: 2,
        characters: [rickEntity],
      );

      final result = await useCase(params);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (success) {
        expect(success.result.results, [rickEntity, mortyEntity]);
        expect(success.isLastPage, isTrue);
      });
    });

    test('forwards search and status filters to repository', () async {
      when(
        () => mockRepository.getCharacters(
          page: 1,
          name: 'Rick',
          filterStatus: CharacterStatus.dead,
        ),
      ).thenAnswer(
        (_) async => Right(charactersListEntity(count: 0, results: const [])),
      );

      await useCase(
        AddCharactersByPageUseCaseParams(
          name: 'Rick',
          filterStatus: CharacterStatus.dead,
        ),
      );

      verify(
        () => mockRepository.getCharacters(
          page: 1,
          name: 'Rick',
          filterStatus: CharacterStatus.dead,
        ),
      ).called(1);
    });

    test('returns Left when repository fails', () async {
      when(
        () => mockRepository.getCharacters(
          page: any(named: 'page'),
          name: any(named: 'name'),
          filterStatus: any(named: 'filterStatus'),
        ),
      ).thenAnswer(
        (_) async => Left(GraphQLErrorException(message: 'Network error')),
      );

      final result = await useCase(AddCharactersByPageUseCaseParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error.message, 'Network error'),
        (_) => fail('Expected error'),
      );
    });
  });
}
