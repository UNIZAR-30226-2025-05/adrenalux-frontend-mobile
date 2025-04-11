import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adrenalux_frontend_mobile/main.dart' as app;
import '../mocks/mock_api_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  
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
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ]);
    mockApiService.mockGetFullImageUrl();
    mockApiService.mockGetPlantillas([]);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (context) => SobresProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()..setLocale(const Locale('es')),),
        Provider<ApiService>.value(value: mockApiService),
        Provider<GoogleAuthService>.value(value: mockGoogleAuthService),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: app.MyApp(),
      ),
    );
  }

  Future<void> navigateToAchievementsScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 2));

    await tester.tap(find.byKey(Key('navigate-achievements'))); 
    await tester.pumpAndSettle();
  }

  group('AchievementsScreen Tests', () {
    testWidgets('Display empty state when no achievements', (WidgetTester tester) async {
      mockApiService.mockGetUserData({'logros': []});
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.tap(find.byKey(Key('welcome-screen-gesture')));
      await tester.pump(Duration(seconds: 2));
      
      expect(find.byKey(Key('empty-achievements')), findsOneWidget);
    });

    testWidgets('Display list of achievements', (WidgetTester tester) async {
      await navigateToAchievementsScreen(tester);
      
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byKey(Key('achievement-item-1')), findsOneWidget);
      expect(find.byKey(Key('achievement-item-2')), findsOneWidget);
    });

    testWidgets('Show achievement details correctly', (WidgetTester tester) async {
      await navigateToAchievementsScreen(tester);
      
      final firstAchievement = find.byKey(Key('achievement-item-1'));
      expect(find.descendant(of: firstAchievement, matching: find.text('Primer logro alcanzado')), findsOneWidget);
      
      expect(find.descendant(of: firstAchievement, matching: find.byIcon(Icons.emoji_events)), findsOneWidget);
    });
  });
}