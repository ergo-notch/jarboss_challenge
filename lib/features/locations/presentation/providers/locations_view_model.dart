import 'package:jarboss_challenge/core/core.dart';

final addLocationsByPageUseCaseProvider =
    Provider<AddPaginatedItemsByPageUseCase<LocationEntity>>(
      (ref) => AddPaginatedItemsByPageUseCase<LocationEntity>(
        fetchPage: ({required page, name, filterValue}) =>
            ref.read(repositoryProvider).getLocations(page: page, name: name),
      ),
    );

final locationsViewModelProvider =
    StateNotifierProvider<
      PaginatedListViewModel<LocationEntity>,
      PaginatedListState<LocationEntity>
    >(
      (ref) => PaginatedListViewModel<LocationEntity>(
        useCase: ref.read(addLocationsByPageUseCaseProvider),
      ),
    );
