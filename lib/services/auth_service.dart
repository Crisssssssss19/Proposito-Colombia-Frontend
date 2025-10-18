import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://localhost:3210/api/acceso";

  Future<Map<String, dynamic>> login(String correoAcceso, String claveAcceso) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "correoAcceso": correoAcceso,
        "claveAcceso": claveAcceso,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      if (body.containsKey('datos') && body['datos'] != null) {
        final datos = body['datos'];
        return {
          "token": datos["tokenApp"],
          "foto": datos["fotoApp"],
          "expiraEn": datos["expiraEn"],
        };
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } else {
      throw Exception('Error al iniciar sesión (${response.statusCode})');
    }
  }

  // ✅ REGISTRO (para empresa o aspirante)
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar usuario (${response.statusCode})');
    }
  }
}
