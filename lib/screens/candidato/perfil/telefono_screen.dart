import 'package:flutter/material.dart';
import '/config/theme.dart';
import '/services/telefono_service.dart';

enum VerificationStatus { unverified, pending, verified }

class TelefonoScreen extends StatefulWidget {
  const TelefonoScreen({Key? key}) : super(key: key);

  @override
  State<TelefonoScreen> createState() => _TelefonoScreenState();
}

class _TelefonoScreenState extends State<TelefonoScreen> {
  final TelefonoService _telefonoService = TelefonoService();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  bool _editando = false;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isVerifying = false;
  VerificationStatus status = VerificationStatus.unverified;

  @override
  void initState() {
    super.initState();
    _cargarTelefono();
  }

  Future<void> _cargarTelefono() async {
    try {
      final telefono = await _telefonoService.obtenerTelefonoUsuario();
      setState(() {
        _telefonoController.text = telefono;
        _isLoading = false;
        status = VerificationStatus.unverified;
      });
    } catch (e) {
      print("Error cargando teléfono: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarCodigo() async {
    setState(() => _isSending = true);
    try {
      final result = await _telefonoService.enviarCodigoCambio();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["mensaje"] ?? "Código enviado")),
      );
      setState(() {
        status = VerificationStatus.pending;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error enviando código: $e")),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _verificarCodigo() async {
    if (_codigoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa el código recibido")),
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final result = await _telefonoService.verificarCambioTelefono(
        _codigoController.text.trim(),
        _telefonoController.text.trim(),
      );

      if (result["codigoEstado"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ ${result["mensaje"]}")),
        );
        setState(() {
          status = VerificationStatus.verified;
          _editando = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ ${result["mensaje"]}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verificando código: $e")),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cambio de teléfono", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTelefonoSection(),
            const SizedBox(height: 20),
            if (status == VerificationStatus.pending)
              _buildCodigoSection(),
            const SizedBox(height: 20),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTelefonoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightPrimary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Número de teléfono", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _telefonoController,
            readOnly: !_editando,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_editando ? Icons.check : Icons.edit, color: AppTheme.lightPrimary),
                onPressed: () {
                  if (_editando) {
                    setState(() => _editando = false);
                    _enviarCodigo(); // Enviar código al número anterior
                  } else {
                    setState(() => _editando = true);
                  }
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Estado: ${_textoEstado()}",
            style: TextStyle(color: _colorEstado(), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCodigoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ingresa el código enviado a tu teléfono anterior",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _codigoController,
            keyboardType: TextInputType.number,
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
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightPrimary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "Por seguridad, debes confirmar el cambio desde tu número actual. "
        "Recibirás un código SMS para validar el cambio antes de actualizarlo.",
        style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
      ),
    );
  }

  String _textoEstado() {
    switch (status) {
      case VerificationStatus.pending:
        return "Pendiente de verificación";
      case VerificationStatus.verified:
        return "Verificado";
      default:
        return "Sin verificar";
    }
  }

  Color _colorEstado() {
    switch (status) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.verified:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
