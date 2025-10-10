class UserRoleCompanyIdDto {
  final int idUsuario;
  final int idEmpresa;

  UserRoleCompanyIdDto({
    required this.idUsuario,
    required this.idEmpresa,
  });

  factory UserRoleCompanyIdDto.fromJson(Map<String, dynamic> json) {
    return UserRoleCompanyIdDto(
      idUsuario: json['idUsuario'] ?? 0,
      idEmpresa: json['idEmpresa'] ?? 0,
    );
  }
}
