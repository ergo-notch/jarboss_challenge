import 'package:jarboss_challenge/core/core.dart';
import 'package:mocktail/mocktail.dart';

class MockIDataSource extends Mock implements IDataSource {}

class MockIRepository extends Mock implements IRepository {}


const rickEntity = CharacterEntity(
  id: '1',
  name: 'Rick Sanchez',
  status: CharacterStatus.alive,
  imageUrl: 'https://example.com/rick.png',
);

const mortyEntity = CharacterEntity(
  id: '2',
  name: 'Morty Smith',
  status: CharacterStatus.alive,
  imageUrl: 'https://example.com/morty.png',
);

CharactersListModel charactersListModel({
  num count = 2,
  num? next = 2,
  List<CharacterModel> results = const [
    CharacterModel(
      id: '1',
      name: 'Rick Sanchez',
      status: 'Alive',
      image: 'https://example.com/rick.png',
    ),
    CharacterModel(
      id: '2',
      name: 'Morty Smith',
      status: 'Alive',
      image: 'https://example.com/morty.png',
    ),
  ],
}) {
  return CharactersListModel(count: count, next: next, results: results);
}


CharactersListEntity charactersListEntity({
  num count = 2,
  num? next = 2,
  List<CharacterEntity> results = const [rickEntity, mortyEntity],
}) {
  return CharactersListEntity(count: count, next: next, results: results);
}

