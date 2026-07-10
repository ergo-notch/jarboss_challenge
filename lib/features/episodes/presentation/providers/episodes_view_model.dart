import 'package:jarboss_challenge/core/core.dart';

final addEpisodesByPageUseCaseProvider =
    Provider<AddPaginatedItemsByPageUseCase<EpisodeEntity>>(
      (ref) => AddPaginatedItemsByPageUseCase<EpisodeEntity>(
        fetchPage: ({required page, name, filterValue}) =>
            ref.read(repositoryProvider).getEpisodes(page: page, name: name),
      ),
    );

final episodesViewModelProvider =
    NotifierProvider<EpisodesListNotifier, PaginatedListState<EpisodeEntity>>(
      EpisodesListNotifier.new,
    );

class EpisodesListNotifier extends PaginatedListNotifier<EpisodeEntity> {
  @override
  AddPaginatedItemsByPageUseCase<EpisodeEntity> get useCase =>
      ref.read(addEpisodesByPageUseCaseProvider);
}
