import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
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

    registerFallbackValue(
      Draft(
        id: 0,
        name: "Default Draft",
        draft: {},
      )
    );

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
      ..mockGetCollection([
        {
          'id':50,
          'nombre': 'Ter Stegen',
          'alias': 'Ter Stegen',
          'equipo': 'FC Barcelona',
          'ataque': 50,
          'control': 40,
          'defensa': 100,
          'tipo_carta': CARTA_LUXURY,
          'escudo': FIXED_IMAGE,
          'photo': FIXED_IMAGE,
          'posicion': 'goalkeeper',
          'precio': 1500000.0,
          'cantidad': 3,
          'enVenta': true,
          'mercadoCartaId': 101,
        }
      ])
      ..mockGetPlantillas()
      ..mockGetUserData()
      ..mockGetToken()
      ..mockCreatePlantilla(true)
      ..mockActivarPlantilla(true)
      ..mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ])
      ..mockGetFullImageUrl()
      ..mockValidateToken(true)
      ..mockFetchLeaderboard()
      ..mockDeletePlantilla(true)
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

  Future<void> navigateToEditDraftScreen(WidgetTester tester) async {
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

    await tester.tap(find.byKey(Key('drafts-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();
  }

  Future<void> navigateToNewDraftScreen(WidgetTester tester) async {
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

    await tester.tap(find.byKey(Key('drafts-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('create_template_button')));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextField), 'Nuevo Equipo');
    await tester.tap(find.byKey(Key('confirm_create_template')));
    await tester.pumpAndSettle();
  }

  group('DraftsScreen Tests', () {
    testWidgets('Muestra jugadores existentes al cargar', (WidgetTester tester) async {
      await navigateToEditDraftScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(Key('draft_card_FWD1')), findsOneWidget);
      expect(find.byKey(Key('draft_card_FWD2')), findsOneWidget);
    });

    testWidgets('Abre panel de selección al tocar posición', (WidgetTester tester) async {
      await navigateToEditDraftScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('draft_card_GK')));
      await tester.pumpAndSettle();

      expect(find.text('Seleccionar jugador (GK)'), findsOneWidget);
      expect(find.byKey(Key('draft_card_GK')), findsOneWidget);
      expect(find.text('Ter Stegen'), findsOneWidget);
    });

    testWidgets('No mostrar cartas ya elegidas en el panel de selección', (WidgetTester tester) async {
      await navigateToEditDraftScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('draft_card_GK')));
      await tester.pumpAndSettle();

      expect(find.text('Seleccionar jugador (GK)'), findsOneWidget);
      expect(find.text('Neuer'), findsOneWidget);

      await tester.tap(find.text('Ter Stegen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('draft_card_GK')));
      await tester.pumpAndSettle();

      expect(find.text('Ter Stegen'), findsOneWidget);
    });

    testWidgets('Guardar cambios en plantilla', (WidgetTester tester) async {
      await navigateToEditDraftScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('draft_card_GK')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ter Stegen'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('save-button')));
      await tester.pumpAndSettle();

      expect(find.byType(DraftsScreen), findsOneWidget);
    });

    testWidgets('No guardar si no plantilla no completada', (WidgetTester tester) async {
      await navigateToNewDraftScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('save-button')));
      await tester.pumpAndSettle();

      expect(find.byType(DraftsScreen), findsNothing);
    });

    testWidgets('Muestra diálogo al salir con cambios', (WidgetTester tester) async {
      await navigateToEditDraftScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('draft_card_GK')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ter Stegen'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('exit-dialog')), findsOneWidget);
    });

    testWidgets('No muestra diálogo al salir sin cambios', (WidgetTester tester) async {
      await navigateToEditDraftScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('exit-dialog')), findsNothing);
      expect(find.byType(DraftsScreen), findsOneWidget);
    });
  });
}
