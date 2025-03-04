import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomSearchMenu<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getItemName;
  final Function(List<T>) onFilteredItemsChanged;
  final String? label;

  const CustomSearchMenu({
    required this.items,
    required this.getItemName,
    required this.onFilteredItemsChanged,
    this.label, 
    Key? key,
  }) : super(key: key);

  @override
  _SearchBarState<T> createState() => _SearchBarState<T>();
}

class _SearchBarState<T> extends State<CustomSearchMenu<T>> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_filterItems);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _controller.text.toLowerCase();
    final filtered = widget.items
        .where((item) => widget.getItemName(item).toLowerCase().contains(query))
        .toList();
    widget.onFilteredItemsChanged(filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label ?? AppLocalizations.of(context)!.search,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}