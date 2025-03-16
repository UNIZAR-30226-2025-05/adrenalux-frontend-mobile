const String CARTA_NORMAL = "Normal";
const String CARTA_LUXURY = "Luxury";
const String CARTA_MEGALUXURY = "Megaluxury";
const String CARTA_LUXURYXI = "Luxury XI";

Map<String, int> ordenRareza = {
  CARTA_NORMAL: 0,
  CARTA_LUXURY: 1,
  CARTA_MEGALUXURY: 2,
  CARTA_LUXURYXI: 3,
};

class PlayerCard  {
  final int id;
  final int? marketId;
  final String playerName;
  final String playerSurname;
  final String team;
  final int shot;
  final int control;
  final int defense;
  final String teamLogo;
  final String rareza;
  final double averageScore;
  final String playerPhoto;
  final String position;
  final double price;
  final int amount;
  bool onSale;

  PlayerCard({
    required this.id,
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
    this.marketId,
    this.amount = 1,
    this.onSale = false,
  });

  factory PlayerCard.fromJson(Map<String, dynamic> json) {
    return PlayerCard(
      id : json['id'].toInt() ?? '',
      playerName: json['nombre'] ?? '',
      playerSurname: json['alias'] ?? '',
      team: json['equipo'] ?? '',
      shot: json['ataque'] ?? 0,
      control: json['control'] ?? 0,
      defense: json['defensa'] ?? 0,
      rareza: json['tipo_carta'] ?? 'Normal',
      teamLogo: json['escudo'] ?? '',
      averageScore: ((json['ataque'] + json['control'] + json['defensa']) / 3).toDouble(),
      playerPhoto: json['photo'] ?? '',
      position: json['posicion'] ?? '',
      price: (json['precio'] ?? 0).toDouble(),
      amount: (json['cantidad'] ?? 1),
      onSale: (json['enVenta'] ?? false),
      marketId: (json['mercadoCartaId'])
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerCard &&
        other.playerName == playerName &&
        other.playerSurname == playerSurname;
  }

  @override
  int get hashCode => playerName.hashCode ^ playerSurname.hashCode;
}