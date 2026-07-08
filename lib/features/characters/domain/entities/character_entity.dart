import 'package:jarboss_challenge/features/characters/data/models/character_model.dart';

enum CharacterStatus {
  alive('alive'),
  dead('dead'),
  unknown('unknown');

  final String value;

  const CharacterStatus(this.value);

  @override
  String toString() {
    return value;
  }
}

class CharacterEntity {
  final String? id;
  final String? name;
  final CharacterStatus? status;
  final String? imageUrl;

  const CharacterEntity({this.id, this.name, this.status, this.imageUrl});

  factory CharacterEntity.fromModel(CharacterModel model) {
    return CharacterEntity(
      id: model.id,
      name: model.name,
      status: _mapStatus(model.status),
      imageUrl: model.image,
    );
  }

  static CharacterStatus? _mapStatus(String? status) {
    if (status?.toLowerCase() == 'alive') {
      return CharacterStatus.alive;
    } else if (status?.toLowerCase() == 'dead') {
      return CharacterStatus.dead;
    } else {
      return CharacterStatus.unknown;
    }
  }
}
