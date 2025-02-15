import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
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
                          'ID Amigo: ${user.friendCode}',
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
                              'ID amigo copiado al portapapeles',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                ExperienceCircleAvatar(
                  imagePath: user.photo,
                  experience: user.xp.toDouble(),
                  size: 'lg',
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'Lvl: ${user.level}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  'Xp: ${user.xp}',
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
                              title: Text('Editar nombre de usuario'),
                              content: TextField(
                                controller: _controller,
                                decoration: InputDecoration(hintText: 'Nombre de usuario'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    user.name = _controller.text;
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Guardar'),
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
                    color: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
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
                              'Parece que no has jugado ninguna partida, ¡anímate!',
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
                                    color: Colors.black.withOpacity(0.1),
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
                                        isVictory ? 'Victoria' : 'Derrota',
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
                                      '11 - 0', //Poner resultado de la partida cuando este definido
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
              onTap: () {
                Navigator.pop(context);
              },
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
