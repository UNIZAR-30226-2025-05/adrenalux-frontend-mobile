import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card_collection.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExchangeScreen extends StatefulWidget {
  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  List<PlayerCard> _filteredPlayerCards = [];
  List<PlayerCard> _playerCards = [];
  List<PlayerCardWidget> _filteredPlayerCardWidgets = [];

  bool _isConfirmed = false;
  PlayerCard? _selectedUserCard;
  PlayerCard? _selectedOpponentCard;
  bool _isExchangeActive = false;

  @override
  void initState() {
    super.initState();
    _loadPlayerCards();
  }

  void _loadPlayerCards() async {
    _playerCards = await getCollection();
    _filteredPlayerCards = _playerCards;
    _filteredPlayerCards.forEach((card) => _filteredPlayerCardWidgets.add(
      PlayerCardWidget(
        playerCard: card,
        size: "sm",
      ),
    ));

    setState(() {}); 
  }

  void _handleExchange() {
    setState(() {
      _isConfirmed = !_isConfirmed;
      _isExchangeActive = _isConfirmed;
    });
  }

  void _updateFilteredItems(List<PlayerCard> filteredItems) {
    setState(() {
      _filteredPlayerCards = filteredItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false, 
          backgroundColor: theme.colorScheme.surface,
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.exchange,
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
          Positioned(
            top: screenSize.height * 0.05,
            left: screenSize.width * 0.05,
            right: screenSize.width * 0.05,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlayerCardWidget(
                          playerCard: _selectedUserCard ?? _playerCards.first,
                          size: "sm",
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.you,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.height * 0.018,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.swap_horiz, color: Colors.white, size: 30),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlayerCardWidget(
                          playerCard: _selectedOpponentCard ?? _playerCards.last,
                          size: "sm",
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Jugador2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.height * 0.018,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.02),
                ElevatedButton(
                  onPressed: _handleExchange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConfirmed 
                        ? Colors.red 
                        : theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.1,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _isConfirmed ? AppLocalizations.of(context)!.cancel_exchange : AppLocalizations.of(context)!.confirm_exchange,
                    style: TextStyle(
                      fontSize: screenSize.height * 0.018,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenSize.height * 0.45,
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
            ),
            child: Panel(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.5,
              content: Stack(
                children: [
                  Column(
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
                        child: CardCollection(
                          playerCardWidgets: _filteredPlayerCardWidgets,
                          onCardTap: _isExchangeActive
                              ? (card) {}
                              : (card) => setState(() => _selectedUserCard = card),
                        ),
                      ),
                    ],
                  ),
                  if (_isExchangeActive)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.block,
                                color: Colors.white60,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context)!.cant_select,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}