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
  late List<PlayerCardWidget> sortedCards;

  @override
  void initState() {
    super.initState();
    _prepareCards();
  }

  @override
  void didUpdateWidget(CardCollection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerCardWidgets != widget.playerCardWidgets) {
      _prepareCards();
    }
  }

  void _prepareCards() {
    final availableCards = widget.playerCardWidgets.where(
      (card) => card.playerCard.amount > 0
    ).toList();

    final lockedCards = widget.playerCardWidgets.where(
      (card) => card.playerCard.amount <= 0
    ).toList();

    setState(() {
      sortedCards = [...availableCards, ...lockedCards];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    final double cardWidth = (screenSize.width - 48) / 3;
    final double cardHeight = cardWidth * 1.47;

    return sortedCards.isEmpty
  ? Center(
      child: Text(
        "No hay cartas disponibles",
        style: TextStyle(
          fontSize: screenSize.height * 0.02,
          color: Colors.grey,
        ),
      ),
    )
  : GridView.builder(
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
        final isLocked = cardWidget.playerCard.amount <= 0;

        return Opacity(
          opacity: isLocked ? 0.5 : 1.0,
          child: IgnorePointer(
            ignoring: isLocked,
            child: GestureDetector(
              onTap: () => widget.onCardTap(cardWidget.playerCard),
              child: Stack(
                children: [
                  cardWidget,
                  if (isLocked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: screenSize.width * 0.08,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}