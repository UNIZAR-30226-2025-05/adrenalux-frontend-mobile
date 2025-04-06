import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_up_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/home_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/welcome_screen.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/main.dart' as app;
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mocks/mock_api_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('Auth Flow Test', () {
    late MockApiService mockApiService;
    late MockGoogleAuthService mockGoogleAuthService;

    setUp(() {
      mockApiService = MockApiService();
      mockGoogleAuthService = MockGoogleAuthService();
      SharedPreferences.setMockInitialValues({});

      mockApiService.mockGetToken();
      mockApiService.mockValidateToken(true);
      mockApiService.mockGetUserData();
      mockApiService.mockGetSobresDisponibles([
          Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
          Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
          Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 500),
        ]);
      mockApiService.mockGetSobre({'cartas': [], 'logroActualizado': false});
      mockApiService.mockGetCollection([]);
      mockApiService.mockGetFriends([]);
      mockApiService.mockGetFullImageUrl();
      mockApiService.mockGetFriendRequests([]);
    });

    testWidgets('Usuario autenticado navega a MenuScreen', (WidgetTester tester) async {
      print("Inicializando test para usuario autenticado...");

      await tester.runAsync(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MatchProvider()),
              ChangeNotifierProvider(create: (context) => SobresProvider()),
              ChangeNotifierProvider(create: (context) => ThemeProvider()),
              ChangeNotifierProvider(create: (context) => LocaleProvider()),
              Provider<ApiService>.value(value: mockApiService),
              Provider<GoogleAuthService>.value(value: mockGoogleAuthService),
            ],
            child: app.MyApp(),
          ),
        );

        await tester.pump(const Duration(seconds: 2));

        expect(find.byType(WelcomeScreen), findsOneWidget);

        await tester.tap(find.byKey(Key('welcome-screen-gesture')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.byType(MenuScreen), findsOneWidget);
        expect(find.byKey(const Key('menu-screen')), findsOneWidget);

        expect(find.byType(HomeScreen), findsOneWidget);

        expect(find.byType(BottomNavigationBar), findsOneWidget);

        print("Test completado: Usuario autenticado navega a MenuScreen.");
      });
    });

    testWidgets('Usuario no autenticado navega a SignUpScreen', (tester) async {
      print("Inicializando test para usuario no autenticado...");

      mockApiService.mockValidateToken(false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MatchProvider()),
            ChangeNotifierProvider(create: (context) => SobresProvider()),
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => LocaleProvider()),
            Provider<ApiService>.value(value: mockApiService),
            Provider<GoogleAuthService>.value(value: mockGoogleAuthService),
          ],
          child: app.MyApp(),
        ),
      );

      await tester.pump();

      await tester.tap(find.byKey(Key('welcome-screen-gesture')));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);

      print("Test completado: Usuario no autenticado navega a SignUpScreen.");
    });
  });
}