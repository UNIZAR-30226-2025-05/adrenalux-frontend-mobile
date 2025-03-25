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
  final String? winnerId;
  final bool isDraw;
  final Map<String, int> scores;
  final Map<String, int> puntosChange;

  MatchResult({
    required this.winnerId,
    required this.isDraw,
    required this.scores,
    required this.puntosChange,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) => MatchResult(
        winnerId: json['winnerId'],
        isDraw: json['isDraw'],
        scores: Map<String, int>.from(json['scores']),
        puntosChange: Map<String, int>.from(json['puntosChange']),
      );

  int getUserScore(String userId) => scores[userId] ?? 0;

  int getOpponentScore(String userId) => scores.values.firstWhere(
        (score) => score != getUserScore(userId),
        orElse: () => 0,
      );
}

class MatchProvider extends ChangeNotifier {
  RoundInfo? _currentRound;
  OpponentSelection? _opponentSelection;
  RoundResult? _roundResult;
  MatchResult? _matchResult;
  final Set<String> _usedCards = {};

  RoundInfo? get currentRound => _currentRound;
  OpponentSelection? get opponentSelection => _opponentSelection;
  RoundResult? get roundResult => _roundResult;
  MatchResult? get matchResult => _matchResult;
  Set<String> get usedCards => _usedCards;


  void addUsedCard(String cardId) {
    _usedCards.add(cardId);
    notifyListeners();
  }

  void resetUsedCards() {
    _usedCards.clear();
    notifyListeners();
  }

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
    resetUsedCards();
    notifyListeners();
  }

  static of(BuildContext buildContext) {}
}