import 'session_manager.dart';
import 'dart:convert';
import 'package:swallow_app/models/history_status_vacant.dart';
import 'package:http/http.dart' as http;
import '../dtos/history_status_vacant_dto.dart';
import '../services/vacancy_service.dart';
import '../services/status_vacant_service.dart';

class HistoryStatusVacantService {
  Future<HistoryStatusVacant> _mapDtoToModel(HistoryStatusVacantDto dto) async {
    final vacante = await VacancyService().getVacanteById(dto.idVacante);
    final estadoVacante = await StatusVacantService.getStatusVacantById(dto.idEstadoVacante);
    return HistoryStatusVacant(
      id: dto.id,
      vacante: vacante,
      estadoVacante: estadoVacante,
      fechaHistorialEstadoVacante: DateTime.parse(dto.fechaHistorialEstadoVacante),
    );
  }
  static const String baseUrl = "http://localhost:3210/historialEstadosVacantes";

  static Future<HistoryStatusVacant> getById(int id) async {
    final url = Uri.parse("$baseUrl/$id");
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final dto = HistoryStatusVacantDto.fromJson(jsonDecode(response.body)['datos']);
      return await HistoryStatusVacantService()._mapDtoToModel(dto);
    } else {
      throw Exception("Error al obtener empresa por id tipo empresa: ${response.body}");
    }
  }

  Future<List<HistoryStatusVacant>> getByVacanteId(int vacanteId) async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse('$baseUrl/vacante/$vacanteId'), headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['datos'] ?? [];
      List<HistoryStatusVacant> result = [];
      for (var item in list) {
        final dto = HistoryStatusVacantDto.fromJson(item);
        result.add(await _mapDtoToModel(dto));
      }
      return result;
    } else {
      throw Exception('Error al obtener historial por id de vacante');
    }
  }

  Future<HistoryStatusVacant> deleteHistorial(HistoryStatusVacant history) async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.delete(
      Uri.parse('$baseUrl/historial-estado-vacante/${history.id}'),
      headers: headers,
      body: json.encode({
        "id": history.id,
        "idVacante": history.vacante.id,
        "idEstadoVacante": history.estadoVacante.id,
        "fechaHistorialEstadoVacante": history.fechaHistorialEstadoVacante,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dto = HistoryStatusVacantDto.fromJson(data['datos']);
      return await _mapDtoToModel(dto);
    } else {
      throw Exception('Error al eliminar historial');
    }
  }
}