import 'package:flutter/material.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:jarboss_challenge/features/episodes/presentation/providers/episodes_view_model.dart';
import 'package:jarboss_challenge/features/episodes/presentation/widgets/episode_tile.dart';

class EpisodesPage extends ConsumerWidget {
  static const String path = '/episodes';
  static const String name = 'episodes';

  const EpisodesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginatedListPage<EpisodeEntity, EpisodesListNotifier>(
      listProvider: episodesViewModelProvider,
      title: 'Episodios',
      searchHintText: 'Buscar episodio...',
      buildSuccessSlivers: (context, state, _) {
        return [
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              return EpisodeTile(episode: state.items[index]);
            }, childCount: state.items.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 1.5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
          ),
        ];
      },
    );
  }
}
