import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';

Map<String, String> tiposCarta = {
  CARTA_NORMAL: 'assets/card_template.png',
  CARTA_LUXURY: 'assets/card_luxury.png',
  CARTA_MEGALUXURY: 'assets/card_megaluxury.png',
  CARTA_LUXURYXI: 'assets/card_luxuryxi.png',
};

class PlayerCardWidget extends StatefulWidget {
  final PlayerCard playerCard;
  final String size;
  final ImageProvider? playerPhotoImage;
  final ImageProvider? teamLogoImage;     
  const PlayerCardWidget({
    Key? key,
    required this.playerCard,
    required this.size,
    this.playerPhotoImage,
    this.teamLogoImage,
  }) : super(key: key);

  @override
  _PlayerCardWidgetState createState() => _PlayerCardWidgetState();
}

class _PlayerCardWidgetState extends State<PlayerCardWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.playerCard.amount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        precacheImage(NetworkImage(widget.playerCard.teamLogo), context);
        precacheImage(NetworkImage(widget.playerCard.playerPhoto), context);
      });
    }
  }

  double _getMultiplier() {
    switch (widget.size) {
      case 'sm':
        return 0.5;
      case 'lg':
        return 1.8;
      case 'md':
      default:
        return 1.2;
    }
  }

 @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    final double multiplier = _getMultiplier() * screenSize.width / 375;
    final String cardTemplate = tiposCarta[widget.playerCard.rareza] ?? 'assets/card_template.png';
    final bool isLocked = widget.playerCard.amount == 0;

    return Container(
      width: 200 * multiplier,
      height: 300 * multiplier,
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            cardTemplate,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (isLocked)
            Positioned.fromRelativeRect(
              rect: RelativeRect.fromLTRB(
                screenSize.width * 0.035,
                screenSize.height * 0.025,
                screenSize.width * 0.05,
                screenSize.height * 0.040,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          if (!isLocked)
            Positioned(
              top: 35 * multiplier,
              right: 35 * multiplier,
              child: Image(
                image: widget.teamLogoImage ??
                    NetworkImage(widget.playerCard.teamLogo),
                width: 30 * multiplier,
                height: 30 * multiplier,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.error, color: Colors.red),
              ),
            ),
          if (!isLocked)
            Positioned(
              top: 42.5 * multiplier,
              left: 40 * multiplier,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8 * multiplier),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply),
                  child: Image(
                    image: widget.playerPhotoImage ??
                        NetworkImage(widget.playerCard.playerPhoto),
                    width: 120 * multiplier,
                    height: 120 * multiplier,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          if (isLocked)
            Positioned(
              top: 90 * multiplier,
              left: 75 * multiplier,
              child: Icon(
                Icons.lock,
                size: 40 * multiplier,
                color: Colors.white,
              ),
            ),
          Positioned(
            bottom: (isLocked ? 90 : 40) * multiplier,
            left: 30 * multiplier,
            right: 30 * multiplier,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.playerCard.playerSurname}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * multiplier,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10 * multiplier),
                if (!isLocked)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatBox(widget.playerCard.shot, Colors.red, multiplier),
                      _buildStatBox(widget.playerCard.control, Colors.blue, multiplier),
                      _buildStatBox(widget.playerCard.defense, Colors.green, multiplier),
                    ],
                  ),
                SizedBox(height: 10 * multiplier),
                if (!isLocked)
                  Center(
                    child: _buildStatBox(widget.playerCard.averageScore.toInt(),
                        const Color.fromARGB(255, 254, 166, 84), multiplier),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatBox(int value, Color color, double multiplier) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * multiplier, vertical: 3 * multiplier),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4 * multiplier),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12 * multiplier,
        ),
      ),
    );
  }
}
