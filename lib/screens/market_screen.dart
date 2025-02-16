import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
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
    final user = User();
    _filteredPlayerCards = user.cards;
  }

  void _updateFilteredItems(List<PlayerCard> filteredItems) {
    setState(() {
      _filteredPlayerCards = filteredItems;
    });
  }

  void _onCardTap(PlayerCard playerCard) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Provider.of<ThemeProvider>(context).currentTheme;
        final screenSize = ScreenSize.of(context);
        return AlertDialog(
          content: Container(
            width: screenSize.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Wrap(  
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '¿Quieres comprar esta carta por ',
                      style: TextStyle(
                        fontSize: screenSize.height * 0.015,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,  
                    ),
                    Text(
                      '${playerCard.price}',
                      style: TextStyle(
                        fontSize: screenSize.height * 0.015,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      softWrap: true,
                    ),
                    SizedBox(width: screenSize.width * 0.005),
                    Image.asset(
                      'assets/moneda.png',
                      width: screenSize.height * 0.025,
                      height: screenSize.height * 0.025,
                    ),
                    Text(
                      '?',
                      style: TextStyle(
                        fontSize: screenSize.height * 0.015,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
                Divider(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  thickness: 1.0,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Llamada al backend para comprar la carta
                          showCustomSnackBar(
                            context, 
                            SnackBarType.success, 
                            "Carta añadida a tu colección", 
                            3);

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: Size(screenSize.width * 0.3, screenSize.height * 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Aceptar',
                          style: TextStyle(
                            fontSize: screenSize.height * 0.02,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color.fromARGB(255, 233, 103, 94), const Color.fromARGB(255, 167, 11, 0)],
                          begin: Alignment.topLeft,
                          stops: [0.0, 1.0],
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: Size(screenSize.width * 0.3, screenSize.height * 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: screenSize.height * 0.02,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                      items: user.cards,
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