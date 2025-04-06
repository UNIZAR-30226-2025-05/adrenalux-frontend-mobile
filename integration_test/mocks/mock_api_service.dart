import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/sobre.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:adrenalux_frontend_mobile/services/api_service.dart';
import 'package:adrenalux_frontend_mobile/services/google_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {
  void mockValidateToken(bool value) {
    when(() => validateToken()).thenAnswer((_) async => value);
  }

  void mockGetToken() {
    when(() => getToken()).thenAnswer((_) async => 'eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwiZW1haWwiOiJtYXJjb3Nnb21hbWFydGluZXpAZ21haWwuY29tIiwiaWF0IjoxNzQzODUyMTg0LCJleHAiOjE3NzU0MDk3ODR9.QnUCLt48CPOO9gvgHIaYbu_cwgE8AdoWPGAOhVPvh1Q');
  }
  
  void mockGetUserData() {
    when(() => getUserData()).thenAnswer((_) async {
      updateUser(
        1,
        "Usuario Ejemplo",
        "usuario@ejemplo.com",
        "FRIEND123",
        "assets/profile_1.png",
        1000,
        500,
        1000,
        5,
        1500,
        DateTime.now().subtract(Duration(hours: 2)),
        [
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
        [
          Partida(
            id: 1,
            turn: 10,
            state: GameState.finished,
            winnerId: 1,
            date: DateTime.now().subtract(Duration(days: 1)),
            player1: 1,
            player2: 2,
            puntuacion1: 3,
            puntuacion2: 2,
          ),
        ],
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

  void mockGetMarket(List<PlayerCard> market) {
    when(() => getMarket()).thenAnswer((_) async => market);
  }

  void mockGetDailyLuxuries(List<PlayerCard> dailyLuxuries) {
    when(() => getDailyLuxuries()).thenAnswer((_) async => dailyLuxuries);
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
    when(() => updateUserData(any(), any())).thenAnswer((_) async => success);
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
