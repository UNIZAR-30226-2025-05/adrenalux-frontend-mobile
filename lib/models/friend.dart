class Friend {
  final int id;
  final String name;
  final String photo;

  Friend({
    required this.id,
    required this.name,
    required this.photo,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['nombre'],
      photo: json['foto'],
    );
  }
}