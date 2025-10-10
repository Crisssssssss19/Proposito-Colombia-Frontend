class StatusVacantDto {
  final int id;
  final String nombreEstadoVacante;
  final int ordenEstadoVacante;

  StatusVacantDto({
    required this.id,
    required this.nombreEstadoVacante,
    required this.ordenEstadoVacante,
  });

  factory StatusVacantDto.fromJson(Map<String, dynamic> json) {
    return StatusVacantDto(
      id: json['id'] ?? 0,
      nombreEstadoVacante: json['nombreEstadoVacante'] ?? '',
      ordenEstadoVacante: json['ordenEstadoVacante'] ?? 0,
    );
  }
}
