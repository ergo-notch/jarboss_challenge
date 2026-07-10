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
    final info = json['info'] as Map<String, dynamic>?;
    final rawResults = json['results'] as List<dynamic>?;

    return CharactersListModel(
      count: info?['count'] as num?,
      next: _parsePageFromUrl(info?['next'] as String?),
      prev: _parsePageFromUrl(info?['prev'] as String?),
      results: rawResults == null
          ? null
          : List.unmodifiable(
              rawResults.map(
                (item) => CharacterModel.fromJson(item as Map<String, dynamic>),
              ),
            ),
    );
  }

  static num? _parsePageFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final page = Uri.parse(url).queryParameters['page'];
    return page == null ? null : num.tryParse(page);
  }

  @override
  List<Object?> get props => [count, next, prev, results];
}
