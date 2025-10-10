import '../services/vacancy_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swallow_app/dtos/requirement_dto.dart';
import 'package:swallow_app/models/api_response.dart';
import 'package:swallow_app/models/requirement.dart';

class RequirementService {
  static const String baseUrl = "http://localhost:3210/requisitos";

  Future<Requirement> createRequisito(Requirement requisito) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": requisito.id,
        "idVacante": requisito.vacante.id,
        "tituloRequisito": requisito.tituloRequisito,
        "detalleRequsito": requisito.detalleRequisito,
        "ordenRequisito": requisito.ordenRequisito,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => RequirementDto.fromJson(data),
      );
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception("Error al crear el requisito: ${response.body}");
    }
  }

  Future<Requirement> updateRequisito(int id, Requirement requisito) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": requisito.id,
        "idVacante": requisito.vacante.id,
        "tituloRequisito": requisito.tituloRequisito,
        "detalleRequsito": requisito.detalleRequisito,
        "ordenRequisito": requisito.ordenRequisito,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => RequirementDto.fromJson(data),
      );
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception("Error al actualizar el requisito: ${response.body}");
    }
  }

  Future<bool> deleteRequisito(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Error al eliminar el requisito: ${response.body}");
    }
  }

  Future<List<Requirement>> getAllRequisitos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => (data as List)
            .map((item) => RequirementDto.fromJson(item))
            .toList(),
      );
      return Future.wait(apiResponse.datos.map((dto) => _mapDtoToModel(dto)));
    } else {
      throw Exception("Error al obtener los requisitos: ${response.body}");
    }
  }

  Future<List<Requirement>> getRequisitosByIdVacante(int idVacante) async {
    final response = await http.get(Uri.parse("$baseUrl/vacante/$idVacante"));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => (data as List)
            .map((item) => RequirementDto.fromJson(item))
            .toList(),
      );
      return Future.wait(apiResponse.datos.map((dto) => _mapDtoToModel(dto)));
    } else {
      throw Exception("Error al obtener los requisitos por vacante: ${response.body}");
    }
  }

  Future<Requirement> getRequisitoById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/obtener/$id"));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => RequirementDto.fromJson(data),
      );
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception("Error al obtener el requisito: ${response.body}");
    }
  }

  Future<Requirement> _mapDtoToModel(RequirementDto dto) async {
    final vacante = await VacancyService().getVacanteById(dto.idVacante);
    return Requirement(
      id: dto.id,
      vacante: vacante,
      tituloRequisito: dto.tituloRequisito,
      detalleRequisito: dto.detalleRequisito,
      ordenRequisito: dto.ordenRequisito,
    );
  }
}