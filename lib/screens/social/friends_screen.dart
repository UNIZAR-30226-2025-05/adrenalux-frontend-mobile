import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/constants/keys.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/screens/social/view_profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
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

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _loadFriends();
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    try {
      setState(() => _loadingRequests = true);
      final requests = await getFriendRequests();
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
          message: AppLocalizations.of(context)!.err_load_friend_req + ': ${e.toString()}',
          duration: 5,
        );
      }
    }
  }

  Future<void> _loadFriends() async {
    try {
      setState(() => _loading = true);
      final friends = await getFriends();
      if (mounted) {
        setState(() {
          _friends = friends.map((friend) {
            return {
              'id': friend['id'],
              'username': friend['username'],
              'name': friend['name'],
              'lastname': friend['lastname'],
              'avatar': friend['avatar'],
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

  Widget _buildEmptyState(String text, ThemeData theme, ScreenSize screenSize) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenSize.height * 0.025,
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
      final success = await sendFriendRequest(friendCode);
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
      showCustomSnackBar(
        type: SnackBarType.error, 
        message: e.toString().replaceAll("Exception: ", ""), 
        duration: 5
      );
    } 
  }

  void _showAddFriendDialog() {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final screenSize = ScreenSize.of(context);
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            AppLocalizations.of(context)!.add_friend,
            style: TextStyle(
              fontSize: screenSize.height * 0.025,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          content: SizedBox(
            width: screenSize.width * 0.8,
            child: TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.friend_code,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.code),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => _sendRequest(codeController.text),
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request, ThemeData theme, ScreenSize screenSize) {
    final sender = request['sender'] as Map<String, dynamic>;
    
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
        leading: CircleAvatar(
          radius: screenSize.width * 0.05,
          backgroundImage: AssetImage(sender['avatar'] ?? ''),
          onBackgroundImageError: (_, __) => 
              const AssetImage('assets/default_profile.jpg'),
        ),
        title: Text(
          sender['username'] ?? '',
          style: TextStyle(
            fontSize: screenSize.height * 0.02,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          '${sender['name']} ${sender['lastname']}',
          style: TextStyle(
            fontSize: screenSize.height * 0.016,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green, size: screenSize.height * 0.025),
              onPressed: () => _handleAcceptRequest(request['id']),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red, size: screenSize.height * 0.025),
              onPressed: () => _handleDeclineRequest(request['id']),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAcceptRequest(String id) async {
    print("Id : $id");
    final success = await acceptRequest(id);

    if(success) {
      _loadFriendRequests();
      showCustomSnackBar(type: SnackBarType.success, message:AppLocalizations.of(context)!.friend_request_accepted, duration: 3);
    } else {
      showCustomSnackBar(type: SnackBarType.error, message:AppLocalizations.of(context)!.err_accept_friend_request, duration: 3);
    }
  }
  void _handleDeclineRequest(String id) async {
    final success = await declineRequest(id) ?? false;

    if(success) {
      _loadFriendRequests();
      showCustomSnackBar(type: SnackBarType.info, message:AppLocalizations.of(context)!.friend_request_declined,duration: 3);
    } else {
      showCustomSnackBar(type: SnackBarType.error, message:AppLocalizations.of(context)!.err_decline_friend_request, duration: 3);
    }
  }
  
  _navigateToViewProfile(friendId, isConnected) async {
    final friend = await getFriendDetails(friendId);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewProfileScreen(friend: friend, connected: isConnected),
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
      showCustomSnackBar(
        type: SnackBarType.error,
        message:AppLocalizations.of(context)!.err_cancel_exchange + ': ${e.toString()}',
        duration: 3,
      );
    }
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
        onTap: () async {
          await _navigateToViewProfile(friend['id'], friend['isConnected']);
        },
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: friend['isConnected'] ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: screenSize.width * 0.05 - 2,
            backgroundImage: (friend['avatar'] as String).isNotEmpty
                ? AssetImage(friend['avatar'])
                : const AssetImage('assets/default_profile.jpg') as ImageProvider,
            onBackgroundImageError: (_, __) =>
                const AssetImage('assets/default_profile.jpg'),
          ),
        ),
        title: Text(
          friend['name'],
          style: TextStyle(
            fontSize: screenSize.height * 0.02,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.swap_horiz,
                size: screenSize.height * 0.025,
                color: friend['isConnected'] ? Colors.green : const Color.fromARGB(255, 98, 102, 87),
              ),
              onPressed: () => _handleExchange(friend['id'], friend['isConnected']),
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                size: screenSize.height * 0.025,
                color: Colors.red,
              ),
              onPressed: () => _showDeleteConfirmationDialog(friend['id']),
            ),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.03,
          vertical: screenSize.height * 0.008,
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
    final success = await deleteFriend(idFriend) ?? false;

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

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: CircularProgressIndicator(
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildFriendList(ThemeData theme, ScreenSize screenSize) {
    if (_loading) return _buildLoading(theme);
    return _filteredFriends.isEmpty 
        ? _buildEmptyState(AppLocalizations.of(context)!.no_friends, theme, screenSize)
        : ListView.builder(
            itemCount: _filteredFriends.length,
            itemBuilder: (_, i) => _buildFriendItem(_filteredFriends[i], theme, screenSize),
          );
  }

  Widget _buildRequestList(ThemeData theme, ScreenSize screenSize) {
    if (_loadingRequests) return _buildLoading(theme);
    return _filteredRequests.isEmpty
        ? _buildEmptyState(AppLocalizations.of(context)!.no_friend_req, theme, screenSize)
        : ListView.builder(
            itemCount: _filteredRequests.length,
            itemBuilder: (_, i) => _buildRequestItem(_filteredRequests[i], theme, screenSize),
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          backgroundColor: theme.colorScheme.surface,
          centerTitle: true,
          leading: SizedBox(width: screenSize.width * 0.1),
          title: Text(
            AppLocalizations.of(context)!.friends,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: screenSize.height * 0.03,
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
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Panel(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.8,
              content: Column(
                children: [       
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.03),
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
                            _updateFilteredItems(_filteredFriends);
                          } else {
                            _updateFilteredItems(_filteredRequests);  
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.person_add_alt_1,
                              size: screenSize.height * 0.02,
                              color: theme.colorScheme.onPrimary,
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.add,
                              style: TextStyle(
                                fontSize: screenSize.height * 0.016,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _showAddFriendDialog,
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  _showFriends ? Icons.mail : Icons.group,
                                  size: screenSize.height * 0.02,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                if (_showFriends && _friendRequests.isNotEmpty)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: screenSize.height * 0.015,
                                      height: screenSize.height * 0.015,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            label: Text(
                              _showFriends ? AppLocalizations.of(context)!.requests : AppLocalizations.of(context)!.friends,
                              style: TextStyle(
                                fontSize: screenSize.height * 0.016,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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

                  SizedBox(height: screenSize.height * 0.02),

                  Expanded(
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : _showFriends
                            ? (_filteredFriends.isEmpty
                                ? _buildEmptyState(AppLocalizations.of(context)!.no_friends, theme, screenSize)
                                : _buildFriendList(theme, screenSize))
                            : (_filteredRequests.isEmpty
                                ? _buildEmptyState(AppLocalizations.of(context)!.no_friend_req, theme, screenSize)
                                : _buildRequestList(theme, screenSize)),
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