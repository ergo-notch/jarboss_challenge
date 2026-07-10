import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/features/characters/data/models/character_model.dart';

enum CharacterStatus {
  alive('alive'),
  dead('dead'),
  unknown('unknown');

  final String value;

  const CharacterStatus(this.value);

  String get apiFilterValue => value;

  @override
  String toString() => value;
}

@immutable
class CharacterEntity extends Equatable {
  final String? id;
  final String? name;
  final CharacterStatus? status;
  final String? species;
  final String? imageUrl;

  const CharacterEntity({
    this.id,
    this.name,
    this.status,
    this.species,
    this.imageUrl,
  });

  factory CharacterEntity.fromModel(CharacterModel model) {
    return CharacterEntity(
      id: model.id,
      name: model.name,
      status: _mapStatus(model.status),
      species: model.species,
      imageUrl: model.image,
    );
  }

  static CharacterStatus? _mapStatus(String? status) {
    return switch (status?.toLowerCase()) {
      'alive' => CharacterStatus.alive,
      'dead' => CharacterStatus.dead,
      _ => CharacterStatus.unknown,
    };
  }

  @override
  List<Object?> get props => [id, name, status, species, imageUrl];
}
