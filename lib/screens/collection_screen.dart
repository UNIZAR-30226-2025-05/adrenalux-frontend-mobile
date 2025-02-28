import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/screens/focusCard_screen.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card_collection.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollectionScreen extends StatefulWidget {
  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<PlayerCard> _playerCards = [];
  // Esta lista contendrá el resultado filtrado sin aplicar orden.
  List<PlayerCard> _unsortedFilteredPlayerCards = [];
  // Esta lista es la que se muestra, ya ordenada (o no, según _currentSortCriteria).
  List<PlayerCard> _filteredPlayerCards = [];
  
  IconData _sortIcon = Icons.sort;
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentSortCriteria; // Criterio de orden actual

  @override
  void initState() {
    super.initState();
    _loadPlayerCards();
  }

  void _loadPlayerCards() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      List<PlayerCard> collection = await getCollection();
      if (!mounted) return;
      setState(() {
        _playerCards = collection;
        // Inicialmente, el filtrado sin ordenar es igual a la colección completa.
        _unsortedFilteredPlayerCards = List.from(collection);
        _filteredPlayerCards = List.from(collection);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.err_user_data;
        _isLoading = false;
      });
    }
  }

  void _onCardTap(PlayerCard playerCard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FocusCardScreen(playerCard: playerCard),
      ),
    );
  }

  /// Ordena la lista [items] según el criterio especificado.
  List<PlayerCard> _getSortedItems(List<PlayerCard> items, String criteria) {
    List<PlayerCard> sortedList = List.from(items);
    switch (criteria) {
      case 'team':
        sortedList.sort((a, b) => a.team.compareTo(b.team));
        break;
      case 'rareza':
        // Por ejemplo, usando averageScore como criterio de rareza
        sortedList.sort((a, b) => b.averageScore.compareTo(a.averageScore));
        break;
      case 'position':
        sortedList.sort((a, b) => b.position.compareTo(a.position));
        break;
      default:
        break;
    }
    return sortedList;
  }

  /// Actualiza la lista filtrada. Guarda en _unsortedFilteredPlayerCards el resultado sin ordenar.
  void _updateFilteredItems(List<PlayerCard> filteredItems) {
    _unsortedFilteredPlayerCards = List.from(filteredItems);
    List<PlayerCard> updatedList = _currentSortCriteria != null
        ? _getSortedItems(filteredItems, _currentSortCriteria!)
        : filteredItems;
    setState(() {
      _filteredPlayerCards = updatedList;
    });
  }

  /// Si se selecciona el mismo criterio, se "desordena" volviendo al orden original filtrado.
  void _sortCards(String criteria) {
    if (_currentSortCriteria == criteria) {
      // Se presionó el mismo criterio: se borra el orden y se restaura el orden original.
      setState(() {
        _currentSortCriteria = null;
        _sortIcon = Icons.sort;
        _filteredPlayerCards = List.from(_unsortedFilteredPlayerCards);
      });
    } else {
      setState(() {
        _currentSortCriteria = criteria;
        switch (criteria) {
          case 'team':
            _sortIcon = Icons.group;
            break;
          case 'rareza':
            _sortIcon = Icons.star;
            break;
          case 'position':
            _sortIcon = Icons.sports_soccer;
            break;
        }
        _filteredPlayerCards = _getSortedItems(_unsortedFilteredPlayerCards, criteria);
      });
    }
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
                AppLocalizations.of(context)!.order,
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
                title: Text(AppLocalizations.of(context)!.order_by_team),
                onTap: () {
                  _sortCards('team');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text(AppLocalizations.of(context)!.order_by_rarity),
                onTap: () {
                  _sortCards('rareza');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.sports_soccer),
                title: Text(AppLocalizations.of(context)!.order_by_position),
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
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.collection,
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 18,
                ),
              ),
            )
          else
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
                        items: _playerCards,
                        getItemName: (playerCard) =>
                            '${playerCard.playerName} ${playerCard.playerSurname}',
                        onFilteredItemsChanged: _updateFilteredItems,
                      ),
                    ),
                    Expanded(
                      child: _filteredPlayerCards.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.err_no_packs,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : CardCollection(
                              playerCards: _filteredPlayerCards,
                              onCardTap: _onCardTap,
                              key: ValueKey(
                                  "${_currentSortCriteria}_${_filteredPlayerCards.length}"),
                            ),
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
