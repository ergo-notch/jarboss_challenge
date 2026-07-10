import 'package:jarboss_challenge/core/core.dart';

final addEpisodesByPageUseCaseProvider =
    Provider<AddPaginatedItemsByPageUseCase<EpisodeEntity>>(
      (ref) => AddPaginatedItemsByPageUseCase<EpisodeEntity>(
        fetchPage: ({required page, name, filterValue}) =>
            ref.read(repositoryProvider).getEpisodes(page: page, name: name),
      ),
    );

final episodesViewModelProvider =
    StateNotifierProvider<
      PaginatedListViewModel<EpisodeEntity>,
      PaginatedListState<EpisodeEntity>
    >(
      (ref) => PaginatedListViewModel<EpisodeEntity>(
        useCase: ref.read(addEpisodesByPageUseCaseProvider),
      ),
    );
