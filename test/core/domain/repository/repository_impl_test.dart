import 'package:flutter_test/flutter_test.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockIDataSource mockDataSource;
  late RepositoryImpl repository;

  setUp(() {
    mockDataSource = MockIDataSource();
    repository = RepositoryImpl(dataSource: mockDataSource);
  });

  group('RepositoryImpl.getCharacters', () {
    test('returns mapped entity when data source succeeds', () async {
      when(
        () => mockDataSource.getCharacters(
          page: any(named: 'page'),
          name: any(named: 'name'),
          filterStatus: any(named: 'filterStatus'),
        ),
      ).thenAnswer((_) async => charactersListModel());

      final result = await repository.getCharacters(page: 1);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (entity) {
        expect(entity.count, 2);
        expect(entity.results, [rickEntity, mortyEntity]);
      });
    });

    test('forwards name and status filters to data source', () async {
      when(
        () => mockDataSource.getCharacters(
          page: 2,
          name: 'Rick',
          filterStatus: CharacterStatus.alive,
        ),
      ).thenAnswer((_) async => charactersListModel(count: 1, next: null));

      await repository.getCharacters(
        page: 2,
        name: 'Rick',
        filterStatus: CharacterStatus.alive,
      );

      verify(
        () => mockDataSource.getCharacters(
          page: 2,
          name: 'Rick',
          filterStatus: CharacterStatus.alive,
        ),
      ).called(1);
    });

    test(
      'returns Left when data source throws ApiException',
      () async {
        when(
          () => mockDataSource.getCharacters(
            page: any(named: 'page'),
            name: any(named: 'name'),
            filterStatus: any(named: 'filterStatus'),
          ),
        ).thenThrow(
          ApiException(
            type: ApiErrorType.serverError,
            technicalMessage: 'API error',
          ),
        );

        final result = await repository.getCharacters();

        expect(result.isLeft(), isTrue);
      result.fold((error) => expect(error.userMessage, isNotEmpty), (_) {
        fail('Expected error');
      });
      },
    );
  });
}
