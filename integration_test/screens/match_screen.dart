import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/match_results_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/game/match_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/home_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/animated_round_dialog.dart';
import 'package:adrenalux_frontend_mobile/widgets/card.dart';
import 'package:adrenalux_frontend_mobile/widgets/round_result_dialog.dart';
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
import '../test_util.dart';
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

    mockSocketService.on('match_found', SocketService().handleMatchFound);
    mockSocketService.on('round_start', SocketService().handleRoundStart);
    mockSocketService.on('match_ended', SocketService().handleMatchEnded);
    mockSocketService.on('round_result', SocketService().handleRoundResult);
    mockSocketService.on('opponent_selection', SocketService().handleOpponentSelection);
    mockSocketService.on('match_paused', SocketService().handleMatchPaused);
    mockSocketService.on('pause_requested', SocketService().handlePauseRequested);

    mockApiService
      ..mockGetUserData({'plantilla_activa_id' : 1})
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
      ..mockGetToken()
      ..mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ])
      ..mockGetFullImageUrl()
      ..mockValidateToken(true)
      ..mockFetchLeaderboard()
      ..mockGetFriendDetails();
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

  Future<void> navigateToMatchScreen(WidgetTester tester, bool starter) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds : 1));

    final bottomNavBar = find.byType(BottomNavigationBar);
    await tester.tap(find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.sports_soccer),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.sports_esports));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('choose_game_option')));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(Key('quick_match')));
    await tester.pump(Duration(seconds: 1));

    mockSocketService.simulateEvent('match_found', {
      'matchId': 1,
      'user1Id': 1,
      'user2Id': 2,
      'plantilla1': 1,
      'plantilla2': 2
    });

    mockSocketService.simulateEvent('round_start', {
      'roundNumber': 1,
      'starter': starter ? '1' : '2',
      'phase': 'selection'
    });
    await tester.pumpAndSettle();
  }

  group('MatchScreen Tests', () {
    testWidgets('Se muestra correctamente la pantalla de partida', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);

      expect(find.byType(AnimatedRoundDialog), findsOneWidget);
      expect(find.byType(MatchScreen), findsOneWidget);
    });

    testWidgets('Probar flujo de rendición en caso de éxito', (WidgetTester tester) async {  
      await navigateToMatchScreen(tester, true);
      
      await tester.waitUntilDisappear(
        find.byType(AnimatedRoundDialog),
        timeout: Duration(seconds: 10), 
      );
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key("surrender")));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byKey(Key("confirm_surrender")), findsOneWidget);

      await tester.tap(find.byKey(Key("accept_surrender")));
      mockSocketService.simulateEvent('match_ended', {
        'winnerId': '2',
        'isDraw': false,
        'scores': {
          '1': 0,
          '2': 0
        },
        'puntosChange' : {
          '1': 0,
          '2': 15
        }
      });

      await tester.pumpAndSettle();

      expect(find.byType(MatchResultScreen), findsOneWidget);
    });

    testWidgets('Probar flujo de rendición por parte del oponente', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      
      await tester.waitUntilDisappear(
        find.byType(AnimatedRoundDialog),
        timeout: Duration(seconds: 10), 
      );

      mockSocketService.simulateEvent('match_ended', {
        'winnerId': '1',
        'isDraw': false,
        'scores': {
          '1': 0,
          '2': 0
        },
        'puntosChange' : {
          '1': 15,
          '2': 0
        }
      });

      await tester.pumpAndSettle();

      expect(find.byType(MatchResultScreen), findsOneWidget);
    });

    testWidgets('Probar flujo de rendición cancelada', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog), timeout: Duration(seconds: 10), );
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key("surrender")));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text("Cancelar"));
      await tester.pumpAndSettle();
      
      expect(find.byType(MatchScreen), findsOneWidget);
    });

    testWidgets('Probar visualización del resultado de la ronda', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog), timeout: Duration(seconds: 10), );

      mockSocketService.simulateEvent('round_result', {
        'ganador': '1',
        'scores': {'1': 5, '2': 3},
        'detalles': {
          'jugador1': '1',
          'carta_j1': {
            "id": 1,
            "nombre": "Lionel",
            "alias": "Messi",
            "equipo": "Inter Miami",
            "ataque": 95,
            "control": 98,
            "defensa": 40,
            "tipo_carta": CARTA_LUXURY,
            "escudo": FIXED_IMAGE,
            "averageScore": 9.5,
            "photo": FIXED_IMAGE,
            "posicion": "forward",
            "precio": 1500000.0
          },
          'skill_j1': 'ataque',
          'carta_j2': {
            "id": 2,
            "nombre": "Cristiano",
            "alias": "Ronaldo",
            "equipo": "Al-Nassr",
            "ataque": 93,
            "control": 90,
            "defensa": 45,
            "tipo_carta": CARTA_MEGALUXURY,
            "escudo": FIXED_IMAGE,
            "averageScore": 9.3,
            "photo": FIXED_IMAGE,
            "posicion": "forward",
            "precio": 2000000.0
          },
          'skill_j2': 'defensa',
        },
      });
      
      await tester.pumpAndSettle();
      expect(find.byType(RoundResultDialog), findsOneWidget);
    });

    testWidgets('Elección del oponente muestra indicador en draft rival', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));

      mockSocketService.simulateEvent('opponent_selection', {
        'carta':  {
          "id": 2,
          "nombre": "Cristiano",
          "alias": "Ronaldo",
          "equipo": "Al-Nassr",
          "ataque": 93,
          "control": 90,
          "defensa": 45,
          "tipo_carta": CARTA_MEGALUXURY,
          "escudo": FIXED_IMAGE,
          "averageScore": 9.3,
          "photo": FIXED_IMAGE,
          "posicion": "forward",
          "precio": 2000000.0
        },
        'skill': 'defensa',
      });
      
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(PageView),
        Offset(-300, 0), 
        1000,
      );
      await tester.pumpAndSettle();

      final positionFinder = find.descendant(
        of: find.byKey(Key('draft_card_FWD1')), 
        matching: find.byIcon(Icons.star_rounded),
      );
      
      expect(positionFinder, findsOneWidget);
    });

    testWidgets('Partida termina en empate', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);

      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));
      
      mockSocketService.simulateEvent('match_ended', {
      'winnerId': null,
      'isDraw': true,
      'scores': {'1': 2, '2': 2},
      'puntosChange' : {'1': 10, '2': 10}
      });
      
      await tester.pumpAndSettle();
      expect(find.byType(MatchResultScreen), findsOneWidget);
      expect(find.byKey(Key('resultText')).evaluate().single.widget, isA<Text>().having((t) => (t).data, 'text', '¡Empate!'));
    });

    testWidgets('Selección válida de carta cambia el turno', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));

      final userCard = find.byType(PlayerCardWidget).first;
      await tester.tap(userCard);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      
      await tester.tap(find.byKey(Key('button-ataque')));
      await tester.pumpAndSettle();

      expect(mockSocketService.emittedEvents['select_card'], {
        'cartaId': '11',
        'skill': 'ataque',
      });
      
      expect(find.byKey(Key('wait-selection')), findsOneWidget);
    });

    testWidgets('No se puede seleccionar carta en turno del oponente', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, false);
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));

      final userCard = find.byType(PlayerCardWidget).first;
      await tester.tap(userCard);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    }); 

    testWidgets('Carta usada se marca como no disponible', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));

      final userCard = find.byKey(Key('draft_card_FWD1'));
      await tester.tap(userCard);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('button-ataque')));
      await tester.pumpAndSettle();

      mockSocketService.simulateEvent('opponent_selection', {
        'carta':  {
          "id": 2,
          "nombre": "Cristiano",
          "alias": "Ronaldo",
          "equipo": "Al-Nassr",
          "ataque": 93,
          "control": 90,
          "defensa": 45,
          "tipo_carta": CARTA_MEGALUXURY,
          "escudo": FIXED_IMAGE,
          "averageScore": 9.3,
          "photo": FIXED_IMAGE,
          "posicion": "forward",
          "precio": 2000000.0
        },
        'skill': 'defensa',
      });
      
      await tester.pumpAndSettle();

      mockSocketService.simulateEvent('round_result', {
        'ganador': '1',
        'scores': {'1': 5, '2': 3},
        'detalles': {
          'jugador1': '1',
          'carta_j1': {
            "id": 1,
            "nombre": "Lionel",
            "alias": "Messi",
            "equipo": "Inter Miami",
            "ataque": 95,
            "control": 98,
            "defensa": 40,
            "tipo_carta": CARTA_LUXURY,
            "escudo": FIXED_IMAGE,
            "averageScore": 9.5,
            "photo": FIXED_IMAGE,
            "posicion": "forward",
            "precio": 1500000.0
          },
          'skill_j1': 'ataque',
          'carta_j2': {
            "id": 2,
            "nombre": "Cristiano",
            "alias": "Ronaldo",
            "equipo": "Al-Nassr",
            "ataque": 93,
            "control": 90,
            "defensa": 45,
            "tipo_carta": CARTA_MEGALUXURY,
            "escudo": FIXED_IMAGE,
            "averageScore": 9.3,
            "photo": FIXED_IMAGE,
            "posicion": "forward",
            "precio": 2000000.0
          },
          'skill_j2': 'defensa',
        },
      });
        
      mockSocketService.simulateEvent('round_start', {
        'roundNumber': 2,
        'starter': '1',
        'phase': 'selection'
      });

      await tester.pumpAndSettle();

      await tester.waitUntilDisappear(
        find.byType(RoundResultDialog),
        timeout: Duration(seconds: 10), 
      );

      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));

      await tester.tap(userCard);
      await tester.pump(Duration(seconds: 1));

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('Solicitar pausa exitosamente', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key("pause")));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.byKey(Key("accept_pause")));
      await tester.pumpAndSettle();

      expect(mockSocketService.emittedEvents['request_pause'], isNotNull);

      mockSocketService.simulateEvent('match_paused', {});
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

     testWidgets('Recibir y aceptar solicitud de pausa', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));

      mockSocketService.simulateEvent('pause_requested', {'matchId': 1});
      await tester.tapAt(Offset(100, 100));
      await tester.pump(Duration(seconds: 1));

      expect(find.byKey(Key('snack-bar')), findsOneWidget);
  
      await tester.tap(find.byKey(Key('snack-bar-button')));
      await tester.pumpAndSettle();

      expect(mockSocketService.emittedEvents['request_pause'], isNotNull);
  
      mockSocketService.simulateEvent('match_paused', {});
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Rechazar solicitud de pausa', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);
      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));

      mockSocketService.simulateEvent('pause_requested', {'matchId': 1});
      await tester.tapAt(Offset(100, 100));
      await tester.pump(Duration(seconds: 1));

      await tester.tap(find.byKey(Key('snack-bar-close')));
      await tester.pumpAndSettle();

      expect(find.byType(MatchScreen), findsOneWidget);
    });

     testWidgets('Navegación a pantalla de Home tras partida', (WidgetTester tester) async {
      await navigateToMatchScreen(tester, true);

      await tester.waitUntilDisappear(find.byType(AnimatedRoundDialog));
      
      mockSocketService.simulateEvent('match_ended', {
      'winnerId': '1',
      'isDraw': false,
      'scores': {'1': 3, '2': 2},
      'puntosChange' : {'1': 15, '2': 0}
      });
      
      await tester.pumpAndSettle();
      expect(find.byType(MatchResultScreen), findsOneWidget);

      await tester.tap(find.byKey(Key('home-button')));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}