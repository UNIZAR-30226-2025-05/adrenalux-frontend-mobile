import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/widgets/card_collection.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/constants/empty_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExchangeScreen extends StatefulWidget {
  final String exchangeId;
  final String? opponentUsername;

  const ExchangeScreen({
    required this.exchangeId,
    this.opponentUsername, 
  });

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> with RouteAware{
  late ApiService apiService;
  List<PlayerCard> _filteredPlayerCards = [];
  List<PlayerCard> _playerCards = [];
  List<PlayerCardWidget> _filteredPlayerCardWidgets = [];
  Map<String, bool> _confirmations = {};

  bool _isLoading = true;
  bool _isConfirmed = false;
  bool _isExchangeActive = false;
  PlayerCard? _selectedUserCard;
  PlayerCard? _selectedOpponentCard;
  late SocketService _socketService;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false); 
    _socketService = Provider.of<SocketService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
    _loadPlayerCards();
  }

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
    _socketService.onConfirmationsUpdated = null;
    _socketService.onOpponentCardSelected = null;
    SocketService.routeObserver.unsubscribe(this);
    SocketService().currentRouteName = null;  
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

  void _setupSocketListeners() {
    _socketService.onOpponentCardSelected = updateOpponentCard;
    _socketService.onConfirmationsUpdated = updateConfirmations;
  }

  void updateConfirmations(Map<String, bool> confirmations) {
    if (mounted) {
      setState(() {
        _confirmations = confirmations;
        _isConfirmed = _confirmations[User().id.toString()] ?? false;
      });
    }
  }

  void updateOpponentCard(PlayerCard card) {
    if (mounted) {
      setState(() {
        _selectedOpponentCard = card;
      });
    }
  }

  Future<void> _loadPlayerCards() async {
    try {
      final cards = await apiService.getCollection();
      
      if (!mounted) return;

      setState(() {
        _playerCards = cards;
        _filteredPlayerCards = List.from(_playerCards);
        _filteredPlayerCardWidgets = _filteredPlayerCards
            .map((card) => 
                PlayerCardWidget(
                  key: Key('card-${card.id}'),
                  playerCard: card, 
                  size: "sm"
              ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showCustomSnackBar(
          type: SnackBarType.error,
          message: '${AppLocalizations.of(context)!.error_loading_players} ${e.toString()}',
        );
      }
    }
  }

  void _handleExchange() {
    if (!_isLoading) {
      setState(() => _isExchangeActive = !_isExchangeActive);
      if (_isConfirmed) {
        _socketService.cancelConfirmation(widget.exchangeId);
      } else {
        if (_selectedUserCard == null){
          showCustomSnackBar(
            type: SnackBarType.error,
            message: AppLocalizations.of(context)!.must_select_card,
          );
          _isConfirmed = false;
          return;
        }

        setState(() {
          _isConfirmed = true;
          _isExchangeActive = true;
        });
        _socketService.confirmExchange(widget.exchangeId);
      }
    }
  }

  void _showCancelExchangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cancel_exchange),
        content: Text(AppLocalizations.of(context)!.cancel_exchange_msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            key: Key('confirm-cancel-exchange-button'),
            onPressed: () {
              _socketService.cancelExchange(widget.exchangeId);
              Navigator.pop(context); 
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  void _selectCard(card) {
    setState(() => _selectedUserCard = card);
    _socketService.selectCard(widget.exchangeId, card.id);
  }

  void _updateFilteredItems(List<PlayerCard> filteredItems) {
    setState(() {
      _filteredPlayerCards = filteredItems;
      _filteredPlayerCardWidgets = _filteredPlayerCards.map((card) => PlayerCardWidget(
        playerCard: card,
        size: "sm",
      )).toList();
    });
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: ScreenSize.of(context).height * 0.025),
          Text(
            AppLocalizations.of(context)!.waiting,
            style: TextStyle(color: Colors.white, fontSize: 16),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    if (_isLoading) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(),
        body: _buildLoadingIndicator(),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.exchange,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: screenSize.height * 0.03,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/soccer_field.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.01,
            right: screenSize.width * 0.03,
            child: SizedBox(
              height: screenSize.height * 0.045,
              child: TextButton(
                key: Key('cancel-exchange-button'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.04,
                    vertical: screenSize.height *0.005,
                  ),
                ),
                onPressed: () => _showCancelExchangeDialog(),
                child: Text(
                  AppLocalizations.of(context)!.abandon,
                  style: TextStyle(
                    fontSize: screenSize.height * 0.015,
                  ),),
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.05,
            left: screenSize.width * 0.05,
            right: screenSize.width * 0.05,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlayerCardColumn(
                      key : Key('user-card'),
                      card: _selectedUserCard ?? returnEmptyCard(),
                      label: AppLocalizations.of(context)!.you,
                      isCurrentUser: true,
                    ),
                    Icon(Icons.swap_horiz, color: Colors.white, size: 30),
                    _buildPlayerCardColumn(
                      key : Key('opponent-card'),
                      card: _selectedOpponentCard ?? returnEmptyCard(),
                      label: widget.opponentUsername ?? AppLocalizations.of(context)!.loading_user,
                      isCurrentUser: false,
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.02),
                ElevatedButton(
                  onPressed: _handleExchange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConfirmed ? Colors.red : theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.1,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    key: Key('confirm-exchange-button'),
                    _isConfirmed 
                        ? AppLocalizations.of(context)!.cancel_exchange
                        : AppLocalizations.of(context)!.confirm_exchange,
                    style: TextStyle(
                      fontSize: screenSize.height * 0.018,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenSize.height * 0.4,
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
            ),
            child: Panel(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.5,
              content: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: screenSize.height * 0.1,
                        child: CustomSearchMenu<PlayerCard>(
                          items: _playerCards,
                          getItemName: (playerCard) => 
                              '${playerCard.playerName} ${playerCard.playerSurname}',
                          onFilteredItemsChanged: _updateFilteredItems,
                        ),
                      ),
                      Expanded(
                        child: CardCollection(
                          key: Key('card-collection'),
                          playerCardWidgets: _filteredPlayerCardWidgets,
                          onCardTap: _isExchangeActive
                              ? (card) {}
                              : (card) => _selectCard(card),
                        ),
                      ),
                    ],
                  ),
                  if (_isExchangeActive)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.block,
                                color: Colors.white60,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text(
                                key: Key('cant-select-text'),
                                AppLocalizations.of(context)!.cant_select,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCardColumn({
    required Key key,
    required PlayerCard card,
    required String label,
    required bool isCurrentUser,
  }) {
    final currentUserId = User().id.toString();
    final opponentId = _confirmations.keys.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    
    final isConfirmed = isCurrentUser 
        ? _confirmations[currentUserId] ?? false
        : _confirmations[opponentId] ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayerCardWidget(
          key: key,
          playerCard: card, 
          size: "sm"
        ),
        SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenSize.of(context).height * 0.018,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: isConfirmed
                  ? Icon(Icons.check_circle, 
                        color: Colors.green, 
                        size: 16,
                        key: ValueKey('confirmed_$label'))
                  : Icon(Icons.pending, 
                        color: Colors.amber, 
                        size: 16,
                        key: ValueKey('pending_$label')),
            ),
          ],
        ),
      ],
    );
  }
}