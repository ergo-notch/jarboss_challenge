import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'episode_model.dart';

@immutable
class DetailsModel extends Equatable {
  final String? id;
  final String? name;
  final String? status;
  final String? species;
  final String? type;
  final String? origin;
  final String? location;
  final String? image;
  final List<EpisodeModel>? episodes;

  const DetailsModel({
    this.id,
    this.name,
    this.status,
    this.species,
    this.type,
    this.origin,
    this.location,
    this.image,
    this.episodes,
  });

  factory DetailsModel.fromJson(Map<String, dynamic> json) {
    final character = json['character'] as Map<String, dynamic>?;
    final rawEpisodes = character?['episode'] as List<dynamic>?;

    return DetailsModel(
      id: character?['id']?.toString(),
      name: character?['name'] as String?,
      status: character?['status'] as String?,
      species: character?['species'] as String?,
      type: character?['type'] as String?,
      origin: character?['origin']?['name'] as String?,
      location: character?['location']?['name'] as String?,
      image: character?['image'] as String?,
      episodes: rawEpisodes == null
          ? null
          : List.unmodifiable(
              rawEpisodes.map(
                (item) => EpisodeModel.fromJson(item as Map<String, dynamic>),
              ),
            ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    species,
    type,
    origin,
    location,
    image,
    episodes,
  ];
}
