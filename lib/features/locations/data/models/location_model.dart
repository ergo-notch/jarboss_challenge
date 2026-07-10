import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class LocationModel extends Equatable {
  final String? id;
  final String? name;
  final String? type;
  final String? dimension;

  const LocationModel({this.id, this.name, this.type, this.dimension});

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json['id']?.toString(),
    name: json['name'] as String?,
    type: json['type'] as String?,
    dimension: json['dimension'] as String?,
  );

  @override
  List<Object?> get props => [id, name, type, dimension];
}
