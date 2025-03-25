import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
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
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
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

  @override
  void initState() {
    super.initState();
    user = User();
  }

  Future<void> _showImageSelectionDialog() async {
    ApiService apiService = ApiService();
    String? selectedImage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    double padding = screenSize.width * 0.05;
    double avatarSize = screenSize.width * 0.3;
    double fontSize = screenSize.width * 0.05;
    double iconSize = screenSize.width * 0.07;

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
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padding, padding * 2, padding, padding),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.friend_id}: ${user.friend_code}',
                          style: TextStyle(
                            fontSize: fontSize * 0.6,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, 
                              color: theme.colorScheme.primary, 
                              size: iconSize * 0.8),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: user.friend_code));
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
                SizedBox(height: screenSize.height * 0.02),
                GestureDetector(
                  onTap: _showImageSelectionDialog,
                  child: ExperienceCircleAvatar(
                    imagePath: user.photo,
                    experience: user.xp,
                    xpMax: user.xpMax,
                    size: 'lg',
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  '${AppLocalizations.of(context)!.level}: ${user.level}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  '${AppLocalizations.of(context)!.xp}: ${user.xp}',
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
                      user.name,
                      style: TextStyle(
                        fontSize: fontSize * 1.2,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, 
                          color: theme.colorScheme.primary, 
                          size: iconSize),
                      onPressed: () => _showUsernameDialog(context),
                    ),
                  ],
                ),
                _buildDivider(screenSize, theme),
                Expanded(
                  child: user.partidas.isEmpty
                      ? _buildEmptyGamesMessage(padding, fontSize, theme)
                      : _buildGamesList(screenSize, padding, fontSize, theme),
                ),
              ],
            ),
          ),
          _buildCloseButton(padding, avatarSize, iconSize, theme),
        ],
      ),
    );
  }

  Widget _buildDivider(ScreenSize screenSize, ThemeData theme) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        screenSize.height * 0.02,
        screenSize.height * 0.02,
        screenSize.height * 0.02,
        0,
      ),
      width: screenSize.width * 0.9,
      height: 1,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.surfaceContainerLow,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGamesMessage(
      double padding, double fontSize, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
        child: Text(
          AppLocalizations.of(context)!.no_games_msg,
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

  Widget _buildGamesList(
      ScreenSize screenSize, double padding, double fontSize, ThemeData theme) {
    return ListView.builder(
      itemCount: user.partidas.length > 10 ? 10 : user.partidas.length,
      itemBuilder: (context, index) {
        final partida = user.partidas[index];
        final puntuacion1 = partida.player1 == User().id ? partida.puntuacion1 : partida.puntuacion2;
        final puntuacion2 = partida.player1 == User().id ? partida.puntuacion2 : partida.puntuacion1;
        
        final isPaused = partida.state == 'pause';
        final isDraw = partida.state == 'draw' ;
        final isVictory = partida.winnerId == user.id && !isDraw;

        Color color;
        IconData icon;
        String statusText;

        if (isPaused) {
          color = Colors.grey;
          icon = Icons.pause;
          statusText = "Pausa";
        } else if (isDraw) {
          color = Colors.blue;
          icon = Icons.people_alt_outlined;
          statusText = "Empate";
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
              Icon(icon, color: color, size: screenSize.height * 0.05),
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
                    '${user.name} vs ${partida.player1 == user.id ? partida.player2 : partida.player1}',
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
                  isPaused ? '-- - --' : '$puntuacion1 - $puntuacion2',
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

  Widget _buildCloseButton(
      double padding, double avatarSize, double iconSize, ThemeData theme) {
    return Positioned(
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
                offset: const Offset(0, 2),
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
    );
  }

  void _showUsernameDialog(BuildContext context) {
    ApiService apiService = ApiService();
    TextEditingController _controller = TextEditingController(text: user.name);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.update_username),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.username,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final newName = _controller.text.trim();
                if (newName.isNotEmpty) {
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
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }
}