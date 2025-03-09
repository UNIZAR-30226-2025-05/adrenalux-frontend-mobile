import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card_collection.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
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

class _ExchangeScreenState extends State<ExchangeScreen> {
  List<PlayerCard> _filteredPlayerCards = [];
  List<PlayerCard> _playerCards = [];
  List<PlayerCardWidget> _filteredPlayerCardWidgets = [];
  bool _isLoading = true;
  bool _isConfirmed = false;
  bool _isExchangeActive = false;
  PlayerCard? _selectedUserCard;
  PlayerCard? _selectedOpponentCard;
  late SocketService _socketService;

  // Tarjeta vacía por defecto
  final PlayerCard _emptyCard = PlayerCard(
    id: 0,
    playerName: '',
    playerSurname: '',
    averageScore: 0,
    position: '',
    amount: 0,
    shot: 0,
    defense: 0,
    control: 0,
    price: 0,
    rareza: CARTA_NORMAL,
    playerPhoto: '',
    team: '',
    teamLogo: '',
  );

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _loadPlayerCards();
  }

  Future<void> _loadPlayerCards() async {
    try {
      final cards = await getCollection();
      
      if (!mounted) return;

      setState(() {
        _playerCards = cards;
        _filteredPlayerCards = List.from(_playerCards);
        _filteredPlayerCardWidgets = _filteredPlayerCards
            .map((card) => PlayerCardWidget(playerCard: card, size: "sm"))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showCustomSnackBar(
          type: SnackBarType.error,
          message: 'Error loading cards: ${e.toString()}',
        );
      }
    }
  }

  void _handleExchange() {
    if (!_isLoading) {
      setState(() {
        _isConfirmed = !_isConfirmed;
        _isExchangeActive = _isConfirmed;
      });
    }
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
          centerTitle: true,
        ),
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
                      card: _selectedUserCard ??
                          _playerCards.firstWhere(
                              (card) => card.id == _emptyCard.id,
                              orElse: () => _emptyCard),
                      label: AppLocalizations.of(context)!.you,
                    ),
                    Icon(Icons.swap_horiz, color: Colors.white, size: 30),
                    _buildPlayerCardColumn(
                      card: _selectedOpponentCard ??
                          _playerCards.lastWhere(
                              (card) => card.id == _emptyCard.id,
                              orElse: () => _emptyCard),
                      label: widget.opponentUsername ??
                          AppLocalizations.of(context)!.loading_user,
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.02),
                ElevatedButton(
                  onPressed: _handleExchange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isConfirmed ? Colors.red : theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.1,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
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
                          playerCardWidgets: _filteredPlayerCardWidgets,
                          onCardTap: _isExchangeActive
                              ? (card) {}
                              : (card) => setState(() => _selectedUserCard = card),
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
    required PlayerCard card,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayerCardWidget(playerCard: card, size: "sm"),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenSize.of(context).height * 0.018,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _socketService.cancelExchangeRequest(widget.exchangeId);
    super.dispose();
  }
}