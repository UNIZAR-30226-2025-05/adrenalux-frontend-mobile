import 'package:adrenalux_frontend_mobile/models/card.dart';
import 'package:adrenalux_frontend_mobile/models/user.dart';
import 'package:flutter/material.dart';

class RoundInfo {
  final int roundNumber;
  final bool isUserTurn;
  final String phase;

  RoundInfo({
    required this.roundNumber,
    required this.isUserTurn,
    required this.phase,
  });

  factory RoundInfo.fromJson(Map<String, dynamic> json) => RoundInfo(
        roundNumber: json['roundNumber'],
        isUserTurn: int.parse(json['starter']) == User().id,
        phase: json['phase'],
      );
}

class OpponentSelection {
  final PlayerCard card;
  final String skill;

  OpponentSelection({
    required this.card,
    required this.skill,
  });

  factory OpponentSelection.fromJson(Map<String, dynamic> json) => OpponentSelection(
        card: PlayerCard.fromJson(json['carta']),
        skill: json['skill'],
      );
}

class RoundResult {
  final String? winnerId;
  final Map<String, int> scores;
  final PlayerCard userCard;
  final String userSkill;
  final PlayerCard opponentCard;
  final String opponentSkill;

  RoundResult({
    required this.winnerId,
    required this.scores,
    required this.userCard,
    required this.userSkill,
    required this.opponentCard,
    required this.opponentSkill,
  });

  factory RoundResult.fromJson(Map<String, dynamic> json) {
    final detalles = json['detalles'];
    final bool isUserPlayer1 = User().id == int.parse(detalles['jugador1']);
    return RoundResult(
      winnerId: json['ganador'],
      scores: Map<String, int>.from(json['scores']),
      userCard: PlayerCard.fromJson(
        isUserPlayer1 ? detalles['carta_j1'] : detalles['carta_j2']
      ),
      userSkill: isUserPlayer1 ? detalles['skill_j1'] : detalles['skill_j2'],
      opponentCard: PlayerCard.fromJson(
        isUserPlayer1 ? detalles['carta_j2'] : detalles['carta_j1']
      ),
      opponentSkill: isUserPlayer1 ? detalles['skill_j2'] : detalles['skill_j1'],
    );
  }
}

class MatchResult {
  final int userFinalScore;
  final int opponentFinalScore;
  final String winner;
  final DateTime matchEndTime;

  MatchResult({
    required this.userFinalScore,
    required this.opponentFinalScore,
    required this.winner,
    required this.matchEndTime,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) => MatchResult(
        userFinalScore: json['user_final_score'],
        opponentFinalScore: json['opponent_final_score'],
        winner: json['winner'],
        matchEndTime: DateTime.parse(json['match_end_time']),
      );
}

class MatchProvider extends ChangeNotifier {
  RoundInfo? _currentRound;
  OpponentSelection? _opponentSelection;
  RoundResult? _roundResult;
  MatchResult? _matchResult;

  RoundInfo? get currentRound => _currentRound;
  OpponentSelection? get opponentSelection => _opponentSelection;
  RoundResult? get roundResult => _roundResult;
  MatchResult? get matchResult => _matchResult;

  void updateRound(RoundInfo roundInfo) {
    _currentRound = roundInfo;
    notifyListeners();
  }

  void updateOpponentSelection(OpponentSelection selection) {
    _opponentSelection = selection;
    notifyListeners();
  }

  void updateRoundResult(RoundResult result) {
    _roundResult = result;
    notifyListeners();
  }

  void endMatch(MatchResult result) {
    _matchResult = result;
    _currentRound = null;
    _opponentSelection = null;
    _roundResult = null;
    notifyListeners();
  }

  static of(BuildContext buildContext) {}
}