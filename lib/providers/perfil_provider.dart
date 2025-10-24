import 'package:flutter/material.dart';
import '../services/perfil_service.dart';

class PerfilProvider with ChangeNotifier {
  final PerfilService _perfilService = PerfilService();

  Map<String, dynamic>? _perfil;
  bool _cargando = false;
  String? _error;

  Map<String, dynamic>? get perfil => _perfil;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarPerfil() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _perfilService.obtenerPerfil();
      _perfil = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiarPerfil() {
    _perfil = null;
    notifyListeners();
  }
}
