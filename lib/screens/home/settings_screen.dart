import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/panel.dart';
import 'package:adrenalux_frontend_mobile/widgets/custom_snack_bar.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {

  void cerrarSesion(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    final success = await apiService.signOut();

    if(success) {
      await prefs.remove('token'); 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } else {
      showCustomSnackBar(
        type: SnackBarType.error,
        message: AppLocalizations.of(context)!.err_sign_out,
        duration: 3
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenSize.appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.settings,
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.02), 
                  _buildOption(
                    Key('theme_switch'),
                    context,
                    icon: Icons.brightness_6,
                    text: AppLocalizations.of(context)!.switch_theme,
                    onTap: () {
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                    },
                  ),
                  _buildOption(
                    Key('logout_button'),
                    context,
                    icon: Icons.logout,
                    text: AppLocalizations.of(context)!.log_out,
                    onTap: () => cerrarSesion(context),
                  ),
                  _buildOption(
                    Key('language_switch'),
                    context,
                    icon: Icons.lan,
                    text: AppLocalizations.of(context)!.language,
                     onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(AppLocalizations.of(context)!.pick_language),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  key: Key('spanish_language'),
                                  leading: const Icon(Icons.flag),
                                  title: Text(AppLocalizations.of(context)!.spanish),
                                  onTap: () {
                                    Provider.of<LocaleProvider>(context, listen: false)
                                        .setLocale(const Locale('es'));
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  key: Key('english_language'),
                                  leading: const Icon(Icons.flag),
                                  title: Text(AppLocalizations.of(context)!.english),
                                  onTap: () {
                                    Provider.of<LocaleProvider>(context, listen: false)
                                        .setLocale(const Locale('en'));
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  _buildOption(
                    Key('info_button'),
                    context,
                    icon: Icons.info,
                    text: AppLocalizations.of(context)!.info,
                    onTap: () {
                      showCustomSnackBar(                  
                        type: SnackBarType.info,
                        message: AppLocalizations.of(context)!.info_message, 
                        duration: 6
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(Key key, BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenSize = ScreenSize.of(context);
    double fontSize = screenSize.width * 0.05;
    double iconSize = screenSize.width * 0.07;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01, horizontal: screenSize.width * 0.05),
      padding: EdgeInsets.all(screenSize.height * 0.01),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        key: key,
        leading: Icon(icon, color: theme.colorScheme.primary, size: iconSize),
        title: Text(
          text,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: fontSize * 0.8,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}