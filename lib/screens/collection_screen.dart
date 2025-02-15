import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/widgets/card_collection.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:collection/collection.dart';

class CollectionScreen extends StatefulWidget {
  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<PlayerCard> _filteredPlayerCards = [];
  IconData _sortIcon = Icons.sort;

  @override
  void initState() {
    super.initState();
    final user = User();
    _filteredPlayerCards = user.cards;
  }

  void _updateFilteredItems(List<PlayerCard> filteredItems) {
    setState(() {
      _filteredPlayerCards = filteredItems;
    });
  }

  void _sortCards(String criteria) {
    setState(() {
      switch (criteria) {
        case 'team':
          _filteredPlayerCards = _groupAndSortBy(_filteredPlayerCards, (card) => card.team);
          _sortIcon = Icons.group;
          break;
        case 'rareza':
          _filteredPlayerCards.sort((a, b) => b.rareza.index.compareTo(a.rareza.index));
          _sortIcon = Icons.star;
          break;
        case 'position':
          _filteredPlayerCards = _groupAndSortBy(_filteredPlayerCards, (card) => card.position);
          _sortIcon = Icons.sports_soccer;
          break;
      }
    });
  }

  List<PlayerCard> _groupAndSortBy(List<PlayerCard> cards, String Function(PlayerCard) keySelector) {
    final grouped = groupBy(cards, keySelector);
    final sortedKeys = grouped.keys.toList()..sort();
    return sortedKeys.expand((key) => grouped[key]!).toList();
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ordenar',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(
                color: Colors.grey.shade400,
                thickness: 1.0,
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Por equipo'),
                onTap: () {
                  _sortCards('team');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text('Por rareza'),
                onTap: () {
                  _sortCards('rareza');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.sports_soccer),
                title: Text('Por posición'),
                onTap: () {
                  _sortCards('position');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = User();
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Center(
            child: Text(
              'Colección',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: screenSize.height * 0.03,
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/soccer_field.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Panel(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.8,
              content: Column(
                children: [
                  SizedBox(
                    height: screenSize.height * 0.1,
                    child: CustomSearchMenu<PlayerCard>(
                      items: user.cards,
                      getItemName: (playerCard) => '${playerCard.playerName} ${playerCard.playerSurname}',
                      onFilteredItemsChanged: _updateFilteredItems,
                    ),
                  ),
                  Expanded(
                    child: CardCollection(playerCards: _filteredPlayerCards),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: screenSize.height * 0.08,
        height: screenSize.height * 0.08,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryFixed,
              theme.colorScheme.primaryFixedDim
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: _showSortMenu,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(_sortIcon, color: theme.colorScheme.onInverseSurface),
          ),
        ),
      ),
    );
  }
}