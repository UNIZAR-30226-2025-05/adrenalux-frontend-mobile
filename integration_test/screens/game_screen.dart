import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/drafts_screen.dart';
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
      ..mockGetPlantillas()
      ..mockGetUserData()
      ..mockGetToken()
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

  Future<void> navigateToGameScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 1));

    final bottomNavBar = find.byType(BottomNavigationBar);
    await tester.tap(find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.sports_soccer),
    ));
    await tester.pumpAndSettle();
  }

  group('GameScreen Tests', () {
    testWidgets('Muestra el leaderboard correctamente', (WidgetTester tester) async {
      await navigateToGameScreen(tester);
      
      expect(find.text('Jugador1'), findsOneWidget);
      expect(find.text('1500'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Alternar entre leaderboard global y de amigos', (WidgetTester tester) async {
      await navigateToGameScreen(tester);
      
      await tester.tap(find.byIcon(Icons.group));
      await tester.pumpAndSettle();
      
      verify(() => mockApiService.fetchLeaderboard(false)).called(1);
    });

    testWidgets('Mostrar diálogo de partida rápida', (WidgetTester tester) async {
      await navigateToGameScreen(tester);
      
      await tester.tap(find.byIcon(Icons.sports_esports));
      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('choose_game_option')), findsOneWidget);
    });

    testWidgets('Unirse al matchmaking con draft completo', (WidgetTester tester) async {
      mockApiService.mockGetUserData({'plantilla_activa_id' : 1});
      await navigateToGameScreen(tester);
      await tester.tap(find.byIcon(Icons.sports_esports));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('choose_game_option')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('quick_match')));
      await tester.pump(Duration(seconds: 1));
      
      expect(mockSocketService.emittedEvents['join_matchmaking'], isNotNull);
    });

    testWidgets('Mostrar error al unirse sin draft', (WidgetTester tester) async {
      await navigateToGameScreen(tester);
      await tester.tap(find.byIcon(Icons.sports_esports));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('quick_match')));
      await tester.pump(Duration(seconds: 1));
      
      expect(find.byKey(Key('incomplete_draft')), findsOneWidget);
    });

    testWidgets('Mostrar partidas pausadas', (WidgetTester tester) async {
      mockApiService.mockGetPartidasPausadas([
        Partida(
          id: 1,
          turn: 10,
          state: GameState.paused,
          winnerId: null,
          date: DateTime.now().subtract(const Duration(days: 1)),
          player1: 1,
          player2: 2,
          puntuacion1: 2,
          puntuacion2: 1,
        ),
      ]);

      await navigateToGameScreen(tester);
      
      await tester.tap(find.byIcon(Icons.sports_esports));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('resume_paused')));
      await tester.pumpAndSettle();
      
      expect(find.text('2-1'), findsOneWidget);
    });

    testWidgets('Navegar a pantalla de drafts', (WidgetTester tester) async {
      await navigateToGameScreen(tester);
      
      await tester.tap(find.byKey(Key('drafts-button')));
      await tester.pumpAndSettle();
      
      expect(find.byType(DraftsScreen), findsOneWidget);
    });

    testWidgets('Manejar error al cargar leaderboard', (WidgetTester tester) async {
      mockApiService.mockFetchLeaderboard([]);
      await navigateToGameScreen(tester);
      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('no_leaderboard_data')), findsOneWidget);
    });
  });
}