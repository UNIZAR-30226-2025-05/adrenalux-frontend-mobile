import 'package:adrenalux_frontend_mobile/screens/game/drafts_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/game/tournaments_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/screens/game/match_screen.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isGlobal = true;
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      isLoading = true;
      leaderboard = [];
    });
    
    try {
      List<Map<String, dynamic>> data = await fetchLeaderboard(isGlobal);
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

  Widget _buildLeaderboardEntry(int rank, String name, int score, ScreenSize screenSize) {
    Color circleColor = _getCircleColor(rank);
    Color circleGradientColor = _getCircleGradientColor(circleColor);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05, vertical: screenSize.height * 0.01),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: screenSize.width * 0.10, 
                height: screenSize.width * 0.10, 
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), 
                  ),
                ),
              ),
              SizedBox(width: screenSize.width * 0.04),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Text('$score', style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(width: screenSize.width * 0.1),
        ],
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
              fontSize: screenSize.height * 0.03,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
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
              padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
              child: Column(
                children: [
                  Panel(
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.475,
                    content: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(screenSize.width * 0.025, screenSize.height * 0.01, 0, screenSize.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isGlobal ? AppLocalizations.of(context)!.global_laderboard : AppLocalizations.of(context)!.friend_laderboard,
                                  style: TextStyle(
                                    fontSize: screenSize.height * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(isGlobal ? Icons.group : Icons.public),
                                  onPressed: () {
                                    setState(() {
                                      isGlobal = !isGlobal;
                                    });
                                    _fetchLeaderboard();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(),
                        SizedBox(height: screenSize.height * 0.005),
                        if (isLoading)
                          Container(
                            height: screenSize.height * 0.3,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (leaderboard.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.025),
                            child: Text(
                              AppLocalizations.of(context)!.err_laderboard,
                              style: TextStyle(
                                fontSize: screenSize.height * 0.02,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...leaderboard.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            return _buildLeaderboardEntry(
                              index + 1,
                              data['name'],
                              data['score'],
                              screenSize,
                            );
                          }).toList(),
                        SizedBox(height: screenSize.height * 0.01),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  GestureDetector(
                    onTap: () => _navigateToDrafts(),
                    child: Panel(
                      width: screenSize.width * 0.9,
                      height: screenSize.height * 0.1,
                      content: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: screenSize.width * 0.09),
                            Text(AppLocalizations.of(context)!.draft),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final user = User();
                          
                          if (!user.isDraftComplete || user.selectedDraft == null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Draft incompleto"),
                                content: Text("No has seleccionado ningúna plantilla para jugar"),
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
                      
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchScreen(
                                userTemplate: user.selectedDraft!,
                                rivalTemplate: user.selectedDraft!,
                              ),
                              settings: RouteSettings(name: '/match'),
                            ),
                          );
                        },
                        child: Panel(
                          width: screenSize.width * 0.4,
                          height: screenSize.height * 0.15,
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sports_esports, size: screenSize.width * 0.09),
                              Text(AppLocalizations.of(context)!.match),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToTournaments(),
                        child: Panel(
                          width: screenSize.width * 0.4,
                          height: screenSize.height * 0.15,
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emoji_events, size: screenSize.width * 0.09),
                              Text(AppLocalizations.of(context)!.tournament),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
