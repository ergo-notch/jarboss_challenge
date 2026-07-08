import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:jarboss_challenge/features/details/data/models/details_model.dart';

import '../../../../core/core.dart';

@immutable
class DetailsEntity extends Equatable {
  final String? id;
  final String? name;
  final CharacterStatus? status;
  final String? species;
  final String? type;
  final String? origin;
  final String? location;
  final String? imageUrl;
  final List<String>? episodes;

  const DetailsEntity({
    this.id,
    this.name,
    this.status,
    this.species,
    this.type,
    this.origin,
    this.location,
    this.imageUrl,
    this.episodes,
  });

  factory DetailsEntity.fromModel(DetailsModel model) {
    return DetailsEntity(
      id: model.id,
      name: model.name,
      status: _mapStatus(model.status),
      species: model.species,
      type: model.type,
      origin: model.origin,
      location: model.location,
      imageUrl: model.image,
      episodes: model.episodes == null
          ? null
          : List.unmodifiable(
              model.episodes!.map(
                (episode) => '${episode.episode ?? ''} - ${episode.name}',
              ),
            ),
    );
  }

  static CharacterStatus? _mapStatus(String? status) {
    return switch (status?.toLowerCase()) {
      'alive' => CharacterStatus.alive,
      'dead' => CharacterStatus.dead,
      _ => CharacterStatus.unknown,
    };
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
    imageUrl,
    episodes,
  ];
}
