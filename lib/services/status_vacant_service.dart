import 'dart:convert';
import 'package:swallow_app/models/api_response.dart';
import 'package:swallow_app/models/status_vacant.dart';
import 'package:http/http.dart' as http;
import 'package:swallow_app/services/session_manager.dart';

class StatusVacantService {
  static const String baseUrl = "http://localhost:3210/estadosVacantes";

  static Future<List<StatusVacant>> getAllEstadosVacante() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse(baseUrl);
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if(response.statusCode==200){
      return ApiResponse<List<StatusVacant>>.fromJson(jsonDecode(response.body),(data) => (data as List).map((e) => StatusVacant.fromJson(e)).toList()).datos;
    } else {
      throw Exception("Error al listar los estados de vacantes: ${response.body}");
    }
  }

  static Future<StatusVacant> updateEstadoVacante(StatusVacant statusVacant) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse(baseUrl);
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": statusVacant.id,
        "nombreEstadoVacante": statusVacant.nombreEstadoVacante,
        "ordenEstadoVacante": statusVacant.ordenEstadoVacante,
      }),
    );
    if(response.statusCode==200){
      return ApiResponse<StatusVacant>.fromJson(jsonDecode(response.body), (d)=> StatusVacant.fromJson(d)).datos;
    } else {
      throw Exception("Error al actualizar Empresa numero ${response.statusCode}: ${response.body}");
    }
  }

  static Future<StatusVacant> deleteEstadoVacante(int id) async{
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if(response.statusCode==200){
      return ApiResponse<StatusVacant>.fromJson(jsonDecode(response.body), (d)=> StatusVacant.fromJson(d)).datos;
    } else {
      throw Exception("Error al actualizar Empresa numero ${response.statusCode}: ${response.body}");
    }
  }

  static Future<StatusVacant> getStatusVacantById(int id) async {
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
      return ApiResponse<StatusVacant>.fromJson(jsonDecode(response.body), (d) => StatusVacant.fromJson(d)).datos;
    } else {
      throw Exception("Error al obtener estado vacante por id: ${response.body}");
    }
  }
}