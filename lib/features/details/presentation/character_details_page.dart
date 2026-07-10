import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:jarboss_challenge/features/details/presentation/widgets/episodes_list_widget.dart';

import 'providers/details_view_model.dart';

class CharacterDetailsPage extends ConsumerStatefulWidget {
  static const String path = '/character/:id';
  static const String name = '/character-details';

  final String characterId;
  final CharacterEntity? character;

  const CharacterDetailsPage({
    super.key,
    required this.characterId,
    this.character,
  });

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

  String? get _imageUrl =>
      widget.character?.imageUrl ??
      ref.watch(detailsViewModelProvider).details?.imageUrl;

  String get _displayName =>
      ref.watch(detailsViewModelProvider).details?.name ??
      widget.character?.name ??
      '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detailsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            leading: IconButton(
              iconSize: 40,
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            actions: const [ThemeToggleButton()],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final statusBar = MediaQuery.paddingOf(context).top;
                const expandedHeight = 320.0;
                final collapsedHeight = kToolbarHeight + statusBar;
                final expandRatio =
                    ((height - collapsedHeight) /
                            (expandedHeight - collapsedHeight))
                        .clamp(0.0, 1.0);
                final titleColor = Color.lerp(
                  colorScheme.onSurface,
                  colorScheme.onPrimary,
                  expandRatio,
                )!;

                return FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(
                    left: 56,
                    right: 56,
                    bottom: 16 * expandRatio + 8 * (1 - expandRatio),
                  ),
                  title: Text(
                    _displayName,
                    maxLines: expandRatio > 0.5 ? 2 : 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                      shadows: expandRatio > 0.3
                          ? const [Shadow(blurRadius: 8, color: Colors.black54)]
                          : null,
                    ),
                  ),
                  background: _CharacterHeaderImage(
                    heroTag: widget.characterId,
                    imageUrl: _imageUrl,
                    status: state.details?.status,
                  ),
                );
              },
            ),
          ),
          if (state.status == FetchStatus.fetching && state.details == null)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.status == FetchStatus.error && state.details == null)
            SliverFillRemaining(
              child: RetryWidget(
                errorMessage: 'Error al cargar el personaje',
                onRetry: loadCharacterDetails,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          label: 'Estado',
                          value: (state.details?.status?.value ?? '')
                              .toUpperCase(),
                          valueColor: switch (state.details?.status) {
                            CharacterStatus.alive => Colors.green,
                            CharacterStatus.dead => Colors.red,
                            _ => null,
                          },
                        ),
                        _DetailRow(
                          label: 'Especie',
                          value: state.details?.species ?? '',
                        ),
                        _DetailRow(
                          label: 'Tipo',
                          value: state.details?.type ?? '',
                        ),
                        _DetailRow(
                          label: 'Origen',
                          value: state.details?.origin ?? '',
                        ),
                        _DetailRow(
                          label: 'Ubicación',
                          value: state.details?.location ?? '',
                        ),
                        if (state.details?.episodes != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Episodios (${state.details!.episodes!.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          EpisodesListWidget(
                            episodes: state.details?.episodes ?? [],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CharacterHeaderImage extends StatelessWidget {
  final String heroTag;
  final String? imageUrl;
  final CharacterStatus? status;

  const _CharacterHeaderImage({
    required this.heroTag,
    this.imageUrl,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      transitionOnUserGestures: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Colors.black12),
            )
          else
            const ColoredBox(color: Colors.black12),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (status == CharacterStatus.dead
                          ? Colors.red
                          : status == CharacterStatus.alive
                          ? Colors.green
                          : Colors.white)
                      .withValues(alpha: 0.8),
                  (status == CharacterStatus.dead
                          ? Colors.red
                          : status == CharacterStatus.alive
                          ? Colors.green
                          : Colors.white)
                      .withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
