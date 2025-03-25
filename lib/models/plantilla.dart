import 'package:adrenalux_frontend_mobile/models/card.dart';
class Draft {
  final int? id;
  final String name;
  final Map<String, PlayerCard?> draft;

  Draft({
    this.id,
    required this.name,
    required this.draft,
  });

  static const List<String> positions = [
    'GK',
    'DEF1', 'DEF2', 'DEF3', 'DEF4', 
    'MID1', 'MID2', 'MID3',
    'FWD1', 'FWD2', 'FWD3'
  ];

  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
      id: json['id'] as int,
      name: json['nombre'] as String,
      draft: (json['plantilla'] as Map<String, dynamic>).map((key, value) {
        return MapEntry(
          key,
          value != null 
              ? PlayerCard.fromJson(value as Map<String, dynamic>) 
              : null,
        );
      }),
    );
  }
}