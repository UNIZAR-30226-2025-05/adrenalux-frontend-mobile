import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
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
    mockApiService.mockGetCollection([]);

    mockApiService.mockGetUserData();
    mockApiService.mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ]);
    mockApiService.mockGetFullImageUrl();

    mockApiService.mockGetFriends([
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
    ]);
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: app.MyApp(),
      ),
    );
  }

  Future<void> navigateToExchangeScreen(WidgetTester tester) async {
    mockSocketService.on('exchange_accepted', (data) => SocketService().handleExchangeAccepted(data));
    const testExchangeId = '2-1';
    const testFriendName = 'Amigo1';

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 2));

    await tester.tap(find.byKey(Key('navigate-exchange'))); 
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('friend-card-0')));
    await tester.pump(Duration(seconds: 1));

    mockSocketService.simulateEvent('exchange_accepted', {
        'exchangeId': testExchangeId,
        'solicitanteUsername': testFriendName,
        'receptorUsername': User().name
      });
    await tester.pumpAndSettle();
  }

  testWidgets('Muestra cartas del usuario cargadas', (WidgetTester tester) async {
    mockApiService.mockGetCollection();
    
    await navigateToExchangeScreen(tester);
    await tester.pumpAndSettle();
    
    expect(find.byType(PlayerCardWidget), findsNWidgets(5));
    expect(find.text('Messi'), findsOneWidget);
    expect(find.text('Ronaldo'), findsOneWidget);
    expect(find.text('Player3'), findsOneWidget);
  });

  testWidgets('Selección de carta actualiza UI y socket', (WidgetTester tester) async {
    mockApiService.mockGetCollection();
    
    await navigateToExchangeScreen(tester);

    expect(find.byKey(Key('card-1')), findsOneWidget);

    final userCardFinder = find.byKey(Key('user-card'));
    expect(userCardFinder, findsOneWidget);
    expect(find.descendant(of: userCardFinder, matching: find.text('Messi')), findsOneWidget);

    expect(mockSocketService.emittedEvents['select_cards'], isNotNull);
    expect(mockSocketService.emittedEvents['select_cards'], {'exchangeId': '2-1', 'cardId': 1});

  });
}