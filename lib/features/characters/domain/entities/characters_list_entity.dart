import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:jarboss_challenge/features/characters/data/models/characters_list_model.dart';
import 'package:jarboss_challenge/features/characters/domain/entities/character_entity.dart';

@immutable
class CharactersListEntity extends Equatable {
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
        results: model.results == null
            ? null
            : List.unmodifiable(
                model.results!.map(CharacterEntity.fromModel),
              ),
      );

  @override
  List<Object?> get props => [count, next, prev, results];
}
