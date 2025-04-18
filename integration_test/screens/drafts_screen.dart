import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/game/edit_draft_screen.dart';
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

  Future<void> navigateToDraftsScreen(WidgetTester tester) async {
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
  }

  group('DraftsScreen Tests', () {
    testWidgets('Muestra lista de drafts cargados', (WidgetTester tester) async {
      await navigateToDraftsScreen(tester);
      
      expect(find.text('Draft 1'), findsOneWidget);
      expect(find.byKey(Key('draft_template_1')), findsOneWidget);
    });

    testWidgets('Crear nuevo draft con diálogo', (WidgetTester tester) async {
      await navigateToDraftsScreen(tester);
      
      await tester.tap(find.byKey(Key('create_template_button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'Nuevo Equipo');
      await tester.tap(find.byKey(Key('confirm_create_template')));
      await tester.pumpAndSettle();
      
      expect(find.byType(EditDraftScreen), findsOneWidget);
    });

    testWidgets('Eliminar draft existente', (WidgetTester tester) async {
      await navigateToDraftsScreen(tester);
      
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump(Duration(seconds: 3));
      
      verify(() => mockApiService.deletePlantilla(1)).called(1);
      expect(find.text('Draft 1'), findsNothing);
    });

    testWidgets('Navegar a edición de draft', (WidgetTester tester) async {
      await navigateToDraftsScreen(tester);
      
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();
      
      expect(find.byType(EditDraftScreen), findsOneWidget);
    });

    testWidgets('Mostrar estado vacío sin drafts', (WidgetTester tester) async {
      mockApiService.mockGetPlantillas([]);
      await navigateToDraftsScreen(tester);
      
      expect(find.text('No hay plantillas creadas'), findsOneWidget);
    });

    testWidgets('Manejar error al cargar drafts', (WidgetTester tester) async {
      mockApiService.mockGetPlantillas([]);
      await navigateToDraftsScreen(tester);
      
      expect(find.byKey(Key('no_templates_message')), findsOneWidget);
    });

    testWidgets('Seleccionar draft activo', (WidgetTester tester) async {
      await navigateToDraftsScreen(tester);
      
      await tester.tap(find.byKey(Key('active_template_panel')));
      await tester.pump(Duration(seconds: 1));
      
      await tester.tap(find.byKey(Key('draft_template_1')));
      await tester.pumpAndSettle();
      
      expect(User().currentSelectedDraft.name, 'Draft 1');
    });
  });
}
