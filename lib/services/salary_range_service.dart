import 'session_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dtos/salary_range_dto.dart';
import '../models/salary_range.dart';

class SalaryRangeService {
  final String baseUrl = 'http://localhost:3210/rangos-salariales';

  Future<SalaryRange> getSalaryRangeById(int id) async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse('$baseUrl/obtener/$id'), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = SalaryRangeDto.fromJson(data['datos']);
      return _mapDtoToModel(dto);
    } else {
      throw Exception('Error al obtener rango salarial por id');
    }
  }

  Future<List<SalaryRange>> getSalaryRanges() async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse('$baseUrl/obtener/todos'), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> rangesJson = data['datos'] ?? [];
      final dtos = rangesJson.map((e) => SalaryRangeDto.fromJson(e)).toList();
      return dtos.map((dto) => _mapDtoToModel(dto)).toList();
    } else {
      throw Exception('Error al obtener rangos salariales');
    }
  }

  SalaryRange _mapDtoToModel(SalaryRangeDto dto) {
    return SalaryRange(
      id: dto.id,
      salarioMin: dto.salarioMin,
      salarioMax: dto.salarioMax,
    );
  }
}
