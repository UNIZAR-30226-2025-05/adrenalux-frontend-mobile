import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {
  static const String FIXED_IMAGE = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png';
  void mockValidateToken(bool value) {
    when(() => validateToken()).thenAnswer((_) async => value);
  }

  void mockGetToken() {
    when(() => getToken()).thenAnswer((_) async => 'eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwiZW1haWwiOiJtYXJjb3Nnb21hbWFydGluZXpAZ21haWwuY29tIiwiaWF0IjoxNzQzODUyMTg0LCJleHAiOjE3NzU0MDk3ODR9.QnUCLt48CPOO9gvgHIaYbu_cwgE8AdoWPGAOhVPvh1Q');
  }

  void mockGetUserData([Map<String, dynamic> customData = const {}]) {
    final defaultData = {
      'id': 1,
      'name': "Usuario Ejemplo",
      'email': "usuario@ejemplo.com",
      'friend_code': "FRIEND123",
      'photo': "assets/profile_1.png",
      'coins': 1000,
      'gems': 500,
      'xp': 1000,
      'level': 5,
      'xpMax': 1500,
      'lastConnection': DateTime.now().subtract(const Duration(hours: 7)),
      'logros': [
        Logro(
          id: 1,
          description: "Primer logro alcanzado",
          rewardType: "coins",
          rewardAmount: 100,
          logroType: 1,
          requirement: 10,
          achieved: true,
        ),
        Logro(
          id: 2,
          description: "Segundo logro pendiente",
          rewardType: "xp",
          rewardAmount: 50,
          logroType: 2,
          requirement: 20,
          achieved: false,
        ),
      ],
      'partidas': [
        Partida(
          id: 1,
          turn: 10,
          state: GameState.paused,
          winnerId: null,
          date: DateTime.now().subtract(const Duration(days: 1)),
          player1: 1,
          player2: 2,
          puntuacion1: 3,
          puntuacion2: 2,
        ),
        Partida(
          id: 1,
          turn: 10,
          state: GameState.finished,
          winnerId: 1,
          date: DateTime.now().subtract(const Duration(days: 1)),
          player1: 1,
          player2: 2,
          puntuacion1: 3,
          puntuacion2: 2,
        ),
        Partida(
          id: 1,
          turn: 10,
          state: GameState.finished,
          winnerId: null,
          date: DateTime.now().subtract(const Duration(days: 1)),
          player1: 1,
          player2: 2,
          puntuacion1: 3,
          puntuacion2: 2,
        ),
      ],
    };

    final mergedData = {...defaultData, ...customData};

    final partidas = (mergedData['partidas'] as List<dynamic>?)
      ?.map((e) => e is Partida ? e : Partida.fromJson(e as Map<String, dynamic>))
      .toList();

    when(() => getUserData()).thenAnswer((_) async {
      updateUser(
        mergedData['id'] as int,
        mergedData['name'] as String,
        mergedData['email'] as String,
        mergedData['friend_code'] as String,
        mergedData['photo'] as String,
        mergedData['coins'] as int,
        mergedData['gems'] as int,
        mergedData['xp'] as int,
        mergedData['level'] as int,
        mergedData['xpMax'] as int,
        mergedData['lastConnection'] as DateTime,
        mergedData['logros'] as List<Logro>,
        partidas ?? [],
      );
    });
  }

  void mockGetSobresDisponibles(List<Sobre> sobres) {
    when(() => getSobresDisponibles()).thenAnswer((_) async => sobres);
  }

  void mockGetSobre(Map<String, dynamic> sobreResponse) {
    when(() => getSobre(any())).thenAnswer((_) async => sobreResponse);
  }

  void mockGetFriendDetails(Map<String, dynamic> friendDetails) {
    when(() => getFriendDetails(any())).thenAnswer((_) async => friendDetails);
  }

  void mockGetCollection(List<PlayerCard> collection) {
    when(() => getCollection()).thenAnswer((_) async => collection);
  }

  void mockGetMarket([List<Map<String, dynamic>>? customMarket]) {
    final defaultMarket = [
      {
        'id': 1,
        'nombre': 'Lionel',
        'alias': 'Messi',
        'equipo': 'Inter Miami',
        'ataque': 95,
        'control': 98,
        'defensa': 40,
        'tipo_carta': CARTA_LUXURY,
        'escudo': FIXED_IMAGE,
        'photo': FIXED_IMAGE,
        'posicion': 'Forward',
        'precio': 1500000.0,
        'cantidad': 1,
        'enVenta': true,
        'mercadoCartaId': 101,
      },
      {
        'id': 2,
        'nombre': 'Cristiano',
        'alias': 'Ronaldo',
        'equipo': 'Al-Nassr',
        'ataque': 93,
        'control': 90,
        'defensa': 45,
        'tipo_carta': CARTA_MEGALUXURY,
        'escudo': FIXED_IMAGE,
        'photo': FIXED_IMAGE,
        'posicion': 'Forward',
        'precio': 2000000.0,
        'cantidad': 1,
        'enVenta': true,
        'mercadoCartaId': 102,
      },
    ];

    final mergedMarket = customMarket ?? defaultMarket;

    final market = mergedMarket
        .map((e) => e is PlayerCard ? e : PlayerCard.fromJson(e))
        .toList()
        .cast<PlayerCard>();

    when(() => getMarket()).thenAnswer((_) async => market);
  }

  void mockGetDailyLuxuries([List<Map<String, dynamic>>? customDailyLuxuries]) {
    final defaultDailyLuxuries = [
      {
        'id': 3,
        'nombre': 'Kylian',
        'alias': 'Mbappe',
        'equipo': 'Paris Saint-Germain',
        'ataque': 92,
        'control': 89,
        'defensa': 50,
        'tipo_carta': CARTA_LUXURYXI,
        'escudo': FIXED_IMAGE,
        'photo': FIXED_IMAGE,
        'posicion': 'Forward',
        'precio': 1800000.0,
        'cantidad': 1,
        'enVenta': true,
        'mercadoCartaId': 103,
      },
      {
        'id': 4,
        'nombre': 'Virgil',
        'alias': 'van Dijk',
        'equipo': 'Liverpool',
        'ataque': 60,
        'control': 75,
        'defensa': 95,
        'tipo_carta': CARTA_LUXURY,
        'escudo': FIXED_IMAGE,
        'photo': FIXED_IMAGE,
        'posicion': 'Defender',
        'precio': 1200000.0,
        'cantidad': 1,
        'enVenta': true,
        'mercadoCartaId': 104,
      },
    ];

    final mergedDailyLuxuries = customDailyLuxuries ?? defaultDailyLuxuries;

    final dailyLuxuries = mergedDailyLuxuries
        .map((e) => e is PlayerCard ? e : PlayerCard.fromJson(e))
        .toList()
        .cast<PlayerCard>();

    when(() => getDailyLuxuries()).thenAnswer((_) async => dailyLuxuries);
  }

  void mockPurchaseMarketCard(bool success) {
    when(() => purchaseMarketCard(any())).thenAnswer((_) async {
      if (!success) {
        throw Exception("Error al comprar la carta del mercado");
      }
      return;
    });
  }

  void mockPurchaseDailyCard(bool success) {
    when(() => purchaseDailyCard(any())).thenAnswer((_) async {
      if (!success) {
        throw Exception("Error al comprar la carta del mercado");
      }
      return;
    });
  }

  void mockGetFriends(List<Map<String, dynamic>> friends) {
    when(() => getFriends()).thenAnswer((_) async => friends);
  }

  void mockGetFriendRequests(List<Map<String, dynamic>> friendRequests) {
    when(() => getFriendRequests()).thenAnswer((_) async => friendRequests);
  }

  void mockGetActiveTournaments(List<Map<String, dynamic>> tournaments) {
    when(() => getActiveTournaments()).thenAnswer((_) async => tournaments);
  }

  void mockGetUserTournaments(List<Map<String, dynamic>> tournaments) {
    when(() => getUserTournaments()).thenAnswer((_) async => tournaments);
  }

  void mockGetFullImageUrl() {
    when(() => getFullImageUrl(any())).thenAnswer((invocation) {
      final path = invocation.positionalArguments.first as String;
      return 'https://adrenalux.duckdns.org${path.startsWith('/') ? path : '/$path'}';
    });
  }

  void mockGetLeaderboard(List<Map<String, dynamic>> leaderboard) {
    when(() => fetchLeaderboard(any())).thenAnswer((_) async => leaderboard);
  }

  void mockUpdateUserData(bool success) {
    when(() => updateUserData(any(), any())).thenAnswer((invocation) async {
      final imageUrl = invocation.positionalArguments[0] as String?;
      final name = invocation.positionalArguments[1] as String?;
      updateProfileInfo(name: name , photo: imageUrl);
      return success;
    });
  }

  void mockSignUp(Map<String, dynamic> response) {
    when(() => signUp(any(), any(), any(), any(), any(), any())).thenAnswer((_) async => response);
  }

  void mockSignIn(Map<String, dynamic> response) {
    when(() => signIn(any(), any())).thenAnswer((_) async => response);
  }
}

class MockGoogleAuthService extends Mock implements GoogleAuthService {
  void mockSignInWithGoogle() {
    when(() => GoogleAuthService.signInWithGoogle(any())).thenAnswer((_) async => {
      'token': 'fake-token',
      'user': {'id': 1, 'email': 'test@test.com'}
    });
  }
}
