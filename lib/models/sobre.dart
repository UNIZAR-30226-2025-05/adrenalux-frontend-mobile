class Sobre {
  final String tipo;
  final String imagen;
  final int precio;

  Sobre({required this.tipo, required this.imagen, required this.precio});

  factory Sobre.fromJson(Map<String, dynamic> json) {
    return Sobre(
      tipo: json['tipo'],
      imagen: json['imagen'],
      precio: json['precio'],
    );
  }
}

