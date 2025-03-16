import 'package:adrenalux_frontend_mobile/models/card.dart';

class Draft {
  final String name;
  final Map<String, PlayerCard?> draft;

  Draft({
    required this.name,
    required this.draft,
  });

  void addPlayer(String position, PlayerCard player) {
    draft[position] = player;
  }
}
