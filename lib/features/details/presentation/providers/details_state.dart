import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/core/core.dart';

const _unset = Object();

@immutable
class DetailsState extends Equatable {
  final FetchStatus status;
  final DetailsEntity? details;
  final AppException? error;

  const DetailsState({
    this.status = FetchStatus.initial,
    this.details,
    this.error,
  });

  DetailsState copyWith({
    FetchStatus? status,
    DetailsEntity? details,
    Object? error = _unset,
  }) {
    return DetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [status, details, error];
}
