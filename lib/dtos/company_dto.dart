import 'package:swallow_app/dtos/interest_dto.dart';
import 'package:swallow_app/dtos/user_role_company_dto.dart';

class CompanyDto {
  final int id;
  final int idTipoEmpresa;
  final String nombreEmpresa;
  final String direccionEmpresa;
  final String telefonoEmpresa;
  final List<InterestDto> interes;
  final List<UserRoleCompanyDto> relUsuarioEmpresa;

  CompanyDto({
    required this.id,
    required this.idTipoEmpresa,
    required this.nombreEmpresa,
    required this.direccionEmpresa,
    required this.telefonoEmpresa,
    required this.interes,
    required this.relUsuarioEmpresa,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    return CompanyDto(
      id: json['id'] ?? 0,
      idTipoEmpresa: json['idTipoEmpresa'] ?? 0,
      nombreEmpresa: json['nombreEmpresa'] ?? '',
      direccionEmpresa: json['direccionEmpresa'] ?? '',
      telefonoEmpresa: json['telefonoEmpresa'] ?? '',
      interes: (json['interesIds'] as List<dynamic>? ?? []).map((e) => InterestDto.fromJson(e)).toList(),
      relUsuarioEmpresa: (json['relUsuarioEmpresaIds'] as List<dynamic>? ?? []).map((e) => UserRoleCompanyDto.fromJson(e)).toList(),
    );
  }
}
