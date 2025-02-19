import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:adrenalux_frontend_mobile/models/card.dart';
class User {
  static final User _singleton = User._internal();

  int id = -1;
  String name = "",
      email = "",
      friendCode = "",
      photo = 'assets/default_profile.jpg';

  int adrenacoins = 0,
      xp = 0,
      level = 0,
      puntosClasificacion = 0;

  List<Logro> logros = [];
  List<Partida> partidas = [];
  List<PlayerCard> cards = [
    PlayerCard(
      playerName: 'Lionel',
      playerSurname: 'Messi',
      team : 'Paris Saint-Germain',
      shot: 95,
      control: 98,
      defense: 40,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 97.5,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Cristiano',
      playerSurname: 'Ronaldo',
      team : 'Juventus',
      shot: 94,
      control: 90,
      defense: 35,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 95.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Neymar',
      playerSurname: 'Jr.',
      team: "Paris Saint-Germain",
      shot: 92,
      control: 95,
      defense: 30,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 94.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Kylian',
      playerSurname: 'Mbappe',
      team : "Paris Saint-Germain",
      shot: 93,
      control: 92,
      defense: 35,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 94.5,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Luka',
      playerSurname: 'Modric',
      team: "Real Madrid",
      shot: 85,
      control: 95,
      defense: 80,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 90.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Medio',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Sergio',
      playerSurname: 'Ramos',
      team: "Real Madrid",
      shot: 70,
      control: 85,
      defense: 95,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.normal,
      averageScore: 90.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Virgil',
      playerSurname: 'van Dijk',
      team: "Liverpool",
      shot: 60,
      control: 80,
      defense: 95,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxuryXI,
      averageScore: 88.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Delantero',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Kevin',
      playerSurname: 'De Bruyne',
      team: "Manchester City",
      shot: 85,
      control: 95,
      defense: 75,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxuryXI,
      averageScore: 92.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Defensa',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Robert',
      playerSurname: 'Lewandowski',
      team :  "Bayern Munich",
      shot: 95,
      control: 90,
      defense: 40,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.normal,
      averageScore: 93.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Medio',
      price : 20.0,
    ),
    PlayerCard(
      playerName: 'Manuel',
      playerSurname: 'Neuer',
      team : "Bayern Munich",
      shot: 50,
      control: 85,
      defense: 95,
      teamLogo: 'assets/mock_team.png',
      rareza: Rareza.luxury,
      averageScore: 90.0,
      playerPhoto: 'assets/mock_player.png',
      position: 'Delantero',
      price : 20.0,
    ),
  ];
  
  factory User() {
    return _singleton;
  }
  
  User._internal();
}
void resetUser() {
  User user = User();
  user.id = -1;
  user.name = "";
  user.email = "";
  user.friendCode = "";
  user.photo = 'assets/default_profile.png';
  user.adrenacoins = 0;
  user.xp = 0;
  user.level = 0;
  user.puntosClasificacion = 0;
  user.logros.clear();
  user.partidas.clear();
}


updateUser(int id, String name, String email, String friendCode, String photo, int adrenacoins, 
          int xp, int level, int puntosClasificacion, List<Logro> logros, List<Partida> partidas) {

  final user = User();
  user.id = id;
  user.name = name;
  user.email = email;
  user.friendCode = friendCode;
  user.photo = photo;
  user.adrenacoins = adrenacoins;
  user.xp = xp;
  user.level = level;
  user.puntosClasificacion = puntosClasificacion;
  user.logros = logros;
  user.partidas = partidas;
}

void updatePartidas(List<Partida> partidas) {
  final user = User();
  user.partidas = partidas;
}

void updateAchievements(List<Logro> logros) {
  final user = User();
  user.logros = logros;
}

List<Logro> getAchievements() {
  final user = User();
  return user.logros.where((logro) => logro.achieved).toList();
}

void updateProfileInfo({String? name, String? email, String? photo}) {
  final user = User();
  if (name != null) user.name = name;
  if (email != null) user.email = email;
  if (photo != null) user.photo = photo;
}

void updateGameStats({int? adrenacoins, int? xp, int? puntos}) {
  final user = User();
  if (adrenacoins != null) user.adrenacoins = adrenacoins;
  if (xp != null) user.xp = xp;
  if (puntos != null) user.puntosClasificacion = puntos;
}

void levelUpUser() {
  final user = User();
  user.level++;
}

void setFriendCode(String code) {
  User().friendCode = code;
}

void addAdrenacoins(int cantidad) {
  User().adrenacoins += cantidad;
}

void addExperience(int xp) {
  User().xp += xp;
}

void updateClasificacion(int puntos) {
  User().puntosClasificacion = puntos;
}

void setUserId(int id) => User().id = id;
void setUserName(String name) => User().name = name;
void setUserEmail(String email) => User().email = email;
void setUserPhoto(String photo) => User().photo = photo;