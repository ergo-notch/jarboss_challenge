import '../../../../core/core.dart';

class CharactersListModel {
  final num? count;
  final num? next;
  final num? prev;
  final List<CharacterModel>? results;

  const CharactersListModel({this.count, this.next, this.prev, this.results});

  factory CharactersListModel.fromJson(Map<String, dynamic> json) =>
      CharactersListModel(
        count: json['characters']['info']['count'],
        next: json['characters']['info']['next'],
        prev: json['characters']['info']['prev'],
        results:
            (json['characters']['results'] as List<dynamic>?)
                ?.map((e) => CharacterModel.fromJson(e))
                .toList(),
      );
}
