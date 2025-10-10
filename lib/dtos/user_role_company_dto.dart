import 'package:swallow_app/dtos/user_role_company_id_dto.dart';

class UserRoleCompanyDto {
  final UserRoleCompanyIdDto id;
  final int permisoRelUsuarioEmpresa;

  UserRoleCompanyDto({
    required this.id,
    required this.permisoRelUsuarioEmpresa,
  });

  factory UserRoleCompanyDto.fromJson(Map<String, dynamic> json) {
    return UserRoleCompanyDto(
      id: UserRoleCompanyIdDto.fromJson(json['id'] ?? {}),
      permisoRelUsuarioEmpresa: json['permisoRelUsuarioEmpresa'] ?? 0,
    );
  }
}
