import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/features/locations/data/models/location_model.dart';

@immutable
class LocationEntity extends Equatable {
  final String? id;
  final String? name;
  final String? type;
  final String? dimension;

  const LocationEntity({this.id, this.name, this.type, this.dimension});

  factory LocationEntity.fromModel(LocationModel model) => LocationEntity(
    id: model.id,
    name: model.name,
    type: model.type,
    dimension: model.dimension,
  );

  @override
  List<Object?> get props => [id, name, type, dimension];
}
