class InterestIdDto {
  final int idEmpresa;
  final int idUsuario;

  InterestIdDto({
    required this.idEmpresa,
    required this.idUsuario,
  });

  factory InterestIdDto.fromJson(Map<String, dynamic> json) {
    return InterestIdDto(
      idEmpresa: json['idEmpresa'] ?? 0,
      idUsuario: json['idUsuario'] ?? 0,
    );
  }
}
