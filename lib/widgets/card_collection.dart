import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';

class CardCollection extends StatefulWidget {
  final List<PlayerCardWidget> playerCardWidgets;
  final Function(PlayerCard) onCardTap;

  const CardCollection({
    required this.playerCardWidgets,
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
  late final List<PlayerCardWidget> sortedCards;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepareCards();
  }

  void _prepareCards() {
    List<PlayerCardWidget> availableCards = [];
    List<PlayerCardWidget> lockedCards = [];

    for (var cardWidget in widget.playerCardWidgets) {
      if (cardWidget.playerCard.amount > 0) {
        availableCards.add(cardWidget);
      } else {
        lockedCards.add(cardWidget);
      }
    }
    sortedCards = [...availableCards, ...lockedCards];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    final double cardWidth = (screenSize.width - 48) / 3;
    final double cardHeight = cardWidth * 1.47;

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: cardWidth / cardHeight,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: sortedCards.length,
      itemBuilder: (context, index) {
        final cardWidget = sortedCards[index];
        return GestureDetector(
          onTap: () {
            if (cardWidget.playerCard.amount > 0) {
              widget.onCardTap(cardWidget.playerCard);
            }
          },
          child: cardWidget,
        );
      },
    );
  }
}
