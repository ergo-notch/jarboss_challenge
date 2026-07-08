import 'episode_model.dart';

class DetailsModel {
  final String? id;
  final String? name;
  final String? status;
  final String? species;
  final String? type;
  final String? origin;
  final String? location;
  final String? image;
  final List<EpisodeModel>? episodes;

  DetailsModel({
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

  factory DetailsModel.fromJson(Map<String, dynamic> json) => DetailsModel(
    id: json['character']['id'] as String?,
    name: json['character']['name'] as String?,
    status: json['character']['status'] as String?,
    species: json['character']['species'] as String?,
    type: json['character']['type'] as String?,
    origin: json['character']['origin']['name'] as String?,
    location: json['character']['location']['name'] as String?,
    image: json['character']['image'] as String?,
    episodes:
        (json['character']['episode'] as List<dynamic>?)
            ?.map((e) => EpisodeModel.fromJson(e))
            .toList(),
  );
}
