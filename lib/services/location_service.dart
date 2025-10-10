import 'session_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dtos/location_dto.dart';
import '../models/location.dart';

class LocationService {
  final String baseUrl = 'http://localhost:3210/api/ubicacion';

  Future<List<Location>> getUbicaciones() async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> ubicacionesJson = data['datos'] ?? [];
      final dtos = ubicacionesJson.map((e) => LocationDto.fromJson(e)).toList();
      return dtos.map((dto) => _mapDtoToModel(dto)).toList();
    } else {
      throw Exception('Error al obtener ubicaciones');
    }
  }

  Future<List<Location>> buscarUbicaciones(String nombre) async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse('$baseUrl/buscar?nombre=$nombre'), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> ubicacionesJson = data['datos'] ?? [];
      final dtos = ubicacionesJson.map((e) => LocationDto.fromJson(e)).toList();
      return dtos.map((dto) => _mapDtoToModel(dto)).toList();
    } else {
      throw Exception('Error al buscar ubicaciones');
    }
  }

  Future<Location> getUbicacionById(int id) async {
    final token = await SessionManager.getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = LocationDto.fromJson(data['datos'] ?? {});
      return _mapDtoToModel(dto);
    } else {
      throw Exception('Error al obtener ubicación por ID');
    }
  }

  Location _mapDtoToModel(LocationDto dto) {
    // Cuando necesitemos obtener la ubicación padre, hacer la llamada aquí
    return Location(
      idUbicacion: dto.idUbicacion,
      idPadreUbicacion: null, // Hay que mapear aqui en un futuro
      nombreUbicacion: dto.nombreUbicacion,
      idDaneUbicaicon: dto.idDaneUbicaicon,
      longitudUbicacion: dto.longitudUbicacion,
      latitudUbicacion: dto.latitudUbicacion,
    );
  }
}
