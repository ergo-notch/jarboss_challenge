import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class EpisodeModel extends Equatable {
  final String? name;
  final String? episode;

  const EpisodeModel({this.name, this.episode});

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
    name: json['name'] as String?,
    episode: json['episode'] as String?,
  );

  @override
  List<Object?> get props => [name, episode];
}
