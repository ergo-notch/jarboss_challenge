import 'package:jarboss_challenge/core/core.dart';

final addLocationsByPageUseCaseProvider =
    Provider<AddPaginatedItemsByPageUseCase<LocationEntity>>(
      (ref) => AddPaginatedItemsByPageUseCase<LocationEntity>(
        fetchPage: ({required page, name, filterValue}) =>
            ref.read(repositoryProvider).getLocations(page: page, name: name),
      ),
    );

final locationsViewModelProvider =
    NotifierProvider<LocationsListNotifier, PaginatedListState<LocationEntity>>(
      LocationsListNotifier.new,
    );

class LocationsListNotifier extends PaginatedListNotifier<LocationEntity> {
  @override
  AddPaginatedItemsByPageUseCase<LocationEntity> get useCase =>
      ref.read(addLocationsByPageUseCaseProvider);
}
