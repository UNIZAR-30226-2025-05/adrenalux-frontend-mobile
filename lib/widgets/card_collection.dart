import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/screens/focusCard_screen.dart';

class CardCollection extends StatelessWidget {
  final List<PlayerCard> playerCards;

  const CardCollection({
    required this.playerCards,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    final double cardWidth = (screenSize.width - 48) / 3; 
    final double cardHeight = cardWidth * 1.5; 
    final int cardsPerRow = 3;

    List<Widget> rows = [];

    for (int i = 0; i < playerCards.length; i += cardsPerRow) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < cardsPerRow; j++) {
        if (i + j < playerCards.length) {
          rowChildren.add(
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FocusCardScreen(playerCard: playerCards[i + j]),
                  ),
                );
              },
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: PlayerCardWidget(playerCard: playerCards[i + j], size: "sm"),
                ),
              ),
            ),
          );
        } else {
          rowChildren.add(SizedBox(width: cardWidth, height: cardHeight));
        }
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: rows,
      ),
    );
  }
}