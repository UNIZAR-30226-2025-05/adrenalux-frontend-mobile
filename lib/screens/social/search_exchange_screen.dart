import 'package:adrenalux_frontend_mobile/screens/social/exchange_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestExchangeScreen extends StatefulWidget {
  @override
  _RequestExchangeScreenState createState() => _RequestExchangeScreenState();
}

class _RequestExchangeScreenState extends State<RequestExchangeScreen> {
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _filteredFriends = [];
  bool _loading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await getFriends();
      if (mounted) {
        setState(() {
          _friends = friends;
          _filteredFriends = friends;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: AppLocalizations.of(context)!.err_load_friends + ': ${e.toString()}',
          duration: 5,
        );
        if (kDebugMode) {
          setState(() {
            _friends = getMockFriends();
            _filteredFriends = getMockFriends();
            _loading = false;
          });
        }
      }
    }
  }

  void _updateFilteredItems(List<Map<String, dynamic>> filteredItems) {
    setState(() {
      _filteredFriends = filteredItems;
    });
  }

  Widget _buildFriendItem(Map<String, dynamic> friend, ThemeData theme, ScreenSize screenSize) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.005,
        horizontal: screenSize.width * 0.02,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _handleExchange(friend['id']),
        leading: CircleAvatar(
          radius: screenSize.width * 0.05,
          backgroundImage: (friend['avatar'] as String).isNotEmpty
              ? AssetImage(friend['avatar'])
              : const AssetImage('assets/default_profile.jpg') as ImageProvider,
          onBackgroundImageError: (_, __) => 
              const AssetImage('assets/default_profile.jpg'),
        ),
        title: Text(
          friend['name'],
          style: TextStyle(
            fontSize: screenSize.height * 0.02,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
  bool _reqExchange = false;

  void _handleExchange(String idFriend) async {
    final friend = _filteredFriends.firstWhere(
      (f) => f['id'] == idFriend,
      orElse: () => {'name': 'Amigo', 'id': idFriend},
    );
    final friendName = friend['name'];

    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _reqExchange = true;
        return _buildWaitingDialog(
          context,
          theme,
          screenSize,
          friendName,
          friend['id'],
        );
      },
    ).then((_) => _reqExchange = false);

    _setupWebSocketListener(friend['id']);
  }

  Widget _buildWaitingDialog(BuildContext context, ThemeData theme, 
      ScreenSize screenSize, String friendName, String friendId) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Column(
          children: [
            SizedBox(height: screenSize.height * 0.01),
            Text(
              AppLocalizations.of(context)!.waiting,
              style: TextStyle(
                fontSize: screenSize.height * 0.025,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              friendName,
              style: TextStyle(
                fontSize: screenSize.height * 0.03,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: screenSize.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: screenSize.height * 0.03),
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: screenSize.height * 0.01),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => _cancelExchange(friendId),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: Text(
                AppLocalizations.of(context)!.cancel_exchange,
                style: TextStyle(
                  fontSize: screenSize.height * 0.018,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setupWebSocketListener(int friendId) {

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExchangeScreen(
        ),
      ),
    );
  }

  void _cancelExchange(String friendId) async {
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.err_cancel_exchange + ': ${e.toString()}',
        duration: 3,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    double padding = screenSize.width * 0.05;
    double avatarSize = screenSize.width * 0.3;
    double iconSize = screenSize.width * 0.07;

    return Scaffold(
      key: _scaffoldKey,
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
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Panel(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.8,
              content: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.02),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.choose_player,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: screenSize.height * 0.02,
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SizedBox(
                    height: screenSize.height * 0.08,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: screenSize.height * 0.6, 
                            ),
                            child: CustomSearchMenu<Map<String, dynamic>>(
                              items: _friends,
                              getItemName: (friend) => friend['name'],
                              onFilteredItemsChanged: _updateFilteredItems,
                            ),
                          )
                        ),
                        SizedBox(width: screenSize.width * 0.03),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : _filteredFriends.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context)!.no_friends,
                                  style: TextStyle(
                                    fontSize: screenSize.height * 0.025,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.only(
                                  top: screenSize.height * 0.01,
                                  bottom: screenSize.height * 0.1,
                                ),
                                itemCount: _filteredFriends.length,
                                itemBuilder: (context, index) => _buildFriendItem(
                                  _filteredFriends[index],
                                  theme,
                                  screenSize,
                                ),
                              ),
                  ),
                ],
              ),
            ),
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