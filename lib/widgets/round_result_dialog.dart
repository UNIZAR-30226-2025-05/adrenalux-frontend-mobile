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
    final isDraw = widget.result.winnerId == null;
    final isWinner = widget.result.winnerId == User().id.toString();

    return FadeTransition(
      opacity: _opacityAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(screenSize.width * 0.03),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isPortrait ? screenSize.width * 0.95 : screenSize.width * 0.7,
            maxHeight: screenSize.height * 0.7,
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
                _buildTitle(isDraw, isWinner, theme),
                SizedBox(height: screenSize.height * 0.02),
                _buildCardRow(),
                SizedBox(height: screenSize.height * 0.02),
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
      child: isPortrait 
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _cardRowChildren(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _cardColumnChildren(),
            ),
    );
  }

  List<Widget> _cardRowChildren() => [
    _buildPlayerCard(widget.result.userCard, widget.result.userSkill, true),
    _buildVsText(),
    _buildPlayerCard(widget.result.opponentCard, widget.result.opponentSkill, false),
  ];

  List<Widget> _cardColumnChildren() => [
    _buildPlayerCard(widget.result.userCard, widget.result.userSkill, true),
    Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
      child: _buildVsText(),
    ),
    _buildPlayerCard(widget.result.opponentCard, widget.result.opponentSkill, false),
  ];

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
            isUser ? AppLocalizations.of(context)!.you : AppLocalizations.of(context)!.opponent,
            style: TextStyle(
              fontSize: _dynamicFontSize(3.5),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            skill.toUpperCase(),
            style: TextStyle(
              fontSize: _dynamicFontSize(3),
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _getCardSize() {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide < 350) return 'xs';
    if (shortestSide < 500) return 'sm';
    return 'md';
  }

  Widget _buildVsText() {
    return Text(
      'VS',
      style: TextStyle(
        fontSize: isPortrait 
            ? screenSize.width * 0.08 
            : screenSize.height * 0.08,
        fontWeight: FontWeight.bold,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildTitle(bool isDraw, bool isWinner, ThemeData theme) {
    return Text(
      isDraw ? AppLocalizations.of(context)!.draw 
           : (isWinner ? AppLocalizations.of(context)!.win : AppLocalizations.of(context)!.defeat),
      style: theme.textTheme.headlineMedium?.copyWith(
        color: isDraw ? Colors.blue : (isWinner ? Colors.green : Colors.red),
        fontWeight: FontWeight.bold,
        fontSize: _dynamicFontSize(7),
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
            fontSize: _dynamicFontSize(4.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        isPortrait
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _scoreItems(),
              )
            : Column(
                children: _scoreItems(),
              ),
      ],
    );
  }

  List<Widget> _scoreItems() => [
    _buildScoreItem(
      widget.result.userSkill, 
      Colors.blue, 
      Icons.arrow_upward
    ),
    SizedBox(width: isPortrait ? screenSize.width * 0.05 : 0,
         height: isPortrait ? 0 : screenSize.height * 0.02),
    _buildScoreItem(
      widget.result.opponentSkill, 
      Colors.orange, 
      Icons.arrow_downward
    ),
  ];

  Widget _buildScoreItem(String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: _dynamicFontSize(6),
        ),
        SizedBox(height: screenSize.height * 0.005),
        Text(
          value,
          style: TextStyle(
            fontSize: _dynamicFontSize(5),
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _dynamicFontSize(double multiplier) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return (shortestSide * multiplier) / 100;
  }
}