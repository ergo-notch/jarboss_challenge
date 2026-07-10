import 'package:flutter_test/flutter_test.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockIRepository mockRepository;
  late AddPaginatedItemsByPageUseCase<CharacterEntity> useCase;

  setUpAll(() {
    registerFallbackValue(
      AddPaginatedItemsByPageUseCaseParams<CharacterEntity>(),
    );
  });

  setUp(() {
    mockRepository = MockIRepository();
    useCase = AddPaginatedItemsByPageUseCase<CharacterEntity>(
      fetchPage: ({required page, name, filterValue}) async {
        final status = filterValue == null
            ? null
            : CharacterStatus.values.firstWhere(
                (value) => value.apiFilterValue == filterValue,
              );
        final result = await mockRepository.getCharacters(
          page: page,
          name: name,
          filterStatus: status,
        );
        return result.map(
          (success) => PaginatedListEntity<CharacterEntity>(
            count: success.count,
            next: success.next,
            prev: success.prev,
            results: success.results,
          ),
        );
      },
    );
  });

  group('AddPaginatedItemsByPageUseCase<CharacterEntity>', () {
    test('returns cached characters when already on last page', () async {
      final params = AddPaginatedItemsByPageUseCaseParams<CharacterEntity>(
        page: 3,
        items: [rickEntity],
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

      final params = AddPaginatedItemsByPageUseCaseParams<CharacterEntity>(
        page: 2,
        items: [rickEntity],
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
        AddPaginatedItemsByPageUseCaseParams<CharacterEntity>(
          name: 'Rick',
          filterValue: CharacterStatus.dead.apiFilterValue,
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
        (_) async => Left(
          ApiException(
            type: ApiErrorType.network,
            technicalMessage: 'Network error',
          ),
        ),
      );

      final result = await useCase(
        AddPaginatedItemsByPageUseCaseParams<CharacterEntity>(),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error.userMessage, isNotEmpty),
        (_) => fail('Expected error'),
      );
    });
  });
}
