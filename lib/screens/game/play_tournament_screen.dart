import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/screens/home/profile_screen.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/close_button_widget.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  List<dynamic> _matches = [];
  bool _isLoadingMatches = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();

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

  Future<void> _loadMatches() async {
    try {
      final matches = await ApiService().getTournamentMatches(widget.tournament['id']);
      setState(() {
        _matches = matches;
        _isLoadingMatches = false;
      });
    } catch (e) {
      setState(() => _isLoadingMatches = false);
    }
  }

  Widget _buildDynamicBracket(ScreenSize screenSize) {
    if (_isLoadingMatches) {
      return Center(child: CircularProgressIndicator());
    }

    final rounds = _organizeMatchesIntoRounds();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoundSection(AppLocalizations.of(context)!.tournamentQuarterFinals , rounds['quarters'] ?? [], screenSize),
            _buildRoundSection(AppLocalizations.of(context)!.tournamentSemiFinals, rounds['semis'] ?? [], screenSize),
            _buildRoundSection(AppLocalizations.of(context)!.tournamentFinal, rounds['final'] ?? [], screenSize),
            SizedBox(height: screenSize.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundSection(String title, List<dynamic> matches, ScreenSize screenSize) {
    if (matches.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenSize.height * 0.02,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        Wrap(
          spacing: screenSize.width * 0.05,
          runSpacing: screenSize.height * 0.03,
          children: matches.map((match) => _buildMatchCard(match, screenSize)).toList(),
        ),
        SizedBox(height: screenSize.height * 0.04),
      ],
    );
  }

  Widget _buildMatchCard(dynamic match, ScreenSize screenSize) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final player1 = _getParticipantById(match['user1_id']);
    final player2 = _getParticipantById(match['user2_id']);

    final ganadorId = match['ganador_id'];
    final winner = ganadorId != null ? _getParticipantById(ganadorId) : null;

    return Container(
      width: screenSize.width * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.03),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerCardForMatch(player1, winner: winner, screenSize: screenSize),
                SizedBox(width: screenSize.width * 0.03),
                _buildPlayerCardForMatch(player2, winner: winner, screenSize: screenSize),
              ],
            ),
            SizedBox(height: screenSize.height * 0.015),
            Divider(color: Colors.white54),
            SizedBox(height: screenSize.height * 0.015),
            Text(
              _formatMatchDate(match['fecha']),
              style: TextStyle(
                fontSize: screenSize.height * 0.015,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCardForMatch(Map<String, dynamic>? player, {Map<String, dynamic>? winner, required ScreenSize screenSize}) {
    if (player == null) return SizedBox.shrink();

    final bool isWinner = winner != null && winner['user_id'] == player['user_id'];

    return Container(
      width: screenSize.width * 0.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.05),
            Colors.black.withOpacity(0.1)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: isWinner ? Border.all(color: Colors.greenAccent, width: 2) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
            child: CircleAvatar(
              backgroundImage: AssetImage(player['avatar']),
              radius: screenSize.width * 0.08,
            ),
          ),
          Text(
            player['nombre'],
            style: TextStyle(
              fontSize: screenSize.height * 0.018,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              color: isWinner ? Colors.greenAccent : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height * 0.008),
          Text(
            'Lv. ${player['level']}',
            style: TextStyle(
              fontSize: screenSize.height * 0.016,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }


  Map<String, List<dynamic>> _organizeMatchesIntoRounds() {
    final sortedMatches = List.from(_matches)
      ..sort((a, b) => a['fecha'].compareTo(b['fecha']));

    return {
      'quarters': sortedMatches.take(4).toList(),
      'semis': sortedMatches.skip(4).take(2).toList(),
      'final': sortedMatches.skip(6).take(1).toList(),
    };
  }

  Map<String, dynamic>? _getParticipantById(int id) {
    return widget.participants.firstWhere(
      (p) => p['user_id'] == id,
      orElse: () => null,
    );
  }

  String _formatMatchDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yy - HH:mm').format(date);
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
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
    final currentUser = User();
    final isCreator = widget.tournament['creatorId'] == currentUser.id;

    final participantes = widget.participants.length;
    final canStartTournament = participantes >= 2 && participantes % 2 == 0;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenSize.width * 0.03),
        child: Container(
          width: screenSize.width * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceDim,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, 
                      size: screenSize.height * 0.035,
                      color: Colors.amber[700],
                    ),
                    SizedBox(width: screenSize.width * 0.02),
                    Text(
                      widget.tournament['name'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.white54, height: screenSize.height * 0.03),
                
                _buildInfoRow(Icons.event, 'Fecha de inicio', 
                    widget.tournament['startDate']?.toString() ?? 'Por definir', theme, screenSize),
                _buildInfoRow(Icons.people, 'Participantes', 
                    '${participantes}/${widget.tournament['maxParticipants']}', theme, screenSize),
                _buildInfoRow(Icons.military_tech, 'Premio', 
                    '${widget.tournament['prize']}', theme, screenSize),
                _buildInfoRow(Icons.description, 'Descripción', 
                    widget.tournament['description'], theme, screenSize),
                
                SizedBox(height: screenSize.height * 0.03),
                
                if (widget.tournament['isInProgress'])
                  _buildTimer(screenSize)
                else
                  _buildActionButtons(isCreator, canStartTournament, screenSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimer(ScreenSize screenSize) {
    return Center(
      child: Container(
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
          _timeRemaining.inSeconds <= 0 
              ? AppLocalizations.of(context)!.nextMatchStartingSoon
              : "${AppLocalizations.of(context)!.nextMatchIn}:\n${_formatDuration(_timeRemaining)}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenSize.height * 0.016,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, ThemeData theme, ScreenSize screenSize) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.008),
      padding: EdgeInsets.all(screenSize.width * 0.02),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: screenSize.height * 0.022, color: Colors.white70),
          SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: screenSize.height * 0.016,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    )),
                Text(value,
                    style: TextStyle(
                      fontSize: screenSize.height * 0.018,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isCreator, bool canStart, ScreenSize screenSize) {
    if (isCreator) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canStart ? _startTournament : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canStart ? Colors.green[800] : Colors.grey[600],
                minimumSize: Size(double.infinity, screenSize.height * 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: canStart ? 4 : 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.startTournament,
                style: TextStyle(
                  fontSize: screenSize.height * 0.018,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          SizedBox(width: screenSize.width * 0.02),
          Expanded(
            child: ElevatedButton(
              onPressed: _showAbandonTournamentDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                minimumSize: Size(double.infinity, screenSize.height * 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.leaveTournament,
                style: TextStyle(
                  fontSize: screenSize.height * 0.018,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: _showAbandonTournamentDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            minimumSize: Size(screenSize.width * 0.7, screenSize.height * 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.leaveTournament,
            style: TextStyle(
              fontSize: screenSize.height * 0.018,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),
        ),
      );
    }
  }

  void _startTournament() async {
    final success = await ApiService().startTournament(widget.tournament['id']);
    if (success) {
      showCustomSnackBar(
        type: SnackBarType.success,
        message: AppLocalizations.of(context)!.tournamentStartedSuccess,
        duration: 5
      );
    } else {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.tournamentStartedError,
        duration: 5
      );
    }
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
                return _buildParticipantCard(participant, screenSize);
              },
            ),
          ),
        ],
      ),
    );
  }

  _navigateToViewProfile(friendId, isConnected) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(friendId: friendId.toString(), connected: isConnected),
      ),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> participant, ScreenSize screenSize) {
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
                        child: GestureDetector( 
                          onTap: () async {
                            await _navigateToViewProfile(participant['id'], participant['isConnected']);
                          }, 
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
                                  image: AssetImage(participant['avatar'].startsWith('/') 
                                    ? participant['avatar'].substring(1) 
                                    : participant['avatar']),
                                fit: BoxFit.cover,
                              ),
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

  void _showAbandonTournamentDialog() {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(AppLocalizations.of(context)!.leaveTournamentTitle,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          content: Text(AppLocalizations.of(context)!.leaveTournamentMessage,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () async {
                final success = await ApiService().abandonTournament(widget.tournament['id']);
                Navigator.pop(context);
                Navigator.pop(context);
                
                if (success) {
                  showCustomSnackBar(type: SnackBarType.success, message: AppLocalizations.of(context)!.tournamentLeaveSuccess, duration: 5);
                } else {
                  showCustomSnackBar(type: SnackBarType.error, message: AppLocalizations.of(context)!.tournamentLeaveError, duration: 5);
                }
              },
              child: Text(AppLocalizations.of(context)!.abandon,
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
                        ? _buildDynamicBracket(screenSize)
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