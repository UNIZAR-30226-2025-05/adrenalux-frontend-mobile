import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter/material.dart';

enum Rareza { normal, luxury, megaLuxury, luxuryXI }

class PlayerCard extends StatelessWidget {
  final String playerName;
  final String playerSurname;
  final int shot;
  final int control;
  final int defense;
  final String teamLogo;
  final Rareza rareza;
  final double averageScore;
  final String playerPhoto;
  final String size;

  const PlayerCard({
    required this.playerName,
    required this.playerSurname,
    required this.shot,
    required this.control,
    required this.defense,
    required this.rareza,
    required this.teamLogo,
    required this.averageScore,
    required this.playerPhoto,
    this.size = 'md',
    Key? key,
  }) : super(key: key);

  double _getMultiplier() {
    
    switch (size) {
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

    return Container(
      width: 200 * multiplier,
      height: 300 * multiplier,
      child: Stack(
        children: [
          Image.asset(
            'assets/card_template.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: 25 * multiplier,
            right: 25 * multiplier,
            child: Image.asset(
              teamLogo,
              width: 40 * multiplier,
              height: 40 * multiplier,
            ),
          ),
          Positioned(
            top: 63 * multiplier,
            left: 50 * multiplier,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8 * multiplier),
              child: Image.asset(
                playerPhoto,
                width: 100 * multiplier,
                height: 100 * multiplier,
                fit: BoxFit.cover,
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
                  '$playerName $playerSurname',
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
                    _buildStatBox(shot, Colors.red, multiplier),
                    _buildStatBox(control, Colors.blue, multiplier),
                    _buildStatBox(defense, Colors.green, multiplier),
                  ],
                ),
                SizedBox(height: 10 * multiplier),
                Center(
                  child: _buildStatBox(averageScore.toInt(), const Color.fromARGB(255, 254, 166, 84), multiplier),
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