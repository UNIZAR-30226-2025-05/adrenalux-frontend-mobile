import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';

class CardCollection extends StatefulWidget {
  final List<PlayerCard> playerCards;
  final Function(PlayerCard) onCardTap;

  const CardCollection({
    required this.playerCards,
    this.onCardTap = _defaultOnCardTap,
    Key? key,
  }) : super(key: key);

  static void _defaultOnCardTap(PlayerCard playerCard) {
    // Función vacía por defecto
  }

  @override
  _CardCollectionState createState() => _CardCollectionState();
}

class _CardCollectionState extends State<CardCollection> {
  late Future<List<Widget>> _preloadedCards;

  @override
  void initState() {
    super.initState();
    _preloadedCards = _loadAllCardImagesAndBuildWidgets();
  }

  Future<List<Widget>> _loadAllCardImagesAndBuildWidgets() async {
    List<Widget> cardWidgets = [];
    for (var card in widget.playerCards) {
      final image = NetworkImage(card.playerPhoto);
      final logo = NetworkImage(card.teamLogo);
      await precacheImage(image, context);
      await precacheImage(logo, context);
      
      cardWidgets.add(
        GestureDetector(
          onTap: () {
            if (card.amount > 0) {
              widget.onCardTap(card);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: PlayerCardWidget(
              playerCard: card,
              size: "sm",
            ),
          ),
        ),
      );
    }
    return cardWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    final double cardWidth = (screenSize.width - 48) / 3;
    final double cardHeight = cardWidth * 1.5;
    final int cardsPerRow = 3;

    return FutureBuilder<List<Widget>>(
      future: _preloadedCards,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }
        final cardWidgets = snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            children: List.generate(
              (cardWidgets.length / cardsPerRow).ceil(),
              (rowIndex) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    cardsPerRow,
                    (colIndex) {
                      int cardIndex = rowIndex * cardsPerRow + colIndex;
                      if (cardIndex < cardWidgets.length) {
                        return cardWidgets[cardIndex];
                      } else {
                        return SizedBox(width: cardWidth, height: cardHeight);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
