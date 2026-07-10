import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarboss_challenge/features/characters/presentation/providers/characters_state.dart';
import 'package:jarboss_challenge/features/characters/presentation/widgets/character_tile.dart';

import '../../../core/core.dart';
import '../../details/presentation/providers/details_view_model.dart';
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

  final List<DropdownMenuItem<CharacterStatus?>> _filterItems = [
    DropdownMenuItem(value: null, child: Text('Todos')),
    DropdownMenuItem(value: CharacterStatus.alive, child: Text('Vivo')),
    DropdownMenuItem(value: CharacterStatus.dead, child: Text('Muerto')),
    DropdownMenuItem(
      value: CharacterStatus.unknown,
      child: Text('Desconocido'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersViewModelProvider);
    final viewModel = ref.read(charactersViewModelProvider.notifier);
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
                backgroundColor: colorScheme.surfaceContainerLow,
                surfaceTintColor: colorScheme.surfaceTint,
                actions: const [ThemeToggleButton()],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DebouncedSearchBar(
                      hintText: 'Buscar por nombre...',
                      initialValue: state.searchQuery,
                            onSearch: (query) => viewModel.searchByName(query),
                          ),
                        ),
                        SizedBox(width: 8),
                        DropdownButton<CharacterStatus?>(
                          iconEnabledColor: colorScheme.onSurface,
                          isDense: true,
                          icon: Icon(Icons.filter_list),
                          iconSize: 16,
                          value: state.filterStatus,
                          items: _filterItems,
                          onChanged: (value) => viewModel.filterByStatus(value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ..._buildContentSlivers(context, state),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(
    BuildContext context,
    CharactersState state,
  ) {
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
              ref.read(detailsViewModelProvider.notifier).clear();
              context.go(
                '/characters/character/${character?.id}',
                extra: character,
              );
            },
            character: character,
          );
        }, childCount: state.characters.length),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.characterGridCrossAxisCount(context),
          childAspectRatio: 4 / 5,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
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
