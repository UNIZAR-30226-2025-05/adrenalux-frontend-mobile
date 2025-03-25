import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/constants/app_gradients.dart';
import 'package:intl/intl.dart';

class MatchResultScreen extends StatelessWidget {
  final MatchResult result;

  const MatchResultScreen({super.key, required this.result});

  Duration _calculateMatchDuration() {
    final startTime = DateTime.now().subtract(Duration(minutes: 12));
    return result.matchEndTime.difference(startTime);
  }

  Widget _buildResultIndicator(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final isDraw = result.winner == 'draw';
    final isWinner = result.winner == 'user';

    return Column(
      children: [
        Icon(
          isDraw ? Icons.people_alt_rounded : 
             (isWinner ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded),
          size: screenSize.width * 0.3,
          color: isDraw ? Colors.white : 
               (isWinner ? Colors.amber : const Color(0xFFFF6B6B)),
        ),
        SizedBox(height: screenSize.height * 0.02),
        Text(
          isDraw ? '¡Empate!' : 
             (isWinner ? '¡Victoria!' : 'Derrota'),
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
            '${result.userFinalScore}',
            style: TextStyle(
              fontSize: screenSize.width * 0.12,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              shadows: [
                Shadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
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
            '${result.opponentFinalScore}',
            style: TextStyle(
              fontSize: screenSize.width * 0.12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFA53D),
              shadows: [
                Shadow(
                  color: const Color(0xFFFFA53D).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
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
    final duration = _calculateMatchDuration();
    final durationFormat = DateFormat('mm:ss').format(
      DateTime(0).add(duration),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.popUntil(
                context, (route) => route.isFirst),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/soccer_field_dark.jpg'),
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
                      vertical: screenSize.height * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, color: Colors.white70, 
                            size: screenSize.width * 0.05),
                        SizedBox(width: screenSize.width * 0.02),
                        Text(
                          'Duración: $durationFormat',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.06),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        context,
                        text: 'Revancha',
                        icon: Icons.replay,
                        gradient: AppGradients.blueGradient,
                        onPressed: () {/* Lógica de revancha */},
                      ),
                      SizedBox(width: screenSize.width * 0.05),
                      _buildActionButton(
                        context,
                        text: 'Menú Principal',
                        icon: Icons.home,
                        gradient: AppGradients.orangeGradient,
                        onPressed: () => Navigator.popUntil(
                            context, (route) => route.isFirst),
                      ),
                    ],
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