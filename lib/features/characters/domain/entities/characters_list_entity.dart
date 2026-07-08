import 'package:jarboss_challenge/core/core.dart';

class CharactersListEntity {
  final num? count;
  final num? next;
  final num? prev;
  final List<CharacterEntity>? results;

  const CharactersListEntity({this.count, this.next, this.prev, this.results});

  factory CharactersListEntity.fromModel(CharactersListModel model) =>
      CharactersListEntity(
        count: model.count,
        next: model.next,
        prev: model.prev,
        results: model.results
            ?.map((x) => CharacterEntity.fromModel(x))
            .toList(),
      );
}
