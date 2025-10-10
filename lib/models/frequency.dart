class Frequency {
  final int id;
  final String nombre;

  Frequency({
    required this.id,
    required this.nombre,
  });

  factory Frequency.fromJson(Map<String, dynamic> json) {
    return Frequency(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}