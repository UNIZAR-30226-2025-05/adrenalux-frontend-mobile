import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
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

  Future<void> navigateToMarketScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 2));

    await tester.tap(find.byKey(Key('navigate-market')));
    await tester.pumpAndSettle();
  }

  group('MarketScreen Tests', () {
    testWidgets('Display market and daily cards correctly', (WidgetTester tester) async {
      mockApiService.mockGetMarket();
      mockApiService.mockGetDailyLuxuries();
      mockApiService.mockGetUserData({'coins': 10000});
      
      await navigateToMarketScreen(tester);
      
      expect(find.text('Messi'), findsOneWidget);
      expect(find.text('Ronaldo'), findsOneWidget);
      expect(find.text('Mbappe'), findsOneWidget);
      expect(find.text('van Dijk'), findsOneWidget);
      expect(find.byType(PlayerCardWidget), findsNWidgets(4));
    });

    testWidgets('Show empty state when no cards available', (WidgetTester tester) async {
      mockApiService.mockGetMarket([]);
      mockApiService.mockGetDailyLuxuries([]);
      
      await navigateToMarketScreen(tester);
      
      expect(find.byKey(Key('no-cards-available')), findsNWidgets(2));
    });

    testWidgets('Filter cards using search', (WidgetTester tester) async {
      mockApiService.mockGetMarket();
      mockApiService.mockGetDailyLuxuries();
      
      await navigateToMarketScreen(tester);
      
      await tester.enterText(find.byType(TextField), 'Lionel');
      await tester.pumpAndSettle();
      
      expect(find.text('Messi'), findsOneWidget);
    });

    testWidgets('Successful card purchase', (WidgetTester tester) async {
      mockApiService.mockGetMarket();
      mockApiService.mockGetDailyLuxuries();
      mockApiService.mockPurchaseDailyCard(true);
      mockApiService.mockPurchaseMarketCard(true);
      mockApiService.mockGetUserData({'coins': 15000000});
      
      await navigateToMarketScreen(tester);
      
      await tester.tap(find.byType(PlayerCardWidget).first);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text(AppLocalizations.of(tester.element(find.byType(AlertDialog)))!.accept));
      await tester.pump(Duration(seconds: 2));
      
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
      expect(find.text(AppLocalizations.of(tester.element(find.byType(Scaffold)))!.card_added), findsOneWidget);
    });

    testWidgets('Insufficient coins for purchase', (WidgetTester tester) async {
      mockApiService.mockGetMarket();
      mockApiService.mockGetDailyLuxuries();
      mockApiService.mockGetUserData({'coins': 1000});
      
      await navigateToMarketScreen(tester);
      
      await tester.tap(find.byType(PlayerCardWidget).first);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text(AppLocalizations.of(tester.element(find.byType(AlertDialog)))!.accept));
      await tester.pump(Duration(seconds: 2));
      
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
      expect(find.text(AppLocalizations.of(tester.element(find.byType(Scaffold)))!.err_no_coins), findsOneWidget);
    });

    testWidgets('Server error handling', (WidgetTester tester) async {
      mockApiService.mockGetMarket();
      mockApiService.mockGetDailyLuxuries();
      mockApiService.mockPurchaseDailyCard(false);
      mockApiService.mockPurchaseMarketCard(false);
      mockApiService.mockGetUserData({'coins': 15000000});
      
      await navigateToMarketScreen(tester);
      
      await tester.tap(find.byType(PlayerCardWidget).first);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text(AppLocalizations.of(tester.element(find.byType(AlertDialog)))!.accept));
      await tester.pump(Duration(seconds: 2));
      
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
      expect(find.text("Error al comprar la carta del mercado"), findsOneWidget);
    });

    testWidgets('Display correct coin balance in app bar', (WidgetTester tester) async {
      const testCoins = 12345;
      mockApiService.mockGetUserData({'coins': testCoins});
      mockApiService.mockGetMarket();
      mockApiService.mockGetDailyLuxuries();
      
      await navigateToMarketScreen(tester);
      
      expect(find.text('$testCoins'), findsOneWidget);
      expect(find.byKey(Key('user-coins')), findsOneWidget);
    });
  });
}