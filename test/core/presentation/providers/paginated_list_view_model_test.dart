import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarboss_challenge/core/core.dart';

import '../../../helpers/mocks.dart';

class _TestItem {
  final String id;
  const _TestItem(this.id);
}

class _TestPaginatedListNotifier extends PaginatedListNotifier<_TestItem> {
  @override
  AddPaginatedItemsByPageUseCase<_TestItem> get useCase =>
      ref.read(_testUseCaseProvider);
}

final _testUseCaseProvider = Provider<AddPaginatedItemsByPageUseCase<_TestItem>>(
  (ref) => throw UnimplementedError('Override in tests'),
);

final _testListProvider =
    NotifierProvider<_TestPaginatedListNotifier, PaginatedListState<_TestItem>>(
      _TestPaginatedListNotifier.new,
    );

void main() {
  late ProviderContainer container;

  ProviderContainer buildContainer({
    required PaginatedPageFetcher<_TestItem> fetchPage,
  }) {
    return ProviderContainer(
      overrides: [
        _testUseCaseProvider.overrideWithValue(
          AddPaginatedItemsByPageUseCase(fetchPage: fetchPage),
        ),
      ],
    );
  }

  tearDown(() => container.dispose());

  group('PaginatedListNotifier', () {
    test('refresh transitions from initial to success with items', () async {
      container = buildContainer(
        fetchPage: ({required page, name, filterValue}) async => Right(
          paginatedEntity(
            count: 2,
            next: null,
            results: const [_TestItem('1'), _TestItem('2')],
          ),
        ),
      );

      final notifier = container.read(_testListProvider.notifier);
      expect(container.read(_testListProvider).status, FetchStatus.initial);

      await notifier.refresh();

      final state = container.read(_testListProvider);
      expect(state.status, FetchStatus.success);
      expect(state.items, hasLength(2));
      expect(state.isLastPage, isTrue);
    });

    test('refresh sets empty status when API returns no items', () async {
      container = buildContainer(
        fetchPage: ({required page, name, filterValue}) async =>
            Right(paginatedEntity(count: 0, next: null, results: const [])),
      );

      await container.read(_testListProvider.notifier).refresh();

      final state = container.read(_testListProvider);
      expect(state.status, FetchStatus.empty);
      expect(state.items, isEmpty);
    });

    test('refresh sets error status when use case fails', () async {
      container = buildContainer(
        fetchPage: ({required page, name, filterValue}) async => Left(
          ApiException(
            type: ApiErrorType.network,
            technicalMessage: 'Network error',
          ),
        ),
      );

      await container.read(_testListProvider.notifier).refresh();

      final state = container.read(_testListProvider);
      expect(state.status, FetchStatus.error);
      expect(state.error, isNotNull);
      expect(state.items, isEmpty);
    });

    test('fetchMore appends next page and marks last page', () async {
      var callCount = 0;
      container = buildContainer(
        fetchPage: ({required page, name, filterValue}) async {
          callCount++;
          if (page == 1) {
            return Right(
              paginatedEntity(
                count: 2,
                next: 2,
                results: const [_TestItem('1')],
              ),
            );
          }
          return Right(
            paginatedEntity(
              count: 2,
              next: null,
              results: const [_TestItem('2')],
            ),
          );
        },
      );

      final notifier = container.read(_testListProvider.notifier);
      await notifier.refresh();
      await notifier.fetchMore();

      final state = container.read(_testListProvider);
      expect(callCount, 2);
      expect(state.items, hasLength(2));
      expect(state.isLastPage, isTrue);
      expect(state.status, FetchStatus.success);
    });

    test('fetchMore does nothing when already on last page', () async {
      var callCount = 0;
      container = buildContainer(
        fetchPage: ({required page, name, filterValue}) async {
          callCount++;
          return Right(
            paginatedEntity(
              count: 1,
              next: null,
              results: const [_TestItem('1')],
            ),
          );
        },
      );

      final notifier = container.read(_testListProvider.notifier);
      await notifier.refresh();
      await notifier.fetchMore();

      expect(callCount, 1);
    });

    test('searchByName resets list and forwards query to use case', () async {
      String? capturedName;
      container = buildContainer(
        fetchPage: ({required page, name, filterValue}) async {
          capturedName = name;
          return Right(
            paginatedEntity(
              count: 1,
              next: null,
              results: const [_TestItem('rick')],
            ),
          );
        },
      );

      final notifier = container.read(_testListProvider.notifier);
      await notifier.refresh();
      await notifier.searchByName('Rick');

      final state = container.read(_testListProvider);
      expect(capturedName, 'Rick');
      expect(state.searchQuery, 'Rick');
      expect(state.items, hasLength(1));
    });

    test('filterByValue resets list and forwards filter to use case', () async {
      String? capturedFilter;
      container = buildContainer(
        fetchPage: ({required page, name, filterValue}) async {
          capturedFilter = filterValue;
          return Right(
            paginatedEntity(
              count: 1,
              next: null,
              results: const [_TestItem('dead')],
            ),
          );
        },
      );

      final notifier = container.read(_testListProvider.notifier);
      await notifier.refresh();
      await notifier.filterByValue('dead');

      final state = container.read(_testListProvider);
      expect(capturedFilter, 'dead');
      expect(state.filterValue, 'dead');
      expect(state.items, hasLength(1));
    });

    test('keeps loaded items and surfaces error on pagination failure', () async {
      var callCount = 0;
      container = buildContainer(
        fetchPage: ({required page, name, filterValue}) async {
          callCount++;
          if (page == 1) {
            return Right(
              paginatedEntity(
                count: 4,
                next: 2,
                results: const [_TestItem('1')],
              ),
            );
          }
          return Left(
            ApiException(
              type: ApiErrorType.network,
              technicalMessage: 'Network error',
            ),
          );
        },
      );

      final notifier = container.read(_testListProvider.notifier);
      await notifier.refresh();
      await notifier.fetchMore();

      final state = container.read(_testListProvider);
      expect(callCount, 2);
      expect(state.status, FetchStatus.success);
      expect(state.items, hasLength(1));
      expect(state.error, isNotNull);
    });
  });
}
