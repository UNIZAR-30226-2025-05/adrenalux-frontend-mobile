import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/constants/app_gradients.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchResultScreen extends StatelessWidget {
  final MatchResult result;

  const MatchResultScreen({super.key, required this.result});
  
  Widget _buildResultIndicator(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final userId = User().id.toString();
    final isDraw = result.isDraw;
    final isWinner = result.winnerId == userId;

    return Column(
      children: [
        Icon(
          isDraw 
              ? Icons.people_alt_rounded 
              : (isWinner 
                  ? Icons.emoji_events_rounded 
                  : Icons.sports_soccer_sharp),
          size: screenSize.width * 0.3,
          color: isDraw 
              ? Colors.white 
              : (isWinner 
                  ? Colors.amber 
                  : const Color(0xFFFF6B6B)),
        ),
        SizedBox(height: screenSize.height * 0.02),
        Text(
          key: Key('resultText'),
          isDraw ? '¡${AppLocalizations.of(context)!.draw}!' : (isWinner ? '${AppLocalizations.of(context)!.win}!' : '${AppLocalizations.of(context)!.defeat}'),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: screenSize.width * 0.08,
            fontWeight: FontWeight.w900,
            foreground: Paint()..shader = AppGradients.mainGradient.createShader(
              Rect.fromLTWH(0, 0, screenSize.width, 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    final userId = User().id.toString();
    final userScore = result.scores[userId] ?? 0;
    final opponentScore = result.scores.entries
        .firstWhere(
          (entry) => entry.key != userId,
          orElse: () => const MapEntry('', 0),
        )
        .value;

    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        gradient: AppGradients.scoreBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$userScore',
            style: TextStyle(
              fontSize: screenSize.width * 0.12,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              shadows: [
                Shadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
            child: Text(
              '-',
              style: TextStyle(
                fontSize: screenSize.width * 0.08,
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            '$opponentScore',
            style: TextStyle(
              fontSize: screenSize.width * 0.12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFA53D),
              shadows: [
                Shadow(
                  color: const Color(0xFFFFA53D).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required String text,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    final screenSize = ScreenSize.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        key: Key('home-button'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.02,
            horizontal: screenSize.width * 0.06,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: screenSize.width * 0.06, color: Colors.white),
            SizedBox(width: screenSize.width * 0.03),
            Text(
              text,
              style: TextStyle(
                fontSize: screenSize.width * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final userId = User().id.toString();
    final puntosGanados = result.puntosChange[userId] ?? 0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/soccer_field.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(screenSize.width * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResultIndicator(context),
                  SizedBox(height: screenSize.height * 0.05),
                  _buildScoreRow(context),
                  SizedBox(height: screenSize.height * 0.04),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                      vertical: screenSize.height * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.main_menu}:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.008),
                        Text(
                          '+$puntosGanados',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.06,
                            color: Colors.lightGreenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.06),
                  _buildActionButton(
                    context,
                    text: '${AppLocalizations.of(context)!.main_menu}',
                    icon: Icons.home,
                    gradient: AppGradients.orangeGradient,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MenuScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}