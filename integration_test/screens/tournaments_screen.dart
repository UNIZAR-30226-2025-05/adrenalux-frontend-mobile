import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/play_tournament_screen.dart';
import 'package:adrenalux_frontend_mobile/services/socket_service.dart';
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

  group('TournamentsScreen Tests', () {
    testWidgets('Muestra lista de torneos activos', (WidgetTester tester) async {
      await navigateToTournamentsScreen(tester);
      
      expect(find.text('Torneo Global'), findsOneWidget);
      expect(find.byKey(Key('join-tournament-1')), findsOneWidget);
    });

    testWidgets('Muestra estado vacío sin torneos', (WidgetTester tester) async {
      mockApiService.mockGetActiveTournaments([]);
      
      await navigateToTournamentsScreen(tester);
      
      expect(find.text('No hay torneos activos'), findsOneWidget);
    });

    testWidgets('Crea torneo exitosamente', (WidgetTester tester) async {
      final newTournament = {
        'id': 3,
        'nombre': 'Nuevo Torneo',
        'descripcion': 'Desc',
        'premio': 2000,
        'contrasena': null,
        'fecha_inicio': null,
        'ganador_id': null,
        'creador_id': '1',
        'torneo_en_curso': false,
      };
      
      mockApiService.mockCreateTournament(newTournament);
      mockApiService.mockGetTournamentDetails({
        'torneo': newTournament,
        'participantes': [],
      });

      await navigateToTournamentsScreen(tester);
      
      await tester.tap(find.byKey(Key('create-tournament-button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(0), 'Nuevo Torneo');
      await tester.enterText(find.byType(TextFormField).at(2), '2000');
      await tester.enterText(find.byType(TextFormField).at(3), 'Desc');
      
      await tester.tap(find.byKey(Key('confirm-create-tournament')));
      await tester.pumpAndSettle();

      expect(find.byType(TournamentScreen), findsOneWidget);
    });

    testWidgets('Muestra error al crear torneo inválido', (WidgetTester tester) async {
      mockApiService.mockCreateTournamentError('Nombre inválido');

      await navigateToTournamentsScreen(tester);
      
      await tester.tap(find.byKey(Key('create-tournament-button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(0), 'Inv');
      await tester.enterText(find.byType(TextFormField).at(2), 2000.toString());
      await tester.enterText(find.byType(TextFormField).at(3), 'Desc');
      
      await tester.tap(find.byKey(Key('confirm-create-tournament')));
      await tester.pump(Duration(seconds : 1));

      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Permite unirse a torneo sin contraseña', (WidgetTester tester) async {
      mockApiService.mockJoinTournamentSuccess();
      mockApiService.mockGetTournamentDetails({
        'torneo': {
          'id': 1,
          'nombre': 'Torneo de Prueba',
          'fecha_inicio': null,
          'maxParticipants': 8,
          'premio': '1000',
          'descripcion': 'Descripción de prueba',
          'torneo_en_curso': false,
          'contrasena': null,
          'creador_id': 123, 
        },
        'participantes': [],
      });

      await navigateToTournamentsScreen(tester);
      
      await tester.tap(find.byKey(Key('join-tournament-1')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('confirm-join-tournament')));
      await tester.pumpAndSettle();

      expect(find.byType(TournamentScreen), findsOneWidget);
    });

    testWidgets('Redirige si tiene torneo activo', (WidgetTester tester) async {
      mockApiService.mockGetUserTournaments([
        {
          'id': '1',
          'name': 'Torneo Activo',
          'ganador_id': null,
          'torneo_en_curso': true,
          'premio': 2000,
          'contrasena': null,
          'fecha_inicio': null,
          'creador_id': '1',
        }
      ]);
      mockApiService.mockGetTournamentDetails({
        'torneo': {
          'id': 1,
          'nombre': 'Torneo de Prueba',
          'fecha_inicio': null,
          'maxParticipants': 8,
          'premio': '1000',
          'descripcion': 'Descripción de prueba',
          'torneo_en_curso': false,
          'contrasena': null,
          'creador_id': 123, 
        },
        'participantes': [
          {
            'user_id': User().id, 
            'avatar': 'assets/avatar.png',
            'nombre': 'Usuario Actual',
            'level': 10,
            'victorias': 5,
            'partidas': [],
            'progreso': 0.75,
            'isOnline': true,
            'id': User().id,
            'isConnected': false,
          },
        ],
      });

      await navigateToTournamentsScreen(tester);

      expect(find.byType(TournamentScreen), findsOneWidget);
    });

    testWidgets('Muestra torneos protegidos con contraseña', (WidgetTester tester) async {
      mockApiService.mockJoinTournamentSuccess();

      mockApiService.mockGetActiveTournaments([
        {
          'id': 2,
          'nombre': 'Torneo Privado',
          'descripcion': 'Con contraseña',
          'premio': 500,
          'contrasena': '1234',
          'fecha_inicio': null,
          'ganador_id': null,
          'creador_id': '1',
          'torneo_en_curso': false,
        }
      ]);

      mockApiService.mockGetTournamentDetails({
        'torneo': {
          'id': 2,
          'nombre': 'Torneo Privado',
          'descripcion': 'Con contraseña',
          'premio': 500,
          'contrasena': '1234',
          'fecha_inicio': null,
          'ganador_id': null,
          'creador_id': '1',
          'torneo_en_curso': false,
        },
        'participantes': [
          {
            'user_id': 1, 
            'avatar': 'assets/avatar.png',
            'nombre': 'Usuario 1',
            'level': 10,
            'victorias': 5,
            'partidas': [],
            'progreso': 0.75,
            'isOnline': true,
            'id': 1,
            'isConnected': false,
          },
          {
            'user_id': User().id, 
            'avatar': 'assets/avatar.png',
            'nombre': 'Usuario Actual',
            'level': 10,
            'victorias': 5,
            'partidas': [],
            'progreso': 0.75,
            'isOnline': true,
            'id': User().id,
            'isConnected': false,
          },
        ],
      });
      
      await navigateToTournamentsScreen(tester);
      
      await tester.tap(find.byKey(Key('join-tournament-2')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('join-tournament-password')), '1234');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('confirm-join-tournament')));
      await tester.pumpAndSettle();
      
      expect(find.byType(TournamentScreen), findsOneWidget);
    });

    testWidgets('Muestra error al unirse con contraseña incorrecta', (WidgetTester tester) async {
      mockApiService.mockJoinTournamentError('Contraseña incorrecta');
      
      await navigateToTournamentsScreen(tester);
      
      await tester.tap(find.byKey(Key('join-tournament-1')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'wrongpass');
      await tester.tap(find.byKey(Key('confirm-join-tournament')));
      await tester.pump();

      expect(find.text('Contraseña incorrecta'), findsOneWidget);
    });

    testWidgets('Actualiza lista al cambiar entre global/amigos', (WidgetTester tester) async {
      mockApiService.mockGetFriendsTournaments([
        {
          'id': 4,
          'nombre': 'Torneo Amigos',
          'descripcion': 'Solo amigos',
          'premio': 500,
          'contrasena': null,
          'fecha_inicio': null,
          'ganador_id': null,
          'creador_id': '2',
          'torneo_en_curso': false,
        }
      ]);

      await navigateToTournamentsScreen(tester);
      
      await tester.tap(find.text('Global'));
      await tester.pumpAndSettle();

      expect(find.text('Torneo Amigos'), findsOneWidget);
    });
       
    testWidgets('Muestra estado de torneo en progreso', (WidgetTester tester) async {
      mockApiService.mockGetActiveTournaments([
        {
          'id': 2,
          'nombre': 'Torneo Privado',
          'descripcion': 'Con contraseña',
          'premio': 500,
          'contrasena': '1234',
          'fecha_inicio': DateTime.now().toIso8601String(),
          'ganador_id': null,
          'creador_id': '1',
          'torneo_en_curso': true,
        }
      ]);


      await navigateToTournamentsScreen(tester);
      
      expect(find.byKey(Key('closed-tournament-text')), findsOneWidget);
    });

    testWidgets('Valida formulario de creación correctamente', (WidgetTester tester) async {
      await navigateToTournamentsScreen(tester);
      
      await tester.tap(find.byKey(Key('create-tournament-button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('confirm-create-tournament')));
      await tester.pump(Duration(seconds: 1));
      
      expect(find.text('Este campo es obligatorio'), findsNWidgets(3));
    });
  });
}