class EpisodeModel {
  final String? name;
  final String? episode;

  EpisodeModel({this.name, this.episode});

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
    name: json['name'] as String?,
    episode: json['episode'] as String?,
  );
}
