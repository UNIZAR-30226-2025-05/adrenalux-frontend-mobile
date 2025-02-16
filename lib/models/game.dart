
enum GameState {idle, inProgress, finished, paused }

class Partida {
  final int id;
  final int turn;
  final GameState state;
  final String? winnerId;
  final DateTime date;
  final String player1;
  final String player2;
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
      turn: json['turn'],
      state: GameState.values.firstWhere((e) => e.toString() == 'GameState.${json['state']}'),
      winnerId: json['winnerId'],
      date: DateTime.parse(json['date']),
      player1: json['player1'],
      player2: json['player2'],
      tournamentId: json['tournamentId'],
    );
  }
}