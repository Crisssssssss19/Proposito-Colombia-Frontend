import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class PerfilService {
  final StorageService _storageService = StorageService();
  static const String baseUrl = "http://localhost:3210/perfil"; 

  Future<Map<String, dynamic>> obtenerPerfil() async {
    final token = await _storageService.getToken();
    final userId = await _storageService.getUserId();

    if (token == null || userId == null) {
      throw Exception("Token o ID de usuario no encontrados. Inicia sesión nuevamente.");
    }

    final url = Uri.parse("$baseUrl/$userId/completo/");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener el perfil (${response.statusCode})");
    }
  }
}
