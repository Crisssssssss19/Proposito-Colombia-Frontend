class JourneyDto {
  final int id;
  final String nombre;

  JourneyDto({
    required this.id,
    required this.nombre,
  });

  factory JourneyDto.fromJson(Map<String, dynamic> json) {
    return JourneyDto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}
