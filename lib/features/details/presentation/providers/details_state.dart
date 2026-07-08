import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/core/core.dart';

@immutable
class DetailsState extends Equatable {
  final FetchStatus status;
  final DetailsEntity? details;
  
  const DetailsState({this.status = FetchStatus.initial, this.details});

  DetailsState copyWith({FetchStatus? status, DetailsEntity? details}) {
    return DetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => [status, details];
}
