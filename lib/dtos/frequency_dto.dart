class FrequencyDto {
  final int id;
  final String nombre;

  FrequencyDto({
    required this.id,
    required this.nombre,
  });

  factory FrequencyDto.fromJson(Map<String, dynamic> json) {
    return FrequencyDto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}
