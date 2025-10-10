import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swallow_app/dtos/location_dto.dart';
import 'package:swallow_app/models/location.dart';
import '../dtos/user_dto.dart';
import '../models/user.dart';
import 'package:swallow_app/services/session_manager.dart';

class UserService {
  final String baseUrl = 'http://localhost:3210/api/usuario'; // Cambia por tu URL real

  Future<List<User>> getAllUsuarios() async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> usuariosJson = data['datos'] ?? [];
      final dtos = usuariosJson.map((e) => UserDto.fromJson(e)).toList();
      return dtos.map((dto) => _mapDtoToModel(dto)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  Future<User> getUsuario(int idUsuario) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/id/$idUsuario'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = UserDto.fromJson(data['datos']);
      return _mapDtoToModel(dto);
    } else {
      throw Exception('Error al obtener usuario');
    }
  }

  Future<User> createUsuario(Map<String, dynamic> usuarioRequest) async {
    final token = await SessionManager.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(usuarioRequest),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = UserDto.fromJson(data['datos']);
      return _mapDtoToModel(dto);
    } else {
      throw Exception('Error al crear usuario');
    }
  }

  Future<List<User>> buscarUsuariosPorNombre(String nombre) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/buscar?nombre=$nombre'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> usuariosJson = data['datos'] ?? [];
      final dtos = usuariosJson.map((e) => UserDto.fromJson(e)).toList();
      return dtos.map((dto) => _mapDtoToModel(dto)).toList();
    } else {
      throw Exception('Error al buscar usuarios por nombre');
    }
  }

  Future<User> updateUsuario(int id, Map<String, dynamic> usuarioRequest) async {
    final token = await SessionManager.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(usuarioRequest),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dto = UserDto.fromJson(data['datos']);
      return _mapDtoToModel(dto);
    } else {
      throw Exception('Error al editar usuario');
    }
  }

  Future<bool> deleteUsuario(int id) async {
    final token = await SessionManager.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al eliminar usuario');
    }
  }

  Future<List<User>> buscarUsuariosPorTipoDocumento(int tipo) async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/tipo/$tipo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> usuariosJson = data['datos'] ?? [];
      final dtos = usuariosJson.map((e) => UserDto.fromJson(e)).toList();
      return dtos.map((dto) => _mapDtoToModel(dto)).toList();
    } else {
      throw Exception('Error al buscar usuarios por tipo de documento');
    }
  }

  User _mapDtoToModel(UserDto dto){
    LocationDto ubicacionDto = dto.ubicacion;
    return User(
      idUsuario: dto.idUsuario,
      nombresUsuario: dto.nombresUsuario,
      apellidosUsuario: dto.apellidosUsuario,
      estadoUsuario: dto.estadoUsuario,
      documentoUsuario: dto.documentoUsuario,
      ubicacionResponseDto: Location(
        idUbicacion: ubicacionDto.idUbicacion,
        idPadreUbicacion: null,
        nombreUbicacion: ubicacionDto.nombreUbicacion,
        idDaneUbicaicon: ubicacionDto.idDaneUbicaicon,
        longitudUbicacion: ubicacionDto.longitudUbicacion,
        latitudUbicacion: ubicacionDto.latitudUbicacion
        ), // Mapear cuando se implemente
    );
  }
}
