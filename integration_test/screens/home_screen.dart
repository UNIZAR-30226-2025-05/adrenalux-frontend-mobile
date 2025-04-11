import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/home/achievements_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/profile_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/sobre_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/market_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/social/search_exchange_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:carousel_slider/carousel_slider.dart';
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

    mockApiService.mockGetToken();
    mockApiService.mockValidateToken(true);

    mockApiService.mockGetUserData();
    mockApiService.mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ]);
    mockApiService.mockGetSobre({'cartas': [], 'logroActualizado': false});
    mockApiService.mockGetCollection([]);
    mockApiService.mockGetFriends([]);
    mockApiService.mockGetFullImageUrl();
    mockApiService.mockGetFriendRequests([]);
    mockApiService.mockGetPlantillas([]);
    mockApiService.mockSignIn({
      'token': 'fake-token',
      'user': {'id': 1, 'email': 'test@test.com'}
    });

    mockApiService.mockGetMarket();

    mockApiService.mockGetDailyLuxuries();
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
      child: MaterialApp(
        locale: const Locale('es'),
        home: app.MyApp(),
      ),
    );
  }

  Future<void> navigateToHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pumpAndSettle();
  }

  group('HomeScreen Tests', () {
    testWidgets('Muestra los elementos principales', (WidgetTester tester) async {
      mockApiService.mockGetSobre({
        'cartas': [
          {'id': 1, 'nombre': 'Carta 1', 'imagen': 'test_image.png'}
        ],
        'logroActualizado': false
      });

      await navigateToHomeScreen(tester);

      expect(find.byType(ExperienceCircleAvatar), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
      expect(find.byType(CarouselSlider), findsOneWidget);
      expect(find.text('Mercado'), findsOneWidget);
    });

    testWidgets('Muestra los sobres correctamente', (WidgetTester tester) async {
      await navigateToHomeScreen(tester);

      expect(find.byType(CarouselSlider), findsOneWidget);
      expect(find.text('100'), findsOneWidget); 
      expect(find.text('500'), findsOneWidget); 
      expect(find.text('2500'), findsOneWidget); 
    });

    testWidgets('Abre un sobre correctamente', (WidgetTester tester) async {
      mockApiService.mockGetSobre({
        'cartas': [
          PlayerCard(
            id: 1,
            playerName: 'Lionel',
            playerSurname: 'Messi',
            team: 'Inter Miami',
            shot: 95,
            control: 98,
            defense: 40,
            rareza: CARTA_LUXURY,
            teamLogo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png',
            averageScore: 77.67,
            playerPhoto: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png',
            position: 'Forward',
            price: 1500000.0,
            amount: 1,
            onSale: false,
            marketId: 0,
          ),
        ],
        'logroActualizado': false
      });

      await navigateToHomeScreen(tester);

      await tester.tap(find.byKey(Key('pack-carousel-item-0')));
      await tester.pump(Duration (seconds: 4));

      expect(find.byType(OpenPackScreen), findsOneWidget);
    });

    testWidgets('Muestra el cooldown del sobre gratuito', (WidgetTester tester) async {
      final user = User();
      user.freePacksAvailable.value = false;
      user.packCooldown.value = 3600000; 

      await navigateToHomeScreen(tester);
      final cooldownTextFinder = find.byKey(Key('pack-cooldown'));
      expect(cooldownTextFinder, findsOneWidget);

      final cooldownText = tester.widget<Text>(cooldownTextFinder).data!;
      expect(cooldownText.compareTo('01:00:00') <= 0, isTrue);
    });

    testWidgets('Navega al MarketScreen', (WidgetTester tester) async {
      await navigateToHomeScreen(tester);

      await tester.tap(find.byKey(Key('navigate-market')));
      await tester.pumpAndSettle();

      expect(find.byType(MarketScreen), findsOneWidget);
    });

    testWidgets('Navega a la pantalla de intercambio', (WidgetTester tester) async {
      await navigateToHomeScreen(tester);
      
      await tester.tap(find.byKey(Key('navigate-exchange'))); 
      await tester.pumpAndSettle();
      
      expect(find.byType(RequestExchangeScreen), findsOneWidget);
    });

    testWidgets('Navega a la pantalla de perfil', (WidgetTester tester) async {
      await navigateToHomeScreen(tester);
      
      await tester.tap(find.byType(ExperienceCircleAvatar)); 
      await tester.pumpAndSettle();
      
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Navega a la pantalla de logros', (WidgetTester tester) async {
      await navigateToHomeScreen(tester);
      
      await tester.tap(find.byKey(Key('navigate-achievements'))); 
      await tester.pumpAndSettle();
      
      expect(find.byType(AchievementsScreen), findsOneWidget);
    });

    testWidgets('Muestra las monedas correctamente', (WidgetTester tester) async {
      await navigateToHomeScreen(tester);
      
      final coinsDisplay = find.byKey(Key('adrenacoins-display'));
      
      expect(coinsDisplay, findsOneWidget);
      expect((tester.widget(coinsDisplay) as Text).data, '1000');
    });
  });
}