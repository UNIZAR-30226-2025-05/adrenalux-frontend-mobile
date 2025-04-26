import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/match_results_screen.dart';
import 'package:adrenalux_frontend_mobile/widgets/animated_round_dialog.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/round_result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:adrenalux_frontend_mobile/constants/draft_positions.dart';
import 'package:adrenalux_frontend_mobile/constants/empty_card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';

class MatchScreen extends StatefulWidget {
  final int matchId;
  final Draft userTemplate;
  final Map<String, dynamic>? resumedData;
  final bool? tournamentMatch;

  const MatchScreen({
    super.key,
    required this.matchId,
    required this.userTemplate,
    this.resumedData,
    this.tournamentMatch
  });

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with RouteAware, WidgetsBindingObserver{
  int _currentPage = 0;
  int? _currentRound;

  int _userScore = 0;
  int _opponentScore = 0;

  bool _isRoundDialogVisible = false;
  bool _isResultDialogVisible = false;
  bool _isSurrenderSent = false;
  bool _loadedResumedData = false;

  final PageController _pageController = PageController();

  bool _isMatchPaused = false;
  RoundResult? _lastShownResult;
  OpponentSelection? lastOpponentSelection;

  late Draft rivalDraft;
  late MatchProvider _matchProvider;
  
  @override
  void initState() {
    super.initState();
    rivalDraft = _createEmptyRivalTemplate();
    WidgetsBinding.instance.addObserver(this);
  }

  void _handleResumedData(Map<String, dynamic> data) {
    final user1Id = data['user1Id'] as int;
    final isUser1 = User().id == user1Id;

    final userKey = isUser1 ? 'user1' : 'user2';
    final opponentKey = isUser1 ? 'user2' : 'user1';

    _userScore = data['scores'][userKey] ?? 0;
    _opponentScore = data['scores'][opponentKey] ?? 0;

    final userUsedCards = (data['usedCards'][userKey] as List? ?? [])
        .map((c) => c['id'].toString())
        .toList();

    final opponentUsedCards = (data['usedCards'][opponentKey] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .toList();

    userUsedCards.forEach(_matchProvider.addUsedCard);
    _updateRivalDraft(opponentUsedCards);
    _loadedResumedData = true;

    print("Datos reanudados mapeados - Usuario: $userKey");
  }

  void _updateRivalDraft(List<Map<String, dynamic>> usedCards) {
    usedCards.forEach((cartaData) {
      final position = _getOpponentSlot(cartaData['posicion'] as String); 
      final card = PlayerCard.fromJson(cartaData);
      if (position != null) {
        rivalDraft.draft[position] = card;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _matchProvider = Provider.of<MatchProvider>(context, listen: true)
    ..addListener(_handleProviderUpdate); 

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_loadedResumedData && widget.resumedData != null) {
        _handleResumedData(widget.resumedData!);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleProviderUpdate();
      }
    });
    
    final route = ModalRoute.of(context);
    if (route is PageRoute) { 
      SocketService.routeObserver.subscribe(this, route);
    }
  }

  void _handleProviderUpdate() {
    if (mounted) {
      setState(() { 
        _checkForRoundResult();
        _checkOpponentSelection();
        _checkRoundUpdate();
        _checkForMatchEnd();
      });
    }
  }

  void dispose() {
    SocketService.routeObserver.unsubscribe(this);
    _matchProvider.removeListener(_handleProviderUpdate);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _sendSurrenderIfNeeded();
    }
  }

  void _sendSurrenderIfNeeded() {
    if (_matchProvider.matchResult == null && !_isSurrenderSent) {
      _isSurrenderSent = true; 
      Provider.of<SocketService>(context, listen: false).sendSurrender(widget.matchId);
    }
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

  Draft _createEmptyRivalTemplate() {
    final emptyDraft = <String, PlayerCard?>{};
    
    for (String position in Draft.positions) {
      emptyDraft[position] = returnEmptyCard();
    }

    return Draft(
      id: -1,
      name: 'Rival',
      draft: emptyDraft,
    );
  }

  PlayerCard createIndicatorCard() {
    final indicator = returnEmptyCard();
    indicator.setIndicator(true);
    return indicator;
  }

  String? _getOpponentSlot(String backendPosition) {
    switch (backendPosition.toLowerCase()) {
      case 'goalkeeper':
        if (rivalDraft.draft["GK"]!.amount == 0) return "GK";
        break;
      case 'defender':
        for (var slot in ["DEF1", "DEF2", "DEF3", "DEF4"]) {
          if (rivalDraft.draft[slot]!.amount == 0) return slot;
        }
        break;
      case 'midfielder':
        for (var slot in ["MID1", "MID2", "MID3"]) {
          if (rivalDraft.draft[slot]!.amount == 0) return slot;
        }
        break;
      case 'forward':
        for (var slot in ["FWD1", "FWD2", "FWD3"]) {
          if (rivalDraft.draft[slot]!.amount == 0) return slot;
        }
        break;
    }
    return null;
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
                Text(AppLocalizations.of(context)!.select_ability, style: theme.textTheme.titleSmall),
                SizedBox(height: screenSize.height * 0.015),
                _buildAbilityButton(
                  context,
                  icon: Icons.sports_soccer_sharp,
                  label: "${AppLocalizations.of(context)!.ability_shot} - ${player.shot}",
                  color: Colors.redAccent,
                  ability: 'ataque',
                  player: player,
                ),
                _buildAbilityButton(
                  context,
                  icon: Icons.control_camera,
                  label: "${AppLocalizations.of(context)!.ability_control} - ${player.control}",
                  color: Colors.blueAccent,
                  ability: 'control',
                  player: player,
                ),
                _buildAbilityButton(
                  context,
                  icon: Icons.shield_sharp,
                  label: "${AppLocalizations.of(context)!.ability_defense} - ${player.defense}",
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
          key: Key('button-$ability'),
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

  void _showPauseMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.request_pause),
        content: Text(AppLocalizations.of(context)!.pause_request_message),
        actions: [
          TextButton(
            key: Key("accept_pause"),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<SocketService>(context, listen: false).sendPauseRequest(widget.matchId);
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
  
  void _useAbility(String ability, PlayerCard player) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    Navigator.pop(context);
    final currentRound = _matchProvider.currentRound;
    
    if (currentRound == null || !currentRound.isUserTurn) {
      print("No es tu turno");
      return;
    }

    if (_matchProvider.usedCards.contains(player.id.toString())) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.card_already_used,
      );
      return;
    }

    if (currentRound.phase == 'response') {
      final opponentPosition = _matchProvider.opponentSelection?.card.position;
      
      if (player.position != opponentPosition) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: '${AppLocalizations.of(context)!.select_position} ${_positionName(opponentPosition)}',
        );
        return;
      }
    }

    _matchProvider.addUsedCard(player.id.toString());

    if (currentRound.phase == 'selection') {
      socketService.selectMatchCard(player.id.toString(), ability);
    } else if (currentRound.phase == 'response') {
      socketService.selectMatchResponse(player.id.toString(), ability);
    }

    _matchProvider.updateRound(
      RoundInfo(
        roundNumber: currentRound.roundNumber,
        isUserTurn: false,
        phase: currentRound.phase,
      )
    );
  }

  String _positionName(String? position) {
    switch (position?.toLowerCase()) {
      case 'goalkeeper': return 'portero';
      case 'defender': return 'defensa';
      case 'midfielder': return 'mediocentro';
      case 'forward': return 'delantero';
      default: return 'jugador';
    }
  }

  void _handleCardTap(PlayerCard? player, String? position) {
    final isUserTurn = _matchProvider.currentRound?.isUserTurn ?? false;
    final isUsed = player != null && _matchProvider.usedCards.contains(player.id.toString());
    
    if (player != null && isUserTurn && !_isMatchPaused && !isUsed) {
      _showAbilityDialog(player);
    }
  }

  void _confirmSurrender() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          key: Key("confirm_surrender"),
          AppLocalizations.of(context)!.confirm_surrender
        ),
        content: Text(AppLocalizations.of(context)!.confirm_surrender_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            key: Key("accept_surrender"),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<SocketService>(context, listen: false).sendSurrender(widget.matchId);
            },
            child: Text(AppLocalizations.of(context)!.accept, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _checkForMatchEnd() {
    if (_matchProvider.matchResult != null && 
        !_isResultDialogVisible && 
        !_isRoundDialogVisible) {
          
      final result = _matchProvider.matchResult!;
      _matchProvider.reset();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MatchResultScreen(result: result),
          ),
        );
      });
    }
  }

  void _checkRoundUpdate() {
    final newRound = _matchProvider.currentRound;
    if(newRound != null && 
      newRound.roundNumber != _currentRound && 
      !_isRoundDialogVisible && 
      !_isResultDialogVisible) {
      
      _isRoundDialogVisible = true;
      
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.4),
          barrierDismissible: false,
          builder: (context) => AnimatedRoundDialog(
            roundNumber: newRound.roundNumber,
            isUserTurn: newRound.isUserTurn,
          ),
        ).then((_) {
          _isRoundDialogVisible = false;
          _currentRound = newRound.roundNumber;
          _checkForRoundResult(); 
        });
      });
    }
  }

  void _checkOpponentSelection() {
    final opponentSelection = _matchProvider.opponentSelection;
    if(opponentSelection != null && 
      opponentSelection.card.id != lastOpponentSelection?.card.id) {

      setState(() {
        lastOpponentSelection = opponentSelection;
        final opponentSlot = _getOpponentSlot(opponentSelection.card.position);
        if (opponentSlot != null) {
          rivalDraft.draft[opponentSlot] = createIndicatorCard();
        }
      });
    }
  }

  void _checkForRoundResult() {
    final currentResult = _matchProvider.roundResult;
    
    
    if (currentResult != null && 
      currentResult != _lastShownResult &&
      !_isRoundDialogVisible && 
      !_isResultDialogVisible) {

      final cardSelected = currentResult.opponentCard;
      _isResultDialogVisible = true;

      _userScore = currentResult.scores[User().id.toString()] ?? 0;
      _opponentScore = currentResult.scores.entries
      .firstWhere(
          (entry) => entry.key != User().id.toString(), 
          orElse: () => const MapEntry('', 0), 
      )
      .value;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => RoundResultDialog(result: currentResult),
        ).then((_) {
          
          _isResultDialogVisible = false;
          _lastShownResult = currentResult;
          rivalDraft.draft[_getOpponentSlot(cardSelected.position) ?? ''] = cardSelected;
          _checkRoundUpdate(); 
        });
      });
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
                  "$_opponentScore",
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
                  _confirmSurrender();
                }
              },
              itemBuilder: (BuildContext context) => [
                if(widget.tournamentMatch ?? true)
                  PopupMenuItem<String>(
                    key: Key("pause"),
                    value: "pause",
                    child: Row(
                      children: [
                        Icon(Icons.pause, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(AppLocalizations.of(context)!.pause),
                      ],
                    ),
                  ),
                PopupMenuItem<String>(
                  key: Key("surrender"),
                  value: "surrender",
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.surrender),
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
                  draft: rivalDraft,
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
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  key: (_matchProvider.currentRound?.isUserTurn ?? false) ? Key('choose-card') : Key('wait-selection'),
                  (_matchProvider.currentRound?.isUserTurn ?? false) 
                  ? AppLocalizations.of(context)!.choose_a_card 
                  : AppLocalizations.of(context)!.waiting_for_selection,
                  
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.035,
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
