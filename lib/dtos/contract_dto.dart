class ContractDto {
  final int id;
  final String nombre;

  ContractDto({
    required this.id,
    required this.nombre,
  });

  factory ContractDto.fromJson(Map<String, dynamic> json) {
    return ContractDto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}
