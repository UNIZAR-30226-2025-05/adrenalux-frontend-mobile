import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/game_screen.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
import 'package:adrenalux_frontend_mobile/widgets/close_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
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
      ..mockGetActiveTournaments([
        {
          'id': 1,
          'nombre': 'Torneo Global',
          'descripcion': 'Descripción',
          'premio': 1000,
          'contrasena': null,
          'fecha_inicio': null,
          'ganador_id': null,
          'creador_id': '1',
          'torneo_en_curso': false,
        }
      ])
      ..mockGetUserTournaments([])
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
      ..mockGetUserTournaments([
        {
          'id': 1,
          'name': 'Torneo de Prueba',
          'startDate': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          'maxParticipants': 8,
          'prize': '1000',
          'description': 'Descripción de prueba',
          'isInProgress': false,
          'creatorId': 1,
        }
      ])
      ..mockGetTournamentDetails(
        {
        'torneo' : {
            'id': 3,
            'nombre': 'Torneo de Prueba',
            'descripcion': 'Descripción de prueba',
            'premio': 1000,
            'contrasena': null,
            'fecha_inicio': null,
            'ganador_id': null,
            'creador_id': 1,
            'torneo_en_curso': false,
            },
          'participantes': [
            {
              'id': 1,
              'user_id': 1,
              'nombre': 'Organizador',
              'avatar': 'assets/avatar.png',
              'level': 10,
              'victorias': 5,
              'partidas': [],
              'progreso': 0.75,
              'isOnline': true,
              'isConnected': false,
            },
            {
              'id': 2,
              'user_id': 2,
              'nombre': 'Participante 1',
              'avatar': 'assets/avatar2.png',
              'level': 8,
              'victorias': 3,
              'partidas': [],
              'progreso': 0.6,
              'isOnline': true,
              'isConnected': false,
            }
          ],
        }
      )
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

  Future<void> navigateToTournamentsScreen(WidgetTester tester) async {
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

    await tester.tap(find.byKey(Key('tournaments-button')));

    await tester.pumpAndSettle();
  }

  group('TournamentScreen Tests', () {
    testWidgets('Muestra información básica del torneo', (WidgetTester tester) async {
      await navigateToTournamentsScreen(tester);
      
      expect(find.byKey(Key('Torneo de Prueba_title')), findsOneWidget);
      expect(find.text('Descripción de prueba'), findsOneWidget);
      expect(find.byKey(Key('Participantes_2/8')), findsOneWidget);
      expect(find.byKey(Key('Premio_1000')), findsOneWidget);
    });

    testWidgets('Muestra botón de iniciar solo para creador', (WidgetTester tester) async {
      mockApiService.mockGetTournamentMatches([]);
      
      await navigateToTournamentsScreen(tester);
      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('startTournamentButton')), findsOneWidget);
    });

    testWidgets('Muestra partidas organizadas en rondas', (WidgetTester tester) async {

      mockApiService.mockGetTournamentDetails(
        {
        'torneo' : {
            'id': 3,
            'nombre': 'Torneo de Prueba',
            'descripcion': 'Descripción de prueba',
            'premio': 1000,
            'contrasena': null,
            'fecha_inicio': null,
            'ganador_id': null,
            'creador_id': 1,
            'torneo_en_curso': true,
            },
          'participantes': [
            {
              'id': 1,
              'user_id': 1,
              'nombre': 'Organizador',
              'avatar': 'assets/avatar.png',
              'level': 10,
              'victorias': 5,
              'partidas': [],
              'progreso': 0.75,
              'isOnline': true,
              'isConnected': false,
            },
            {
              'id': 2,
              'user_id': 2,
              'nombre': 'Participante 1',
              'avatar': 'assets/avatar2.png',
              'level': 8,
              'victorias': 3,
              'partidas': [],
              'progreso': 0.6,
              'isOnline': true,
              'isConnected': false,
            }
          ],
        }
      );
      final mockMatches = [
        {'id': 1, 'user1_id': 1, 'user2_id': 2, 'fecha': DateTime.now().toString(), 'ganador_id': null},
      ];
      
      mockApiService.mockGetTournamentMatches(mockMatches);
      
      await navigateToTournamentsScreen(tester);
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle(); 

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(Key('Final_title')), findsOneWidget);
    });

    testWidgets('Muestra contador para próxima partida', (WidgetTester tester) async {
      final nextMatchDate = DateTime.now().add(Duration(minutes: 5));
      final mockMatches = [
        {'id': 1, 'user1_id': 1, 'user2_id': 2, 'fecha': nextMatchDate.toIso8601String(), 'ganador_id': null},
      ];
      
      mockApiService.mockGetTournamentMatches(mockMatches);
      
      await navigateToTournamentsScreen(tester);
      await tester.pumpAndSettle();
      
      expect(find.textContaining('m'), findsOneWidget);
    });

    testWidgets('Muestra feedback al iniciar torneo exitosamente', (WidgetTester tester) async {
      mockApiService.mockStartTournament(true);
      
      await navigateToTournamentsScreen(tester);
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('startTournamentButton')));
      await tester.pump(Duration(seconds: 1));
      
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Muestra participantes correctamente', (WidgetTester tester) async {
      await navigateToTournamentsScreen(tester);
      await tester.pumpAndSettle();
      
      
      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle(); 

      expect(find.text('Organizador'), findsOneWidget);
      expect(find.text('Participante 1'), findsOneWidget);
    });

    testWidgets('Navega a GameScreen al cerrar', (WidgetTester tester) async {
      await navigateToTournamentsScreen(tester);
      
      await tester.tap(find.byType(CloseButtonWidget));
      await tester.pumpAndSettle();
      
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('Marca ganador correctamente', (WidgetTester tester) async {
      final mockMatches = [
        {'id': 1, 'user1_id': 1, 'user2_id': 2, 'fecha': DateTime.now().toString(), 'ganador_id': 1},
      ];
      
      mockApiService.mockGetTournamentMatches(mockMatches);
      
      await navigateToTournamentsScreen(tester);
      await tester.pumpAndSettle();
      
      final winnerCard = find.byWidgetPredicate((widget) 
          => widget is Container && (widget.decoration as BoxDecoration?)?.border != null);
      expect(winnerCard, findsOneWidget);
    });

    testWidgets('Muestra mensaje cuando no hay próximas partidas', (WidgetTester tester) async {
      mockApiService.mockGetTournamentDetails(
        {
        'torneo' : {
            'id': 3,
            'nombre': 'Torneo de Prueba',
            'descripcion': 'Descripción de prueba',
            'premio': 1000,
            'contrasena': null,
            'fecha_inicio': null,
            'ganador_id': null,
            'creador_id': 1,
            'torneo_en_curso': true,
            },
          'participantes': [
            {
              'id': 1,
              'user_id': 1,
              'nombre': 'Organizador',
              'avatar': 'assets/avatar.png',
              'level': 10,
              'victorias': 5,
              'partidas': [],
              'progreso': 0.75,
              'isOnline': true,
              'isConnected': false,
            },
            {
              'id': 2,
              'user_id': 2,
              'nombre': 'Participante 1',
              'avatar': 'assets/avatar2.png',
              'level': 8,
              'victorias': 3,
              'partidas': [],
              'progreso': 0.6,
              'isOnline': true,
              'isConnected': false,
            }
          ],
        }
      );
      mockApiService.mockGetTournamentMatches([]);
      
      await navigateToTournamentsScreen(tester);
      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('nextMatchStartingSoon')), findsOneWidget);
    });
  });
}