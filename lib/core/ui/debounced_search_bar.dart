import 'dart:async';

import 'package:flutter/material.dart';

class DebouncedSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final Duration debounceDuration;
  final String hintText;
  final String? initialValue;

  const DebouncedSearchBar({
    super.key,
    required this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 400),
    this.hintText = 'Buscar...',
    this.initialValue,
  });

  @override
  State<DebouncedSearchBar> createState() => _DebouncedSearchBarState();
}

class _DebouncedSearchBarState extends State<DebouncedSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearch(value.trim());
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {});
    _debounce?.cancel();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SearchBar(
      controller: _controller,
      hintText: widget.hintText,
      leading: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
      trailing: [
        if (_controller.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
            onPressed: _clear,
          ),
      ],
      onChanged: _onTextChanged,
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(colorScheme.surface),
      side: WidgetStateProperty.all(
        BorderSide(color: colorScheme.outlineVariant),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
