import 'package:jarboss_challenge/features/characters/domain/use_cases/add_characters_by_page_use_case.dart';
import 'package:jarboss_challenge/features/characters/presentation/providers/characters_state.dart';

import '../../../../core/core.dart';

final charactersViewModelProvider =
    StateNotifierProvider<CharactersViewModel, CharactersState>(
      (ref) => CharactersViewModel(
        getCharactersByPageUseCase: ref.read(
          addCharactersByPageUseCaseProvider,
        ),
      ),
    );

class CharactersViewModel extends StateNotifier<CharactersState> {
  final AddCharactersByPageUseCase getCharactersByPageUseCase;

  bool _paginationLocked = false;

  CharactersViewModel({required this.getCharactersByPageUseCase})
    : super(const CharactersState());

  bool get _isLoading =>
      state.status == FetchStatus.fetching ||
      state.status == FetchStatus.loadingMore;

  Future<void> refreshCharacters() async {
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
      existingCharacters: const [],
      isRefresh: true,
      name: state.searchQuery,
      filterStatus: state.filterStatus,
    );
  }

  Future<void> searchByName(String query) async {
    if (query == state.searchQuery && state.characters.isNotEmpty) return;
    if (_isLoading) return;

    state = state.copyWith(
      searchQuery: query,
      status: FetchStatus.fetching,
      error: null,
      nextPage: 1,
      isLastPage: false,
      isLoadingMore: false,
      characters: const [],
    );

    await _loadPage(
      page: 1,
      existingCharacters: const [],
      isRefresh: true,
      name: query,
      filterStatus: state.filterStatus,
    );
  }

  Future<void> fetchCharacters() async {
    if (_paginationLocked || _isLoading || state.isLastPage) return;

    _paginationLocked = true;
    final pageToFetch = state.nextPage ?? 1;
    final existingCharacters = state.characters;
    final isInitialLoad = existingCharacters.isEmpty;

    state = state.copyWith(
      status: isInitialLoad ? FetchStatus.fetching : FetchStatus.loadingMore,
      isLoadingMore: !isInitialLoad,
      error: null,
    );

    try {
      await _loadPage(
        page: pageToFetch,
        existingCharacters: existingCharacters,
        isRefresh: false,
        name: state.searchQuery,
        filterStatus: state.filterStatus,
      );
    } finally {
      _paginationLocked = false;
      _clearLoadingFlags();
    }
  }

  Future<void> filterByStatus(CharacterStatus? value) async {
    if (value == state.filterStatus && state.characters.isNotEmpty) return;
    if (_isLoading) return;

    state = state.copyWith(
      filterStatus: value,
      status: FetchStatus.fetching,
      error: null,
      nextPage: 1,
      isLastPage: false,
      isLoadingMore: false,
      characters: const [],
    );

    await _loadPage(
      page: 1,
      existingCharacters: const [],
      isRefresh: true,
      name: state.searchQuery,
      filterStatus: value,
    );
  }

  Future<void> _loadPage({
    required num page,
    required List<CharacterEntity> existingCharacters,
    required bool isRefresh,
    required String? name,
    CharacterStatus? filterStatus,
  }) async {
    try {
      final result = await getCharactersByPageUseCase.call(
        AddCharactersByPageUseCaseParams(
          page: page,
          characters: isRefresh ? const [] : existingCharacters,
          isLastPage: isRefresh ? false : state.isLastPage,
          name: name?.isNotEmpty == true ? name : null,
          filterStatus: filterStatus,
        ),
      );

      result.fold(
        (error) => _handleFailure(
          error: error,
          page: page,
          existingCharacters: existingCharacters,
        ),
        (success) {
          final characters = success.result.results ?? [];
          state = state.copyWith(
            status: characters.isEmpty ? FetchStatus.empty : FetchStatus.success,
            nextPage: success.result.next,
            totalResults: success.result.count,
            characters: characters,
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
        existingCharacters: existingCharacters,
      );
    } finally {
      _clearLoadingFlags();
    }
  }

  void _handleFailure({
    required AppException error,
    required num page,
    required List<CharacterEntity> existingCharacters,
  }) {
    final isRateLimited =
        error is ApiException && error.type == ApiErrorType.rateLimited;

    if (existingCharacters.isEmpty) {
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
        (state.status == FetchStatus.fetching && state.characters.isNotEmpty)) {
      state = state.copyWith(
        isLoadingMore: false,
        status: state.characters.isEmpty
            ? state.status
            : FetchStatus.success,
      );
    }
  }
}
