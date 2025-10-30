import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class CorreoService {
  static const String baseUrl = "http://localhost:3210/api/correo";
  final StorageService _storage = StorageService();

  /// 🔹 Obtiene el correo del perfil
  Future<Map<String, dynamic>> obtenerCorreo() async {
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();

    final url = Uri.parse("http://localhost:3210/perfil/$userId/completo");
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded["data"];
    } else {
      throw Exception("Error al obtener el perfil (${response.statusCode})");
    }
  }

  /// 🔹 Obtiene el estado del correo (maneja 'short', 'string', etc.)
  Future<dynamic> obtenerEstadoCorreo(String correo) async {
    final token = await _storage.getToken();
    final encodedCorreo = Uri.encodeComponent(correo);
    final url = Uri.parse("$baseUrl/buscar?correoVerificacion=$encodedCorreo");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["datos"]["estadoCorreoVerificado"]; // ✅ clave correcta
    } else if (response.statusCode == 401) {
      throw Exception("No autorizado (token inválido o expirado)");
    } else {
      throw Exception("Error al obtener estado del correo (${response.statusCode})");
    }
  }

  /// 🔹 Envía el correo con el código
  Future<Map<String, dynamic>> enviarVerificacion(String correo) async {
    final token = await _storage.getToken();
    final url = Uri.parse("$baseUrl/enviar?correoVerificacion=$correo"); // ✅ parámetro correcto

    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.body.isEmpty) {
      throw Exception("El servidor no devolvió respuesta JSON");
    }

    final data = jsonDecode(response.body);
    return {
      "codigoEstado": data["codigoEstado"],
      "mensaje": data["mensaje"],
    };
  }

  /// 🔹 Verifica el código recibido
  Future<Map<String, dynamic>> verificarCodigo(String correo, String codigo) async {
    final token = await _storage.getToken();
    final url = Uri.parse("$baseUrl/validar?correoVerificacion=$correo&codigo=$codigo"); // ✅ endpoint correcto

    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.body.isEmpty) {
      throw Exception("El servidor no devolvió respuesta JSON");
    }

    final data = jsonDecode(response.body);
    return {
      "codigoEstado": data["codigoEstado"],
      "mensaje": data["mensaje"],
    };
  }
}
