import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class EpisodeListModel extends Equatable {
  final String? id;
  final String? name;
  final String? airDate;
  final String? episode;

  const EpisodeListModel({
    this.id,
    this.name,
    this.airDate,
    this.episode,
  });

  factory EpisodeListModel.fromJson(Map<String, dynamic> json) =>
      EpisodeListModel(
        id: json['id']?.toString(),
        name: json['name'] as String?,
        airDate: json['air_date'] as String?,
        episode: json['episode'] as String?,
      );

  @override
  List<Object?> get props => [id, name, airDate, episode];
}
