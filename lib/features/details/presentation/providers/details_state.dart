import 'package:jarboss_challenge/core/core.dart';

class DetailsState {
  final FetchStatus status;
  final DetailsEntity? details;
  const DetailsState({this.status = FetchStatus.initial, this.details});

  DetailsState copyWith({FetchStatus? status, DetailsEntity? details}) {
    return DetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
    );
  }
}
