import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/widgets/searchBar.dart';
import 'package:adrenalux_frontend_mobile/models/friend.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter/foundation.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Friend> _friends = [];
  List<Friend> _filteredFriends = [];
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
          _scaffoldKey.currentContext!,
          SnackBarType.error,
          'Error al cargar amigos: ${e.toString()}',
          5,
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

  void _updateFilteredItems(List<Friend> filteredItems) {
    setState(() {
      _filteredFriends = filteredItems;
    });
  }

  void _showAddFriendDialog() {
  final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
  final screenSize = ScreenSize.of(context);
  final TextEditingController codeController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Añadir amigo',
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
              labelText: 'Código de amigo',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.code),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Añadir'),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildFriendItem(Friend friend, ThemeData theme, ScreenSize screenSize) {
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
          backgroundImage: friend.photo.isNotEmpty
              ? NetworkImage(friend.photo)
              : const AssetImage('assets/default_profile.jpg') as ImageProvider,
          onBackgroundImageError: (_, __) => 
              const AssetImage('assets/default_profile.jpg'),
        ),
        title: Text(
          friend.name,
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
              icon: Icon(Icons.swap_horiz, size: screenSize.height * 0.025, color : Colors.green),
              onPressed: () => _handleExchange(friend),
              color: theme.colorScheme.primary,
            ),
            IconButton(
              icon: Icon(Icons.delete, size: screenSize.height * 0.025, color: Colors.red),
              onPressed: () => _handleDelete(friend),
              color: theme.colorScheme.error,
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

  void _handleExchange(Friend friend) {/* Lógica de intercambio */}
  void _handleDelete(Friend friend) {/* Lógica de eliminación */}

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
          title: Center(
            child: Text(
              'Amigos',
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
                            child: CustomSearchMenu<Friend>(
                              items: _friends,
                              getItemName: (friend) => friend.name,
                              onFilteredItemsChanged: _updateFilteredItems,
                            ),
                          )
                        ),
                        SizedBox(width: screenSize.width * 0.03),
                        Container(
                          height: screenSize.height * 0.06,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.person_add_alt_1,
                              size: screenSize.height * 0.02,
                              color: theme.colorScheme.onPrimary,
                            ),
                            label: Text(
                              'Añadir',
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
                                  'No tienes amigos agregados',
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
        ],
      ),
    );
  }
}