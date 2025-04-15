import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/close_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final String? friendId;
  final bool? connected;

  const ProfileScreen({Key? key, this.friendId, this.connected}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  Map<String, dynamic>? friend;
  bool isLoading = true;
  final List<String> _profileImages = [
    "assets/profile_1.png",
    "assets/profile_2.png",
    "assets/profile_3.png",
    "assets/profile_4.png",
    "assets/profile_5.png",
    "assets/profile_6.png",
    "assets/profile_7.png",
    "assets/profile_8.png",
  ];

  bool get isFriendProfile => widget.friendId != null;

  @override
  void initState() {
    super.initState();
    if (isFriendProfile) {
      _loadFriendData();
    } else {
      user = User();
      isLoading = false;
    }
  }

  Future<void> _loadFriendData() async {
    ApiService apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final data = await apiService.getFriendDetails(widget.friendId!);
      setState(() {
        friend = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.err_load_friends,
      );
    }
  }

  Future<void> _showImageSelectionDialog() async {
    if (isFriendProfile) return;

    ApiService apiService = Provider.of<ApiService>(context, listen: false); 
    String? selectedImage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              key: Key('image-selection-dialog'),
              title: Text(AppLocalizations.of(context)!.choose_pfp),
              content: Container(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _profileImages.length,
                  itemBuilder: (context, index) {
                    final image = _profileImages[index];
                    return GestureDetector(
                      key : Key('profile-image-$index'),
                      onTap: () => setDialogState(() => selectedImage = image),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImage == image
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(image),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  key: Key('confirm-image-selection'),
                  onPressed: selectedImage == null
                      ? null
                      : () async {
                          final success = await apiService.updateUserData(selectedImage, null);
                          if (success) {
                            setState(() {
                              user.photo = selectedImage!;
                            });
                            Navigator.pop(context);
                            showCustomSnackBar(
                              type: SnackBarType.success,
                              message: AppLocalizations.of(context)!.update_pfp,
                              duration: 3,
                            );
                          } else {
                            Navigator.pop(context);
                            showCustomSnackBar(
                              type: SnackBarType.error,
                              message: AppLocalizations.of(context)!.err_update_pfp,
                              duration: 3,
                            );
                          }
                        },
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(ScreenSize screenSize, ThemeData theme, double fontSize, double iconSize) {
    final friendCode = isFriendProfile 
        ? (friend?['friend_code']?.toString() ?? "N/A") 
        : user.friend_code;
        
    final name = isFriendProfile 
        ? (friend?['name'] ?? "")
        : user.name;

    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              screenSize.width * 0.05, 
              screenSize.width * 0.1, 
              screenSize.width * 0.05, 
              screenSize.width * 0.05
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  key : Key('friend-code'),
                  '${AppLocalizations.of(context)!.friend_id}: $friendCode',
                  style: TextStyle(
                    fontSize: fontSize * 0.6,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                IconButton(
                  key: Key('copy-friend-code-button'),
                  icon: Icon(Icons.copy, 
                      color: theme.colorScheme.primary, 
                      size: iconSize * 0.8),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: friendCode));
                    showCustomSnackBar(
                      type: SnackBarType.info,
                      message: AppLocalizations.of(context)!.friend_id_copied,
                      duration: 3,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (widget.connected != null && isFriendProfile)
          Container(
            width: screenSize.width * 0.7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: screenSize.width * 0.03,
                  height: screenSize.height * 0.01,
                  decoration: BoxDecoration(
                    color: widget.connected! ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.01),
                Text(
                  widget.connected!
                      ? AppLocalizations.of(context)!.connected
                      : AppLocalizations.of(context)!.disconnected,
                  style: TextStyle(
                    color: widget.connected! ? Colors.green : Colors.red,
                    fontSize: fontSize * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        GestureDetector(
          key: Key('profile-avatar'),
          onTap: isFriendProfile ? null : _showImageSelectionDialog,
          child: ExperienceCircleAvatar(
            imagePath: isFriendProfile 
                ? (friend?['avatar'] ?? 'assets/default_profile.jpg').replaceFirst(RegExp(r'^/'), '')
                : user.photo,
            experience: isFriendProfile ? (friend?['xp'] ?? 0) : user.xp,
            xpMax: isFriendProfile ? (friend?['xpMax'] ?? 100) : user.xpMax,
            size: 'lg',
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        Text(
          key: Key('profile-level'),
          '${AppLocalizations.of(context)!.level}: ${isFriendProfile ? (friend?['level'] ?? 1) : user.level}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Text(
          key: Key('profile-xp'),
          '${AppLocalizations.of(context)!.xp}: ${isFriendProfile ? (friend?['xp'] ?? 0) : user.xp}',
          style: TextStyle(
            fontSize: fontSize * 0.8,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: screenSize.height * 0.03),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: fontSize * 1.2,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (!isFriendProfile) IconButton(
              icon: Icon(
                key: Key('edit-username-icon'),
                Icons.edit, 
                color: theme.colorScheme.primary, 
                size: iconSize
              ),
              onPressed: () => _showUsernameDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameList(ScreenSize screenSize, ThemeData theme, double fontSize, double padding) {
    final partidas = isFriendProfile 
        ? (friend?['partidas'] ?? [])
        : user.partidas;
        
    final userId = isFriendProfile ? (friend?['id']) : user.id;

    if (partidas.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
          child: Text(
            key: Key('no-games-text'),
            isFriendProfile 
                ? AppLocalizations.of(context)!.no_games_friend
                : AppLocalizations.of(context)!.no_games_msg,
            style: TextStyle(
              fontSize: fontSize * 0.8,
              color: theme.textTheme.bodyLarge?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: partidas.length > 10 ? 10 : partidas.length,
      itemBuilder: (context, index) {
        final partida = partidas[index];
        final isPaused = partida.state == GameState.paused;
        final isDraw = partida.state == GameState.finished && partida.winnerId == null;
        final isVictory = partida.winnerId == userId && !isDraw;

        final puntuacion1 = partida.player1 == userId 
            ? partida.puntuacion1 
            : partida.puntuacion2;
        final puntuacion2 = partida.player1 == userId 
            ? partida.puntuacion2 
            : partida.puntuacion1;

        Color color;
        IconData icon;
        String statusText;

        if (isPaused) {
          color = Colors.grey;
          icon = Icons.pause;
          statusText = AppLocalizations.of(context)!.paused;
        } else if (isDraw) {
          color = Colors.blue;
          icon = Icons.people_alt_outlined;
          statusText = AppLocalizations.of(context)!.draw;
        } else {
          color = isVictory ? Colors.green : Colors.red;
          icon = Icons.sports_soccer;
          statusText = isVictory 
              ? AppLocalizations.of(context)!.win 
              : AppLocalizations.of(context)!.defeat;
        }

        return Container(
          margin: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.005,
            horizontal: screenSize.width * 0.05,
          ),
          padding: EdgeInsets.all(screenSize.height * 0.01),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.surfaceContainerLow,
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                key: Key('game-status-icon-$index'),
                icon, 
                color: color, 
                size: screenSize.height * 0.05
              ),
              SizedBox(width: screenSize.width * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize * 0.8),
                  ),
                  Text(
                    '${isFriendProfile ? (friend?['name']) : user.name} vs ${partida.player1 == userId ? partida.player2 : partida.player1}',
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: fontSize * 0.6),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(right: padding * 0.5),
                child: Text(
                  '$puntuacion1 - $puntuacion2',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: fontSize * 0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (isFriendProfile && friend == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.err_load_friends),
        ),
      );
    }

    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final padding = screenSize.width * 0.05;
    final fontSize = screenSize.width * 0.05;
    final iconSize = screenSize.width * 0.07;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
            ),
          ),
          Panel(
            width: screenSize.width,
            height: screenSize.height,
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileHeader(screenSize, theme, fontSize, iconSize),
                Divider(),
                Expanded(
                  child: _buildGameList(screenSize, theme, fontSize, padding),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: 
                CloseButtonWidget(
                  size: 60,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showUsernameDialog(BuildContext context) {
    if (isFriendProfile) return;

    ApiService apiService = Provider.of<ApiService>(context, listen: false); 
    TextEditingController _controller = TextEditingController(text: user.name);
    final _formKey = GlobalKey<FormState>();
    bool _isUsernameValid = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              key: Key('username-dialog'),
              title: Text(AppLocalizations.of(context)!.update_username),
              content: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  key: Key('username-textfield'),
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.username,
                    errorMaxLines: 2,
                  ),
                  validator: (value) {
                    final username = value?.trim() ?? '';
                    if (username.isEmpty) {
                      return AppLocalizations.of(context)!.usernameRequired;
                    }
                    if (username.length > 20) {
                      return AppLocalizations.of(context)!.maxNameChars;
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
                      return AppLocalizations.of(context)!.invalidChars;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _isUsernameValid = _formKey.currentState?.validate() ?? false;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  key: Key('save-username-button'),
                  onPressed: _isUsernameValid ? () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final newName = _controller.text.trim();
                      final success = await apiService.updateUserData(null, newName);
                      if (success) {
                        setState(() {
                          user.name = newName;
                        });
                        Navigator.pop(context);
                        showCustomSnackBar(
                          type: SnackBarType.success,
                          message: AppLocalizations.of(context)!.username_updated,
                          duration: 3,
                        );
                      } else {
                        Navigator.pop(context);
                        showCustomSnackBar(
                          type: SnackBarType.error,
                          message: AppLocalizations.of(context)!.err_update_username,
                          duration: 3,
                        );
                      }
                    }
                  } : null,
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}