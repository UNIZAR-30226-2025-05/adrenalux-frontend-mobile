enum Rareza { normal, luxury, megaLuxury, luxuryXI }

class PlayerCard  {
  final String playerName;
  final String playerSurname;
  final String team;
  final int shot;
  final int control;
  final int defense;
  final String teamLogo;
  final Rareza rareza;
  final double averageScore;
  final String playerPhoto;
  final String position;
  final double price;
  final int amount;

  const PlayerCard({
    required this.playerName,
    required this.playerSurname,
    required this.team,
    required this.shot,
    required this.control,
    required this.defense,
    required this.rareza,
    required this.teamLogo,
    required this.averageScore,
    required this.playerPhoto,
    required this.position,
    required this.price,
    this.amount = 1,
  });

  factory PlayerCard.fromJson(Map<String, dynamic> json) {
    return PlayerCard(
      playerName: json['nombre'] ?? '',
      playerSurname: json['alias'] ?? '',
      team: json['equipo'] ?? '',
      shot: json['ataque'] ?? 0,
      control: json['control'] ?? 0,
      defense: json['defensa'] ?? 0,
      rareza: _mapRareza(json['tipo_carta'] ?? 'normal'),
      teamLogo: json['escudo'] ?? '',
      averageScore: ((json['ataque'] + json['control'] + json['defensa']) / 3).toDouble(),
      playerPhoto: json['photo'] ?? '',
      position: json['posicion'] ?? '',
      price: (json['precio'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 1),
    );
  }

  static Rareza _mapRareza(String rareza) {
    switch (rareza.toLowerCase()) {
      case 'luxury':
        return Rareza.luxury;
      case 'megaLuxury':
        return Rareza.megaLuxury;
      case 'luxuryXI':
        return Rareza.luxuryXI;
      default:
        return Rareza.normal;
    }
  }
}