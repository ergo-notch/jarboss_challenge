import 'package:jarboss_challenge/features/details/domain/use_cases/get_character_details_use_case.dart';
import 'package:jarboss_challenge/features/details/presentation/providers/details_state.dart';

import '../../../../core/core.dart';

final detailsViewModelProvider =
    StateNotifierProvider<DetailsViewModel, DetailsState>(
      (ref) => DetailsViewModel(
        getCharacterDetailsUseCase: ref.read(
          getCharacterDetailsUseCaseProvider,
        ),
      ),
    );

class DetailsViewModel extends StateNotifier<DetailsState> {
  final GetCharacterDetailsUseCase getCharacterDetailsUseCase;

  DetailsViewModel({required this.getCharacterDetailsUseCase})
    : super(const DetailsState());

  void clear() {
    state = const DetailsState();
  }

  Future<void> getCharacterDetails({String? characterId}) async {
    state = const DetailsState(status: FetchStatus.fetching);
    final result = await getCharacterDetailsUseCase(characterId);
    result.fold(
      (error) => state = state.copyWith(status: FetchStatus.error),
      (details) =>
          state = state.copyWith(status: FetchStatus.success, details: details),
    );
  }
}
