import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/core/core.dart';

const _unset = Object();

@immutable
class CharactersState extends Equatable {
  final FetchStatus status;
  final String? errorMessage;
  final num? nextPage;
  final num? totalResults;
  final List<CharacterEntity> characters;
  final bool isLastPage;
  final bool isLoadingMore;
  final String searchQuery;

  final CharacterStatus? filterStatus;

  const CharactersState({
    this.status = FetchStatus.initial,
    this.errorMessage,
    this.nextPage,
    this.totalResults,
    this.characters = const [],
    this.isLastPage = false,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.filterStatus,
  });

  CharactersState copyWith({
    FetchStatus? status,
    String? errorMessage,
    num? nextPage,
    num? totalResults,
    List<CharacterEntity>? characters,
    bool? isLastPage,
    bool? isLoadingMore,
    String? searchQuery,
    Object? filterStatus = _unset,
  }) {
    return CharactersState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      nextPage: nextPage ?? this.nextPage,
      totalResults: totalResults ?? this.totalResults,
      characters: characters != null
          ? List.unmodifiable(characters)
          : this.characters,
      isLastPage: isLastPage ?? this.isLastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: identical(filterStatus, _unset)
          ? this.filterStatus
          : filterStatus as CharacterStatus?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    nextPage,
    totalResults,
    characters,
    isLastPage,
    isLoadingMore,
    searchQuery,
    filterStatus,
  ];
}
