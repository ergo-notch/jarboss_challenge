import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/core/core.dart';

const _unset = Object();

@immutable
class PaginatedListState<T> extends Equatable {
  final FetchStatus status;
  final AppException? error;
  final num? nextPage;
  final num? totalResults;
  final List<T> items;
  final bool isLastPage;
  final bool isLoadingMore;
  final String searchQuery;
  final String? filterValue;

  const PaginatedListState({
    this.status = FetchStatus.initial,
    this.error,
    this.nextPage,
    this.totalResults,
    this.items = const [],
    this.isLastPage = false,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.filterValue,
  });

  PaginatedListState<T> copyWith({
    FetchStatus? status,
    Object? error = _unset,
    num? nextPage,
    num? totalResults,
    List<T>? items,
    bool? isLastPage,
    bool? isLoadingMore,
    String? searchQuery,
    Object? filterValue = _unset,
  }) {
    return PaginatedListState<T>(
      status: status ?? this.status,
      error: identical(error, _unset) ? this.error : error as AppException?,
      nextPage: nextPage ?? this.nextPage,
      totalResults: totalResults ?? this.totalResults,
      items: items != null ? List.unmodifiable(items) : this.items,
      isLastPage: isLastPage ?? this.isLastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filterValue: identical(filterValue, _unset)
          ? this.filterValue
          : filterValue as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    error,
    nextPage,
    totalResults,
    items,
    isLastPage,
    isLoadingMore,
    searchQuery,
    filterValue,
  ];
}
