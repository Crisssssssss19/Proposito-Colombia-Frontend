import 'package:flutter/material.dart';
import '../services/pre_register_service.dart';

class PreRegistroProvider extends ChangeNotifier {
  final PreRegistroService _service = PreRegistroService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _mensajeServidor;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get mensajeServidor => _mensajeServidor;

  /// Envía código SMS
  Future<bool> enviarCodigo(String telefono) async {
    _isLoading = true;
    _errorMessage = null;
    _mensajeServidor = null;
    notifyListeners();

    try {
      final result = await _service.enviarCodigo(telefono);
      _isLoading = false;
      _mensajeServidor = result['mensaje'];
      notifyListeners();
      return result['codigoEstado'] == 200;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Verifica código ingresado
  Future<bool> validarCodigo(String telefono, String codigo) async {
    _isLoading = true;
    _errorMessage = null;
    _mensajeServidor = null;
    notifyListeners();

    try {
      final result = await _service.validarCodigo(telefono, codigo);
      _isLoading = false;
      _mensajeServidor = result['mensaje'];
      notifyListeners();
      return result['codigoEstado'] == 200;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
