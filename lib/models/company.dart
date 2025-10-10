import 'package:swallow_app/models/company_type.dart';
import 'package:swallow_app/models/interest.dart';
import 'package:swallow_app/models/user_role_company.dart';

class Company {
  final int id;
  final CompanyType tipoEmpresa;
  final String nombreEmpresa;
  final String direccionEmpresa;
  final String telefonoEmpresa;
  final List<Interest> interes;
  final List<UserRoleCompany> relUsuarioEmpresa;

  Company({
    required this.id,
    required this.tipoEmpresa,
    required this.nombreEmpresa,
    required this.direccionEmpresa,
    required this.telefonoEmpresa,
    required this.interes,
    required this.relUsuarioEmpresa,
  });

  /*factory Company.fromJson(Map<String, dynamic> json){
    return Company(
      id: json['id'] ?? 0,
      idTipoEmpresa: json['idTipoEmpresa'] ?? 0,
      nombreEmpresa: json['nombreEmpresa'] ?? '',
      direccionEmpresa: json['direccionEmpresa'] ?? '',
      telefonoEmpresa: json['telefonoEmpresa'] ?? '',
      interes: (jsonDecode(json['interes']) as List<dynamic>).map((req) => Interest.fromJson(req))
          .toList(),
      relUsuarioEmpresa: (jsonDecode(json['relUsuarioEmpresa']) as List<dynamic>).map((req) => UserRoleCompany.fromJson(req))
          .toList(),
    );
  }*/
}