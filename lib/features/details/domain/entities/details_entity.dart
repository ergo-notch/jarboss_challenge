import 'package:jarboss_challenge/features/details/data/models/details_model.dart';

import '../../../../core/core.dart';

class DetailsEntity {
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
      episodes: model.episodes
          ?.map((x) => '${x.episode ?? ''} - ${x.name}')
          .toList(),
    );
  }

  static CharacterStatus? _mapStatus(String? status) {
    if (status?.toLowerCase() == 'alive') {
      return CharacterStatus.alive;
    } else if (status?.toLowerCase() == 'dead') {
      return CharacterStatus.dead;
    } else {
      return CharacterStatus.unknown;
    }
  }
}
