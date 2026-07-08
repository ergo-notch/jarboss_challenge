import 'package:jarboss_challenge/core/core.dart';

class CharactersState {
  final FetchStatus status;
  final String? errorMessage;
  final num? nextPage;
  final num? totalResults;
  final List<CharacterEntity> characters;
  final bool isLastPage;

  const CharactersState({
    this.status = FetchStatus.initial,
    this.errorMessage,
    this.nextPage,
    this.totalResults,
    this.characters = const [],
    this.isLastPage = false,
  });

  CharactersState copyWith({
    FetchStatus? status,
    String? errorMessage,
    num? nextPage,
    num? totalResults,
    List<CharacterEntity>? characters,
    bool? isLastPage,
  }) {
    return CharactersState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPage: nextPage ?? this.nextPage,
      totalResults: totalResults ?? this.totalResults,
      characters: characters ?? this.characters,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}
