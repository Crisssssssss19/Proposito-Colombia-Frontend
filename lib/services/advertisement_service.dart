import 'dart:typed_data';
import 'package:swallow_app/dtos/advertisement_dto.dart';
import 'package:swallow_app/models/advertisement.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/services/vacancy_service.dart';
import 'package:swallow_app/services/session_manager.dart';

class AdvertisementService {
  static const String baseUrl = "http://localhost:3210/anuncios";

  static Future<Advertisement> create(int idVacante, http.MultipartFile file) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse(baseUrl);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    request.files.add(file);
    request.fields['idVacante'] = jsonEncode(idVacante);
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      final dto = AdvertisementDto.fromJson(jsonDecode(response.body)['datos']);
      return await _mapDtoToModel(dto);
    } else {
      throw Exception("Error al crear el anuncio: ${response.body}");
    }
  }

  static Future<Advertisement> update(int id, http.MultipartFile file) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/$id/imagen");
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest('PUT', url);
    request.headers.addAll(headers);
    request.files.add(file);
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      final dto = AdvertisementDto.fromJson(jsonDecode(response.body)['datos']);
      return await _mapDtoToModel(dto);
    } else {
      throw Exception("Error al actualizar el anuncio: ${response.body}");
    }
  }

  static Future<int> delete(int id) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body)['data'] as int;
  }

  static Future<Advertisement> findById(int id) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final dto = AdvertisementDto.fromJson(jsonDecode(response.body)['datos']);
      return await _mapDtoToModel(dto);
    } else {
      throw Exception("Error al obtener anuncio por id: ${response.body}");
    }
  }

  static Future<List<Advertisement>> findAll() async {
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
      final List<dynamic> dataList = jsonDecode(response.body)['datos'] ?? [];
      List<Advertisement> result = [];
      for (var item in dataList) {
        final dto = AdvertisementDto.fromJson(item);
        result.add(await _mapDtoToModel(dto));
      }
      return result;
    } else {
      throw Exception("Error al listar los anuncios: ${response.body}");
    }
  }

  static Future<Advertisement> findByVacanteId(int vacanteId) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/vacante/$vacanteId");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final dto = AdvertisementDto.fromJson(jsonDecode(response.body)['datos']);
      return await _mapDtoToModel(dto);
    } else {
      throw Exception("Error al obtener anuncio por id de vacante: ${response.body}");
    }
  }

  static Future<Uint8List?> obtenerImagen(int id) async {
    final token = await SessionManager.getToken();
    final url = Uri.parse("$baseUrl/$id/imagen");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Error al obtener imagen: ${response.statusCode}");
    }
  }

  static Future<Advertisement> _mapDtoToModel(AdvertisementDto dto) async {
    final vacante = await VacancyService().getVacanteById(dto.idVacante);
    return Advertisement(
      id: dto.id,
      vacante: vacante,
      nombrePublicoAnuncio: dto.nombrePublicoAnuncio,
      nombrePrivadoAnuncio: dto.nombrePrivadoAnuncio,
      tipoAnuncio: dto.tipoAnuncio,
      tamanioAnuncio: dto.tamanioAnuncio,
  );
  }
}