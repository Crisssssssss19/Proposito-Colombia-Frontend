class HistoryStatusVacantDto {
  final int id;
  final int idVacante;
  final int idEstadoVacante;
  final String fechaHistorialEstadoVacante;

  HistoryStatusVacantDto({
    required this.id,
    required this.idVacante,
    required this.idEstadoVacante,
    required this.fechaHistorialEstadoVacante,
  });

  factory HistoryStatusVacantDto.fromJson(Map<String, dynamic> json) {
    return HistoryStatusVacantDto(
      id: json['id'] ?? 0,
      idVacante: json['idVacante'] ?? 0,
      idEstadoVacante: json['idEstadoVacante'] ?? 0,
      fechaHistorialEstadoVacante: json['fechaHistorialEstadoVacante'] ?? '',
    );
  }
}
