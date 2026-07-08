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

  CharactersViewModel({required this.getCharactersByPageUseCase})
    : super(const CharactersState());

  bool get _isLoading =>
      state.status == FetchStatus.fetching ||
      state.status == FetchStatus.loadingMore;

  Future<void> refreshCharacters() async {
    if (_isLoading) return;

    state = state.copyWith(
      status: FetchStatus.fetching,
      errorMessage: null,
      nextPage: 1,
      isLastPage: false,
      isLoadingMore: false,
    );

    await _loadPage(
      page: 1,
      existingCharacters: const [],
      isRefresh: true,
      name: state.searchQuery,
    );
  }

  Future<void> searchByName(String query) async {
    if (query == state.searchQuery && state.characters.isNotEmpty) return;
    if (_isLoading) return;

    state = state.copyWith(
      searchQuery: query,
      status: FetchStatus.fetching,
      errorMessage: null,
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
    );
  }

  Future<void> fetchCharacters() async {
    if (_isLoading || state.isLastPage) return;

    final isInitialLoad = state.characters.isEmpty;
    state = state.copyWith(
      status: isInitialLoad ? FetchStatus.fetching : FetchStatus.loadingMore,
      isLoadingMore: !isInitialLoad,
      errorMessage: null,
    );

    await _loadPage(
      page: state.nextPage ?? 1,
      existingCharacters: state.characters,
      isRefresh: false,
      name: state.searchQuery,
    );
  }

  Future<void> _loadPage({
    required num page,
    required List<CharacterEntity> existingCharacters,
    required bool isRefresh,
    required String? name,
  }) async {
    final result = await getCharactersByPageUseCase.call(
      AddCharactersByPageUseCaseParams(
        page: page,
        characters: isRefresh ? const [] : existingCharacters,
        isLastPage: isRefresh ? false : state.isLastPage,
        name: name?.isNotEmpty == true ? name : null,
      ),
    );

    result.fold(
      (error) {
        if (existingCharacters.isEmpty) {
          state = state.copyWith(
            status: FetchStatus.error,
            errorMessage: error.message,
            isLoadingMore: false,
          );
        } else {
          state = state.copyWith(
            status: FetchStatus.success,
            errorMessage: error.message,
            isLoadingMore: false,
          );
        }
      },
      (success) {
        final characters = success.result.results ?? [];
        state = state.copyWith(
          status: characters.isEmpty ? FetchStatus.empty : FetchStatus.success,
          nextPage: success.result.next,
          totalResults: success.result.count,
          characters: characters,
          isLastPage: success.isLastPage,
          errorMessage: null,
          isLoadingMore: false,
        );
      },
    );
  }
}
