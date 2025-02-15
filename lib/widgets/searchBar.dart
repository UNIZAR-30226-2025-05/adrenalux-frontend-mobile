import 'package:flutter/material.dart';

class CustomSearchMenu<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getItemName;
  final double? listHeight;
  final Function(List<T>) onFilteredItemsChanged;

  const CustomSearchMenu({
    required this.items,
    required this.getItemName,
    required this.onFilteredItemsChanged,
    this.listHeight,
    Key? key,
  }) : super(key: key);

  @override
  _SearchBarState<T> createState() => _SearchBarState<T>();
}

class _SearchBarState<T> extends State<CustomSearchMenu<T>> {
  TextEditingController _controller = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _controller.addListener(_filterItems);
  }

  @override
  void dispose() {
    _controller.removeListener(_filterItems);
    _controller.dispose();
    super.dispose();
  }

  void _filterItems() {
    String query = _controller.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget.getItemName(item).toLowerCase().contains(query))
          .toList();
    });
    widget.onFilteredItemsChanged(_filteredItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Importante!
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Buscar',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Flexible( // Cambiar Expanded por Flexible
          child: Container(
            constraints: BoxConstraints(
              maxHeight: widget.listHeight ?? 200, // Altura máxima configurable
            ),
          ),
        ),
      ],
    );
  }
}