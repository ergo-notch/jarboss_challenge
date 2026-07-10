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

  factory DetailsModel.fromRestJson(
    Map<String, dynamic> json, {
    List<EpisodeModel>? episodes,
  }) {
    return DetailsModel(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      status: json['status'] as String?,
      species: json['species'] as String?,
      type: json['type'] as String?,
      origin: json['origin']?['name'] as String?,
      location: json['location']?['name'] as String?,
      image: json['image'] as String?,
      episodes: episodes == null ? null : List.unmodifiable(episodes),
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
