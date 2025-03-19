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