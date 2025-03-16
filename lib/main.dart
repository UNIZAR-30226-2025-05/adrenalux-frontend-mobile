import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/screens/welcome_screen.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:adrenalux_frontend_mobile/constants/keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SobresProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setSystemUI();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _setSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setSystemUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorObservers: [SocketService.routeObserver],
          scaffoldMessengerKey: scaffoldMessengerKey,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: "Adrenalux",
          theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Provider.of<LocaleProvider>(context).locale,
          home: WelcomeScreen(),
          builder: (context, child) {
            _setSystemUI(); 
            return child!;
          },
        );
      },
    );
  }
}