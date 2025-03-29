import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late ScreenSize screenSize;

  bool get isPortrait => MediaQuery.of(context).orientation == Orientation.portrait;

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
    screenSize = ScreenSize.of(context);
    final theme = Theme.of(context);
    final isWinner = widget.result.winnerId == User().id.toString();

    return FadeTransition(
      opacity: _opacityAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(screenSize.width * 0.03),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenSize.width * 0.95,
            maxHeight: screenSize.height * 0.7, // Reducimos un poco la altura
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.9),
                theme.colorScheme.secondaryContainer.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(screenSize.width * 0.05),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(isWinner, theme),
                SizedBox(height: screenSize.height * 0.03),
                _buildCardRow(), // Cambiamos a fila
                SizedBox(height: screenSize.height * 0.03),
                _buildScoreUpdate(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPlayerCard(widget.result.userCard, widget.result.userSkill, true),
          _buildVsText(),
          _buildPlayerCard(widget.result.opponentCard, widget.result.opponentSkill, false),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayerCard card, String skill, bool isUser) {
    return Flexible(
      child: Column(
        children: [
          PlayerCardWidget(
            playerCard: card,
            size: _getCardSize(),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            isUser ? '${AppLocalizations.of(context)!.you}' : '${AppLocalizations.of(context)!.opponent}',
            style: TextStyle(
              fontSize: screenSize.width * 0.035,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            skill.toUpperCase(),
            style: TextStyle(
              fontSize: screenSize.width * 0.03,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _getCardSize() {
    if (screenSize.width < 350) return 'xs';
    if (screenSize.width < 500) return 'sm';
    return 'md';
  }

  Widget _buildVsText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.03),
      child: Text(
        'VS',
        style: TextStyle(
          fontSize: screenSize.width * 0.08,
          fontWeight: FontWeight.bold,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildTitle(bool isWinner, ThemeData theme) {
    return Text(
      isWinner ? '${AppLocalizations.of(context)!.win}' : '${AppLocalizations.of(context)!.defeat}',
      style: theme.textTheme.headlineMedium?.copyWith(
        color: isWinner ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: screenSize.width * 0.07,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildScoreUpdate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Puntuación Final',
          style: TextStyle(
            fontSize: screenSize.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreItem(
              '${widget.result.userSkill}', 
              Colors.blue, 
              Icons.arrow_upward
            ),
            SizedBox(width: screenSize.width * 0.05),
            _buildScoreItem(
              '${widget.result.opponentSkill}', 
              Colors.orange, 
              Icons.arrow_downward
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreItem(String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: screenSize.width * 0.06,
        ),
        SizedBox(height: screenSize.height * 0.005),
        Text(
          value,
          style: TextStyle(
            fontSize: screenSize.width * 0.05,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}