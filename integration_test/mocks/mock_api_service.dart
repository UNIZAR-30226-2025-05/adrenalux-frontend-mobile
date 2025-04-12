import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
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

    final logros = (mergedData['logros'] as List<dynamic>?)
    ?.map((e) => e is Logro ? e : Logro.fromJson(e as Map<String, dynamic>))
    .toList();

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
        logros ?? [],
        partidas ?? [],
        mergedData['plantilla_activa_id'],
      );
    });
  }

  void mockGetSobresDisponibles(List<Sobre> sobres) {
    when(() => getSobresDisponibles()).thenAnswer((_) async => sobres);
  }

  void mockGetPlantillas([List<Map<String, dynamic>>? customDrafts]) {
    final defaultDrafts = [
      {
        'id': 1,
        'name': 'Draft 1',
        'draft': {
          'FWD1': PlayerCard(
            id: 1,
            playerName: 'Lionel',
            playerSurname: 'Messi',
            team: 'Inter Miami',
            shot: 95,
            control: 98,
            defense: 40,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 9.5,
            playerPhoto: FIXED_IMAGE,
            position: 'forward',
            price: 1500000.0,
          ),
          'FWD2': PlayerCard(
            id: 2,
            playerName: 'Cristiano',
            playerSurname: 'Ronaldo',
            team: 'Al-Nassr',
            shot: 93,
            control: 90,
            defense: 45,
            rareza: CARTA_MEGALUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 9.3,
            playerPhoto: FIXED_IMAGE,
            position: 'forward',
            price: 2000000.0,
          ),
          'FWD3': PlayerCard(
            id: 3,
            playerName: 'Kylian',
            playerSurname: 'Mbappe',
            team: 'Paris Saint-Germain',
            shot: 92,
            control: 89,
            defense: 50,
            rareza: CARTA_LUXURYXI,
            teamLogo: FIXED_IMAGE,
            averageScore: 9.2,
            playerPhoto: FIXED_IMAGE,
            position: 'forward',
            price: 1800000.0,
          ),
          'MID1': PlayerCard(
            id: 4,
            playerName: 'Luka',
            playerSurname: 'Modric',
            team: 'Real Madrid',
            shot: 80,
            control: 95,
            defense: 70,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 8.5,
            playerPhoto: FIXED_IMAGE,
            position: 'midfielder',
            price: 1200000.0,
          ),
          'MID2': PlayerCard(
            id: 5,
            playerName: 'Kevin',
            playerSurname: 'De Bruyne',
            team: 'Manchester City',
            shot: 85,
            control: 92,
            defense: 65,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 8.8,
            playerPhoto: FIXED_IMAGE,
            position: 'midfielder',
            price: 1400000.0,
          ),
          'MID3': PlayerCard(
            id: 6,
            playerName: 'Toni',
            playerSurname: 'Kroos',
            team: 'Real Madrid',
            shot: 78,
            control: 90,
            defense: 68,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 8.4,
            playerPhoto: FIXED_IMAGE,
            position: 'midfielder',
            price: 1100000.0,
          ),
          'DEF1': PlayerCard(
            id: 7,
            playerName: 'Virgil',
            playerSurname: 'van Dijk',
            team: 'Liverpool',
            shot: 60,
            control: 75,
            defense: 95,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 8.9,
            playerPhoto: FIXED_IMAGE,
            position: 'defender',
            price: 1200000.0,
          ),
          'DEF2': PlayerCard(
            id: 8,
            playerName: 'Sergio',
            playerSurname: 'Ramos',
            team: 'Sevilla',
            shot: 65,
            control: 70,
            defense: 90,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 8.7,
            playerPhoto: FIXED_IMAGE,
            position: 'defender',
            price: 1000000.0,
          ),
          'DEF3': PlayerCard(
            id: 9,
            playerName: 'Thiago',
            playerSurname: 'Silva',
            team: 'Chelsea',
            shot: 55,
            control: 72,
            defense: 88,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 8.6,
            playerPhoto: FIXED_IMAGE,
            position: 'defender',
            price: 950000.0,
          ),
          'DEF4': PlayerCard(
            id: 10,
            playerName: 'Jordi',
            playerSurname: 'Alba',
            team: 'Inter Miami',
            shot: 50,
            control: 80,
            defense: 85,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 8.3,
            playerPhoto: FIXED_IMAGE,
            position: 'defender',
            price: 900000.0,
          ),
          'GK': PlayerCard(
            id: 11,
            playerName: 'Manuel',
            playerSurname: 'Neuer',
            team: 'Bayern Munich',
            shot: 10,
            control: 50,
            defense: 95,
            rareza: CARTA_LUXURY,
            teamLogo: FIXED_IMAGE,
            averageScore: 9.0,
            playerPhoto: FIXED_IMAGE,
            position: 'goalkeeper',
            price: 1300000.0,
          ),
        },
      },
    ];

    final mergedDrafts = customDrafts ?? defaultDrafts;

    final drafts = mergedDrafts
        .map((e) => e is Draft
            ? e
            : Draft(
                id: e['id'] as int?,
                name: e['name'] as String,
                draft: (e['draft'] as Map<String, dynamic>).map(
                  (key, value) => MapEntry(
                    key,
                    value == null
                        ? null
                        : (value is PlayerCard
                            ? value
                            : PlayerCard.fromJson(value)),
                  ),
                ),
              ))
        .toList();

    when(() => getPlantillas()).thenAnswer((_) async => drafts.cast<Draft>());
  }

  void mockGetSobre(Map<String, dynamic> sobreResponse) {
    when(() => getSobre(any())).thenAnswer((_) async => sobreResponse);
  }

  void mockGetFriendDetails(Map<String, dynamic> friendDetails) {
    when(() => getFriendDetails(any())).thenAnswer((_) async => friendDetails);
  }

  void mockDeletePlantilla(bool success) {
    when(() => deletePlantilla(any())).thenAnswer((_) async => success);
  }

  void mockActivarPlantilla(bool success) {
    when(() => activarPlantilla(any())).thenAnswer((_) async => success);
  }

  void mockCreatePlantilla(bool success) {
    when(() => createPlantilla(any())).thenAnswer((_) async => success);
  }

  void mockGetCollection([List<Map<String, dynamic>>? customCollection]) {
    final defaultCollection = [
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
        'cantidad': 3,
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
      {
        'id': 3,
        'nombre': 'Player3',
        'alias': 'Player3',
        'equipo': 'Al-Nassr',
        'ataque': 93,
        'control': 90,
        'defensa': 45,
        'tipo_carta': CARTA_MEGALUXURY,
        'escudo': FIXED_IMAGE,
        'photo': FIXED_IMAGE,
        'posicion': 'Forward',
        'precio': 2000000.0,
        'cantidad': 0,
        'enVenta': true,
        'mercadoCartaId': 103,
      },
    ];

    final mergedCollection = customCollection ?? defaultCollection;

    final collection = mergedCollection
        .map((e) => e is PlayerCard ? e : PlayerCard.fromJson(e))
        .toList()
        .cast<PlayerCard>();

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

  void mockSendFriendRequest(bool success) {
    when(() => sendFriendRequest(any())).thenAnswer((_) async {
      if (!success) {
        throw Exception("Error al mandar la solicitud de amistad");
      }
      return success;
    });
  }

  void mockAcceptRequest(bool success) {
    when(() => acceptRequest(any())).thenAnswer((_) async {
      if (!success) {
        throw Exception("Error al aceptar la solicitud de amistad");
      }
      return success;
    });
  }

  void mockDeclineRequest(bool success) {
    when(() => declineRequest(any())).thenAnswer((_) async {
      if (!success) {
        throw Exception("Error al rechazar la solicitud de amistad");
      }
      return success;
    });
  }

  void mockDeleteFriend(bool success) {
    when(() => deleteFriend(any())).thenAnswer((_) async {
      if (!success) {
        throw Exception("Error al borrar al amigo");
      }
      return success;
    });
  }

  void mockGetFriends(List<Map<String, dynamic>> friends) {
    when(() => getFriends()).thenAnswer((_) async => friends);
  }

  void mockGetFriendRequests([List<Map<String, dynamic>>? customFriendRequests]) {
    final defaultFriendRequests = [
      {
        'id': 1,
        'name': 'Amigo1',
        'friend_code': 'FRIEND123',
        'avatar': 'assets/default_profile.jpg',
        'isConnected': true,
      },
      {
        'id': 2,
        'name': 'Amigo2',
        'friend_code': 'FRIEND456',
        'avatar': 'assets/default_profile.jpg',
        'isConnected': false,
      },
    ];

    final mergedFriendRequests = customFriendRequests ?? defaultFriendRequests;

    final friendRequests = mergedFriendRequests
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

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

  void mockGetPartidasPausadas(List<Partida> partidas) {
    when(() => getPartidasPausadas()).thenAnswer((_) async => partidas);
  }

  void mockFetchLeaderboard([List<Map<String, dynamic>>? customLeaderboard]) {
    final defaultLeaderboard = [
    {
      'id': '2',
        'friend_code': '12345',
        'username': 'Jugador1',
        'avatar': 'assets/default_profile.jpg',
        'name': 'Amigo1',
        'lastname': 'Uno',
        'level': 10,
        'isConnected': true,
        'clasificacion' : 1500
      },
      {
        'id': '3',
        'friend_code': '67890',
        'username': 'Jugador2',
        'avatar': 'assets/default_profile.jpg',
        'name': 'Amigo2',
        'lastname': 'Dos',
        'level': 5,
        'isConnected': false,
        'clasificacion' : 400
      }
    ];

    final mergedLeaderboard = customLeaderboard ?? defaultLeaderboard;

    final leaderboard = mergedLeaderboard
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    when(() => fetchLeaderboard(any())).thenAnswer((_) async => leaderboard);
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
