import 'package:flutter/material.dart';
import 'package:jarboss_challenge/core/core.dart';

typedef PaginatedListProvider<T> =
    StateNotifierProvider<PaginatedListViewModel<T>, PaginatedListState<T>>;

class PaginatedListPage<T> extends ConsumerStatefulWidget {
  final PaginatedListProvider<T> listProvider;
  final String title;
  final String searchHintText;
  final Widget Function(
    BuildContext context,
    PaginatedListState<T> state,
    PaginatedListViewModel<T> viewModel,
  )?
  filterBuilder;
  final List<Widget> Function(
    BuildContext context,
    PaginatedListState<T> state,
    VoidCallback fetchMore,
  )
  buildSuccessSlivers;

  const PaginatedListPage({
    super.key,
    required this.listProvider,
    required this.title,
    required this.searchHintText,
    required this.buildSuccessSlivers,
    this.filterBuilder,
  });

  @override
  ConsumerState<PaginatedListPage<T>> createState() =>
      _PaginatedListPageState<T>();
}

class _PaginatedListPageState<T> extends ConsumerState<PaginatedListPage<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _didRequestInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels < position.maxScrollExtent - 50) return;

    _fetchMore();
  }

  void _fetchMore() {
    ref.read(widget.listProvider.notifier).fetchMore();
  }

  Future<void> _refresh() async {
    await ref.read(widget.listProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.listProvider);
    final viewModel = ref.read(widget.listProvider.notifier);

    if (!_didRequestInitialLoad && state.status == FetchStatus.initial) {
      _didRequestInitialLoad = true;
      Future.microtask(viewModel.refresh);
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Icon(Icons.arrow_upward),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
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
                title: Text(widget.title),
                backgroundColor: colorScheme.surfaceContainerLow,
                surfaceTintColor: colorScheme.surfaceTint,
                actions: const [ThemeToggleButton()],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(
                    widget.filterBuilder == null ? 64 : 72,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DebouncedSearchBar(
                            hintText: widget.searchHintText,
                            initialValue: state.searchQuery,
                            onSearch: viewModel.searchByName,
                          ),
                        ),
                        if (widget.filterBuilder != null) ...[
                          const SizedBox(width: 8),
                          widget.filterBuilder!(context, state, viewModel),
                        ],
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
    PaginatedListState<T> state,
  ) {
    if (state.status == FetchStatus.fetching && state.items.isEmpty) {
      return const [
        SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      ];
    }

    if (state.status == FetchStatus.empty) {
      return const [SliverFillRemaining(child: EmptyStateWidget())];
    }

    if (state.status == FetchStatus.error && state.items.isEmpty) {
      return [
        SliverFillRemaining(
          child: RetryWidget(error: state.error!, onRetry: _fetchMore),
        ),
      ];
    }

    return [
      ...widget.buildSuccessSlivers(context, state, _fetchMore),
      if (state.status == FetchStatus.loadingMore)
        const SliverToBoxAdapter(child: LoadingFooterWidget()),
      if (state.error != null && state.items.isNotEmpty)
        SliverToBoxAdapter(
          child: RetryWidget(error: state.error!, onRetry: _fetchMore),
        ),
    ];
  }
}
