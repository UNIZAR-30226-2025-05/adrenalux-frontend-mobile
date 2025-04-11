import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_up_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/home_screen.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adrenalux_frontend_mobile/main.dart' as app;
import '../mocks/mock_api_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  
  late MockApiService mockApiService;
  late MockGoogleAuthService mockGoogleAuthService;

  setUp(() {
    mockApiService = MockApiService();
    mockGoogleAuthService = MockGoogleAuthService();
    SharedPreferences.setMockInitialValues({});

    mockApiService.mockGetToken();
    mockApiService.mockValidateToken(false);
    mockApiService.mockGetPlantillas([]);

    mockApiService.mockGetUserData();
    mockApiService.mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 500),
      ]);
    mockApiService.mockGetSobre({'cartas': [], 'logroActualizado': false});
    mockApiService.mockGetCollection([]);
    mockApiService.mockGetFriends([]);
    mockApiService.mockGetFullImageUrl();
    mockApiService.mockGetFriendRequests([]);
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
      child: MaterialApp(
        locale: const Locale('es'),
        home: app.MyApp(),
      ),
    );
  }

  Future<void> navigateToSignInScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('¿Ya tienes una cuenta? Inicia sesión'));
    await tester.pumpAndSettle();
  }

  group('SignInScreen Tests', () {
    testWidgets('Navega al Home cuando el login es correcto', (WidgetTester tester) async {
      mockApiService.mockSignIn({
        'data': {
          'token': 'fake-token',
          'user': {'id': 1, 'email': 'test@test.com'}
        }
      });

      await navigateToSignInScreen(tester);

      await tester.enterText(find.byKey(Key('email-field')), 'test@test.com');
      await tester.enterText(find.byKey(Key('password-field')), 'password123');

      await tester.tap(find.byKey(Key('login-button')));
      await tester.pumpAndSettle();

      expect(find.byType(MenuScreen), findsOneWidget);
      expect(find.byKey(const Key('menu-screen')), findsOneWidget);

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Muestra error cuando las credenciales son incorrectas', (WidgetTester tester) async {
      mockApiService.mockSignIn({
        'data' : {
          'token': null,
        },
        'statusCode': 401,
        'error': 'Exception: Credenciales inválidas'
      });

      await navigateToSignInScreen(tester);

      await tester.enterText(find.byKey(Key('email-field')), 'test@test.com');
      await tester.enterText(find.byKey(Key('password-field')), 'wrongpassword');

      await tester.tap(find.byKey(Key('login-button')));
      await tester.pump();

      expect(find.text('Credenciales inválidas'), findsOneWidget);
    });

    testWidgets('Muestra errores de validación en el formulario', (WidgetTester tester) async {
      await navigateToSignInScreen(tester);

      await tester.tap(find.byKey(Key('login-button')));
      await tester.pump();

      expect(find.text('El correo es obligatorio'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);

      await tester.enterText(find.byKey(Key('email-field')), 'emailinvalido');
      await tester.tap(find.byKey(Key('login-button')));
      await tester.pump();

      expect(find.text('Ingresa un correo válido'), findsOneWidget);
    });

    testWidgets('Navega a SignUpScreen al tocar el enlace', (WidgetTester tester) async {
      await navigateToSignInScreen(tester);

      await tester.tap(find.text('¿Aún no tienes una cuenta? Registrarse'));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);
    });
  });
}