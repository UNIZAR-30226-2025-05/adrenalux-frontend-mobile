import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final String playerName;
  final String playerSurname;
  final int shot;
  final int control;
  final int defense;
  final String teamLogo;
  final double averageScore;
  final String playerPhoto;
  final String size; 

  PlayerCard({
    required this.playerName,
    required this.playerSurname,
    required this.shot,
    required this.control,
    required this.defense,
    required this.teamLogo,
    required this.averageScore,
    required this.playerPhoto,
    this.size = 'md', 
  });

  @override
  Widget build(BuildContext context) {
    double multiplier;

    switch (size) {
      case 'sm':
        multiplier = 0.5;
        break;
      case 'lg':
        multiplier = 1.8;
        break;
      case 'md':
      default:
        multiplier = 1.2;
        break;
    }

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