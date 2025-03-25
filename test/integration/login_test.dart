import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/screens/home/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:adrenalux_frontend_mobile/screens/auth/sign_in_screen.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}
class MockGoogleAuthService extends Mock implements GoogleAuthService {}
class MockSobresProvider extends Mock implements SobresProvider {}


void main() {
  SharedPreferences.setMockInitialValues({});
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late MockApiService mockApiService;
  late MockGoogleAuthService mockGoogleAuthService;
  final mockSobresProvider = MockSobresProvider();

  setUpAll(() {
    registerFallbackValue(BuildContext);
  });

  setUp(() {
    mockApiService = MockApiService();
    mockGoogleAuthService = MockGoogleAuthService();
    

    when(() => mockSobresProvider.cargarSobres()).thenAnswer((_) async => <Sobre>[]);

    when(() => mockApiService.signIn(any(), any()))
        .thenAnswer((_) async => {'data': {'token': 'valid_token'}});
  });

  Future<void> pumpSignInScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SobresProvider>.value(value: mockSobresProvider),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => LocaleProvider()),
          Provider<ApiService>(create: (_) => mockApiService),
          Provider<GoogleAuthService>(create: (_) => mockGoogleAuthService),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Pruebas de integración para SignInScreen', () {

    testWidgets('Muestra error con email inválido', (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      await tester.enterText(find.byKey(const Key('email-field')), 'invalid-email');
      await tester.enterText(find.byKey(const Key('password-field')), 'Password123!');
      
      await tester.tap(find.byKey(Key('login-button')));
      await tester.pumpAndSettle();

      expect(find.text('Correo electrónico inválido'), findsOneWidget);
    });

    testWidgets('Muestra error con contraseña corta', (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      await tester.enterText(find.byKey(const Key('email-field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password-field')), 'short');
      
      await tester.tap(find.byKey(Key('login-button')));
      await tester.pumpAndSettle();

      expect(find.text('La contraseña debe tener al menos 6 caracteres'), findsOneWidget);
    });

    testWidgets('Muestra error de credenciales incorrectas', (WidgetTester tester) async {
      when(() => mockApiService.signIn(any(), any()))
          .thenThrow(Exception('Credenciales incorrectas'));
      
      await pumpSignInScreen(tester);

      await tester.enterText(find.byKey(const Key('email-field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password-field')), 'WrongPassword');
      
      await tester.tap(find.byKey(Key('login-button')));
      await tester.pumpAndSettle();

      expect(find.text('Credenciales incorrectas'), findsOneWidget);
    });

    testWidgets('Navegación a pantalla de registro', (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      await tester.tap(find.text('¿No tienes una cuenta? Regístrate'));
      await tester.pumpAndSettle();

      expect(find.byType(Placeholder), findsOneWidget); 
    });
  });
}