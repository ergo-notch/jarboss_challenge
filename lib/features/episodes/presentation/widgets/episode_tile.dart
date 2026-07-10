import 'package:flutter/material.dart';
import 'package:jarboss_challenge/features/episodes/domain/entities/episode_entity.dart';

class EpisodeTile extends StatelessWidget {
  final EpisodeEntity episode;

  const EpisodeTile({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Chip(label: Text(episode.episodeCode ?? '')),
            Expanded(
              child: Text(
                episode.name ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Text(episode.airDate ?? ''),
          ],
        ),
      ),
    );
  }
}
