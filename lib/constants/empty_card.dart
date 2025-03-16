import 'package:adrenalux_frontend_mobile/models/card.dart';


PlayerCard returnEmptyCard() {
  return PlayerCard(
    id: 0,
    playerName: '',
    playerSurname: '',
    averageScore: 0,
    position: '',
    amount: 0,
    shot: 0,
    defense: 0,
    control: 0,
    price: 0,
    rareza: CARTA_NORMAL,
    playerPhoto: '',
    team: '',
    teamLogo: '',
  );
}