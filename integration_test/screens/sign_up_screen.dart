import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
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
    mockApiService.mockSignIn({
      'token': 'fake-token',
      'user': {'id': 1, 'email': 'test@test.com'}
    });
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

  Future<void> navigateToSignUpScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pumpAndSettle();
  }

  group('SignUpScreen Tests', () {
    testWidgets('Renderiza correctamente los elementos principales', (WidgetTester tester) async {
      await navigateToSignUpScreen(tester);
      expect(find.byKey(Key('name-field')), findsOneWidget);
      expect(find.byKey(Key('lastname-field')), findsOneWidget);
      expect(find.byKey(Key('username-field')), findsOneWidget);
      expect(find.byKey(Key('email-field')), findsOneWidget);
      expect(find.byKey(Key('password-field')), findsOneWidget);
      expect(find.byKey(Key('confirm-password-field')), findsOneWidget);
      expect(find.byKey(Key('sign-up-button')), findsOneWidget);
      expect(find.byKey(Key('redirect-sign-in')), findsOneWidget);
    });

    testWidgets('Muestra errores de validación en el formulario', (WidgetTester tester) async {
      await navigateToSignUpScreen(tester);

      await tester.tap(find.byKey(Key('sign-up-button')));
      await tester.pumpAndSettle();

      expect(find.text('El nombre es obligatorio'), findsOneWidget);
      expect(find.text('El apellido es obligatorio'), findsOneWidget);
      expect(find.text('El nombre de usuario es obligatorio'), findsOneWidget);
      expect(find.text('El correo es obligatorio'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
      expect(find.text('La confirmación de contraseña es obligatoria'), findsOneWidget);

      await tester.enterText(find.byKey(Key('email-field')), 'emailinvalido');
      await tester.tap(find.byKey(Key('sign-up-button')));
      await tester.pump();

      expect(find.text('Ingresa un correo válido'), findsOneWidget);

      await tester.enterText(find.byKey(Key('password-field')), '123');
      await tester.tap(find.byKey(Key('sign-up-button')));
      await tester.pump();

      expect(find.text('La contraseña debe tener al menos 6 caracteres'), findsOneWidget);

      await tester.enterText(find.byKey(Key('password-field')), 'password123');
      await tester.enterText(find.byKey(Key('confirm-password-field')), 'password456');
      await tester.tap(find.byKey(Key('sign-up-button')));
      await tester.pump();

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('Navega a SignInScreen', (WidgetTester tester) async {
      await navigateToSignUpScreen(tester);

      await tester.tap(find.text('¿Ya tienes una cuenta? Inicia sesión'));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    });
    
    testWidgets('Muestra error cuando el registro falla', (WidgetTester tester) async {
      mockApiService.mockSignUp({'statusCode': 400, 'errorMessage': 'Este correo ya está en uso'});
      await navigateToSignUpScreen(tester);

      await tester.enterText(find.byKey(Key('name-field')), 'test');
      await tester.enterText(find.byKey(Key('lastname-field')), 'test');
      await tester.enterText(find.byKey(Key('username-field')), 'test');
      await tester.enterText(find.byKey(Key('email-field')), 'test@test.com');
      await tester.enterText(find.byKey(Key('password-field')), 'password123');
      await tester.enterText(find.byKey(Key('confirm-password-field')), 'password123');

      await tester.tap(find.byKey(Key('sign-up-button')));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Navega al Home cuando el registro es correcto', (WidgetTester tester) async {
      mockApiService.mockSignUp({
        'statusCode': 201,
        'data': {}, 
      });
      await navigateToSignUpScreen(tester);

      await tester.enterText(find.byKey(Key('name-field')), 'test');
      await tester.enterText(find.byKey(Key('lastname-field')), 'test');
      await tester.enterText(find.byKey(Key('username-field')), 'test');
      await tester.enterText(find.byKey(Key('email-field')), 'test@test.com');
      await tester.enterText(find.byKey(Key('password-field')), 'password123');
      await tester.enterText(find.byKey(Key('confirm-password-field')), 'password123');

      await tester.tap(find.byKey(Key('sign-up-button')));
      await tester.pumpAndSettle();

      expect(find.byType(MenuScreen), findsOneWidget);
      expect(find.byKey(const Key('menu-screen')), findsOneWidget);

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}