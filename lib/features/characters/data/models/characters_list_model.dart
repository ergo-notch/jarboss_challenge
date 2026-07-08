import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'character_model.dart';

@immutable
class CharactersListModel extends Equatable {
  final num? count;
  final num? next;
  final num? prev;
  final List<CharacterModel>? results;

  const CharactersListModel({
    this.count,
    this.next,
    this.prev,
    this.results,
  });

  factory CharactersListModel.fromJson(Map<String, dynamic> json) {
    final rawResults = json['characters']['results'] as List<dynamic>?;

    return CharactersListModel(
      count: json['characters']['info']['count'] as num?,
      next: json['characters']['info']['next'] as num?,
      prev: json['characters']['info']['prev'] as num?,
      results: rawResults == null
          ? null
          : List.unmodifiable(
              rawResults.map(
                (item) => CharacterModel.fromJson(item as Map<String, dynamic>),
              ),
            ),
    );
  }

  @override
  List<Object?> get props => [count, next, prev, results];
}
