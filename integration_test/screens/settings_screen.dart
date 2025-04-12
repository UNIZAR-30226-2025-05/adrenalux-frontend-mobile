import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/settings_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adrenalux_frontend_mobile/main.dart' as app;
import '../mocks/mock_api_service.dart';
import '../mocks/mock_socket_service.dart';
import 'collection_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  
  late MockApiService mockApiService;
  late MockGoogleAuthService mockGoogleAuthService;
  late MockSocketService mockSocketService;

  setUp(() {
    mockApiService = MockApiService();
    mockGoogleAuthService = MockGoogleAuthService();
    mockSocketService = MockSocketService();
    SharedPreferences.setMockInitialValues({});

    mockApiService
      ..mockGetFriends([
        {
        'id': '2',
        'friend_code': '12345',
        'username': 'amigo1',
        'avatar': 'assets/default_profile.jpg',
        'name': 'Amigo1',
        'lastname': 'Uno',
        'level': 10,
        'isConnected': true
        },
        {
        'id': '3',
        'friend_code': '67890',
        'username': 'amigo2',
        'avatar': 'assets/default_profile.jpg',
        'name': 'Amigo2',
        'lastname': 'Dos',
        'level': 5,
        'isConnected': false
        },
      ])
      ..mockGetCollection([
        {
          'id':50,
          'nombre': 'Ter Stegen',
          'alias': 'Ter Stegen',
          'equipo': 'FC Barcelona',
          'ataque': 50,
          'control': 40,
          'defensa': 100,
          'tipo_carta': CARTA_LUXURY,
          'escudo': FIXED_IMAGE,
          'photo': FIXED_IMAGE,
          'posicion': 'goalkeeper',
          'precio': 1500000.0,
          'cantidad': 3,
          'enVenta': true,
          'mercadoCartaId': 101,
        }
      ])
      ..mockGetPlantillas()
      ..mockGetFriendRequests([])
      ..mockGetUserData()
      ..mockGetToken()
      ..mockLogOut(true)
      ..mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ])
      ..mockGetFullImageUrl()
      ..mockValidateToken(true)
      ..mockFetchLeaderboard()
      ..mockGetFriendDetails({
        'logros': [
          Logro(
            id: 1,
            description: "Primer logro alcanzado",
            rewardType: "coins",
            rewardAmount: 100,
            logroType: 1,
            requirement: 10,
            achieved: true,
          ),
        ],
        'partidas': [
          Partida(
            id: 1,
            turn: 10,
            state: GameState.paused,
            winnerId: null,
            date: DateTime.now().subtract(const Duration(days: 1)),
            player1: 1,
            player2: 2,
            puntuacion1: 3,
            puntuacion2: 2,
          ),
        ],
      });
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (context) => SobresProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()..setLocale(const Locale('es')),),
        Provider<SocketService>.value(value: mockSocketService),
        Provider<ApiService>.value(value: mockApiService),
        Provider<GoogleAuthService>.value(value: mockGoogleAuthService),
      ],
      child: app.MyApp(),
    );
  }

  Future<void> navigateToSettingsScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 3));

    final bottomNavBar = find.byType(BottomNavigationBar);
    await tester.tap(find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.settings),
    ));
    await tester.pumpAndSettle();
  }

  group('SettingsScreen Tests', () {
    testWidgets('Muestra todas las opciones de configuración', (WidgetTester tester) async {
      await navigateToSettingsScreen(tester);
      
      expect(find.byKey(Key('theme_switch')), findsOneWidget); 
      expect(find.byKey(Key('logout_button')), findsOneWidget);     
      expect(find.byKey(Key('language_switch')), findsOneWidget);        
      expect(find.byKey(Key('info_button')), findsOneWidget);      
    });

    testWidgets('Cambiar tema actualiza ThemeProvider', (WidgetTester tester) async {
      await navigateToSettingsScreen(tester);
      
      final themeProvider = Provider.of<ThemeProvider>(tester.element(find.byType(SettingsScreen)), listen: false);
      final initialTheme = themeProvider.currentTheme;

      await tester.tap(find.byKey(Key('theme_switch')));
      await tester.pump();

      expect(themeProvider.currentTheme, isNot(equals(initialTheme)));
    });

    testWidgets('Seleccionar idioma actualiza LocaleProvider', (WidgetTester tester) async {
      await navigateToSettingsScreen(tester);

      await tester.tap(find.byKey(Key('language_switch')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('english_language')));
      await tester.pumpAndSettle();

      final localeProvider = Provider.of<LocaleProvider>(tester.element(find.byType(SettingsScreen)), listen: false);
      expect(localeProvider.locale?.languageCode, 'en');
    });

    testWidgets('Cerrar sesión exitosa', (WidgetTester tester) async {
      await navigateToSettingsScreen(tester);
      
      await tester.tap(find.byKey(Key('logout_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('Mostrar info despliega snackbar', (WidgetTester tester) async {
      await navigateToSettingsScreen(tester);

      await tester.tap(find.byKey(Key('info_button')));
      await tester.pump(Duration(seconds: 1));

      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });
  });
}
