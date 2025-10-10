class Contract {
  final int id;
  final String nombre;

  Contract({
    required this.id,
    required this.nombre,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}