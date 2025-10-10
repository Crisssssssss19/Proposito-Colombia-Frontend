import 'package:swallow_app/services/session_manager.dart';

import '../dtos/vacancy_dto.dart';
import '../services/location_service.dart';
import '../services/keyword_service.dart';
import '../services/requirement_service.dart';
import '../services/salary_range_service.dart';
import '../services/journey_service.dart';
import '../services/modality_service.dart';
import '../services/contract_service.dart';
import '../services/frequency_service.dart';
import '../services/user_role_company_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swallow_app/models/api_response.dart';
import 'package:swallow_app/models/vacancy.dart';

class VacancyService {
  Future<Vacancy> _mapDtoToModel(VacancyDto dto) async {
    final location = await LocationService().getUbicacionById(dto.idUbicacion);
    final keywords = await Future.wait(dto.palabrasClaveIds.map((id) => KeywordService().getPalabraClaveById(id)));
    final requirements = await Future.wait(dto.requisitoIds.map((id) => RequirementService().getRequisitoById(id)));
    final salaryRange = await SalaryRangeService().getSalaryRangeById(dto.idRangoSalarial);
    final journey = await JourneyService().getJornadaById(dto.idJornada);
    final modality = await ModalityService().getModalityById(dto.idModalidad);
    final contract = await ContractService().getContratoPorId(dto.idContrato);
    final frequency = await FrequencyService().getFrequencyById(dto.idPeriodicidad);
    final userRoleCompany = await UserRoleCompanyService().getByUsuarioId(dto.relUsuarioEmpresaId.idUsuario);
    return Vacancy(
      id: dto.id,
      idUbicacion: location,
      tituloVacante: dto.tituloVacante,
      descripcionCorta: dto.descripcionCorta,
      fechaInicioVacante: DateTime.parse(dto.fechaInicioVacante),
      fechaFinVacante: DateTime.parse(dto.fechaFinVacante),
      estadoVacante: dto.estadoVacante,
      palabrasClaveIds: keywords,
      requisitoIds: requirements,
      idRangoSalarial: salaryRange,
      idJornada: journey,
      idModalidad: modality,
      idContrato: contract,
      idPeriodicidad: frequency,
      relUsuarioEmpresaId: userRoleCompany.id,
    );
  }
  static const String baseUrl = "http://localhost:3210/vacantes";

  Future<List<Vacancy>> getAllVacantes() async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => (data as List).map((e) => VacancyDto.fromJson(e)).toList(),
      );
      return Future.wait(apiResponse.datos.map((dto) => _mapDtoToModel(dto)));
    }
    throw Exception("Error al obtener las vacantes: ${response.statusCode}");
  }

  Future<Vacancy> getVacanteById(int id) async {
      final token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData, (data) => VacancyDto.fromJson(data));
        return _mapDtoToModel(apiResponse.datos);
      } else {
      throw Exception("Error al obtener la vacante con id $id: ${response.statusCode}");
      }
  }

  Future<Vacancy> createVacante(Vacancy vacante) async {
    final token = await SessionManager.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": vacante.id,
        "idUbicacion": vacante.idUbicacion,
        "tituloVacante": vacante.tituloVacante,
        "descripcionCorta": vacante.descripcionCorta,
        "fechaInicioVacante": vacante.fechaInicioVacante,
        "fechaFinVacante": vacante.fechaFinVacante,
        "estadoVacante": vacante.estadoVacante,
        "palabrasClaveIds": vacante.palabrasClaveIds,
        "requisitoIds": vacante.requisitoIds,
        "idRangoSalarial": vacante.idRangoSalarial,
        "idJornada": vacante.idJornada,
        "idModalidad": vacante.idModalidad,
        "idContrato": vacante.idContrato,
        "idPeriodicidad": vacante.idPeriodicidad,
        "relUsuarioEmpresaId": vacante.relUsuarioEmpresaId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(jsonData, (data) => VacancyDto.fromJson(data));
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception("Error al crear la vacante: ${response.statusCode}");
    }
  }

  Future<Vacancy> updateVacante(int id, Vacancy vacante) async {
    final token = await SessionManager.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "id": vacante.id,
        "idUbicacion": vacante.idUbicacion,
        "tituloVacante": vacante.tituloVacante,
        "descripcionCorta": vacante.descripcionCorta,
        "fechaInicioVacante": vacante.fechaInicioVacante,
        "fechaFinVacante": vacante.fechaFinVacante,
        "estadoVacante": vacante.estadoVacante,
        "palabrasClaveIds": vacante.palabrasClaveIds,
        "requisitoIds": vacante.requisitoIds,
        "idRangoSalarial": vacante.idRangoSalarial,
        "idJornada": vacante.idJornada,
        "idModalidad": vacante.idModalidad,
        "idContrato": vacante.idContrato,
        "idPeriodicidad": vacante.idPeriodicidad,
        "relUsuarioEmpresaId": vacante.relUsuarioEmpresaId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(jsonData, (data) => VacancyDto.fromJson(data));
      return _mapDtoToModel(apiResponse.datos);
    } else {
      throw Exception("Error al actualizar la vacante con id $id: ${response.statusCode}");
    }
  }

  Future<int> deleteVacante(int id) async {
    final token = await SessionManager.getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(jsonData, (data) => data as int);
      return apiResponse.datos;
    } else {
      throw Exception("Error al eliminar la vacante con id $id: ${response.statusCode}");
    } 
  }

  Future<List<Vacancy>> getVacantesByEmpresa(int empresaId) async {
      final token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/empresa/$empresaId"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => (data as List).map((e) => VacancyDto.fromJson(e)).toList(),
      );
      return Future.wait(apiResponse.datos.map((dto) => _mapDtoToModel(dto)));
    } else {
      throw Exception("Error al obtener las vacantes de la empresa $empresaId: ${response.statusCode}");
    }
  }

  Future<List<Vacancy>> getVacantesByUsuarioAndEmpresa(int idUsuario, int idEmpresa) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/usuario/$idUsuario/empresa/$idEmpresa"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
        (data) => (data as List).map((e) => VacancyDto.fromJson(e)).toList(),
      );
      return Future.wait(apiResponse.datos.map((dto) => _mapDtoToModel(dto)));
    } else {
      throw Exception("Error al obtener vacantes del usuario $idUsuario en empresa $idEmpresa: ${response.statusCode}");
    }
  }

  Future<int> getDiasPublicados(int id) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/$id/dias-publicados"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(jsonData, (data) => data as int);
      return apiResponse.datos;
    } else {
      throw Exception("Error al obtener los días publicados para la vacante $id: ${response.statusCode}");
    }
  }
}