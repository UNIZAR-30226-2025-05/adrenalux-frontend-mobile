import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/social/exchange_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
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

  Future<void> navigateToSearchExchangeScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 1));

    await tester.tap(find.byKey(Key('navigate-exchange'))); 
    await tester.pumpAndSettle();
  }

  group('SearchExchangeScreen Tests', () {
    testWidgets('Muestra estado vacío cuando no hay amigos', (WidgetTester tester) async {
      mockApiService.mockGetFriends([]);

      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(Key('no-friends-text')), findsOneWidget);
      expect(find.byIcon(Icons.group_off), findsOneWidget);
    });

    testWidgets('Muestra lista de amigos al cargar', (WidgetTester tester) async {
      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Amigo1'), findsOneWidget);
      expect(find.text('Amigo2'), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsNWidgets(2));
    });

    testWidgets('Muestra diálogo al tocar amigo conectado', (WidgetTester tester) async {
      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();

      final firstFriendExchangeButton = find.byKey(Key('friend-card-0'));
      await tester.tap(firstFriendExchangeButton);
      await tester.pump(Duration(seconds: 1));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining(AppLocalizations.of(tester.element(find.byType(AlertDialog)))!.waiting_response), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(mockSocketService.emittedEvents['request_exchange'], {'receptorId': '2', 'username' : User().name});
    });

    testWidgets('Muestra snackbar si amigo no está conectado', (WidgetTester tester) async {
      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();

      final secondFriendExchangeButton = find.byKey(Key('friend-card-1'));
      await tester.tap(secondFriendExchangeButton);
      await tester.pump(Duration(seconds: 2));

      expect(find.byKey(Key('snack-bar'),), findsOneWidget);
    });

    testWidgets('Filtra amigos correctamente al buscar', (WidgetTester tester) async {
      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(SearchBar), 'Amigo1');
      await tester.pumpAndSettle();

      final friendList = find.byType(GridView); 
      expect(find.descendant(of: friendList, matching: find.text('Amigo1')), findsOneWidget);
      expect(find.descendant(of: friendList, matching: find.text('Amigo2')), findsNothing);
    });

    testWidgets('Reintenta cargar amigos al tocar botón en estado vacío', (WidgetTester tester) async {
      mockApiService.mockGetFriends([]);
      
      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text("Volver a intentar"));
      await tester.pumpAndSettle();
      
      verify(() => mockApiService.getFriends()).called(2); 
    });

    testWidgets('Cierra diálogo y cancela intercambio manualmente', (WidgetTester tester) async {
      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('friend-card-0')));
      await tester.pump(Duration(seconds: 1));
      
      await tester.tap(find.byKey(Key('cancel-exchange-button')));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsNothing);
      expect(mockSocketService.emittedEvents['request_exchange'], {'receptorId': '2', 'username': 'Usuario Ejemplo'});
    });

    testWidgets('Rendimiento con lista grande de amigos', (WidgetTester tester) async {
      mockApiService.mockGetFriends(List.generate(100, (i) => 
        {'id': '$i', 
        'friend_code': 'code$i', 
        'username': 'username$i', 
        'avatar': 'assets/default_profile.jpg', 
        'name': 'Amigo$i', 
        'isConnected': i.isEven,
        'lastname': 'lastname$i',
        'level' : '$i',
        }));
      
      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();
      
      final gridView = find.byType(GridView);
      bool found = false;

      for (int i = 0; i < 20; i++) { 
        try {
          await tester.ensureVisible(find.text('Amigo99'));
          found = true;
          break;
        } catch (_) {
          await tester.drag(gridView, const Offset(0, -600)); 
          await tester.pumpAndSettle();
        }
      }

      expect(found, isTrue, reason: 'No se encontró "Amigo99" después de hacer scroll.');
      expect(find.text('Amigo99'), findsOneWidget);
    });

    testWidgets('Navega a pantalla de intercambio al recibir aceptación', (WidgetTester tester) async {
      mockSocketService.on('exchange_accepted', (data) => SocketService().handleExchangeAccepted(data));
      const testExchangeId = '2-1';
      const testFriendName = 'Amigo1';

      await navigateToSearchExchangeScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('friend-card-0')));
      await tester.pump(Duration(seconds: 1));

      expect(mockSocketService.emittedEvents['request_exchange'], isNotNull);
      expect(mockSocketService.emittedEvents['request_exchange']?['receptorId'], '2');
      expect(mockSocketService.emittedEvents['request_exchange']?['username'], 'Usuario Ejemplo');

      mockSocketService.simulateEvent('exchange_accepted', {
        'exchangeId': testExchangeId,
        'solicitanteUsername': testFriendName,
        'receptorUsername': User().name
      });
      await tester.pumpAndSettle();
      expect(find.byType(ExchangeScreen), findsOneWidget);
      
      final exchangeScreen = tester.widget<ExchangeScreen>(find.byType(ExchangeScreen));
      expect(exchangeScreen.exchangeId, testExchangeId);
      expect(exchangeScreen.opponentUsername, testFriendName);

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}