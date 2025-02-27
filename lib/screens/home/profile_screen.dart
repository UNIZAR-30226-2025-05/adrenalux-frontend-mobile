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

class ProfileScreen extends StatelessWidget {
  Future<void> _showImageSelectionDialog(BuildContext context, User user) async {
    List<String> images = [];
    String? selectedImage;

    // TODO: Llamar al backend para obtener las imágenes disponibles
    // Ejemplo:
    // images = await UserService.getAvailableAvatars();
    
    // Mock temporal de imágenes
    images = [
      'https://t3.ftcdn.net/jpg/00/64/67/80/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfK1qp4n0vbIkXCARdi3EdVxpbxPGWdxOJpw&s',
      'https://t3.ftcdn.net/jpg/00/64/67/80/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfK1qp4n0vbIkXCARdi3EdVxpbxPGWdxOJpw&s',
      'https://t3.ftcdn.net/jpg/00/64/67/80/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfK1qp4n0vbIkXCARdi3EdVxpbxPGWdxOJpw&s',
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.choose_pfp),
              content: Container(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedImage = image),
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
                        child: Image.network(image, fit: BoxFit.cover),
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
                          if(await updateUserData(selectedImage, null)) {
                            showCustomSnackBar(context, SnackBarType.success, AppLocalizations.of(context)!.username_updated, 3);
                          }else {
                            showCustomSnackBar(context, SnackBarType.error, AppLocalizations.of(context)!.err_update_username, 3);
                          }
                          Navigator.pop(context);
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
    final user = User();

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
                          AppLocalizations.of(context)!.friend_id + ': ${user.friendCode}',
                          style: TextStyle(
                            fontSize: fontSize * 0.6,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: theme.colorScheme.primary, size: iconSize * 0.8),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: user.friendCode));
                            showCustomSnackBar(
                              context,
                              SnackBarType.info,
                              AppLocalizations.of(context)!.friend_id_copied, 3,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                GestureDetector(
                  onTap: () => _showImageSelectionDialog(context, user),
                  child: ExperienceCircleAvatar(
                    imagePath: user.photo,
                    experience: user.xp,
                    xpMax: user.xpMax,
                    size: 'lg',
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  AppLocalizations.of(context)!.level + ': ${user.level}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  AppLocalizations.of(context)!.xp + ': ${user.xp}',
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
                      icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: iconSize),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController _controller = TextEditingController(text: user.name);
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!.update_username),
                              content: TextField(
                                controller: _controller,
                                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.username),
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
                                      if(await updateUserData(null, newName)) {
                                        showCustomSnackBar(context, SnackBarType.success, AppLocalizations.of(context)!.username_updated, 3);
                                      }else {
                                        showCustomSnackBar(context, SnackBarType.error, AppLocalizations.of(context)!.err_update_username, 3);
                                      }
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!.save),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(screenSize.height * 0.02, screenSize.height * 0.02, screenSize.height * 0.02, 0),
                  width: screenSize.width * 0.9,
                  height: 1,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.surfaceContainerLow,
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: user.partidas.isEmpty
                     ? Center(
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
                        )
                      : ListView.builder(
                          itemCount: user.partidas.length > 10 ? 10 : user.partidas.length,
                          itemBuilder: (context, index) {
                            final partida = user.partidas[index];
                            final isVictory = partida.winnerId == user.id;
                            final color = isVictory ? Colors.green : Colors.red;
                            final icon = Icons.sports_soccer;

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.005, horizontal: screenSize.width * 0.05),
                              padding: EdgeInsets.all(screenSize.height * 0.01),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.surfaceContainerLow,
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
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
                                        isVictory ? AppLocalizations.of(context)!.win : AppLocalizations.of(context)!.defeat,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize * 0.8,
                                        ),
                                      ),
                                      Text('${user.name} '
                                        'vs ${partida.player1 == user.id ? partida.player2 : partida.player1}',
                                        style: TextStyle(
                                          color: theme.textTheme.bodyLarge?.color,
                                          fontSize: fontSize * 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(right: padding * 0.5),
                                    child: Text(
                                      '11 - 0',
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color,
                                        fontSize: fontSize * 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
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