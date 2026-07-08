import 'package:equatable/equatable.dart';
import 'package:jarboss_challenge/core/core.dart';

class CharactersState extends Equatable {
  final FetchStatus status;
  final String? errorMessage;
  final num? nextPage;
  final num? totalResults;
  final List<CharacterEntity> characters;
  final bool isLastPage;
  final bool isLoadingMore;
  final String searchQuery;

  const CharactersState({
    this.status = FetchStatus.initial,
    this.errorMessage,
    this.nextPage,
    this.totalResults,
    this.characters = const [],
    this.isLastPage = false,
    this.isLoadingMore = false,
    this.searchQuery = '',
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
  }) {
    return CharactersState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      nextPage: nextPage ?? this.nextPage,
      totalResults: totalResults ?? this.totalResults,
      characters: characters ?? this.characters,
      isLastPage: isLastPage ?? this.isLastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
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
  ];
}
