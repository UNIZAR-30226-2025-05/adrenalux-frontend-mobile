import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/focusCard_screen.dart';
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

const String FIXED_IMAGE = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  
  late MockApiService mockApiService;
  late MockGoogleAuthService mockGoogleAuthService;

  setUp(() {
    mockApiService = MockApiService();
    mockGoogleAuthService = MockGoogleAuthService();
    SharedPreferences.setMockInitialValues({});

    mockApiService.mockGetToken();
    mockApiService.mockValidateToken(true);
    mockApiService.mockGetPlantillas([]);

    mockApiService.mockGetUserData();
    mockApiService.mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ]);
    mockApiService.mockGetCollection();
    mockApiService.mockGetFullImageUrl();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (context) => SobresProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()..setLocale(const Locale('es')),),
        Provider<ApiService>.value(value: mockApiService),
        Provider<GoogleAuthService>.value(value: mockGoogleAuthService),
      ],
      child: app.MyApp(),
    );
  }

  Future<void> navigateToFocusCardScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 1));

    final bottomNavBar = find.byType(BottomNavigationBar);
    await tester.tap(find.descendant(
      of: bottomNavBar,
      matching: find.byIcon(Icons.backpack),
    ));
    await tester.pumpAndSettle(Duration(seconds: 1));

    await tester.tap(find.byType(PlayerCardWidget).first);
    await tester.pumpAndSettle();
  }

  group('FocusCardScreen Tests', () {
    testWidgets('Muestra detalles de la carta correctamente', (WidgetTester tester) async {
      await navigateToFocusCardScreen(tester);
      
      expect(find.text('Lionel'), findsOneWidget);
      expect(find.text('Posición: Forward'), findsOneWidget);
      expect(find.byType(PlayerCardWidget), findsOneWidget);
      expect(find.byKey(Key('sell-text')), findsOneWidget);
    });

    testWidgets('Rotación 3D de la carta con gestos', (WidgetTester tester) async {
      await navigateToFocusCardScreen(tester);
      
      final card = find.byType(PlayerCardWidget);
      await tester.drag(card, Offset(300, 0)); 
      await tester.pumpAndSettle();
      
      expect(find.text('POSICIÓN'), findsOneWidget);
    });

    testWidgets('Mostrar diálogo de venta al pulsar botón', (WidgetTester tester) async {
      await navigateToFocusCardScreen(tester);
      
      await tester.tap(find.text('Vender'));
      await tester.pumpAndSettle();
      
      expect(find.text('Establecer precio de venta'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Vender carta con precio válido', (WidgetTester tester) async {
      mockApiService.mockSellCard(true);
      await navigateToFocusCardScreen(tester);
      
      await tester.tap(find.byKey(Key('sell-text')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), '1000');
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('on-sale-text')), findsOneWidget);
      expect(find.byKey(Key('sell-text')), findsNothing);
    });

    testWidgets('Error al vender con precio inválido', (WidgetTester tester) async {
      await navigateToFocusCardScreen(tester);
      
      await tester.tap(find.byKey(Key('sell-text')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), '-100');
      await tester.tap(find.text('Confirmar'));
      await tester.pump(Duration(seconds: 1));
      
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Eliminar carta del mercado', (WidgetTester tester) async {
      mockApiService.mockDeleteFromMarket(true);

      mockApiService.mockSellCard(true);
      await navigateToFocusCardScreen(tester);

      await tester.tap(find.byKey(Key('sell-text')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), '1000');
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('on-sale-text')));
      await tester.pump(Duration(seconds: 1));
      
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
      expect(find.byKey(Key('sell-text')), findsOneWidget);
    });

    testWidgets('Cerrar pantalla con botón', (WidgetTester tester) async {
      await navigateToFocusCardScreen(tester);
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      
      expect(find.byType(FocusCardScreen), findsNothing);
    });
  });
}