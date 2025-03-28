import 'package:adrenalux_frontend_mobile/screens/game/drafts_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/social/view_profile_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/game/tournaments_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SocketService _socketService;
  ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isGlobal = true;
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
    _loadPlantillas();
    _socketService = SocketService();
  }

  Future<void> _loadPlantillas() async {
    setState(() {
      isLoading = true;
    });

    try {
      final plantillas = await apiService.getPlantillas();
      if (plantillas != null) {
        User().drafts = plantillas;
        if (plantillas.isNotEmpty && User().selectedDraft == null) {
          setSelectedDraft(plantillas.first);
        }
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      isLoading = true;
      leaderboard = [];
    });
    
    try {
      List<Map<String, dynamic>> data = await apiService.fetchLeaderboard(isGlobal);
      
      data.sort((a, b) {
        int aScore = int.tryParse(a['clasificacion']?.toString() ?? '0') ?? 0;
        int bScore = int.tryParse(b['clasificacion']?.toString() ?? '0') ?? 0;
        return bScore.compareTo(aScore);
      });

      setState(() {
        leaderboard = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildLeaderboardEntry(int rank, Map<String, dynamic> userData, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final isSmallScreen = screenWidth < 350;

    String name = userData['username']?.toString() ?? 'Usuario';
    int score = int.tryParse(userData['clasificacion']?.toString() ?? '0') ?? 0;
    
    Color circleColor = _getCircleColor(rank);
    Color circleGradientColor = _getCircleGradientColor(circleColor);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewProfileScreen(
              friend: userData,
            ),
          ),
        );
      }, 
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, 
          vertical: screenHeight * 0.02
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: isSmallScreen ? 30 : screenWidth * 0.09,
                  height: isSmallScreen ? 30 : screenWidth * 0.09,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [circleColor, circleGradientColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rank.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 16,
                      ), 
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
          ],
        ),
      ),
    );
  }


  Color _getCircleColor(int rank) {
    if (rank == 1) {
      return Colors.yellow;
    } else if (rank == 2) {
      return Colors.grey;
    } else if (rank == 3) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Color _getCircleGradientColor(Color originalColor) {
    double r = (originalColor.r * 0.4).toDouble();
    double g = (originalColor.g * 0.4).toDouble();
    double b = (originalColor.b * 0.4).toDouble();
    return Color.from(alpha: 1.0, red: r, green: g, blue: b);
  }

  void _joinMatchmaking() {
    final screenSize = ScreenSize.of(context);
    final user = User();
    if (!user.isDraftComplete || user.selectedDraft == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.incomplete_draft),
          content: Text(AppLocalizations.of(context)!.no_draft_selected),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.searching_match),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: screenSize.width * 0.075, height: screenSize.height * 0.1),
              Expanded(child: Text(AppLocalizations.of(context)!.searching_match)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _socketService.leaveMatchmaking();
                Navigator.of(context).pop(); 
              },
              child: Text("Cancelar"),
            ),
          ],
        );
      },
    );
    _socketService.joinMatchmaking();
  }

  void _navigateToDrafts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DraftsScreen(),
      ),
    );
  }

  void _navigateToTournaments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.games,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: screenSize.height.clamp(14, 24) * 0.025,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/soccer_field.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: constraints.maxHeight * 0.02,
                    horizontal: constraints.maxWidth * 0.03
                  ),
                  child: Column(
                    children: [
                      Panel(
                        width: constraints.maxWidth * 0.95,
                        height: constraints.maxHeight * 0.6,
                        content: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: constraints.maxHeight * 0.015,
                                bottom: constraints.maxHeight * 0.015,
                                left: constraints.maxHeight * 0.025,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      isGlobal 
                                        ? AppLocalizations.of(context)!.global_laderboard 
                                        : AppLocalizations.of(context)!.friend_laderboard,
                                      style: TextStyle(
                                        fontSize: 20 * textScale.clamp(0.8, 1.2),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: constraints.maxWidth * 0.06,
                                    icon: Icon(isGlobal ? Icons.group : Icons.public),
                                    onPressed: () {
                                      setState(() => isGlobal = !isGlobal);
                                      _fetchLeaderboard();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Divider(thickness: 1),
                            isLoading
                              ? SizedBox(
                                  height: constraints.maxHeight * 0.3,
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : Expanded(
                                  child: leaderboard.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text(
                                            AppLocalizations.of(context)!.err_laderboard,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                        itemCount: leaderboard.length,
                                        separatorBuilder: (context, index) => Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          return _buildLeaderboardEntry(
                                            index + 1,
                                            leaderboard[index],
                                            constraints,
                                          );
                                        },
                                      ),
                                ),
                          ],
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildActionButtons(constraints),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _navigateToDrafts(),
          child: Panel(
            width: constraints.maxWidth * 0.95,
            height: constraints.maxHeight * 0.12,
            content: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: constraints.maxWidth * 0.08),
                  SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.draft,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () => _joinMatchmaking(),
                child: Panel(
                  width: constraints.maxWidth * 0.45,
                  height: constraints.maxHeight * 0.18,
                  content: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_esports, 
                            size: constraints.maxWidth * 0.12),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.match,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: GestureDetector(
                onTap: () => _navigateToTournaments(),
                child: Panel(
                  width: constraints.maxWidth * 0.45,
                  height: constraints.maxHeight * 0.18,
                  content: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, 
                            size: constraints.maxWidth * 0.12),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.tournament,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}