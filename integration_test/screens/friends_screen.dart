import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/home/profile_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/social/exchange_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:integration_test/integration_test.dart';
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
      ..mockGetFriendRequests([])
      ..mockGetCollection([])
      ..mockGetPlantillas([])
      ..mockGetUserData()
      ..mockGetToken()
      ..mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ])
      ..mockSendFriendRequest(true)
      ..mockAcceptRequest(true)
      ..mockDeclineRequest(true)
      ..mockDeleteFriend(true)
      ..mockGetFullImageUrl()
      ..mockValidateToken(true)
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

  Future<void> navigateToFriendsScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 1));

    final bottomNavBar = find.byType(BottomNavigationBar);
    await tester.tap(find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.people_alt_rounded),
    ));
    await tester.pumpAndSettle();
  }

  group('Friends Screen Tests', () {
    testWidgets('Muestra lista de amigos cargados', (WidgetTester tester) async {

      mockApiService.mockGetFriends([
        {
          'id': '2',
          'friend_code': '12345',
          'username': 'amigo1',
          'name': 'Amigo1',
          'lastname': 'Uno',
          'avatar': 'assets/default_profile.jpg',
          'level': 10,
          'isConnected': true
        }
      ]);

      await navigateToFriendsScreen(tester);
      
      expect(find.text('Amigo1'), findsOneWidget);
      expect(find.byIcon(Icons.sports_esports), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('Muestra estado vacío para amigos', (WidgetTester tester) async {
      mockApiService.mockGetFriends([]);
      await navigateToFriendsScreen(tester);
      
      expect(find.byKey(Key('no-content-text')), findsOneWidget);
    });

    testWidgets('Cancelar intercambio desde diálogo', (WidgetTester tester) async {
      await navigateToFriendsScreen(tester);
      
      await tester.tap(find.byIcon(Icons.swap_horiz).first);
      await tester.pump(Duration(seconds: 1));
      
      await tester.tap(find.byKey(Key('cancel_exchange_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ExchangeScreen), findsNothing);
    });

    testWidgets('Manejo de error en carga de solicitudes', (WidgetTester tester) async {
      mockApiService.mockGetFriendRequests([]);
      
      await navigateToFriendsScreen(tester);
      await tester.tap(find.byKey(Key('alternate_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('no-content-text')), findsOneWidget);
    });

    testWidgets('Navegación al perfil del amigo', (WidgetTester tester) async {
      await navigateToFriendsScreen(tester);
      
      await tester.tap(find.text('Amigo1').first);
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byKey(Key('profile-avatar')), findsOneWidget);

      expect(find.byKey(Key('profile-level')), findsOneWidget);
      expect(find.byKey(Key('profile-xp')), findsOneWidget);
      expect(find.byKey(Key('friend-code')), findsOneWidget);
    });

    testWidgets('Alternar entre amigos y solicitudes', (WidgetTester tester) async {
      mockApiService.mockGetFriends([]);
      mockApiService.mockGetFriendRequests([{
        'id': '100',
        'sender': {
          'id': '3',
          'username': 'solicitante',
          'name': 'Juan',
          'lastname': 'Pérez'
        }
      }]);

      await navigateToFriendsScreen(tester);
      
      await tester.tap(find.byKey(Key('alternate_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('request_item_100')), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Enviar solicitud de amistad exitosa', (WidgetTester tester) async {
      await navigateToFriendsScreen(tester);
      
      await tester.tap(find.byIcon(Icons.person_add_alt_1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('add_friend_textfield')), 'ABCDE123');
      await tester.tap(find.byKey(Key('add_friend_button')));
      await tester.pump(Duration(seconds: 1));

      verify(() => mockApiService.sendFriendRequest('ABCDE123')).called(1);
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Manejo de error al enviar solicitud', (WidgetTester tester) async {
      mockApiService.mockSendFriendRequest(false);
      
      await navigateToFriendsScreen(tester);
      await tester.tap(find.byIcon(Icons.person_add_alt_1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('add_friend_textfield')), 'INVALID');
      await tester.tap(find.byKey(Key('add_friend_button')));
      await tester.pump(Duration(seconds : 2));

      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Aceptar solicitud de amistad', (WidgetTester tester) async {
      mockApiService.mockGetFriendRequests([{
        'id': '100',
        'sender': {'id': '3', 'name': 'Juan', 'lastname': 'Pérez'}
      }]);

      await navigateToFriendsScreen(tester);
      await tester.tap(find.byKey(Key('alternate_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check).first);
      await tester.pump(Duration(seconds: 1));

      verify(() => mockApiService.acceptRequest('100')).called(1);
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Iniciar intercambio con amigo conectado', (WidgetTester tester) async {
      mockSocketService.on('exchange_accepted', (data) => SocketService().handleExchangeAccepted(data));
      const testExchangeId = '2-1';
      const testFriendName = 'Amigo1';
      
      await navigateToFriendsScreen(tester);
      
      await tester.tap(find.byIcon(Icons.swap_horiz).first);
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

    testWidgets('Eliminar amigo con confirmación', (WidgetTester tester) async {
      await navigateToFriendsScreen(tester);
      
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('confirm_delete_button')));
      await tester.pump(Duration(seconds: 1));

      verify(() => mockApiService.deleteFriend('2')).called(1);
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Cancelar eliminación de amigo', (WidgetTester tester) async {
      await navigateToFriendsScreen(tester);
      
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('cancel_delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('Amigo1'), findsOneWidget);
      verifyNever(() => mockApiService.deleteFriend(any()));
    });

    testWidgets('Mostrar error en solicitud de batalla offline', (WidgetTester tester) async {
      mockApiService.mockGetFriends([{
        'id': '2',
        'friend_code': '12345',
        'username': 'amigo1',
        'name': 'Amigo1',
        'lastname': 'Uno',
        'avatar': 'assets/default_profile.jpg',
        'level': 10,
        'isConnected': false
      }]);

      await navigateToFriendsScreen(tester);

      await tester.tap(find.byIcon(Icons.sports_esports).first);
      await tester.pump(Duration(seconds: 1));

      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });
  });
}