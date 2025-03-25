import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ViewProfileScreen extends StatelessWidget {
  final Map<String, dynamic> friend;
  final bool? connected;

  const ViewProfileScreen({Key? key, required this.friend, this.connected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    final String friendCode = friend['friend_code'] ?? friend['id']?.toString() ?? "N/A";
    final String avatar = (friend['avatar'] ?? 'assets/default_profile.jpg').replaceFirst(RegExp(r'^/'), '');
    final String name = friend['name'] ?? "";
    final String lastname = friend['lastname'] ?? "";
    final int level = friend['level'] ?? 1;
    final int xp = friend['xp'] ?? 0;
    final int xpMax = friend['xpMax'] ?? 100;
    final List<dynamic> partidas = friend['partidas'] ?? [];

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
                          AppLocalizations.of(context)!.friend_id + ': $friendCode',
                          style: TextStyle(
                            fontSize: fontSize * 0.6,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: theme.colorScheme.primary, size: iconSize * 0.8),
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
                SizedBox(height: screenSize.height * 0.02),
                if (connected != null) 
                  Container(
                    width: screenSize.width * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: screenSize.width * 0.03,
                          height: screenSize.height * 0.01,
                          decoration: BoxDecoration(
                            color: connected! ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.01),
                        Text(
                          connected!
                              ? AppLocalizations.of(context)!.connected
                              : AppLocalizations.of(context)!.disconnected,
                          style: TextStyle(
                            color: connected! ? Colors.green : Colors.red,
                            fontSize: fontSize * 0.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ExperienceCircleAvatar( 
                  imagePath: avatar,
                  experience: xp,
                  xpMax: xpMax,
                  size: 'lg',
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  AppLocalizations.of(context)!.level + ': $level',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  AppLocalizations.of(context)!.xp + ': $xp',
                  style: TextStyle(
                    fontSize: fontSize * 0.8,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                Text(
                  "$name $lastname",
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
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
                  child: partidas.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                            child: Text(
                              AppLocalizations.of(context)!.no_games_friend,
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
                          itemCount: partidas.length > 10 ? 10 : partidas.length,
                          itemBuilder: (context, index) {
                            final partida = partidas[index];
                            final isVictory = partida['winnerId'] == friend['id'];
                            final color = isVictory ? Colors.green : Colors.red;
                            final icon = Icons.sports_soccer;

                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: screenSize.height * 0.005,
                                  horizontal: screenSize.width * 0.05),
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
                                      Text(
                                        "$name vs ${partida['player1'] == friend['id'] ? partida['player2'] : partida['player1']}",
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
