import 'package:flutter/material.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:jarboss_challenge/features/details/presentation/widgets/episodes_list_widget.dart';

import 'providers/details_view_model.dart';

class CharacterDetailsPage extends ConsumerStatefulWidget {
  static const String path = '/character/:id';
  static const String name = '/character-details';

  final String characterId;

  const CharacterDetailsPage({super.key, required this.characterId});

  @override
  ConsumerState<CharacterDetailsPage> createState() =>
      CharacterDetailsPageState();
}

class CharacterDetailsPageState extends ConsumerState<CharacterDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadCharacterDetails());
  }

  void loadCharacterDetails() {
    ref
        .read(detailsViewModelProvider.notifier)
        .getCharacterDetails(characterId: widget.characterId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detailsViewModelProvider);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            centerTitle: true,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: Colors.yellowAccent,
                size: 40,
              ),
            ),
            title: Text(
              maxLines: 2,
              state.status == FetchStatus.success
                  ? state.details?.name ?? ''
                  : 'Loading...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.yellowAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: state.status == FetchStatus.error
              ? RetryWidget(
                  errorMessage: 'Try again',
                  onRetry: () => loadCharacterDetails(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        spacing: 16,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 350,
                              child: Card(
                                surfaceTintColor: Colors.transparent,
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Colors.deepPurple,
                                    width: 2,
                                  ),
                                ),
                                elevation: 4,
                                shadowColor: Colors.deepPurple,
                                child: Hero(
                                  tag: widget.characterId,
                                  transitionOnUserGestures: true,

                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      height: double.infinity,
                                      width: double.infinity,
                                      state.details?.imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.error),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Origin: ${state.details?.origin ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Location: ${state.details?.location ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Status: ${state.details?.status ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Species: ${state.details?.species ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      EpisodesListWidget(
                        episodes: state.details?.episodes ?? [],
                      ),
                    ],
                  ),
                ),
        ),
        if (state.status == FetchStatus.fetching)
          Container(
            color: Colors.black.withOpacity(0.5),
            height: double.infinity,
            width: double.infinity,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
