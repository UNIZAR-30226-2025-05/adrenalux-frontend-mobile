import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/providers/locale_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/match_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/sobres_provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    mockApiService.mockValidateToken(true);

    mockApiService.mockGetUserData();
    mockApiService.mockGetSobresDisponibles([
        Sobre(tipo: "Básico", imagen: '/public/images/sobres/sobre_energia_lux.png', precio: 100),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_elite_lux.png', precio: 500),
        Sobre(tipo: "Premium", imagen: '/public/images/sobres/sobre_master_lux.png', precio: 2500),
      ]);
    mockApiService.mockGetFullImageUrl();
    mockApiService.mockGetFriendDetails({
      'id': '123',
      'username': 'TestUser',
      'friend_code': 'ABC123',
      'avatar': '/public/images/avatars/avatar1.png',
      'level': 5,
      'experience': 1200,
      'xpMax': 1500,
      'partidas': [
        {'id': '1', 'score': 100, 'date': '2023-01-01'},
        {'id': '2', 'score': 200, 'date': '2023-01-02'},
      ],
      'logros': [
        {'id': '1', 'name': 'First Win', 'description': 'Win your first match'},
        {'id': '2', 'name': 'Top Scorer', 'description': 'Score 200 points'},
      ],
    });
    mockApiService.mockGetPlantillas([]);
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: app.MyApp(),
      ),
    );
  }

  Future<void> navigateToProfileScreenFromHome(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.tap(find.byKey(Key('welcome-screen-gesture')));
    await tester.pump(Duration(seconds: 2));

    await tester.tap(find.byType(ExperienceCircleAvatar)); 
    await tester.pumpAndSettle();
  }

  group('ProfileScreen Tests', () {
    testWidgets('ProfileScreen displays user info', (WidgetTester tester) async {
      await navigateToProfileScreenFromHome(tester);

      expect(find.byKey(Key('profile-avatar')), findsOneWidget);

      expect(find.byKey(Key('profile-level')), findsOneWidget);
      expect(find.byKey(Key('profile-xp')), findsOneWidget);
      expect(find.byKey(Key('friend-code')), findsOneWidget);
    });

    testWidgets('Copy friend code to clipboard', (WidgetTester tester) async {
      await navigateToProfileScreenFromHome(tester);
      
      final copyButton = find.byKey(Key('copy-friend-code-button'));
      await tester.tap(copyButton);
      await tester.pump();

      expect(Clipboard.getData('text/plain'), completion(isNotNull));
      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Display game list with different states', (WidgetTester tester) async {
      await navigateToProfileScreenFromHome(tester);
      
      final pausedIcon = find.byKey(Key('game-status-icon-0'));
      expect(pausedIcon, findsOneWidget);
      final pausedIconWidget = tester.widget<Icon>(pausedIcon);
      expect(pausedIconWidget.icon, Icons.pause);
      expect(pausedIconWidget.color, Colors.grey);

      final victoryIcon = find.byKey(Key('game-status-icon-1'));
      expect(victoryIcon, findsOneWidget);
      final victoryIconWidget = tester.widget<Icon>(victoryIcon);
      expect(victoryIconWidget.icon, Icons.sports_soccer);
      expect(victoryIconWidget.color, Colors.green);

      final drawIcon = find.byKey(Key('game-status-icon-2'));
      expect(drawIcon, findsOneWidget);
      final drawIconWidget = tester.widget<Icon>(drawIcon);
      expect(drawIconWidget.icon, Icons.people_alt_outlined);
      expect(drawIconWidget.color, Colors.blue);
    });

    testWidgets('Show empty state for games list', (WidgetTester tester) async {
      mockApiService.mockGetUserData({'partidas': []});
      
      await navigateToProfileScreenFromHome(tester);
      
      expect(find.byKey(Key('no-games-text')), findsOneWidget);
    });

    testWidgets('Tapping edit icon opens username dialog and updates username', (WidgetTester tester) async {
      mockApiService.mockUpdateUserData(true);

      await navigateToProfileScreenFromHome(tester);

      final editIcon = find.byKey(Key('edit-username-icon'));
      expect(editIcon, findsOneWidget);

      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.byKey(Key('username-dialog')), findsOneWidget);

      final newName = 'NuevoNombre';
      await tester.enterText(find.byKey(Key('username-textfield')), newName);
      await tester.pump();

      final saveButton = find.byKey(Key('save-username-button'));
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pump(Duration(seconds: 2));

      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Tapping profile avatar opens image selection dialog and confirms update', (WidgetTester tester) async {
      mockApiService.mockUpdateUserData(true);
      await navigateToProfileScreenFromHome(tester);

      await tester.tap(find.byKey(Key('profile-avatar')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('image-selection-dialog')), findsOneWidget);

      final imageTile = find.byKey(Key('profile-image-0'));
      await tester.tap(imageTile);
      await tester.pump();

      final confirmButton = find.byKey(Key('confirm-image-selection'));
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);
      await tester.pump(Duration(seconds: 2));

      expect(find.byKey(Key('snack-bar')), findsOneWidget);
    });

    testWidgets('Validate username input', (WidgetTester tester) async {
      await navigateToProfileScreenFromHome(tester);
      await tester.tap(find.byKey(Key('edit-username-icon')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('username-textfield')), '');
      await tester.pump();

      await tester.tap(find.byKey(Key('save-username-button')));
      await tester.pump();
      expect(find.text(AppLocalizations.of(tester.element(find.byType(AlertDialog)))!.usernameRequired), 
        findsOneWidget);
    });

    testWidgets('Cancel dialog without changes', (WidgetTester tester) async {
      await navigateToProfileScreenFromHome(tester);
      
      await tester.tap(find.byKey(Key('edit-username-icon')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocalizations.of(tester.element(find.byType(AlertDialog)))!.cancel));
      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('username-dialog')), findsNothing);
    });
  });
}