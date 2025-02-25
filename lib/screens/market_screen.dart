import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card_collection.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:intl/intl.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<PlayerCard> _filteredPlayerCards = [];
  List<PlayerCard> _playerCards = [];

  final List<PlayerCard> _cracksDelDia = [
    PlayerCard(
      playerName: 'Lionel',
      playerSurname: 'Messi',
      team: 'Paris Saint-Germain',
      shot: 95,
      control: 98,
      defense: 40,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.megaLuxury,
      averageScore: 97.5,
      playerPhoto: 'assets/mock_player.png',
      position: 'Delantero',
      price: 50000.0,
    ),
    PlayerCard(
      playerName: 'Cristiano',
      playerSurname: 'Ronaldo',
      team: 'Juventus',
      shot: 94,
      control: 90,
      defense: 35,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.megaLuxury,
      averageScore: 95.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Delantero',
      price: 500000.0,
    ),
    PlayerCard(
      playerName: 'Neymar',
      playerSurname: 'Jr.',
      team: 'Paris Saint-Germain',
      shot: 92,
      control: 95,
      defense: 30,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.megaLuxury,
      averageScore: 94.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Delantero',
      price: 500000.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMarketCards();
  }

   
  void _loadMarketCards() async {
    _playerCards = await getCollection();
    _filteredPlayerCards = _playerCards;
    setState(() {}); 
  }


  void _updateFilteredItems(List<PlayerCard> filteredItems) {
    setState(() {
      _filteredPlayerCards = filteredItems;
    });
  }

  void _onCardTap(PlayerCard playerCard) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);
    
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: SizedBox(
            width: double.maxFinite,
            child: Text(
              '¿Quieres comprar esta carta por',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenSize.height * 0.022,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          content: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormat("#,##0", "es_ES").format(playerCard.price),
                  style: TextStyle(
                    fontSize: screenSize.height * 0.024,
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Image.asset(
                  'assets/moneda.png',
                  width: screenSize.height * 0.028,
                  height: screenSize.height * 0.028,
                ),
                Text(
                  '?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.height * 0.022,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(top: screenSize.height * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05, vertical: screenSize.height * 0.015),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: screenSize.height * 0.018,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.03), 
                  ElevatedButton(
                    onPressed: () {
                      // Llamada al backend para comprar la carta
                      showCustomSnackBar(
                        context, 
                        SnackBarType.success, 
                        "Carta añadida a tu colección", 
                        3
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05, vertical: screenSize.height * 0.015),
                    ),
                    child: Text(
                      'Aceptar',
                      style: TextStyle(
                        fontSize: screenSize.height * 0.018,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false, 
          backgroundColor: theme.colorScheme.surface,
          title: Center(
            child: Text(
              'Mercado',
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
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    'Cracks del día',
                    style: TextStyle(
                      fontSize: screenSize.height * 0.03,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: screenSize.height * 0.01),
                    child: Divider(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                      thickness: 1.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _cracksDelDia.map((playerCard) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => _onCardTap(playerCard),
                            child: PlayerCardWidget(playerCard: playerCard, size: "sm"),
                          ),
                          SizedBox(height: screenSize.height * 0.0005),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${NumberFormat.decimalPattern().format(playerCard.price)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.inverseSurface,
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.005),
                              Image.asset(
                                'assets/moneda.png',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: screenSize.height * 0.01),
                    child: Divider(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                      thickness: 1.0,
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * 0.1,
                    child: CustomSearchMenu<PlayerCard>(
                      items: _playerCards,
                      getItemName: (playerCard) => '${playerCard.playerName} ${playerCard.playerSurname}',
                      onFilteredItemsChanged: _updateFilteredItems,
                    ),
                  ),
                  Expanded(
                    child: CardCollection(
                      playerCards: _filteredPlayerCards,
                      onCardTap: _onCardTap,
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