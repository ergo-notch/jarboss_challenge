import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class PaginatedListModel<T> extends Equatable {
  final num? count;
  final num? next;
  final num? prev;
  final List<T>? results;

  const PaginatedListModel({
    this.count,
    this.next,
    this.prev,
    this.results,
  });

  factory PaginatedListModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonItem,
  ) {
    final info = json['info'] as Map<String, dynamic>?;
    final rawResults = json['results'] as List<dynamic>?;

    return PaginatedListModel(
      count: info?['count'] as num?,
      next: _parsePageFromUrl(info?['next'] as String?),
      prev: _parsePageFromUrl(info?['prev'] as String?),
      results: rawResults == null
          ? null
          : List.unmodifiable(
              rawResults.map(
                (item) => fromJsonItem(item as Map<String, dynamic>),
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
