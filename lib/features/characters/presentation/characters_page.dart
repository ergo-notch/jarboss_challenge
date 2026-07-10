import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:jarboss_challenge/features/characters/presentation/providers/characters_view_model.dart';
import 'package:jarboss_challenge/features/characters/presentation/widgets/character_tile.dart';
import 'package:jarboss_challenge/features/details/presentation/providers/details_view_model.dart';

class CharactersPage extends ConsumerWidget {
  static const String path = '/characters';
  static const String name = 'characters';

  const CharactersPage({super.key});

  static final List<DropdownMenuItem<CharacterStatus?>> _filterItems = [
    const DropdownMenuItem(value: null, child: Text('Todos')),
    const DropdownMenuItem(value: CharacterStatus.alive, child: Text('Vivo')),
    const DropdownMenuItem(value: CharacterStatus.dead, child: Text('Muerto')),
    const DropdownMenuItem(
      value: CharacterStatus.unknown,
      child: Text('Desconocido'),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginatedListPage<CharacterEntity, CharactersListNotifier>(
      listProvider: charactersViewModelProvider,
      title: 'Personajes',
      searchHintText: 'Buscar por nombre...',
      filterBuilder: (context, state, charactersViewModel) {
        final colorScheme = Theme.of(context).colorScheme;

        return DropdownButton<CharacterStatus?>(
          iconEnabledColor: colorScheme.onSurface,
          isDense: true,
          icon: const Icon(Icons.filter_list),
          iconSize: 16,
          value: charactersViewModel.filterStatus,
          items: _filterItems,
          onChanged: charactersViewModel.filterByStatus,
        );
      },
      buildSuccessSlivers: (context, state, _) {
        return [
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final character = state.items[index];
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
            }, childCount: state.items.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.characterGridCrossAxisCount(context),
              childAspectRatio: 4 / 5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
          ),
        ];
      },
    );
  }
}
