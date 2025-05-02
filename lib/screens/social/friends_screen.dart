import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/screens/home/profile_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/constants/keys.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late ApiService apiService;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext? get safeContext => navigatorKey.currentContext;
  late SocketService _socketService;

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _filteredFriends = [];
  bool _loading = true;
  
  bool _showFriends = true;
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  bool _loadingRequests = false;

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false); 
    _socketService = Provider.of<SocketService>(context, listen: false);
    _loadFriends();
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    try {
      setState(() => _loadingRequests = true);
      final requests = await apiService.getFriendRequests();
      if (mounted) {
        setState(() {
          _friendRequests = requests;
          _filteredRequests = requests;
          _loadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: '${AppLocalizations.of(context)!.err_load_friend_req}: ${e.toString()}',
          duration: 5,
        );
      }
    }
  }

  Future<void> _loadFriends() async {
    try {
      setState(() => _loading = true);
      final friends = await apiService.getFriends();
      if (mounted) {
        setState(() {
          _friends = friends.map((friend) {
            return {
              'id': friend['id'],
              'friend_code': friend['friend_code'],
              'username': friend['username'],
              'name': friend['name'],
              'lastname': friend['lastname'],
              'avatar': (friend['avatar'] as String).replaceFirst(RegExp(r'^/'), ''),
              'level': friend['level'],
              'isConnected': friend['isConnected'],
            };
          }).toList();
          _filteredFriends = List.from(_friends);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message:AppLocalizations.of(context)!.err_load_friends,
          duration: 5,
        );
      }
    }
  }

  Widget _buildEmptyState(String text, ThemeData theme, double scaleFactor) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16 * scaleFactor,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  void _updateFilteredItems(List<Map<String, dynamic>> filteredItems) {
    setState(() {
      _filteredFriends = filteredItems;
    });
  }

  void _sendRequest(String friendCode) async {
    try {
      final success = await apiService.sendFriendRequest(friendCode);
      if (success) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        showCustomSnackBar(
          type: SnackBarType.success, 
          message:AppLocalizations.of(context)!.friend_request_sent,
          duration: 3
        );
        _loadFriendRequests(); 
      }
    } catch (e) {
      if(kDebugMode) {
        showCustomSnackBar(
          type: SnackBarType.error, 
          message: e.toString().replaceAll("Exception: ", ""), 
          duration: 5
        );
      }
    } 
  }

  double _getScaleFactor(ScreenSize screenSize) {
    final shortestSide = min(screenSize.width, screenSize.height);
    return (shortestSide / 400).clamp(0.8, 2.0);
  }

  void _showAddFriendDialog() {
    final scaleFactor = _getScaleFactor(ScreenSize.of(context));
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scaleFactor),
          ),
          title: Text(
            AppLocalizations.of(context)!.add_friend,
            style: TextStyle(fontSize: 18 * scaleFactor),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300 * scaleFactor),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _codeController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.friend_code,
                  labelStyle: TextStyle(fontSize: 14 * scaleFactor),
                  contentPadding: EdgeInsets.all(12 * scaleFactor),
                  errorStyle: TextStyle(
                    fontSize: 12 * scaleFactor,
                    color: Colors.redAccent,
                  ),
                ),
                validator: (value) {
                  final trimmedValue = value?.trim() ?? '';
                  if (trimmedValue.isEmpty) {
                    return AppLocalizations.of(context)!.requiredField;
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(fontSize: 14 * scaleFactor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _sendRequest(_codeController.text.trim());
                }
              },
              child: Text(
                AppLocalizations.of(context)!.add,
                style: TextStyle(fontSize: 14 * scaleFactor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestItem(Key key, Map<String, dynamic> request, ThemeData theme, double scaleFactor) {
    final sender = request['sender'] as Map<String, dynamic>;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8 * scaleFactor,
        horizontal: 16 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12 * scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4 * scaleFactor,
            offset: Offset(0, 2 * scaleFactor),
          ),
        ],
      ),
      child: ListTile(
        key: key,
        leading: CircleAvatar(
          radius: 24 * scaleFactor,
          backgroundImage: AssetImage(sender['avatar'] ?? ''),
          onBackgroundImageError: (_, __) => 
              const AssetImage('assets/default_profile.jpg'),
        ),
        title: Text(
          sender['username'] ?? '',
          style: TextStyle(
            fontSize: 16 * scaleFactor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${sender['name']} ${sender['lastname']}',
          style: TextStyle(
            fontSize: 14 * scaleFactor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green, size: 24 * scaleFactor),
              onPressed: () => _handleAcceptRequest(request['id']),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red, size: 24 * scaleFactor),
              onPressed: () => _handleDeclineRequest(request['id']),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAcceptRequest(String id) async {
    final success = await apiService.acceptRequest(id);

    if(success) {
      _loadFriendRequests();
      showCustomSnackBar(type: SnackBarType.success, message:AppLocalizations.of(context)!.friend_request_accepted, duration: 3);
    } else {
      showCustomSnackBar(type: SnackBarType.error, message:AppLocalizations.of(context)!.err_accept_friend_request, duration: 3);
    }
  }
  void _handleDeclineRequest(String id) async {
    final success = await apiService.declineRequest(id) ?? false;

    if(success) {
      _loadFriendRequests();
      showCustomSnackBar(type: SnackBarType.info, message:AppLocalizations.of(context)!.friend_request_declined,duration: 3);
    } else {
      showCustomSnackBar(type: SnackBarType.error, message:AppLocalizations.of(context)!.err_decline_friend_request, duration: 3);
    }
  }
  
  _navigateToViewProfile(friendId, isConnected) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(friendId: friendId, connected: isConnected),
      ),
    );
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
              key: Key('cancel_exchange_button'),
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

  void _cancelExchange(String friendId) async {
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      if(kDebugMode) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message:AppLocalizations.of(context)!.err_cancel_exchange + ': ${e.toString()}',
          duration: 3,
        );
      }
    }
  }

  void _handleBattle(String idFriend, bool isConnected) {
    if (!isConnected) {
      showCustomSnackBar(
        type: SnackBarType.info,
        message: AppLocalizations.of(context)!.err_battle,
        duration: 3,
      );
      return;
    }

    final friend = _friends.firstWhere(
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
        return _buildBattleWaitingDialog(
          context,
          theme,
          screenSize,
          friendName,
          friend['id'],
        );
      },
    ).then((_) {});

    _socketService.sendMatchRequest(friend['id'], User().name);
  }

  Widget _buildBattleWaitingDialog(BuildContext context, ThemeData theme, 
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
              AppLocalizations.of(context)!.waiting_battle,
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
              onPressed: () => _cancelBattle(friendId),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: Text(
                AppLocalizations.of(context)!.cancel_battle,
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

  void _cancelBattle(String friendId) async {
    try {
      Navigator.of(context, rootNavigator: true).pop();
      _socketService.cancelMatchRequest(friendId);
    } catch (e) {
      if(kDebugMode) {
        showCustomSnackBar(
          type: SnackBarType.error,
          message: AppLocalizations.of(context)!.err_cancel_battle + ': ${e.toString()}',
          duration: 3,
        );
      }
    }
  }

  Widget _buildFriendItem(Key key, Map<String, dynamic> friend, ThemeData theme, double scaleFactor) {
    return Container(
      margin: EdgeInsets.all(16 * scaleFactor),
      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor), 
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12 * scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4 * scaleFactor,
            offset: Offset(0, 2 * scaleFactor),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _navigateToViewProfile(friend['id'], friend['isConnected']),
        key: key,
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: friend['isConnected'] ? Colors.green : Colors.red,
              width: 2 * scaleFactor,
            ),
          ),
          child: CircleAvatar(
            radius: 22 * scaleFactor,
            backgroundImage: AssetImage(friend['avatar'] ?? ''),
          ),
        ),
        title: Text(
          friend['name'],
          style: TextStyle(
            fontSize: 16 * scaleFactor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.sports_esports,
                size: 24 * scaleFactor,
                color: friend['isConnected'] ? Colors.blue : Colors.grey,
              ),
              onPressed: () => _handleBattle(friend['id'], friend['isConnected']),
            ),
            IconButton(
              icon: Icon(
                Icons.swap_horiz,
                size: 24 * scaleFactor,
                color: friend['isConnected'] ? Colors.green : Colors.grey,
              ),
              onPressed: () => _handleExchange(friend['id'], friend['isConnected']),
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                size: 24 * scaleFactor,
                color: Colors.red,
              ),
              onPressed: () => _showDeleteConfirmationDialog(friend['id']),
            ),
          ],
        ),
      ),
    );
  }

  void _handleExchange(String idFriend, bool isConnected) {
    if (!isConnected) {
      showCustomSnackBar(type: SnackBarType.info, message:AppLocalizations.of(context)!.err_exchange, duration: 3);
      return;
    }

    final friend = _friends.firstWhere(
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
        return _buildWaitingDialog(
          context,
          theme,
          screenSize,
          friendName,
          friend['id'],
        );
      },
    ).then((_) {});

    _socketService.sendExchangeRequest(friend['id'], User().name);
  }

  void _handleDelete(String idFriend) async {
    final success = await apiService.deleteFriend(idFriend) ?? false;

    if(success) {
      _loadFriends();
      showCustomSnackBar(type: SnackBarType.info, message:AppLocalizations.of(context)!.friend_deleted, duration: 3);
    } else {
      showCustomSnackBar(type: SnackBarType.error, message:AppLocalizations.of(context)!.err_friend_deleted, duration: 3);
    }
  }

  void _showDeleteConfirmationDialog(String friendId) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);
    final friend = _friends.firstWhere((f) => f['id'] == friendId, orElse: () => {'name': ''});

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          AppLocalizations.of(context)!.delete_friends_text,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: screenSize.height * 0.025,
          ),
        ),
        content: Text(
          "${AppLocalizations.of(context)!.delete_friends_confirmation} ${friend['name']}?",
          style: TextStyle(
            fontSize: screenSize.height * 0.02,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              key: Key('cancel_delete_button'),
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDelete(friendId);
            },
            child: Text(
              key: Key('confirm_delete_button'),
              AppLocalizations.of(context)!.confirm,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(ThemeData theme, double scaleFactor) {
    return Center(
      child: CircularProgressIndicator(
        color: theme.colorScheme.primary,
        strokeWidth: 2 * scaleFactor,
      ),
    );
  }

  Widget _buildFriendList(ThemeData theme, ScreenSize screenSize, double scaleFactor) {
    if (_loading) return _buildLoading(theme, scaleFactor);
    return _filteredFriends.isEmpty 
        ? _buildEmptyState(AppLocalizations.of(context)!.no_friends, theme, scaleFactor)
        : ListView.builder(
            itemCount: _filteredFriends.length,
            itemBuilder: (_, i) => _buildFriendItem(
              Key('friend_item_${_filteredFriends[i]['id']}'),
              _filteredFriends[i], 
              theme, 
              scaleFactor
            ),
          );
  }

  Widget _buildRequestList(ThemeData theme, ScreenSize screenSize, double scaleFactor) {
    if (_loadingRequests) return _buildLoading(theme, scaleFactor);
    return _filteredRequests.isEmpty
        ? _buildEmptyState(AppLocalizations.of(context)!.no_friend_req, theme, scaleFactor)
        : ListView.builder(
            itemCount: _filteredRequests.length,
            itemBuilder: (_, i) => _buildRequestItem(
              Key('request_item_${_filteredRequests[i]['id']}'),
              _filteredRequests[i], 
              theme, 
              scaleFactor
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final scaleFactor = _getScaleFactor(screenSize);
    final appBarHeight = 56.0 * scaleFactor;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: theme.colorScheme.surface,
          centerTitle: true,
          leading: SizedBox(width: 40 * scaleFactor),
          title: Text(
            AppLocalizations.of(context)!.friends,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 20 * scaleFactor,
            ),
          ),
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
            padding: EdgeInsets.all(16 * scaleFactor),
            child: Panel(
              width: screenSize.width,
              height: screenSize.height * 0.85,
              content: Column(
                children: [       
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: screenSize.height * 0.6,
                      ),
                      child: CustomSearchMenu<Map<String, dynamic>>(
                        key: ValueKey(_showFriends), 
                        items: _showFriends ? _friends : _friendRequests,
                        getItemName: (item) => item['name'],
                        onFilteredItemsChanged: (filtered) {
                          if (_showFriends) {
                            _updateFilteredItems(filtered);
                          } else {
                            setState(() => _filteredRequests = filtered);
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24 * scaleFactor,
                      vertical: 8 * scaleFactor
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.person_add_alt_1,
                              size: 24 * scaleFactor,
                              color: theme.colorScheme.onPrimary,
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.add,
                              style: TextStyle(
                                fontSize: 14 * scaleFactor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: EdgeInsets.all(12 * scaleFactor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10 * scaleFactor),
                              ),
                            ),
                            onPressed: _showAddFriendDialog,
                          ),
                        ),
                        SizedBox(width: 12 * scaleFactor),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  _showFriends ? Icons.mail : Icons.group,
                                  size: 24 * scaleFactor,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                if (_showFriends && _friendRequests.isNotEmpty)
                                  Positioned(
                                    top: -4 * scaleFactor,
                                    right: -4 * scaleFactor,
                                    child: Container(
                                      width: 16 * scaleFactor,
                                      height: 16 * scaleFactor,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            label: Text(
                              key: Key('alternate_button'),
                              _showFriends ? AppLocalizations.of(context)!.requests : AppLocalizations.of(context)!.friends,
                              style: TextStyle(
                                fontSize: 14 * scaleFactor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: EdgeInsets.all(12 * scaleFactor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10 * scaleFactor),
                              ),
                            ),
                            onPressed: () {
                              if (_showFriends) {
                                if (_friendRequests.isEmpty && !_loadingRequests) {
                                  _loadFriendRequests();
                                }
                                setState(() => _showFriends = false);
                              } else {
                                setState(() => _showFriends = true);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                              strokeWidth: 2 * scaleFactor,
                            ),
                          )
                        : _showFriends
                            ? _buildFriendList(theme, screenSize, scaleFactor)
                            : _buildRequestList(theme, screenSize, scaleFactor),
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