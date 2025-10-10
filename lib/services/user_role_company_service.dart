import 'package:swallow_app/models/user_role_company_id.dart';
import '../dtos/user_role_company_dto.dart';
import '../services/user_service.dart';
import '../services/company_service.dart';
import 'package:swallow_app/models/api_response.dart';
import 'package:swallow_app/models/user_role_company.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swallow_app/services/session_manager.dart';

class UserRoleCompanyService {
  static const String baseUrl = "http://localhost:3210/relUsuarioEmpresa";

  Future<List<UserRoleCompany>> getAllUsuariosEmpresas() async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => (data as List)
            .map((e) => UserRoleCompanyDto.fromJson(e))
            .toList(),
      );
      return Future.wait(apiResponse.datos.map((dto) => _mapDtoToModel(dto)));
    } else {
      throw Exception("Error al obtener las relaciones usuario-empresa");
    }
  }

  Future<UserRoleCompany> getByUsuarioId(int usuarioId) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/usuario/$usuarioId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => UserRoleCompanyDto.fromJson(data),
      );
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception("Error al obtener la relación por usuarioId");
    }
  }

  Future<UserRoleCompany?> getByEmpresaId(int empresaId) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/empresa/$empresaId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => UserRoleCompanyDto.fromJson(data),
      );
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception("Error al obtener la relación por empresaId");
    }
  }

  Future<UserRoleCompany> createRelUsuarioEmpresa(UserRoleCompany dto) async {
    final token = await SessionManager.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": dto.id,
        "permisoRelUsuarioEmpresa": dto.permisoRelUsuarioEmpresa,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => UserRoleCompanyDto.fromJson(data),
      );
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception("Error al crear la relación usuario-empresa");
    }
  }

  Future<bool> deleteByUsuarioAndEmpresa(
      int usuarioId, int empresaId) async {
    final token = await SessionManager.getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/usuario/$usuarioId/empresa/$empresaId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Error al eliminar la relación usuario-empresa");
    }
  }

  Future<UserRoleCompany> _mapDtoToModel(UserRoleCompanyDto dto) async {
    final usuario = await UserService().getUsuario(dto.id.idUsuario);
    final empresa = await CompanyService.getEmpresaById(dto.id.idEmpresa);
    return UserRoleCompany(
      id: UserRoleCompanyId(
        usuario: usuario,
        empresa: empresa,
      ),
      permisoRelUsuarioEmpresa: dto.permisoRelUsuarioEmpresa,
    );
  }
}