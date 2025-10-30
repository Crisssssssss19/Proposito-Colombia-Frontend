import 'package:flutter/material.dart';
import '/config/theme.dart';
import '/services/correo_service.dart';

enum VerificationStatus { unverified, pending, verified }

class CorreoElectronicoScreen extends StatefulWidget {
  final String email;
  const CorreoElectronicoScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<CorreoElectronicoScreen> createState() => _CorreoElectronicoScreenState();
}

class _CorreoElectronicoScreenState extends State<CorreoElectronicoScreen> {
  final CorreoService _correoService = CorreoService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();

  VerificationStatus status = VerificationStatus.unverified;
  bool _isLoading = true;
  bool _mostrarCampoCodigo = false;
  bool _isSending = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosCorreo();
  }

  Future<void> _cargarDatosCorreo() async {
    try {
      final correo = widget.email;
      emailController.text = correo;

      final estado = await _correoService.obtenerEstadoCorreo(correo);
      setState(() {
        status = _mapearEstado(estado);
        _isLoading = false;
      });
    } catch (e) {
      print("Error cargando estado del correo: $e");
      setState(() => _isLoading = false);
    }
  }

  VerificationStatus _mapearEstado(dynamic estadoRaw) {
  if (estadoRaw == null) return VerificationStatus.unverified;

  int estado;
  if (estadoRaw is int) {
    estado = estadoRaw;
  } else if (estadoRaw is double) {
    estado = estadoRaw.toInt();
  } else if (estadoRaw is String) {
    estado = int.tryParse(estadoRaw) ?? 0;
  } else {
    estado = 0;
  }

  switch (estado) {
    case 1:
      return VerificationStatus.unverified;
    case 2:
      return VerificationStatus.pending;
    case 3:
      return VerificationStatus.verified;
    default:
      return VerificationStatus.unverified;
  }
}


  Future<void> _enviarVerificacion() async {
    if (emailController.text.isEmpty) return;
    setState(() => _isSending = true);

    try {
      final result = await _correoService.enviarVerificacion(emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["mensaje"] ?? "Código enviado")),
      );
      setState(() {
        status = VerificationStatus.pending;
        _mostrarCampoCodigo = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _verificarCodigo() async {
    if (codigoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa el código")),
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final result = await _correoService.verificarCodigo(
        emailController.text.trim(),
        codigoController.text.trim(),
      );

      if (result["codigoEstado"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["mensaje"])),
        );
        setState(() {
          status = VerificationStatus.verified;
          _mostrarCampoCodigo = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["mensaje"])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verificando: $e")),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  // === UI ===
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verificación de correo", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                suffixText: _textoEstado(),
                suffixStyle: TextStyle(color: _colorEstado(), fontWeight: FontWeight.bold),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            if (status == VerificationStatus.unverified)
              ElevatedButton(
                onPressed: _isSending ? null : _enviarVerificacion,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.lightPrimary),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Enviar verificación"),
              ),
            if (_mostrarCampoCodigo || status == VerificationStatus.pending)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text("Ingresa el código recibido"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Código de 6 dígitos",
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verificarCodigo,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: _isVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Confirmar verificación"),
                  ),
                ],
              ),
            const SizedBox(height: 25),
            Text(
              "Verificar tu correo garantiza la seguridad de tu cuenta y recuperación de acceso.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _textoEstado() {
    switch (status) {
      case VerificationStatus.verified:
        return "Verificado";
      case VerificationStatus.pending:
        return "Pendiente";
      default:
        return "Sin verificar";
    }
  }

  Color _colorEstado() {
    switch (status) {
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
