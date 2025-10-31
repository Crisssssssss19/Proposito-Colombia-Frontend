import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class TelefonoService {
  static const String baseUrl = "http://localhost:3210/api/preregistro";
  static const String accesoUrl = "http://localhost:3210/api/acceso";
  final StorageService _storage = StorageService();

  /// 🔹 Obtener teléfono actual del usuario logueado
  Future<String> obtenerTelefonoUsuario() async {
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();

    final url = Uri.parse("$accesoUrl/$userId");
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final acceso = data["datos"];
      return acceso["telefonoAcceso"] ?? "";
    } else {
      throw Exception("Error al obtener teléfono (${response.statusCode})");
    }
  }

  /// 🔹 Enviar código SMS al número actual
  Future<Map<String, dynamic>> enviarCodigoCambio() async {
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();

    final url = Uri.parse("$baseUrl/enviar-cambio?idUsuario=$userId");
    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    final data = jsonDecode(response.body);
    return {
      "codigoEstado": data["codigoEstado"],
      "mensaje": data["mensaje"],
    };
  }

  /// 🔹 Verificar código y actualizar número
  Future<Map<String, dynamic>> verificarCambioTelefono(
      String codigo, String nuevoTelefono) async {
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();
    final encodedTelefono = Uri.encodeQueryComponent(nuevoTelefono); // Codifica el "+"

    final url = Uri.parse(
        "$baseUrl/verificar-cambio?idUsuario=$userId&codigo=$codigo&nuevoTelefono=$encodedTelefono");
    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    final data = jsonDecode(response.body);
    return {
      "codigoEstado": data["codigoEstado"],
      "mensaje": data["mensaje"],
    };
  }
}
