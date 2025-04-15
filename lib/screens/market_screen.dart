import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/widgets/close_button_widget.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/card_collection.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late ApiService apiService;
  List<PlayerCard> _filteredPlayerCards = [];
  List<PlayerCard> _playerCards = [];
  List<PlayerCard> _dailyLuxuries = [];
  List<PlayerCardWidget> _filteredPlayerCardWidgets = [];
  bool _marketLoaded = false;
  bool _dailyLoaded = false;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false); 
    _loadMarketCards();
    _loadDailyLuxuries();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadMarketCards() async {
    try {
      _playerCards = await apiService.getMarket();
      if (mounted) {
        setState(() {
          _filteredPlayerCards = _playerCards;
          _filteredPlayerCardWidgets = _playerCards.map((card) => 
            PlayerCardWidget(playerCard: card, size: "sm")
          ).toList();
          _marketLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error en _loadMarketCards: $e');
      if (mounted) {
        setState(() => _marketLoaded = true);
      }
    }
  }

  void _loadDailyLuxuries() async {
    try {
      final dailyCards = await apiService.getDailyLuxuries();
      if (mounted) {
        setState(() {
          _dailyLuxuries = dailyCards;
          _dailyLoaded = true;
        });
      }
    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: "${AppLocalizations.of(context)!.err_load_daily_cards}: $e",
        duration: 3,
      );
      if (mounted) {
        setState(() => _dailyLoaded = true);
      }
    }
  }

  void _updateFilteredItems(List<PlayerCard> filteredItems) {
    setState(() { 
      _filteredPlayerCards = filteredItems;
      _filteredPlayerCardWidgets = _filteredPlayerCards.map((card) => 
        PlayerCardWidget(
          playerCard: card,
          size: "sm",
        ),
      ).toList();
    });
  }

  void _onCardTap(PlayerCard playerCard) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);
    bool isDailyCard = _dailyLuxuries.any((c) => c.id == playerCard.id);
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05,
            vertical: screenSize.height * 0.02,
          ),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenSize.width * 0.03),
          ),
          title: SizedBox(
            width: double.maxFinite,
            child: Text(
              AppLocalizations.of(context)!.buy_confirm,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenSize.height * 0.022,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          content: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormat("#,##0", "es_ES").format(playerCard.price),
                  style: TextStyle(
                    fontSize: screenSize.height * 0.024,
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.02),
                Image.asset(
                  'assets/moneda.png',
                  width: screenSize.height * 0.028,
                  height: screenSize.height * 0.028,
                ),
                Text(
                  '?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.height * 0.022,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(top: screenSize.height * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: isProcessing ? null : () => Navigator.pop(context),
                     style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.05,
                          vertical: screenSize.height * 0.015),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                        fontSize: screenSize.height * 0.018,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  ElevatedButton(
                    onPressed: isProcessing ? null : () async {
                      final User user = User();
                      if (playerCard.price > user.adrenacoins) {
                        Navigator.of(dialogContext).pop(); 
                        showCustomSnackBar(
                          type: SnackBarType.error,
                          message: AppLocalizations.of(context)!.err_no_coins,
                          duration: 3,
                        );
                        return;
                      }
                      setState(() => isProcessing = true);
                      try {
                        if (isDailyCard) {
                          await apiService.purchaseDailyCard(playerCard.marketId);
                        } else {
                          await apiService.purchaseMarketCard(playerCard.marketId);
                        }
                        
                        _loadMarketCards();
                        _loadDailyLuxuries();
                        Navigator.of(dialogContext).pop();

                        showCustomSnackBar(
                          type: SnackBarType.success,
                          message: AppLocalizations.of(context)!.card_added,
                          duration: 3
                        );
                      } catch (e) {
                        Navigator.of(dialogContext).pop();
                        showCustomSnackBar(
                          type: SnackBarType.error,
                          message: "${e.toString().replaceFirst('Exception:', '').trim()}",
                          duration: 3
                        );
                      } finally {
                        setState(() => isProcessing = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.05,
                          vertical: screenSize.height * 0.015),
                      backgroundColor: isProcessing 
                        ? Colors.grey 
                        : theme.colorScheme.primary,
                    ),
                    child: isProcessing
                    ? SizedBox(
                        width: screenSize.height * 0.018,
                        height: screenSize.height * 0.018,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.accept,
                        style: TextStyle(
                          fontSize: screenSize.height * 0.018,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarInfo(User user, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                key: Key('user-coins'),
                '${user.adrenacoins}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14),
              ),
              SizedBox(width: 4),
              Image.asset(
                'assets/moneda.png',
                width: 20,
                height: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);

    final dailySectionHeight = screenSize.height * 0.225;
    final priceIconSize = screenSize.height * 0.02;
    final verticalSpacing = screenSize.height * 0.02;
    final horizontalPadding = screenSize.width * 0.05;
    final User user = User();
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          title: Stack( 
            children : [
              Center(
                child: Text(
                  AppLocalizations.of(context)!.market,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: screenSize.height * 0.028,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.4 ),
                  child: _buildAppBarInfo(user, theme),
                ),
              ),
            ]
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
                  fit: BoxFit.cover)),
          ),
          if (_marketLoaded && _dailyLoaded) ...[
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Panel(
                width: screenSize.width * 0.9,
                height: screenSize.height * 0.82,
                content: Column(
                  children: [
                    SizedBox(height: verticalSpacing),
                    Text(
                      AppLocalizations.of(context)!.daily_luxuries,
                      style: TextStyle(
                        fontSize: screenSize.height * 0.025,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: verticalSpacing * 0.5,
                          horizontal: screenSize.width * 0.03),
                      child: Divider(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        thickness: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: dailySectionHeight,
                      child: _dailyLuxuries.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _dailyLuxuries.map((playerCard) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _onCardTap(playerCard),
                                      child: PlayerCardWidget(
                                        playerCard: playerCard,
                                        size: "sm",
                                      ),
                                    ),
                                    SizedBox(height: screenSize.height * 0.008),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          NumberFormat.decimalPattern()
                                              .format(playerCard.price),
                                          style: TextStyle(
                                            fontSize: screenSize.height * 0.013,
                                            color: theme.colorScheme.inverseSurface,
                                          ),
                                        ),
                                        SizedBox(width: screenSize.width * 0.008),
                                        Image.asset(
                                          'assets/moneda.png',
                                          width: priceIconSize,
                                          height: priceIconSize,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          : Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                child: Text(
                                  key: Key('no-cards-available'),
                                  AppLocalizations.of(context)!.no_cards_found,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenSize.height * 0.022,
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: verticalSpacing,
                          horizontal: screenSize.width * 0.03),
                      child: Divider(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        thickness: 1.0,
                      ),
                    ),
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
                        onCardTap: _onCardTap,
                      ),
                    ),
                  ],
                ),
              ),
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
          if (!_marketLoaded || !_dailyLoaded)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}