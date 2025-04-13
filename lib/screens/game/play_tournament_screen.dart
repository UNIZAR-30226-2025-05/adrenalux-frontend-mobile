import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/close_button_widget.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    print("Participantes : ${widget.participants}");
    final startDate = widget.tournament['startDate'] as DateTime?;
    _timeRemaining = startDate?.difference(DateTime.now()) ?? Duration.zero;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (startDate != null) {
          _timeRemaining = startDate.difference(DateTime.now());
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    return '${duration.inDays}d ${duration.inHours.remainder(24)}h '
        '${duration.inMinutes.remainder(60)}m';
  }

  Widget _buildPageIndicator() {
    final screenSize = ScreenSize.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: _currentPage == 1 ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: Icon(Icons.chevron_left, 
              color: Colors.white.withOpacity(0.8), 
              size: screenSize.height * 0.025,
          ),
        ),
        Row(
          children: List.generate(2, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
              width: _currentPage == index ? screenSize.width * 0.025 : screenSize.width * 0.02,
              height: screenSize.height * 0.015,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.5),
                boxShadow: [
                  if(_currentPage == index)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 2,
                    )
                ],
              ),
            );
          }),
        ),
        AnimatedOpacity(
          opacity: _currentPage == 0 ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: Icon(Icons.chevron_right, 
              color: Colors.white.withOpacity(0.8), 
              size: screenSize.height * 0.025),
        ),
      ],
    );
  }

  Widget _buildTournamentInfoPanel(ScreenSize screenSize) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    final participantes = widget.tournament['participantes'] != null 
                ? widget.tournament['participantes'].length 
                : 1;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenSize.width * 0.05),
        child: Panel(
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.5,
          content: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nombre del torneo', widget.tournament['name'], theme, screenSize),
                _buildInfoRow('Fecha de inicio', 
                    widget.tournament['startDate']?.toString() ?? 'Por definir', 
                    theme, screenSize),
                _buildInfoRow(
                  'Participantes', 
                  '$participantes/${widget.tournament['maxParticipants']}',
                  theme, 
                  screenSize,
                ),
                
                Spacer(), // Empuja el contenido hacia abajo
                
                if (widget.tournament['isInProgress'])
                  Container(
                    margin: EdgeInsets.only(top: screenSize.height * 0.015),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.03,
                      vertical: screenSize.height * 0.008,
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
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: screenSize.height * 0.015),
                      child: ElevatedButton(
                        onPressed: _showAbandonTournamentDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.05,
                            vertical: screenSize.height * 0.015,
                          ),
                        ),
                        child: Text(
                          'Abandonar Torneo',
                          style: TextStyle(
                            fontSize: screenSize.height * 0.016,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, ThemeData theme, ScreenSize screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text('$title:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: screenSize.height * 0.018,
                )),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: screenSize.height * 0.016,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsGrid(ScreenSize screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height * 0.02),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9, 
              ),
              itemCount: widget.participants.length,
              itemBuilder: (context, index) {
                final participant = widget.participants[index];
                return _buildParticipantCard(participant, screenSize, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> participant, ScreenSize screenSize, int index) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final isCurrentUser = participant['user_id'] == User().id;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isCurrentUser 
              ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
              : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface.withOpacity(0.9),
                theme.colorScheme.background.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Center(
                        child: Container(
                          width: screenSize.width * 0.15,
                          height: screenSize.width * 0.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.8),
                              width: 1.2,
                            ),
                            image: DecorationImage(
                              image: AssetImage(participant['avatar']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      if(participant['isOnline'])
                        Positioned(
                          right: screenSize.width * 0.02,
                          bottom: screenSize.width * 0.02,
                          child: Container(
                            width: screenSize.width * 0.035,
                            height: screenSize.width * 0.035,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white, 
                                width: 1.5
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    
                Flexible(
                  child: Text(
                    participant['nombre'],
                    style: TextStyle(
                      fontSize: screenSize.width * 0.035,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.006),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactStatBadge(
                        icon: Icons.emoji_events,
                        value: participant['victorias'].toString(),
                        screenSize: screenSize,
                        color: Colors.amber,
                        iconSize: screenSize.width * 0.04,
                      ),
                      _buildCompactStatBadge(
                        icon: Icons.sports_esports,
                        value: participant['partidas'].length.toString(),
                        screenSize: screenSize,
                        color: theme.colorScheme.primary,
                        iconSize: screenSize.width * 0.04,
                      ),
                      _buildCompactStatBadge(
                        icon: Icons.star,
                        value: participant['level'].toString(),
                        screenSize: screenSize,
                        color: Colors.blue,
                        iconSize: screenSize.width * 0.04,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: LinearProgressIndicator(
                    value: participant['progreso'] ?? 0.5,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimaryFixedVariant,
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatBadge({
    required IconData icon,
    required String value,
    required ScreenSize screenSize,
    required Color color,
    required double iconSize,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color),
        SizedBox(width: screenSize.width * 0.008),
        Text(
          value,
          style: TextStyle(
            fontSize: screenSize.width * 0.03,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
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
        _buildPlayerPanel(widget.participants[0]['nombre'], widget.participants[0]['avatar'], 
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
        _buildPlayerPanel(widget.participants[1]['nombre'], widget.participants[1]['avatar'],
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
                    widget.participants[0]['nombre'],
                    widget.participants[1]['nombre'],
                    widget.participants[0]['avatar'],
                    widget.participants[1]['avatar'],
                    widget.participants[0]['won'],
                    screenSize,
                  ),
                  SizedBox(width: screenSize.width * 0.015), 
                  _buildHorizontalMatch(
                    widget.participants[2]['nombre'],
                    widget.participants[3]['nombre'],
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
                widget.participants[4]['nombre'],
                widget.participants[5]['nombre'],
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
                widget.participants[6]['nombre'],
                widget.participants[7]['nombre'],
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
                    widget.participants[4]['nombre'],
                    widget.participants[5]['nombre'],
                    widget.participants[4]['avatar'],
                    widget.participants[5]['avatar'],
                    widget.participants[4]['won'],
                    screenSize,
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  _buildHorizontalMatch(
                    widget.participants[6]['nombre'],
                    widget.participants[7]['nombre'],
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

  void _showAbandonTournamentDialog() {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Abandonar Torneo',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          content: Text('¿Estás seguro de que deseas abandonar el torneo?',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () async {
                final success = await ApiService().abandonTournament(widget.tournament['id']);
                Navigator.pop(context);
                Navigator.pop(context);
                
                if (success) {
                  showCustomSnackBar(type: SnackBarType.success, message: "Has abandonado el torneo con éxito", duration: 5);
                } else {
                  showCustomSnackBar(type: SnackBarType.error, message: "Error al abandonar el torneo", duration: 5);
                }
              },
              child: Text('Abandonar',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

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
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildTournamentInfoPanel(screenSize),
                    widget.tournament['isInProgress']
                        ? _buildBracket(screenSize)
                        : _buildParticipantsGrid(screenSize),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenSize.height * 0.1, 
                ),
                child: _buildPageIndicator(),
              ),
            ],
          ),
          Positioned(
            bottom: 20, 
            left: 0,
            right: 0,
            child: Center(
              child: CloseButtonWidget(
                size: 60,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}