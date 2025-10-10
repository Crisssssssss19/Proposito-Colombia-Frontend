import 'session_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dtos/frequency_dto.dart';
import '../models/frequency.dart';

class FrequencyService {
  static const String baseUrl = "http://localhost:3210/periodicidades-pago";

  Future<Frequency> getFrequencyById(int id) async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse("$baseUrl/obtener/$id"), headers: headers);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final dto = FrequencyDto.fromJson(jsonData['datos']);
      return _mapDtoToModel(dto);
    } else {
      throw Exception("Error al obtener periodicidad de pago por id");
    }
  }

  Future<List<Frequency>> getAllFrequencies() async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse("$baseUrl/obtener/todos"), headers: headers);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> list = jsonData['datos'] ?? [];
      final dtos = list.map((e) => FrequencyDto.fromJson(e)).toList();
      return Future.wait(dtos.map(_mapDtoToModel));
    } else {
      throw Exception("Error al obtener todas las periodicidades de pago");
    }
  }

  Future<Frequency> _mapDtoToModel(FrequencyDto dto) async {
    return Frequency(
      id: dto.id,
      nombre: dto.nombre,
    );
  }
}
