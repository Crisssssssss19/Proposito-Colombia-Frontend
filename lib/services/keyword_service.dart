import 'session_manager.dart';
import '../services/user_service.dart';
import '../services/vacancy_service.dart';
import 'package:http/http.dart' as http;
import 'package:swallow_app/dtos/keyword_dto.dart';
import 'package:swallow_app/models/api_response.dart';
import 'package:swallow_app/models/keyword.dart';
import 'dart:convert';

class KeywordService {
  static const String baseUrl = "http://localhost:3210/palabrasClave";

  Future<List<Keyword>> getAllPalabrasClaves() async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => (data as List)
            .map((item) => KeywordDto.fromJson(item))
            .toList(),
      );
      return Future.wait(apiResponse.datos.map((dto)=> _mapDtoToModel(dto)));
    } else {
      throw Exception('Error al obtener las palabras clave');
    }
  }

  Future<Keyword> getPalabraClaveById(int id) async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse("$baseUrl/$id"), headers: headers);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => KeywordDto.fromJson(data),
      );
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception('Error al obtener la palabra clave');
    }
  }

  Future<bool> deletePalabraClave(int id) async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al eliminar la palabra clave');
    }
  }

  Future<Keyword> _mapDtoToModel(KeywordDto dto) async {
    final usuarios = await Future.wait(dto.usuarioIds.map((id) => UserService().getUsuario(id)));
    final vacantes = await Future.wait(dto.vacanteIds.map((id) => VacancyService().getVacanteById(id)));
    return Keyword(
      id: dto.id,
      textoPalabraClave: dto.textoPalabraClave,
      usuarios: usuarios,
      vacantes: vacantes,
    );
  }
}