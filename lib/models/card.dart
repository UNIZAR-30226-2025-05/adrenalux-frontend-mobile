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
  });
}