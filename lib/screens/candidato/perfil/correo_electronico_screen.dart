import 'package:flutter/material.dart';
import '/services/correo_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      emailController.text = widget.email;
      final estado = await _correoService.obtenerEstadoCorreo(widget.email);
      setState(() {
        status = _mapearEstado(estado);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error cargando estado del correo: $e");
      setState(() => _isLoading = false);
    }
  }

  VerificationStatus _mapearEstado(dynamic estadoRaw) {
    if (estadoRaw == null) return VerificationStatus.unverified;
    int estado = estadoRaw is int ? estadoRaw : int.tryParse(estadoRaw.toString()) ?? 0;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text("Email-Verification"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCorreoCard(theme, colorScheme, textTheme),
            const SizedBox(height: 16),
            _buildInfoCard(theme, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCorreoCard(ThemeData theme, ColorScheme colors, TextTheme texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.mail, color: colors.primary),
              const SizedBox(width: 8),
              Text("Correo Electrónico",
                  style: texts.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            readOnly: true,
            style: texts.bodyLarge,
            decoration: InputDecoration(
              labelText: "Dirección de Correo",
              labelStyle: texts.bodyMedium?.copyWith(color: colors.secondary),
              suffixText: _textoEstado(),
              suffixStyle: TextStyle(color: _colorEstado(), fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          if (status == VerificationStatus.unverified)
            _buildVerifyButton(colors),
          if (status == VerificationStatus.pending)
            _buildPendingSection(),
          if (_mostrarCampoCodigo)
            _buildCodigoInput(colors),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(ColorScheme colors) {
    return ElevatedButton.icon(
      onPressed: _isSending ? null : _enviarVerificacion,
      icon: const Icon(LucideIcons.send),
      label: _isSending
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Text("Verificar Correo"),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPendingSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Hemos enviado un código de verificación a tu correo. Revisa tu bandeja y spam.",
              style: TextStyle(color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodigoInput(ColorScheme colors) {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: codigoController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Código de 6 dígitos",
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verificarCodigo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _isVerifying
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Confirmar verificación"),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme, ColorScheme colors, TextTheme texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🔒 ¿Por qué verificar tu correo?",
              style: texts.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "• Asegura que las ofertas laborales lleguen directamente a tu bandeja.\n"
            "• Permite recuperar tu cuenta en caso de olvido de contraseña.\n"
            "• Protege tu perfil de accesos no autorizados.\n"
            "• Aumenta la confianza de los empleadores.",
            style: texts.bodyMedium,
          ),
        ],
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
