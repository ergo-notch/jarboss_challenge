import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class CharacterModel extends Equatable {
  final String? id;
  final String? name;
  final String? status;
  final String? species;
  final String? image;

  const CharacterModel({
    this.id,
    this.name,
    this.status,
    this.species,
    this.image,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
    id: json['id']?.toString(),
    name: json['name'] as String?,
    status: json['status'] as String?,
    species: json['species'] as String?,
    image: json['image'] as String?,
  );

  @override
  List<Object?> get props => [id, name, status, species, image];
}
