import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:flutter/material.dart';

class RoundResultDialog extends StatefulWidget {
  final RoundResult result;

  const RoundResultDialog({super.key, required this.result});

  @override
  _RoundResultDialogState createState() => _RoundResultDialogState();
}

class _RoundResultDialogState extends State<RoundResultDialog> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWinner = widget.result.winnerId == User().id.toString();
    final screenSize = ScreenSize.of(context);

    return FadeTransition(
      opacity: _opacityAnimation,
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          padding: EdgeInsets.all(screenSize.width * 0.04),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.9),
                theme.colorScheme.secondaryContainer.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isWinner ? '¡VICTORIA!' : 'DERROTA',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: isWinner ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              _buildCardComparison(),
              SizedBox(height: screenSize.height * 0.03),
              _buildScoreUpdate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardComparison() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPlayerCard(widget.result.userCard, widget.result.userSkill, true),
        Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildPlayerCard(widget.result.opponentCard, widget.result.opponentSkill, false),
      ],
    );
  }

  Widget _buildPlayerCard(PlayerCard card, String skill, bool isUser) {
    return Column(
      children: [
        PlayerCardWidget(
          playerCard: card,
          size: "sm",
        ),
        Text(
          isUser ? 'Tu carta' : 'Rival',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildScoreUpdate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${widget.result.userSkill}',
          style: TextStyle(fontSize: 24, color: Colors.blue),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.sports_score, color: Colors.amber),
        ),
        Text(
          '${widget.result.opponentSkill}',
          style: TextStyle(fontSize: 24, color: Colors.orange),
        ),
      ],
    );
  }
}