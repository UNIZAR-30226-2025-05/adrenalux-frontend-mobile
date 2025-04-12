import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/focusCard_screen.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adrenalux_frontend_mobile/main.dart' as app;
import '../mocks/mock_api_service.dart';

const String FIXED_IMAGE = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png';

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
    mockApiService.mockGetPlantillas([]);

    mockApiService.mockGetUserData();
    mockApiService.mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ]);
    mockApiService.mockGetCollection();
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
      child: app.MyApp(),
    );
  }

  Future<void> navigateToCollectionScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 1));

    final bottomNavBar = find.byType(BottomNavigationBar);
    await tester.tap(find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.backpack),
    ));
    await tester.pumpAndSettle(Duration(seconds: 1));
  }

  group('CollectionScreen Tests', () {
    testWidgets('Display collection cards', (WidgetTester tester) async {
      await navigateToCollectionScreen(tester);
      
      expect(find.byType(PlayerCardWidget), findsNWidgets(3));
      expect(find.text('Messi'), findsOneWidget);
      expect(find.text('Ronaldo'), findsOneWidget);
      expect(find.text('Player3'), findsOneWidget);
    });

    testWidgets('Filter cards by search', (WidgetTester tester) async {
      await navigateToCollectionScreen(tester);
      
      await tester.enterText(find.byType(TextField), 'Lionel');
      await tester.pumpAndSettle();
      
      expect(find.byType(PlayerCardWidget), findsOneWidget);
      expect(find.text('Ronaldo'), findsNothing);
      expect(find.text('Player3'), findsNothing);
    });

    testWidgets('Sort cards by team when one is unavaiblable', (WidgetTester tester) async {
      await navigateToCollectionScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('order-by-team')));
      await tester.pumpAndSettle();
      
      final cardWidgets = tester.widgetList<PlayerCardWidget>(find.byType(PlayerCardWidget)).toList();
      expect(cardWidgets[0].playerCard.team, 'Al-Nassr'); 
      expect(cardWidgets[1].playerCard.team, 'Inter Miami'); 
      expect(cardWidgets[2].playerCard.team, 'Al-Nassr'); 
    });

    testWidgets('Show empty state', (WidgetTester tester) async {
      mockApiService.mockGetCollection([]);
      await navigateToCollectionScreen(tester);
      
      expect(find.byKey(Key('empty-collection-text')), findsOneWidget);
    });

    testWidgets('Navigate to FocusCardScreen when card has amount >= 1', (WidgetTester tester) async {
      await navigateToCollectionScreen(tester);
      
      await tester.tap(find.byType(PlayerCardWidget).first);
      await tester.pumpAndSettle();
      
      expect(find.byType(FocusCardScreen), findsOneWidget);
    });

    testWidgets('Prevent navigation when card has amount = 0', (WidgetTester tester) async {
      mockApiService.mockGetCollection([
          {
          'id': 1,
          'nombre': 'Lionel',
          'alias': 'Messi',
          'equipo': 'Inter Miami',
          'ataque': 95,
          'control': 98,
          'defensa': 40,
          'tipo_carta': CARTA_LUXURY,
          'escudo': FIXED_IMAGE,
          'photo': FIXED_IMAGE,
          'posicion': 'Forward',
          'precio': 1500000.0,
          'cantidad': 0,
          'enVenta': true,
          'mercadoCartaId': 101,
        },
      ]);
      
      await navigateToCollectionScreen(tester);
      
      await tester.tap(find.byType(PlayerCardWidget).first, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      expect(find.byType(FocusCardScreen), findsNothing);
    });

    testWidgets('Performance test with large number of cards', (WidgetTester tester) async {
      final mockCards = List.generate(1000, (index) => {
        'id': index,
        'nombre': 'Player$index',
        'alias': 'Surname$index',
        'equipo': 'Team ${index % 10}',
        'ataque': 80,
        'control': 80,
        'defensa': 80,
        'tipo_carta': CARTA_LUXURY,
        'escudo': FIXED_IMAGE,
        'photo': FIXED_IMAGE,
        'posicion': 'Forward',
        'precio': 1000.0,
        'cantidad': 1,
        'enVenta': false,
        'mercadoCartaId': null,
        'rareza': 'Común',
      });

      mockApiService.mockGetCollection(mockCards);
      final stopwatch = Stopwatch()..start();

      await navigateToCollectionScreen(tester);
      await tester.pumpAndSettle();

      final listFinder = find.byType(GridView);
      final totalItems = mockCards.length;
      final Set<int> uniqueCardIds = Set();

      const delta = -300.0;
      const iterations = 300; 

      for (int i = 0; i < iterations; i++) {
        final visibleCards = tester.widgetList<PlayerCardWidget>(
          find.byType(PlayerCardWidget),
        ).map((w) => w.playerCard.id).toSet();
        
        uniqueCardIds.addAll(visibleCards);
        
        if (uniqueCardIds.length >= totalItems) break;

        await tester.drag(listFinder, Offset(0, delta));
        await tester.pump();
      }
      stopwatch.stop();
      expect(uniqueCardIds.length, equals(totalItems));
      expect(stopwatch.elapsedMilliseconds, lessThan(35000));
    });
  });
}