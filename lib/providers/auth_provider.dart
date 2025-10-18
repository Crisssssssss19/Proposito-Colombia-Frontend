import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import 'dart:math';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  String? _token;
  String? _userRole;
  String? _errorMessage;
  bool _isLoading = false;

  String? get token => _token;
  String? get userRole => _userRole;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // LOGIN
  Future<bool> login({
    required String correoAcceso,
    required String claveAcceso,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(correoAcceso, claveAcceso);
      _token = response['token'];
      if(_token == null) {
        throw Exception('Token inválido recibido del servidor');
      }
      // Decodificar el token JWT para obtener el rol del usuario
      final parts = _token!.split('.');
      if (parts.length != 3) {
        throw Exception('Token JWT inválido');
      }
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> decoded = jsonDecode(payload);

      final List<dynamic>? roles = decoded['roles'];
      _userRole = roles != null && roles.isNotEmpty ? roles.first : 'ASPIRANTE';

      // Guardar en almacenamiento local
      await _storageService.saveToken(_token!);
      await _storageService.saveUserType(_userRole!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // REGISTRO

  String _randomValue() => "XXX_${Random().nextInt(9999999)}";
  Future<bool> register({
    required String nombres,
    required String apellidos,
    required String correoAcceso,
    required String claveAcceso,
    required String telefono,
    required bool isEmpresa,
  }) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final body = {
      "nombresUsuario": nombres,
      "apellidosUsuario": apellidos.isEmpty ? "XXX_${_randomValue()}" : apellidos,
      "tipoDocumentoUsuario": 1,
      "documentoUsuario": _randomValue(),
      "idUbicacion": 101, // de ejemplo
      "estadoUsuario": 1,
      "telefonoUsuario": telefono.replaceAll(' ', ''),
      "correoAcceso": correoAcceso,
      "claveAcceso": claveAcceso,
      "roles": [isEmpresa ? 'Empresa' : 'Aspirante']
    };

    final response = await _authService.register(body);
    if (response['codigoEstado'] == 201) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['mensaje'] ?? 'Error en el registro';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}


  // LOGOUT
  Future<void> logout() async {
    _token = null;
    _userRole = null;
    await _storageService.clearAll();
    notifyListeners();
  }
}
