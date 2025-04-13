import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/logros.dart';
import 'package:adrenalux_frontend_mobile/models/plantilla.dart';
import 'package:adrenalux_frontend_mobile/models/game.dart';
import 'package:flutter/material.dart';
class User {
  static final User _singleton = User._internal();

  int id = -1;
  String name = "",
      email = "",
      friend_code = "",
      photo = 'assets/default_profile.png';

  int adrenacoins = 0,
      xp = 0,
      xpMax = 1000,
      level = 0,
      puntosClasificacion = 0;
  
  bool dataLoaded = false;

  List<Logro> logros = [];
  List<Partida> partidas = [];

  DateTime? lastFreePack;
  ValueNotifier<bool> freePacksAvailable = ValueNotifier(true);
  ValueNotifier<int> packCooldown = ValueNotifier(0);

  int? selectedDraft;
  List<Draft> drafts = [];
  
  bool get isDraftComplete {
    final currentDraft = currentSelectedDraft;
    
    if (currentDraft.id == -1) {
      return false;
    }
    
    return currentDraft.draft.values.every((player) => player != null) &&
          currentDraft.draft.length == 11;
  }

  Draft get currentSelectedDraft {
    if (selectedDraft == null) {
      return Draft(id: -1, name: '', draft: {});
    }
    
    return drafts.firstWhere(
      (draft) => draft.id == selectedDraft, 
      orElse: () => Draft(id: -1, name: '', draft: {}),
    );
  }

  int? torneo_id = null;
  
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
  user.friend_code = "";
  user.photo = 'assets/default_profile.png';
  user.adrenacoins = 0;
  user.xp = 0;
  user.level = 0;
  user.puntosClasificacion = 0;
  user.logros.clear();
  user.partidas.clear();
  user.torneo_id = null;
}

void setSelectedDraft(int newDraft) {
  final user = User();
  final exists = user.drafts.any((d) => d.id == newDraft);
  
  if (exists) {
    user.selectedDraft = newDraft;
  }
}

void setUserTournamentId(String id) {
  User().torneo_id = int.parse(id);
}

void saveDraftTemplate(String id, String templateName, Map<String, PlayerCard?> draft) {
  final user = User();
  final index = user.drafts.indexWhere((t) => t.id == id);
  
  final newDraft = Draft(
    name: templateName,
    draft: Map.from(draft),
  );

  if (index != -1) {
    user.drafts[index] = newDraft;
  } else {
    user.drafts.add(newDraft);
  }
}

void deleteDraft(int id) {
  User user = User();
  
  if(user.selectedDraft != null && user.selectedDraft == id) {
    user.selectedDraft = null;
  }
  user.drafts.removeWhere((draft) => draft.id == id);
}
  

void updateCooldown() {
  final user = User();
  
  if (user.freePacksAvailable.value) {
    user.packCooldown.value = 0;
    return;
  }

  if (user.lastFreePack == null) {
    user.packCooldown.value = 0;
    return;
  }

  final nextAvailable = user.lastFreePack!.add(Duration(hours: 8));
  final remaining = nextAvailable.difference(DateTime.now());
  
  if (remaining <= Duration.zero) {
    user.freePacksAvailable.value = true;
    user.lastFreePack = DateTime.now();
    user.packCooldown.value = 0;
  } else {
    user.packCooldown.value = remaining.inMilliseconds.clamp(0, 28800000);
  }
}



updateUser(int id, String name, String email, String friendCode, String photo, int adrenacoins, 
      int xp, int xpMax, int level, int puntosClasificacion, DateTime? lastPack, List<Logro> logros, 
      List<Partida> partidas, int? selectedDraft) {

  final user = User();
  user.id = id;
  user.name = name;
  user.email = email;
  user.friend_code = friendCode;
  user.photo = photo;
  user.adrenacoins = adrenacoins;
  user.xp = xp;
  user.xpMax = xpMax;
  user.level = level;
  user.puntosClasificacion = puntosClasificacion;
  user.lastFreePack = lastPack;
  user.logros = logros;
  user.partidas = partidas;
  user.freePacksAvailable = (lastPack == null) ? ValueNotifier(true) : ValueNotifier(false);

  if (selectedDraft != null && user.drafts.any((draft) => draft.id == selectedDraft)) {
    user.selectedDraft = selectedDraft;
  } else {
    user.selectedDraft = null;
  }

  updateCooldown();
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

void updateProfileInfo({String? name, String? photo}) {
  User user = User();
  if (name != null) user.name = name;
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

void setDataLoaded(bool loaded) {
  final user = User();
  user.dataLoaded = loaded;
}

void setFriendCode(String code) {
  User().friend_code = code;
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



void updateLogros(List<Logro> nuevosLogros) {
  final user = User();
  user.logros.addAll(nuevosLogros);
}

void setUserId(int id) => User().id = id;
void setUserName(String name) => User().name = name;
void setUserEmail(String email) => User().email = email;
void setUserPhoto(String photo) => User().photo = photo;