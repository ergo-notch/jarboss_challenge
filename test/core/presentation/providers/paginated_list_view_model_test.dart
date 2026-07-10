import 'package:flutter_test/flutter_test.dart';
import 'package:jarboss_challenge/core/core.dart';

import '../../../helpers/mocks.dart';

class _TestItem {
  final String id;
  const _TestItem(this.id);
}

void main() {
  PaginatedListViewModel<_TestItem> buildViewModel({
    required PaginatedPageFetcher<_TestItem> fetchPage,
  }) {
    return PaginatedListViewModel(
      useCase: AddPaginatedItemsByPageUseCase(fetchPage: fetchPage),
    );
  }

  group('PaginatedListViewModel', () {
    test('refresh transitions from initial to success with items', () async {
      final viewModel = buildViewModel(
        fetchPage: ({required page, name, filterValue}) async => Right(
          paginatedEntity(
            count: 2,
            next: null,
            results: const [_TestItem('1'), _TestItem('2')],
          ),
        ),
      );

      expect(viewModel.state.status, FetchStatus.initial);

      await viewModel.refresh();

      expect(viewModel.state.status, FetchStatus.success);
      expect(viewModel.state.items, hasLength(2));
      expect(viewModel.state.isLastPage, isTrue);
    });

    test('refresh sets empty status when API returns no items', () async {
      final viewModel = buildViewModel(
        fetchPage: ({required page, name, filterValue}) async =>
            Right(paginatedEntity(count: 0, next: null, results: const [])),
      );

      await viewModel.refresh();

      expect(viewModel.state.status, FetchStatus.empty);
      expect(viewModel.state.items, isEmpty);
    });

    test('refresh sets error status when use case fails', () async {
      final viewModel = buildViewModel(
        fetchPage: ({required page, name, filterValue}) async => Left(
          ApiException(
            type: ApiErrorType.network,
            technicalMessage: 'Network error',
          ),
        ),
      );

      await viewModel.refresh();

      expect(viewModel.state.status, FetchStatus.error);
      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.items, isEmpty);
    });

    test('fetchMore appends next page and marks last page', () async {
      var callCount = 0;
      final viewModel = buildViewModel(
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

      await viewModel.refresh();
      await viewModel.fetchMore();

      expect(callCount, 2);
      expect(viewModel.state.items, hasLength(2));
      expect(viewModel.state.isLastPage, isTrue);
      expect(viewModel.state.status, FetchStatus.success);
    });

    test('fetchMore does nothing when already on last page', () async {
      var callCount = 0;
      final viewModel = buildViewModel(
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

      await viewModel.refresh();
      await viewModel.fetchMore();

      expect(callCount, 1);
    });

    test('searchByName resets list and forwards query to use case', () async {
      String? capturedName;
      final viewModel = buildViewModel(
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

      await viewModel.refresh();
      await viewModel.searchByName('Rick');

      expect(capturedName, 'Rick');
      expect(viewModel.state.searchQuery, 'Rick');
      expect(viewModel.state.items, hasLength(1));
    });

    test('filterByValue resets list and forwards filter to use case', () async {
      String? capturedFilter;
      final viewModel = buildViewModel(
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

      await viewModel.refresh();
      await viewModel.filterByValue('dead');

      expect(capturedFilter, 'dead');
      expect(viewModel.state.filterValue, 'dead');
      expect(viewModel.state.items, hasLength(1));
    });

    test('keeps loaded items and surfaces error on pagination failure', () async {
      var callCount = 0;
      final viewModel = buildViewModel(
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

      await viewModel.refresh();
      await viewModel.fetchMore();

      expect(callCount, 2);
      expect(viewModel.state.status, FetchStatus.success);
      expect(viewModel.state.items, hasLength(1));
      expect(viewModel.state.error, isNotNull);
    });
  });
}
