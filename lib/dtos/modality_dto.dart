class ModalityDto {
  final int id;
  final String nombre;

  ModalityDto({
    required this.id,
    required this.nombre,
  });

  factory ModalityDto.fromJson(Map<String, dynamic> json) {
    return ModalityDto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}
