import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/social/exchange_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
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

    mockApiService.mockGetToken();
    mockApiService.mockValidateToken(true);
    mockApiService.mockGetCollection([]);
    mockApiService.mockGetPlantillas([]);

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
      child: app.MyApp(),
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

    final cardFinder1 = find.byKey(Key('card-1'));
    await tester.tap(cardFinder1);
    await tester.pumpAndSettle();

    final userCardFinder = find.byKey(Key('user-card'));
    expect(userCardFinder, findsOneWidget);
    expect(find.descendant(of: userCardFinder, matching: find.text('Messi')), findsOneWidget);

    expect(mockSocketService.emittedEvents['select_cards'], isNotNull);
    expect(mockSocketService.emittedEvents['select_cards'], {'exchangeId': '2-1', 'cardId': 1});
  });

  testWidgets('Filtrar cartas mediante búsqueda', (WidgetTester tester) async {
    mockApiService.mockGetCollection();
    
    await navigateToExchangeScreen(tester);

    await tester.enterText(find.byType(TextField), 'Messi');
    await tester.pumpAndSettle();

    expect(find.byType(PlayerCardWidget), findsNWidgets(3));
    expect(find.descendant(of: find.byType(PlayerCardWidget), matching: find.text('Messi')), findsOneWidget);
  });

  testWidgets('Cancelar intercambio muestra diálogo y emite evento', (WidgetTester tester) async {
    mockApiService.mockGetCollection();
    mockSocketService.on('exchange_cancelled', (data) => SocketService().handleExchangeCancelled(data));
    
    await navigateToExchangeScreen(tester);

    await tester.tap(find.byKey(Key('cancel-exchange-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('confirm-cancel-exchange-button')));
    await tester.pumpAndSettle();

    mockSocketService.simulateEvent('exchange_cancelled', {
      'exchangeId' :  '2-1',
      'message': 'Intercambio cancelado'
    });

    await tester.pump(Duration(seconds: 2));

    expect(mockSocketService.emittedEvents['cancel_exchange'], {'exchangeId' :  '2-1'});
    expect(find.byType(ExchangeScreen), findsNothing);
  });

  testWidgets('Bloquear selección durante intercambio activo', (WidgetTester tester) async {
    mockApiService.mockGetCollection();
    
    await navigateToExchangeScreen(tester);

    await tester.tap(find.byKey(Key('card-1')));
    await tester.tap(find.byKey(Key('confirm-exchange-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('cant-select-text')), findsOneWidget);
    expect(find.byType(PlayerCardWidget), findsNWidgets(5));
  });

  testWidgets('Actualizar estado de confirmación del oponente', (WidgetTester tester) async {
    mockApiService.mockGetCollection();
    
    await navigateToExchangeScreen(tester);

    mockSocketService.simulateEvent('cards_selected', {
      'exchangeId' : '2-1',
      'userId': '2',
      'card' : {
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
        'cantidad': 3,
        'enVenta': true,
        'mercadoCartaId': 101,
      }
    });
    mockSocketService.simulateEvent('confirmation_updated', {
      'confirmations': {'1' : false, '2': true} 
    });
    await tester.pumpAndSettle();

    expect(find.byKey(Key('confirmed_Amigo1')), findsOneWidget);
  });

  testWidgets('Navegar al menú al cancelar intercambio remotamente', (WidgetTester tester) async {
    mockApiService.mockGetCollection();
    mockSocketService.on('exchange_cancelled', (data) => SocketService().handleExchangeCancelled(data));

    await navigateToExchangeScreen(tester);

    mockSocketService.simulateEvent('exchange_cancelled', {});
    await tester.pump(Duration(seconds: 2));

    expect(find.byType(MenuScreen), findsOneWidget);
  });

  testWidgets('Navegar al menú al completar intercambio', (WidgetTester tester) async {
    mockApiService.mockGetCollection();
    mockSocketService.on('exchange_completed', (data) => SocketService().handleExchangeCompleted(data));

    await navigateToExchangeScreen(tester);

    mockSocketService.simulateEvent('exchange_completed', {});
    await tester.pump(Duration(seconds: 2));

    expect(find.byType(MenuScreen), findsOneWidget);
  });
}