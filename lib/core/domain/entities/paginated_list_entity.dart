import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/core/data/models/paginated_list_model.dart';

@immutable
class PaginatedListEntity<T> extends Equatable {
  final num? count;
  final num? next;
  final num? prev;
  final List<T>? results;

  const PaginatedListEntity({
    this.count,
    this.next,
    this.prev,
    this.results,
  });

  static PaginatedListEntity<T> fromModel<T, TModel>(
    PaginatedListModel<TModel> model,
    T Function(TModel model) fromModel,
  ) {
    return PaginatedListEntity<T>(
      count: model.count,
      next: model.next,
      prev: model.prev,
      results: model.results == null
          ? null
          : List.unmodifiable(model.results!.map(fromModel)),
    );
  }

  @override
  List<Object?> get props => [count, next, prev, results];
}
