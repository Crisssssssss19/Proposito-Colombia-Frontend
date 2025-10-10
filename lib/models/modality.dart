class Modality {
  final int id;
  final String nombre;

  Modality({
    required this.id,
    required this.nombre,
  });

  factory Modality.fromJson(Map<String, dynamic> json) {
    return Modality(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}