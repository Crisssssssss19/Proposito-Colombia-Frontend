import 'dart:convert';
import 'package:http/http.dart' as http;

class PreRegistroService {
  static const String baseUrl = "http://localhost:3210/api/preregistro";

  /// 📲 Envía un código SMS al teléfono indicado
  Future<Map<String, dynamic>> enviarCodigo(String telefono) async {
    final encodedTelefono = Uri.encodeQueryComponent(telefono); // 🔹 Codifica el "+"
    final url = Uri.parse('$baseUrl/enviar?telefono=$encodedTelefono');
    final response = await http.post(url);

    try {
      final data = jsonDecode(response.body);
      return {
        'codigoEstado': data['codigoEstado'] ?? 500,
        'mensaje': data['mensaje'] ?? 'Sin mensaje',
        'datos': data['datos']?.toString(),
        'fechaHora': data['fechaHora'] ?? '',
      };
    } catch (e) {
      throw Exception('Error procesando respuesta: ${response.body}');
    }
  }

  /// ✅ Verifica el código recibido
  Future<Map<String, dynamic>> validarCodigo(String telefono, String codigo) async {
    final encodedTelefono = Uri.encodeQueryComponent(telefono);
    final encodedCodigo = Uri.encodeQueryComponent(codigo);

    final url = Uri.parse('$baseUrl/validar?telefono=$encodedTelefono&codigo=$encodedCodigo');
    final response = await http.post(url);

    try {
      final data = jsonDecode(response.body);
      return {
        'codigoEstado': data['codigoEstado'] ?? 500,
        'mensaje': data['mensaje'] ?? 'Sin mensaje',
        'datos': data['datos']?.toString(),
        'fechaHora': data['fechaHora'] ?? '',
      };
    } catch (e) {
      throw Exception('Error procesando respuesta: ${response.body}');
    }
  }
}
