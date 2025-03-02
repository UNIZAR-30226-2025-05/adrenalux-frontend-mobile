import 'package:flutter/material.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    final user = User();

    final panelPadding = screenSize.width * 0.03;
    final itemMargin = EdgeInsets.symmetric(
      vertical: screenSize.height * 0.015,
      horizontal: screenSize.width * 0.02,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.achievements,
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
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
              child: Panel(
                width: screenSize.width * 0.9,
                height: screenSize.height * 0.8,
                content: Container(
                  padding: EdgeInsets.all(panelPadding),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenSize.height * 0.8 - (panelPadding * 2),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(
                            user.logros.length,
                            (i) => Container(
                              margin: itemMargin,
                              padding: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.015,
                                horizontal: screenSize.width * 0.03,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      user.logros[i].photo,
                                      width: screenSize.height * 0.06,
                                      height: screenSize.height * 0.06,
                                      fit: BoxFit.cover),
                                  ),
                                  SizedBox(width: screenSize.width * 0.04),
                                  Expanded(
                                    child: Text(
                                      user.logros[i].description,
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color,
                                        fontSize: screenSize.height * 0.018,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * 0.03,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: screenSize.width * 0.15,
                  height: screenSize.width * 0.15,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: theme.colorScheme.onPrimary,
                    size: screenSize.width * 0.08,
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