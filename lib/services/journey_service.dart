import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swallow_app/models/api_response.dart';
import 'package:swallow_app/models/journey.dart';
import 'package:swallow_app/services/session_manager.dart';

class JourneyService {
  static const String baseUrl = "http://localhost:3210/Jornadas";

  Future<Journey> createJornada(Journey jornada) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": jornada.id,
        "nombre": jornada.nombre,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final apiResponse = ApiResponse<Journey>.fromJson(
        jsonMap,
        (data) => Journey.fromJson(data),
      );
      return apiResponse.datos;
    } else {
      throw Exception(
        "Error al crear la jornada (${response.statusCode}): ${response.body}",
      );
    }
  }

  Future<Journey> updateJornada(Journey jornada) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse(baseUrl);

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": jornada.id,
        "nombre": jornada.nombre,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body);
      final apiResponse = ApiResponse<Journey>.fromJson(
        jsonMap,
        (data) => Journey.fromJson(data),
      );
      return apiResponse.datos;
    } else {
      throw Exception(
        "Error al actualizar jornada (${response.statusCode}): ${response.body}",
      );
    }
  }

  Future<int> deleteJornada(int id) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/$id");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final apiResponse = ApiResponse<int>.fromJson(
        jsonMap,
        (data) => data as int,
      );
      return apiResponse.datos;
    } else {
      throw Exception(
        "Error al eliminar jornada (${response.statusCode}): ${response.body}",
      );
    }
  }

  Future<Journey> getJornadaById(int id) async {
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
      final jsonMap = jsonDecode(response.body);
      final apiResponse = ApiResponse<Journey>.fromJson(
        jsonMap,
        (data) => Journey.fromJson(data),
      );
      return apiResponse.datos;
    } else {
      throw Exception(
        "Error al obtener la jornada (${response.statusCode}): ${response.body}",
      );
    }
  }
}