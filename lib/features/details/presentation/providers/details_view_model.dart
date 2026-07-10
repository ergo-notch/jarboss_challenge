import 'package:jarboss_challenge/features/details/domain/use_cases/get_character_details_use_case.dart';
import 'package:jarboss_challenge/features/details/presentation/providers/details_state.dart';

import '../../../../core/core.dart';

final detailsViewModelProvider =
    NotifierProvider<DetailsViewModel, DetailsState>(DetailsViewModel.new);

class DetailsViewModel extends Notifier<DetailsState> {
  late final GetCharacterDetailsUseCase _getCharacterDetailsUseCase;

  @override
  DetailsState build() {
    _getCharacterDetailsUseCase = ref.read(getCharacterDetailsUseCaseProvider);
    return const DetailsState();
  }

  void clear() {
    state = const DetailsState();
  }

  Future<void> getCharacterDetails({String? characterId}) async {
    state = const DetailsState(status: FetchStatus.fetching);
    final result = await _getCharacterDetailsUseCase(characterId);
    result.fold(
      (error) => state = state.copyWith(
        status: FetchStatus.error,
        error: error,
      ),
      (details) => state = state.copyWith(
        status: FetchStatus.success,
        details: details,
        error: null,
      ),
    );
  }
}
