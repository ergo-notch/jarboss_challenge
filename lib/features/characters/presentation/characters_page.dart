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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersViewModelProvider.notifier).refreshCharacters();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 50) {
      _fetchCharacters();
    }
  }

  void _fetchCharacters() {
    ref.read(charactersViewModelProvider.notifier).fetchCharacters();
  }

  Future<void> _refreshCharacters() async {
    await ref.read(charactersViewModelProvider.notifier).refreshCharacters();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: RefreshIndicator(
        onRefresh: _refreshCharacters,
        child: Scrollbar(
          controller: _scrollController,
          thickness: 8,
          radius: const Radius.circular(10),
          thumbVisibility: false,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 1,
                backgroundColor: colorScheme.surfaceContainerLow,
                surfaceTintColor: colorScheme.surfaceTint,
                actions: [
                  Text('Light Theme'),
                  Switch(value: true, onChanged: (value) {}),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: DebouncedSearchBar(
                      hintText: 'Buscar por nombre...',
                      initialValue: state.searchQuery,
                      onSearch: (query) => ref
                          .read(charactersViewModelProvider.notifier)
                          .searchByName(query),
                    ),
                  ),
                ),
              ),
              ..._buildContentSlivers(state),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(CharactersState state) {
    if (state.status == FetchStatus.fetching && state.characters.isEmpty) {
      return const [
        SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state.status == FetchStatus.empty) {
      return const [SliverFillRemaining(child: EmptyStateWidget())];
    }

    if (state.status == FetchStatus.error && state.characters.isEmpty) {
      return [
        SliverFillRemaining(
          child: RetryWidget(
            errorMessage: state.errorMessage ?? 'Error al cargar personajes',
            onRetry: _fetchCharacters,
          ),
        ),
      ];
    }

    return [
      SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final character = state.characters[index];
          return CharacterTile(
            onSelectCharacter: (character) {
              context.go(
                '/characters/character/${character?.id}',
                extra: character,
              );
            },
            character: character,
          );
        }, childCount: state.characters.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 4 / 5,
          mainAxisSpacing: 0,
          crossAxisSpacing: 2,
        ),
      ),
      if (state.status == FetchStatus.loadingMore)
        const SliverToBoxAdapter(child: LoadingFooterWidget()),
      if (state.errorMessage != null && state.characters.isNotEmpty)
        SliverToBoxAdapter(
          child: RetryWidget(
            errorMessage: state.errorMessage!,
            onRetry: _fetchCharacters,
          ),
        ),
    ];
  }
}
