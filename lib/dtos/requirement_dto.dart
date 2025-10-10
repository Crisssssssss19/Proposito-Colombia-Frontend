class RequirementDto {
  final int id;
  final int idVacante;
  final String tituloRequisito;
  final String detalleRequisito;
  final int ordenRequisito;

  RequirementDto({
    required this.id,
    required this.idVacante,
    required this.tituloRequisito,
    required this.detalleRequisito,
    required this.ordenRequisito,
  });

  factory RequirementDto.fromJson(Map<String, dynamic> json) {
    return RequirementDto(
      id: json['id'] ?? 0,
      idVacante: json['idVacante'] ?? 0,
      tituloRequisito: json['tituloRequisito'] ?? '',
      detalleRequisito: json['detalleRequisito'] ?? '',
      ordenRequisito: json['ordenRequisito'] ?? 0,
    );
  }
}
