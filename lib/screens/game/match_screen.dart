import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/constants/draft_positions.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';

class MatchScreen extends StatefulWidget {
  final Draft userTemplate;
  final Draft rivalTemplate;

  const MatchScreen({
    super.key,
    required this.userTemplate,
    required this.rivalTemplate,
  });

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with RouteAware{
  int _currentPage = 0;
  int _userScore = 0;
  int _rivalScore = 0;
  bool _isUserTurn = true;
  final PageController _pageController = PageController();
  bool _isMatchPaused = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) { 
      SocketService.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    SocketService().currentRouteName = null;  
    SocketService.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    SocketService().currentRouteName = ModalRoute.of(context)?.settings.name;
  }

  @override
  void didPop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SocketService().currentRouteName = ModalRoute.of(context)?.settings.name;
      }
    });
    super.didPop();
  }

  void _showAbilityDialog(PlayerCard player) {
    final theme = Theme.of(context);
    final screenSize = ScreenSize.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(screenSize.width * 0.03),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenSize.width * 0.8,
            maxHeight: screenSize.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlayerCardWidget(
                  playerCard: player,
                  size: "sm",
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text("Seleccionar habilidad", style: theme.textTheme.titleSmall),
                SizedBox(height: screenSize.height * 0.015),
                _buildAbilityButton(
                  context,
                  icon: Icons.sports_soccer_sharp,
                  label: "Tiro - ${player.shot}",
                  color: Colors.redAccent,
                  ability: 'ataque',
                  player: player,
                ),
                _buildAbilityButton(
                  context,
                  icon: Icons.control_camera,
                  label: "Control - ${player.control}",
                  color: Colors.blueAccent,
                  ability: 'control',
                  player: player,
                ),
                _buildAbilityButton(
                  context,
                  icon: Icons.shield_sharp,
                  label: "Defensa - ${player.defense}",
                  color: Colors.greenAccent,
                  ability: 'defensa',
                  player: player,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildAbilityButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required String ability,
      required PlayerCard player}) {
    final screenSize = ScreenSize.of(context);
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.005),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _useAbility(ability, player),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.015,
                horizontal: screenSize.width * 0.04),
            child: Row(
              children: [
                Icon(icon, color: color, size: screenSize.width * 0.06),
                SizedBox(width: screenSize.width * 0.03),
                Text(label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500)),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(screenSize.width * 0.015),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      color: color, size: screenSize.width * 0.04),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _useAbility(String ability, PlayerCard player) {
    Navigator.pop(context);
    print("Usando habilidad $ability con ${player.playerName}");
    setState(() => _isUserTurn = false);
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Partida pausada"),
        actions: [
          Row(
            children: [
              Icon(Icons.play_arrow, color: Colors.green),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Reanudar"),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.red),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Rendirse"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleCardTap(PlayerCard? player, String? position) {
    if (player != null && _isUserTurn && !_isMatchPaused) {
      _showAbilityDialog(player);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$_userScore",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.01),
                Container(
                  width: screenSize.width * 0.05,
                  height: screenSize.height * 0.005, 
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Color.fromARGB(255, 244, 117, 54)], 
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(5), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ], 
                  ),
                ),
                SizedBox(width: screenSize.width * 0.01),
                Text(
                  "$_rivalScore",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 244, 117, 54),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "pause") {
                  _showPauseMenu();
                } else if (value == "surrender") {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: "pause",
                  child: Row(
                    children: [
                      Icon(Icons.pause, color: Colors.blue),
                      SizedBox(width: 10),
                      Text("Pausar"),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: "surrender",
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Rendirse"),
                    ],
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/soccer_field.jpg'),
                        fit: BoxFit.cover)),
                child: FieldTemplate(
                  draft: widget.userTemplate,
                  isInteractive: true,
                  onCardTap: _handleCardTap,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/soccer_field.jpg'),
                        fit: BoxFit.cover)),
                child: FieldTemplate(
                  draft: widget.rivalTemplate,
                  isInteractive: false,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: screenSize.height * 0.025,
            left: 0,
            right: 0,
            child: _buildPageIndicator(),
          ),
        ],
      ),
    );
  }
}
