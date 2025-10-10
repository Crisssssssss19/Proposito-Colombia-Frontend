import 'package:swallow_app/models/interest_id.dart';

import '../dtos/interest_dto.dart';
import '../dtos/interest_id_dto.dart';
import '../services/user_service.dart';
import '../services/company_service.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:swallow_app/models/api_response.dart';
import 'package:swallow_app/models/interest.dart';
import 'package:swallow_app/services/session_manager.dart';

class InterestService {
  Future<Interest> _mapDtoToModel(InterestDto dto) async {
    final empresa = await CompanyService.getEmpresaById(dto.id.idEmpresa);
    final usuario = await UserService().getUsuario(dto.id.idUsuario);
    return Interest(
      id: InterestId(empresa: empresa, usuario: usuario),
      tipoInteres: dto.tipoInteres,
    );
  }
  static const String baseUrl = "http://localhost:3210/intereses";

  Future<Interest> createInteres(Interest dto) async {
    final token = await SessionManager.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": dto.id,
        "tipoInteres": dto.tipoInteres,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return _mapDtoToModel(ApiResponse.fromJson(jsonData, (data) => InterestDto.fromJson(data)).datos);
    } else {
      throw Exception('Error al crear interes');
    }
  }

  Future<Interest> updateInteres(Interest dto) async {
    final token = await SessionManager.getToken();
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": dto.id,
        "tipoInteres": dto.tipoInteres,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return _mapDtoToModel(ApiResponse.fromJson(jsonData, (data) => InterestDto.fromJson(data)).datos);
    } else {
      throw Exception('Error al actualizar interes');
    }
  }

  Future<bool> deleteInteres(int idEmpresa, int idUsuario) async {
    final token = await SessionManager.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$idEmpresa/$idUsuario'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  Future<int> obtenerTipoInteres(int idEmpresa, int idUsuario) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$idEmpresa/$idUsuario/tipo'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(jsonData, (data) => data as int).datos;
    } else {
      throw Exception('Error al obtener tipo de interes');
    }
  }

  Future<List<int>> obtenerEmpresasSeguidas(int idUsuario, int tipoInteres) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/$idUsuario/empresas?tipoInteres=$tipoInteres'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => List<int>.from(data),
      ).datos;
    } else {
      throw Exception('Error al obtener empresas seguidas');
    }
  }

  Future<List<int>> obtenerUsuariosSeguidos(int idEmpresa, int tipoInteres) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/empresa/$idEmpresa/usuarios?tipoInteres=$tipoInteres'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => List<int>.from(data),
      ).datos;
    } else {
      throw Exception('Error al obtener usuarios seguidos');
    }
  }

  Future<List<Interest>> obtenerRelacionesMutuas() async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/match'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<InterestDto> dtos = ApiResponse.fromJson(
        jsonData,
        (data) => (data as List)
            .map((item) => InterestDto.fromJson(item))
            .toList(),
      ).datos;

      return Future.wait(dtos.map((dto) => _mapDtoToModel(dto)));
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al obtener relaciones mutuas');
    }
  }

  Future<bool> usuarioSigueEmpresa(int idEmpresa, int idUsuario) async {
    final token = await SessionManager.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$idEmpresa/$idUsuario/usuarioSigueEmpresa'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> empresaSigueUsuario(int idEmpresa, int idUsuario) async {
    final token = await SessionManager.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$idEmpresa/$idUsuario/empresaSigueUsuario'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> esSeguimientoMutuo(int idEmpresa, int idUsuario) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$idEmpresa/$idUsuario/mutuo'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Error al verificar seguimiento mutuo');
    }
  }

  Future<Interest> getInteresById(InterestIdDto id) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/${id.idUsuario}/${id.idEmpresa}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final dto = InterestDto.fromJson(jsonData['datos']);
      return await _mapDtoToModel(dto);
    } else {
      throw Exception('Error al obtener interes por id');
    }
  }
}