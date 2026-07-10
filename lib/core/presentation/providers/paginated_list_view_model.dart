import 'package:jarboss_challenge/core/core.dart';

class PaginatedListViewModel<TEntity>
    extends StateNotifier<PaginatedListState<TEntity>> {
  final AddPaginatedItemsByPageUseCase<TEntity> useCase;

  bool _paginationLocked = false;

  PaginatedListViewModel({required this.useCase})
    : super(PaginatedListState<TEntity>());

  bool get _isLoading =>
      state.status == FetchStatus.fetching ||
      state.status == FetchStatus.loadingMore;

  Future<void> refresh() async {
    if (_isLoading) return;

    state = state.copyWith(
      status: FetchStatus.fetching,
      error: null,
      nextPage: 1,
      isLastPage: false,
      isLoadingMore: false,
    );

    await _loadPage(
      page: 1,
      existingItems: List<TEntity>.empty(growable: false),
      isRefresh: true,
      name: state.searchQuery,
      filterValue: state.filterValue,
    );
  }

  Future<void> searchByName(String query) async {
    if (query == state.searchQuery && state.items.isNotEmpty) return;
    if (_isLoading) return;

    state = state.copyWith(
      searchQuery: query,
      status: FetchStatus.fetching,
      error: null,
      nextPage: 1,
      isLastPage: false,
      isLoadingMore: false,
      items: List<TEntity>.empty(growable: false),
    );

    await _loadPage(
      page: 1,
      existingItems: List<TEntity>.empty(growable: false),
      isRefresh: true,
      name: query,
      filterValue: state.filterValue,
    );
  }

  Future<void> fetchMore() async {
    if (_paginationLocked || _isLoading || state.isLastPage) return;

    _paginationLocked = true;
    final pageToFetch = state.nextPage ?? 1;
    final existingItems = state.items;
    final isInitialLoad = existingItems.isEmpty;

    state = state.copyWith(
      status: isInitialLoad ? FetchStatus.fetching : FetchStatus.loadingMore,
      isLoadingMore: !isInitialLoad,
      error: null,
    );

    try {
      await _loadPage(
        page: pageToFetch,
        existingItems: existingItems,
        isRefresh: false,
        name: state.searchQuery,
        filterValue: state.filterValue,
      );
    } finally {
      _paginationLocked = false;
      _clearLoadingFlags();
    }
  }

  Future<void> filterByValue(String? value) async {
    if (value == state.filterValue && state.items.isNotEmpty) return;
    if (_isLoading) return;

    state = state.copyWith(
      filterValue: value,
      status: FetchStatus.fetching,
      error: null,
      nextPage: 1,
      isLastPage: false,
      isLoadingMore: false,
      items: List<TEntity>.empty(growable: false),
    );

    await _loadPage(
      page: 1,
      existingItems: List<TEntity>.empty(growable: false),
      isRefresh: true,
      name: state.searchQuery,
      filterValue: value,
    );
  }

  Future<void> _loadPage({
    required num page,
    required List<TEntity> existingItems,
    required bool isRefresh,
    required String? name,
    required String? filterValue,
  }) async {
    try {
      final result = await useCase.call(
        AddPaginatedItemsByPageUseCaseParams(
          page: page,
          items: isRefresh
              ? List<TEntity>.empty(growable: false)
              : existingItems,
          isLastPage: isRefresh ? false : state.isLastPage,
          name: name?.isNotEmpty == true ? name : null,
          filterValue: filterValue,
        ),
      );

      result.fold(
        (error) => _handleFailure(
          error: error,
          page: page,
          existingItems: existingItems,
        ),
        (success) {
          final items = success.result.results ?? [];
          state = state.copyWith(
            status: items.isEmpty ? FetchStatus.empty : FetchStatus.success,
            nextPage: success.result.next,
            totalResults: success.result.count,
            items: items,
            isLastPage: success.isLastPage,
            error: null,
            isLoadingMore: false,
          );
        },
      );
    } catch (error) {
      _handleFailure(
        error: mapToAppException(error),
        page: page,
        existingItems: existingItems,
      );
    } finally {
      _clearLoadingFlags();
    }
  }

  void _handleFailure({
    required AppException error,
    required num page,
    required List<TEntity> existingItems,
  }) {
    final isRateLimited =
        error is ApiException && error.type == ApiErrorType.rateLimited;

    if (existingItems.isEmpty) {
      state = state.copyWith(
        status: FetchStatus.error,
        error: error,
        isLoadingMore: false,
      );
      return;
    }

    state = state.copyWith(
      status: FetchStatus.success,
      error: error,
      isLoadingMore: false,
      nextPage: isRateLimited ? page : state.nextPage,
    );
  }

  void _clearLoadingFlags() {
    if (state.isLoadingMore ||
        state.status == FetchStatus.loadingMore ||
        (state.status == FetchStatus.fetching && state.items.isNotEmpty)) {
      state = state.copyWith(
        isLoadingMore: false,
        status: state.items.isEmpty ? state.status : FetchStatus.success,
      );
    }
  }
}
