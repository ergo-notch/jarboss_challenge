import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarboss_challenge/features/characters/presentation/providers/characters_state.dart';
import 'package:jarboss_challenge/features/characters/presentation/widgets/character_tile.dart';

import '../../../core/core.dart';
import 'providers/characters_view_model.dart';

class CharactersPage extends ConsumerStatefulWidget {
  static const String path = '/characters';
  static const String name = 'characters';

  const CharactersPage({super.key});

  @override
  ConsumerState<CharactersPage> createState() => CharactersPageState();
}

class CharactersPageState extends ConsumerState<CharactersPage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState?.show(); // lanza el refresh al arrancar
      _scrollController.addListener(_onScroll);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      _fetchCharacters();
    }
  }

  void _fetchCharacters() {
    ref.read(charactersViewModelProvider.notifier).fetchCharacters();
  }

  Future<void> _refreshCharacters() async {
    ref.read(charactersViewModelProvider.notifier).refreshCharacters();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersViewModelProvider);

    ref.listen<CharactersState>(charactersViewModelProvider, (previous, next) {
      if (next.status == FetchStatus.success ||
          next.status == FetchStatus.error) {
        _refreshKey.currentState?.deactivate();
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () => _refreshCharacters(),
        child: Stack(
          children: [
            Scrollbar(
              controller: _scrollController,
              thickness: 8,
              radius: const Radius.circular(10),

              thumbVisibility: false,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    expandedHeight: 150,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        AppImages.splashScreen,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  state.status == FetchStatus.error
                      ? SliverToBoxAdapter(
                          child: RetryWidget(
                            errorMessage: 'No results found',
                            onRetry: () => _fetchCharacters(),
                          ),
                        )
                      : SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final character = state.characters[index];
                            return CharacterTile(
                              onSelectCharacter: (character) {
                                context.go(
                                  '/characters/character/${character?.id}',
                                );
                              },
                              character:
                                  character, // Replace with actual character data
                            );
                          }, childCount: state.characters.length),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 4 / 5,
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 2,
                              ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
