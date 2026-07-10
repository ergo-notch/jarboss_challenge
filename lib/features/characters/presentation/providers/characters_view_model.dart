import 'package:jarboss_challenge/core/core.dart';

CharacterStatus? _characterStatusFromFilter(String? filterValue) {
  if (filterValue == null) return null;
  for (final status in CharacterStatus.values) {
    if (status.apiFilterValue == filterValue) return status;
  }
  return null;
}

final addCharactersByPageUseCaseProvider =
    Provider<AddPaginatedItemsByPageUseCase<CharacterEntity>>(
      (ref) => AddPaginatedItemsByPageUseCase<CharacterEntity>(
        fetchPage: ({required page, name, filterValue}) async {
          final result = await ref
              .read(repositoryProvider)
              .getCharacters(
                page: page,
                name: name,
                filterStatus: _characterStatusFromFilter(filterValue),
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
      ),
    );

final charactersViewModelProvider =
    StateNotifierProvider<
      CharactersViewModel,
      PaginatedListState<CharacterEntity>
    >(
      (ref) => CharactersViewModel(
        useCase: ref.read(addCharactersByPageUseCaseProvider),
      ),
    );

class CharactersViewModel extends PaginatedListViewModel<CharacterEntity> {
  CharactersViewModel({required super.useCase});

  CharacterStatus? get filterStatus =>
      _characterStatusFromFilter(state.filterValue);

  Future<void> filterByStatus(CharacterStatus? status) =>
      filterByValue(status?.apiFilterValue);

  Future<void> refreshCharacters() => refresh();

  Future<void> fetchCharacters() => fetchMore();
}
