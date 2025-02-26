
enum GameState {idle, inProgress, finished, paused }

Map<String, GameState> stateMap = {
  'idle': GameState.idle,
  'inProgress': GameState.inProgress,
  'finished': GameState.finished,
  'paused': GameState.paused,
  'en curso': GameState.inProgress,  
  'finalizada': GameState.finished
};

class Partida {
  final int id;
  final int turn;
  final GameState state;
  final int? winnerId;
  final DateTime date;
  final int player1;
  final int player2;
  final int? tournamentId;

  const Partida({
    required this.id,
    required this.turn,
    this.state = GameState.idle,
    this.winnerId,
    required this.date,
    required this.player1,
    required this.player2,
    this.tournamentId,
  });

  factory Partida.fromJson(Map<String, dynamic> json) {
    return Partida(
      id: json['id'],
      turn: json['turno'],
      state: stateMap[json['estado']] ?? GameState.inProgress,
      winnerId: json['ganador_id'],
      date: DateTime.parse(json['fecha']),
      player1: json['user1_id'],
      player2: json['user2_id'],
      tournamentId: json['torneo_id'],
    );
  }
}