import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/features/episodes/data/models/episode_list_model.dart';

@immutable
class EpisodeEntity extends Equatable {
  final String? id;
  final String? name;
  final String? airDate;
  final String? episodeCode;

  const EpisodeEntity({
    this.id,
    this.name,
    this.airDate,
    this.episodeCode,
  });

  factory EpisodeEntity.fromModel(EpisodeListModel model) => EpisodeEntity(
    id: model.id,
    name: model.name,
    airDate: model.airDate,
    episodeCode: model.episode,
  );

  @override
  List<Object?> get props => [id, name, airDate, episodeCode];
}
