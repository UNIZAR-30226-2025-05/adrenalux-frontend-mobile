import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';

class PlayerCardWidget extends StatefulWidget {
  final PlayerCard playerCard;
  final String size;

  const PlayerCardWidget({
    required this.playerCard,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  _PlayerCardWidgetState createState() => _PlayerCardWidgetState();
}

class _PlayerCardWidgetState extends State<PlayerCardWidget> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(NetworkImage(widget.playerCard.teamLogo), context);
      precacheImage(NetworkImage(widget.playerCard.playerPhoto), context);
    });
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
    final String cardTemplate = widget.playerCard.rareza == Rareza.megaLuxury
        ? 'assets/card_megaluxury.png'
        : 'assets/card_template.png';

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

          Positioned(
            top: 35 * multiplier,
            right: 35 * multiplier,
            child: CachedNetworkImage(
              imageUrl: widget.playerCard.teamLogo,
              width: 30 * multiplier,
              height: 30 * multiplier,
              fadeInDuration: Duration(milliseconds: 1),
              errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
            ),
          ),

          Positioned(
            top: 42.5 * multiplier,
            left: 40 * multiplier,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8 * multiplier),
              child: CachedNetworkImage(
                imageUrl: widget.playerCard.playerPhoto,
                width: 120 * multiplier,
                height: 120 * multiplier,
                fadeInDuration: Duration(milliseconds: 1),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
          Positioned(
            bottom: 40 * multiplier,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatBox(widget.playerCard.shot, Colors.red, multiplier),
                    _buildStatBox(widget.playerCard.control, Colors.blue, multiplier),
                    _buildStatBox(widget.playerCard.defense, Colors.green, multiplier),
                  ],
                ),
                SizedBox(height: 10 * multiplier),
                Center(
                  child: _buildStatBox(widget.playerCard.averageScore.toInt(), const Color.fromARGB(255, 254, 166, 84), multiplier),
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