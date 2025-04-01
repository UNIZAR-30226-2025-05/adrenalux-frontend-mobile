import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'dart:async';

class TournamentScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;
  final List<dynamic> participants;

  const TournamentScreen({
    required this.tournament,
    required this.participants,
  });

  @override
  _TournamentScreenState createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  late Duration _timeRemaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    final startDate = widget.tournament['startDate'] as DateTime;
    _timeRemaining = startDate.difference(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = startDate.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    return '${duration.inDays}d ${duration.inHours.remainder(24)}h '
        '${duration.inMinutes.remainder(60)}m';
  }

  Widget _buildPlayerPanel(String name, String avatar, {bool isWinner = false, required ScreenSize screenSize}) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    
    return Container(
      padding: EdgeInsets.all(screenSize.height * 0.003),
      constraints: BoxConstraints(
        maxWidth: screenSize.width * 0.2, 
        maxHeight: screenSize.height * 0.1, 
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: screenSize.width * 0.01,
            offset: Offset(screenSize.width * 0.003, screenSize.width * 0.003), 
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: screenSize.height * 0.05, 
            height: screenSize.height * 0.05, 
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isWinner ? Colors.green : Colors.transparent,
                width: screenSize.width * 0.002,
              ),
              image: DecorationImage(
                image: AssetImage(avatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.002), 
          Text(
            name,
            style: TextStyle(
              fontSize: screenSize.height * 0.012,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalMatch(String p1, String p2, String avatar1, String avatar2, bool? winner, ScreenSize screenSize) {
    return Container(
      constraints: BoxConstraints(maxWidth: screenSize.width * 0.5), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: _buildPlayerPanel(p1, avatar1, 
              isWinner: winner == true,
              screenSize: screenSize,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
            child: Text(
              'VS',
              style: TextStyle(
                fontSize: screenSize.height * 0.016,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
          Flexible(
            child: _buildPlayerPanel(p2, avatar2,
              isWinner: winner == false,
              screenSize: screenSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalFinal(ScreenSize screenSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPlayerPanel(widget.participants[0]['name'], widget.participants[0]['avatar'], 
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.01), 
        Image.asset(
          'assets/world_cup.png',
          width: screenSize.height * 0.06, 
          height: screenSize.height * 0.06, 
          color: Colors.amber[700],
        ),
        SizedBox(height: screenSize.height * 0.01), 
        _buildPlayerPanel(widget.participants[1]['name'], widget.participants[1]['avatar'],
          screenSize: screenSize,
        ),
      ],
    );
  }

  Widget _buildBracket(ScreenSize screenSize) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.01), 
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildHorizontalMatch(
                    widget.participants[0]['name'],
                    widget.participants[1]['name'],
                    widget.participants[0]['avatar'],
                    widget.participants[1]['avatar'],
                    widget.participants[0]['won'],
                    screenSize,
                  ),
                  SizedBox(width: screenSize.width * 0.015), 
                  _buildHorizontalMatch(
                    widget.participants[2]['name'],
                    widget.participants[3]['name'],
                    widget.participants[2]['avatar'],
                    widget.participants[3]['avatar'],
                    widget.participants[2]['won'],
                    screenSize,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenSize.height * 0.015),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02), 
              child: _buildHorizontalMatch(
                widget.participants[4]['name'],
                widget.participants[5]['name'],
                widget.participants[4]['avatar'],
                widget.participants[5]['avatar'],
                null,
                screenSize,
              ),
            ),
            SizedBox(height: screenSize.height * 0.02), 

            _buildVerticalFinal(screenSize),
            SizedBox(height: screenSize.height * 0.02),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
              child: _buildHorizontalMatch(
                widget.participants[6]['name'],
                widget.participants[7]['name'],
                widget.participants[6]['avatar'],
                widget.participants[7]['avatar'],
                null,
                screenSize,
              ),
            ),
            SizedBox(height: screenSize.height * 0.015),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildHorizontalMatch(
                    widget.participants[4]['name'],
                    widget.participants[5]['name'],
                    widget.participants[4]['avatar'],
                    widget.participants[5]['avatar'],
                    widget.participants[4]['won'],
                    screenSize,
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  _buildHorizontalMatch(
                    widget.participants[6]['name'],
                    widget.participants[7]['name'],
                    widget.participants[6]['avatar'],
                    widget.participants[7]['avatar'],
                    widget.participants[6]['won'],
                    screenSize,
                  ),
                ],
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

    double padding = screenSize.width * 0.05;
    double avatarSize = screenSize.width * 0.3;
    double iconSize = screenSize.width * 0.07;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          centerTitle: true,
          title: Text(
            widget.tournament['name'],
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: screenSize.height * 0.022
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/soccer_field.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: screenSize.height * 0.015),
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.03,
                  vertical: screenSize.height * 0.008
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                ),
                child: Text(
                  'Próxima partida en:\n${_formatDuration(_timeRemaining)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.height * 0.016,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(top: screenSize.height * 0.06),
                  child: _buildBracket(screenSize),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: padding * 2,
            left: padding * 2,
            right: padding * 2,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: avatarSize * 0.6,
                height: avatarSize * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryFixedDim,
                      theme.colorScheme.primaryFixed,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.onPrimaryFixed,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.surfaceBright,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: theme.colorScheme.onInverseSurface,
                    size: iconSize * 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}