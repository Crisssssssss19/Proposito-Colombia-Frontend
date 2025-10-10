import 'package:swallow_app/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/services/session_manager.dart';

import 'package:swallow_app/models/company.dart';
import 'package:swallow_app/models/page.dart';
import '../dtos/company_dto.dart';
import '../services/company_type_service.dart';
import '../services/interest_service.dart';
import '../services/user_role_company_service.dart';

class CompanyService {
  static const String baseUrl = "http://localhost:3210/empresas";

  static Future<int> getCantidadEmpresas() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/cantidad");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if(response.statusCode==200){
      return ApiResponse<int>.fromJson(jsonDecode(response.body), (d)=> d).datos;
    } else {
      throw Exception("Error al obtener la cantidad de empresas: ${response.body}");
    }
  }

  static Future<List<Company>> getAllEmpresas() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse(baseUrl);
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> empresasJson = data['datos'] ?? [];
      List<Company> empresas = [];
      for (var item in empresasJson) {
        final dto = CompanyDto.fromJson(item);
        empresas.add(await mapDtoToModel(dto));
      }
      return empresas;
    } else {
      throw Exception("Error al listar las empresas: ${response.body}");
    }
  }

  static Future<Page<Company>> buscarEmpresa({
    String filtro = "",
    int page = 0,
    int size = 10,
  }) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/buscar?filtro=$filtro&page=$page&size=$size");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      final apiResponse = ApiResponse<Page<CompanyDto>>.fromJson(
        jsonMap,
        (datosJson) => Page.fromJson(
          datosJson,
          (empresaJson) => CompanyDto.fromJson(empresaJson),
        ),
      );
      // Mapeo de cada CompanyDto a Company
      final items = await Future.wait(apiResponse.datos.content.map((dto) => mapDtoToModel(dto)));
      return Page<Company>(
        content: items,
        totalElements: apiResponse.datos.totalElements,
        totalPages: apiResponse.datos.totalPages,
        number: apiResponse.datos.number,
        size: apiResponse.datos.size,
      );
    } else {
      throw Exception(
        "Error ${response.statusCode}: ${response.body}",
      );
    }
  }

  static Future<Company> createEmpresa(Company company) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": company.id,
        "idTipoEmpresa": company.tipoEmpresa.id,
        "nombreEmpresa": company.nombreEmpresa,
        "direccionEmpresa": company.direccionEmpresa,
        "telefonoEmpresa": company.telefonoEmpresa,
        "interes": company.interes.map((i) => i.id).toList(),
        "relUsuarioEmpresa": company.relUsuarioEmpresa.map((r) => r.id.usuario).toList(),
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = CompanyDto.fromJson(data['datos']);
      final tipoEmpresa = await CompanyTypeService().getTipoEmpresaById(dto.idTipoEmpresa);
      final interes = await Future.wait(dto.interes.map((i) => InterestService().getInteresById(i.id)));
      final relUsuarioEmpresa = await Future.wait(dto.relUsuarioEmpresa.map((r) => UserRoleCompanyService().getByUsuarioId(r.id.idUsuario)));
      return Company(
        id: dto.id,
        tipoEmpresa: tipoEmpresa,
        nombreEmpresa: dto.nombreEmpresa,
        direccionEmpresa: dto.direccionEmpresa,
        telefonoEmpresa: dto.telefonoEmpresa,
        interes: interes,
        relUsuarioEmpresa: relUsuarioEmpresa,
      );
    } else {
      throw Exception("Error al crear Empresa numero ${response.statusCode}: ${response.body}");
    }
  }

  static Future<Company> updateEmpresa(Company company, int id) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": company.id,
        "idTipoEmpresa": company.tipoEmpresa.id,
        "nombreEmpresa": company.nombreEmpresa,
        "direccionEmpresa": company.direccionEmpresa,
        "telefonoEmpresa": company.telefonoEmpresa,
        "interes": company.interes.map((i) => i.id).toList(),
        "relUsuarioEmpresa": company.relUsuarioEmpresa.map((r) => r.id.usuario).toList(),
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = CompanyDto.fromJson(data['datos']);
      final tipoEmpresa = await CompanyTypeService().getTipoEmpresaById(dto.idTipoEmpresa);
      final interes = await Future.wait(dto.interes.map((i) => InterestService().getInteresById(i.id)));
      final relUsuarioEmpresa = await Future.wait(dto.relUsuarioEmpresa.map((r) => UserRoleCompanyService().getByUsuarioId(r.id.idUsuario)));
      return Company(
        id: dto.id,
        tipoEmpresa: tipoEmpresa,
        nombreEmpresa: dto.nombreEmpresa,
        direccionEmpresa: dto.direccionEmpresa,
        telefonoEmpresa: dto.telefonoEmpresa,
        interes: interes,
        relUsuarioEmpresa: relUsuarioEmpresa,
      );
    } else {
      throw Exception("Error al actualizar Empresa numero ${response.statusCode}: ${response.body}");
    }
  }

  static Future<Company> deleteEmpresa(Company company) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse(baseUrl);
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": company.id,
        "idTipoEmpresa": company.tipoEmpresa.id,
        "nombreEmpresa": company.nombreEmpresa,
        "direccionEmpresa": company.direccionEmpresa,
        "telefonoEmpresa": company.telefonoEmpresa,
        "interes": company.interes.map((i) => i.id).toList(),
        "relUsuarioEmpresa": company.relUsuarioEmpresa.map((r) => r.id.usuario).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = CompanyDto.fromJson(data['datos']);
      final tipoEmpresa = await CompanyTypeService().getTipoEmpresaById(dto.idTipoEmpresa);
      final interes = await Future.wait(dto.interes.map((i) => InterestService().getInteresById(i.id)));
      final relUsuarioEmpresa = await Future.wait(dto.relUsuarioEmpresa.map((r) => UserRoleCompanyService().getByUsuarioId(r.id.idUsuario)));
      return Company(
        id: dto.id,
        tipoEmpresa: tipoEmpresa,
        nombreEmpresa: dto.nombreEmpresa,
        direccionEmpresa: dto.direccionEmpresa,
        telefonoEmpresa: dto.telefonoEmpresa,
        interes: interes,
        relUsuarioEmpresa: relUsuarioEmpresa,
      );
    } else {
      throw Exception("Error al eliminar la empresa: ${response.body}");
    }
  }

  static Future<List<Company>> getEmpresasByTipoEmpresa(int tipoEmpresaId) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/tipo/$tipoEmpresaId");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> empresasJson = data['datos'] ?? [];
      List<Company> empresas = [];
      for (var item in empresasJson) {
        final dto = CompanyDto.fromJson(item);
        final tipoEmpresa = await CompanyTypeService().getTipoEmpresaById(dto.idTipoEmpresa);
        final interes = await Future.wait(dto.interes.map((i) => InterestService().getInteresById(i.id)));
        final relUsuarioEmpresa = await Future.wait(dto.relUsuarioEmpresa.map((r) => UserRoleCompanyService().getByUsuarioId(r.id.idUsuario)));
        empresas.add(Company(
          id: dto.id,
          tipoEmpresa: tipoEmpresa,
          nombreEmpresa: dto.nombreEmpresa,
          direccionEmpresa: dto.direccionEmpresa,
          telefonoEmpresa: dto.telefonoEmpresa,
          interes: interes,
          relUsuarioEmpresa: relUsuarioEmpresa,
        ));
      }
      return empresas;
    } else {
      throw Exception("Error al obtener empresa por id tipo empresa: ${response.body}");
    }
  }

  static Future<Company> getEmpresaById(int id) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/obtener/$id");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = CompanyDto.fromJson(data['datos']);
      return await mapDtoToModel(dto);
    } else {
      throw Exception("Error al obtener empresa por id: ${response.body}");
    }
  }
  
  static Future<Company> mapDtoToModel(CompanyDto dto) async {
    final tipoEmpresa = await CompanyTypeService().getTipoEmpresaById(dto.idTipoEmpresa);
    final interes = await Future.wait(dto.interes.map((i) => InterestService().getInteresById(i.id)));
    final relUsuarioEmpresa = await Future.wait(dto.relUsuarioEmpresa.map((r) => UserRoleCompanyService().getByUsuarioId(r.id.idUsuario)));
    return Company(
      id: dto.id,
      tipoEmpresa: tipoEmpresa,
      nombreEmpresa: dto.nombreEmpresa,
      direccionEmpresa: dto.direccionEmpresa,
      telefonoEmpresa: dto.telefonoEmpresa,
      interes: interes,
      relUsuarioEmpresa: relUsuarioEmpresa,
    );
  }
}