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

  // === UI ===
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🎨 Tema dinámico (claro/oscuro)
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text("Phone-Verification"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPhoneSection(theme, colorScheme),
            const SizedBox(height: 16),
            _buildWhyVerifySection(theme, colorScheme),
            const SizedBox(height: 16),
            _buildInfoBox(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneSection(ThemeData theme, ColorScheme colors) {
    Color borderColor = theme.dividerColor;
    Color fillColor = theme.cardColor;
    String? message;
    Color? messageColor;

    switch (status) {
      case VerificationStatus.pending:
        borderColor = Colors.orange;
        fillColor = Colors.orange.withOpacity(0.08);
        message = "Hemos enviado un código de verificación por SMS a tu número. Revisa tus mensajes.";
        messageColor = Colors.orange;
        break;
      case VerificationStatus.verified:
        borderColor = Colors.green;
        fillColor = Colors.green.withOpacity(0.08);
        message = "Teléfono verificado correctamente";
        messageColor = Colors.green[700];
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone),
              SizedBox(width: 8),
              Text(
                "Número de Teléfono",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text("Número de Contacto",
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          TextField(
            controller: _telefonoController,
            readOnly: !_editando,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_editando ? Icons.check : Icons.edit,
                    color: colors.primary),
                onPressed: () {
                  if (_editando) {
                    setState(() => _editando = false);
                    _enviarCodigo();
                  } else {
                    setState(() => _editando = true);
                  }
                },
              ),
              suffixText: _textoEstado(),
              suffixStyle: TextStyle(
                color: _colorEstado(),
                fontWeight: FontWeight.bold,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          if (status == VerificationStatus.unverified)
            ElevatedButton.icon(
              onPressed: _isSending ? null : _enviarCodigo,
              icon: const Icon(Icons.send, size: 18),
              label: const Text("Verificar Teléfono"),
            ),
          if (status == VerificationStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSending ? null : _enviarCodigo,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: const Text("Reenviar",
                        style: TextStyle(color: Colors.orange)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verificarCodigo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                    ),
                    child: const Text("Ya recibí el código"),
                  ),
                ),
              ],
            ),
          if (message != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: messageColor!.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: messageColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: messageColor, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message!,
                      style: TextStyle(
                        color: messageColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWhyVerifySection(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined),
              SizedBox(width: 8),
              Text("¿Por qué verificar tu teléfono?",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "• Recibe notificaciones importantes sobre ofertas laborales por SMS.\n"
            "• Permite que los empleadores te contacten directamente.\n"
            "• Mejora la seguridad de tu cuenta con verificación en dos pasos.\n"
            "• Aumenta tu credibilidad ante empleadores.",
            style: TextStyle(fontSize: 13.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Tu número de teléfono es utilizado únicamente para procesos de verificación y contacto relacionados con oportunidades laborales. Tu información está protegida según nuestras políticas de privacidad.",
              style: TextStyle(fontSize: 13.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  String _textoEstado() {
    switch (status) {
      case VerificationStatus.pending:
        return "Pendiente";
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
