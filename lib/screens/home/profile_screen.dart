import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'dart:math';
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

  Future<void> _showImageSelectionDialog(context) async {
    final scaleFactor = _getScaleFactor(ScreenSize.of(context));
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8 * scaleFactor,
                    mainAxisSpacing: 8 * scaleFactor,
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

  double _getScaleFactor(ScreenSize screenSize) {
    return (min(screenSize.width, screenSize.height) / 400).clamp(0.8, 2.0);
  }

  Widget _buildProfileHeader(ScreenSize screenSize, ThemeData theme, double scaleFactor) {
    final friendCode = isFriendProfile 
        ? (friend?['friend_code']?.toString() ?? "N/A") 
        : user.friend_code;
        
    final name = isFriendProfile 
        ? (friend?['name'] ?? "")
        : user.name;

    return Column(
      children: [
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
               padding: EdgeInsets.only(bottom: 16.0 * scaleFactor),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${AppLocalizations.of(context)!.friend_id}: $friendCode',
                      style: TextStyle(
                        fontSize: 14 * scaleFactor,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, 
                        color: theme.colorScheme.primary, 
                        size: 20 * scaleFactor),
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
        ),
        if (widget.connected != null && isFriendProfile)
          Padding(
            padding: EdgeInsets.fromLTRB(40.0 * scaleFactor, 16.0 * scaleFactor, 0, 8.0 * scaleFactor),
            child: Container(
              constraints: BoxConstraints(maxWidth: 200 * scaleFactor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 10 * scaleFactor,
                    height: 10 * scaleFactor,
                    decoration: BoxDecoration(
                      color: widget.connected! ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8 * scaleFactor),
                  Text(
                    widget.connected!
                        ? AppLocalizations.of(context)!.connected
                        : AppLocalizations.of(context)!.disconnected,
                    style: TextStyle(
                      color: widget.connected! ? Colors.green : Colors.red,
                      fontSize: 12 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        GestureDetector(
          onTap: isFriendProfile ? null : () => _showImageSelectionDialog(context),
          child: ExperienceCircleAvatar(
            imagePath: isFriendProfile 
                ? (friend?['avatar'] ?? 'assets/default_profile.jpg').replaceFirst(RegExp(r'^/'), '')
                : user.photo,
            experience: isFriendProfile ? (friend?['xp'] ?? 0) : user.xp,
            xpMax: isFriendProfile ? (friend?['xpMax'] ?? 100) : user.xpMax,
            size: 'lg',
          ),
        ),
        SizedBox(height: 16 * scaleFactor),
        Text(
          '${AppLocalizations.of(context)!.level}: ${isFriendProfile ? (friend?['level'] ?? 1) : user.level}',
          style: TextStyle(
            fontSize: 18 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8 * scaleFactor),
        Text(
          '${AppLocalizations.of(context)!.xp}: ${isFriendProfile ? (friend?['xp'] ?? 0) : user.xp}',
          style: TextStyle(
            fontSize: 14 * scaleFactor,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 16 * scaleFactor),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 20 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (!isFriendProfile) IconButton(
              icon: Icon(
                Icons.edit, 
                color: theme.colorScheme.primary, 
                size: 24 * scaleFactor
              ),
              onPressed: () => _showUsernameDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameList(ScreenSize screenSize, ThemeData theme, double scaleFactor) {
    final partidas = isFriendProfile 
        ? (friend?['partidas'] ?? [])
        : user.partidas;
        
    final userId = isFriendProfile ? (friend?['id']) : user.id;

    if (partidas.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0 * scaleFactor),
          child: Text(
            isFriendProfile 
                ? AppLocalizations.of(context)!.no_games_friend
                : AppLocalizations.of(context)!.no_games_msg,
            style: TextStyle(
              fontSize: 14 * scaleFactor,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
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
                vertical: 8 * scaleFactor,
                horizontal: constraints.maxWidth * 0.05,
              ),
              padding: EdgeInsets.all(12 * scaleFactor),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12 * scaleFactor),
              ),
              child: Row(
                children: [
                  Icon(
                    icon, 
                    color: color, 
                    size: 30 * scaleFactor
                  ),
                  SizedBox(width: 12 * scaleFactor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14 * scaleFactor),
                        ),
                        SizedBox(height: 4 * scaleFactor),
                        Text(
                          '${isFriendProfile ? (friend?['name']) : user.name} vs ${partida.player1 == userId ? partida.player2 : partida.player1}',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 12 * scaleFactor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$puntuacion1 - $puntuacion2',
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 14 * scaleFactor),
                  ),
                ],
              ),
            );
          },
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
    final scaleFactor = _getScaleFactor(screenSize);

    return Scaffold(
      body: SafeArea(
        child: Stack(
            children: [
            SingleChildScrollView(
              child: Column(
              children: [
                Panel(
                width: screenSize.width,
                height: screenSize.height,
                content: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.0 * scaleFactor,
                    0.0,
                    8.0 * scaleFactor,
                    16.0 * scaleFactor,
                  ),
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfileHeader(screenSize, theme, scaleFactor),
                    Divider(thickness: 1 * scaleFactor),
                    SizedBox(height: 16 * scaleFactor),
                    SizedBox(
                    height: screenSize.height * 0.4,
                    child: _buildGameList(screenSize, theme, scaleFactor),
                    ),
                  ],
                  ),
                ),
                ),
              ],
              ),
            ),
            Positioned(
              bottom: 30 * scaleFactor,
              left: (screenSize.width - (60 * scaleFactor)) / 2,
              child: CloseButtonWidget(
              size: 60 * scaleFactor,
              onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsernameDialog(BuildContext context) {
    final scaleFactor = _getScaleFactor(ScreenSize.of(context));
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
                    constraints: BoxConstraints(maxWidth: 300 * scaleFactor),
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