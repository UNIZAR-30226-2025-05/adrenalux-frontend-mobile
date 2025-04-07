import 'dart:async';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/close_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestExchangeScreen extends StatefulWidget {
  @override
  _RequestExchangeScreenState createState() => _RequestExchangeScreenState();
}

class _RequestExchangeScreenState extends State<RequestExchangeScreen> {
  late ApiService apiService;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _filteredFriends = [];
  bool _loading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final StreamController<bool> _exchangeStatusController = StreamController<bool>();
  late SocketService _socketService;
  String? _currentExchangeId;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false); 
    _loadFriends();
    _socketService = SocketService();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await apiService.getFriends();
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
            _friends = apiService.getMockFriends();
            _filteredFriends = apiService.getMockFriends();
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

  void _handleExchange(String idFriend, bool isConnected) async {

    if (!isConnected) {
      showCustomSnackBar(type: SnackBarType.info, message:AppLocalizations.of(context)!.err_exchange, duration: 3);
      return;
    }

    _socketService.sendExchangeRequest(idFriend, User().name);
    
    showDialog(
      context: context,
      builder: (context) => _buildExchangeStatusDialog(),
    );
  }

  Widget _buildExchangeStatusDialog() {
    return StreamBuilder<bool>(
      stream: _exchangeStatusController.stream,
      builder: (context, snapshot) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.exchange),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (snapshot.data != true)
                CircularProgressIndicator(),
              if (snapshot.data == true)
                Icon(Icons.check_circle, color: Colors.green),
              SizedBox(height: ScreenSize.of(context).height * 0.025), 
              Text(_getStatusMessage(snapshot.data)),
            ],
          ),
          actions: [
            if (snapshot.data != true)
              TextButton(
                onPressed: () {
                  if (_currentExchangeId != null) {
                    _socketService.cancelExchangeRequest(_currentExchangeId!);
                  }
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              )
          ],
        );
      },
    );
  }


  String _getStatusMessage(bool? status) {
    if (status == null) return AppLocalizations.of(context)!.waiting_response;
    return status ? AppLocalizations.of(context)!.exchange_accepted : AppLocalizations.of(context)!.exchange_declined;
  }

  @override
  void dispose() {
    super.dispose();
    _exchangeStatusController.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(theme, screenSize, isSmallScreen),
      body: Stack(
        children: [
          _buildBackground(),
          _buildMainContent(theme, screenSize, isSmallScreen),
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

  PreferredSizeWidget _buildAppBar(ThemeData theme, ScreenSize screenSize, bool isSmallScreen) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.surface,
      elevation: 1,
      title: Text(
        AppLocalizations.of(context)!.exchange,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/soccer_field.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.15),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, ScreenSize screenSize, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchSection(theme, screenSize),
                  SizedBox(height: 16),
                  Expanded(child: _buildFriendsList(theme, screenSize, isSmallScreen)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(ThemeData theme, ScreenSize screenSize) {
    return SearchBar(
      elevation: MaterialStateProperty.all(1.0),
      backgroundColor: MaterialStateProperty.all(theme.colorScheme.surfaceContainerHigh),
      hintText: AppLocalizations.of(context)!.search,
      leading: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
      onChanged: (value) => _updateFilteredItems(
        _friends.where((friend) => friend['name'].toLowerCase().contains(value.toLowerCase())).toList(),
      ),
    );
  }

  Widget _buildFriendsList(ThemeData theme, ScreenSize screenSize, bool isSmallScreen) {
    if (_loading) return _buildLoadingState(theme);
    if (_filteredFriends.isEmpty) return _buildEmptyState(theme);

    return GridView.builder(
      padding: EdgeInsets.only(bottom: 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredFriends.length,
      itemBuilder: (context, index) => _buildFriendCard(_filteredFriends[index], theme),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleExchange(friend['id'], friend['isConnected']),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage(friend['avatar']?.isNotEmpty == true 
                        ? friend['avatar'] 
                        : 'assets/default_profile.jpg'),
                  ),
                  if (friend['isConnected'])
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.circle, 
                          size: 12, 
                          color: theme.colorScheme.onTertiaryContainer),
                    ),
                ],
              ),
              SizedBox(height: 12),
              Text(friend['name'],
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 8),
              Icon(Icons.swap_horiz, 
                  color: theme.colorScheme.primary,
                  size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.loading,
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, 
              size: 64, 
              color: theme.colorScheme.onSurfaceVariant),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.no_friends,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center),
          SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _loadFriends,
            icon: Icon(Icons.refresh),
            label: Text("Volver a intentar"),
          ),
        ],
      ),
    );
  }
}