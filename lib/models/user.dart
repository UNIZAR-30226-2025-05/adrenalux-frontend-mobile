import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
class User {
  static final User _singleton = User._internal();

  int id = -1;
  String name = "",
      email = "",
      friendCode = "",
      photo = 'assets/default_profile.jpg';

  int adrenacoins = 0,
      xp = 0,
      xpMax = 1000,
      level = 0,
      puntosClasificacion = 0;

  List<Logro> logros = [];
  List<Partida> partidas = [];
  
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
          int xp,int xpMax, int level, int puntosClasificacion, List<Logro> logros, List<Partida> partidas) {

  final user = User();
  user.id = id;
  user.name = name;
  user.email = email;
  user.friendCode = friendCode;
  user.photo = photo;
  user.adrenacoins = adrenacoins;
  user.xp = xp;
  user.xpMax = xpMax;
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
  final user = User();
  user.adrenacoins += cantidad;
}

void subtractAdrenacoins(int cantidad) {
  final user = User();
  user.adrenacoins -= cantidad;
}

void updateExperience(int xp, int xpMax) {
  final user = User();
  user.xp = xp;
  user.xpMax = xpMax;
}

void updateLvl(int lvl) {
  final user = User();
  user.level = lvl;
}

void updateClasificacion(int puntos) {
  User().puntosClasificacion = puntos;
}

void setUserId(int id) => User().id = id;
void setUserName(String name) => User().name = name;
void setUserEmail(String email) => User().email = email;
void setUserPhoto(String photo) => User().photo = photo;