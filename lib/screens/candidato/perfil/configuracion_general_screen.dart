import 'package:flutter/material.dart';
import 'package:swallow_app/config/theme.dart';
import 'package:swallow_app/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfiguracionGeneralScreen extends StatefulWidget {
  const ConfiguracionGeneralScreen({super.key});

  @override
  State<ConfiguracionGeneralScreen> createState() =>
      _ConfiguracionGeneralScreenState();
}

class _ConfiguracionGeneralScreenState
    extends State<ConfiguracionGeneralScreen> {
  final storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración General"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              context,
              title: "Privacidad y Seguridad",
              children: [
                ListTile(
                  leading: const Icon(Icons.key_rounded,
                      color: AppTheme.lightPrimary),
                  title: const Text("Cambiar contraseña"),
                  subtitle: const Text("Actualizar tu contraseña de acceso"),
                  onTap: () => _mostrarCambiarContrasena(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              title: "General",
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppTheme.lightPrimary),
                  title: const Text("Acerca de Swallow"),
                  subtitle: const Text("Versión 1.0.0"),
                  onTap: () => _mostrarAcercaDe(context),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline,
                      color: AppTheme.lightPrimary),
                  title: const Text("Ayuda y soporte"),
                  subtitle: const Text("Centro de ayuda y contacto"),
                  onTap: () => _mostrarAyudaSoporte(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              title: "",
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever,
                      color: AppTheme.accentCoral),
                  title: const Text(
                    "Eliminar cuenta",
                    style: TextStyle(
                        color: AppTheme.accentCoral,
                        fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text("Eliminar permanentemente tu cuenta"),
                  onTap: () => _mostrarEliminarCuenta(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Powered by ©CIEUniMagdalena-2025",
              style:
                  TextStyle(color: AppTheme.lightTextSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }

  // --- DIALOGOS ---
  void _mostrarCambiarContrasena(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CambiarContrasenaDialog(storage: storage),
    );
  }

  void _mostrarAcercaDe(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AcercaDeDialog(),
    );
  }

  void _mostrarAyudaSoporte(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AyudaSoporteDialog(),
    );
  }

  void _mostrarEliminarCuenta(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EliminarCuentaDialog(),
    );
  }
}

// ===============================
//  DIALOG CAMBIAR CONTRASEÑA
// ===============================

class CambiarContrasenaDialog extends StatefulWidget {
  final StorageService storage;

  const CambiarContrasenaDialog({super.key, required this.storage});

  @override
  State<CambiarContrasenaDialog> createState() =>
      _CambiarContrasenaDialogState();
}

class _CambiarContrasenaDialogState extends State<CambiarContrasenaDialog> {
  final controllerActual = TextEditingController();
  final controllerNueva = TextEditingController();
  final controllerConfirmar = TextEditingController();
  bool _isLoading = false;
  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;

  Future<void> _cambiarContrasena() async {
    if (controllerActual.text.trim().isEmpty) {
      _mostrarError('Debe ingresar su contraseña actual');
      return;
    }

    if (controllerNueva.text.trim().isEmpty) {
      _mostrarError('La nueva contraseña no puede estar vacía');
      return;
    }

    if (controllerNueva.text.length < 8) {
      _mostrarError('La contraseña debe tener al menos 8 caracteres');
      return;
    }

    if (controllerNueva.text != controllerConfirmar.text) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }

    if (controllerActual.text == controllerNueva.text) {
      _mostrarError('La nueva contraseña debe ser diferente a la actual');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await widget.storage.getToken();
      final userId = await widget.storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      final response = await http.put(
        Uri.parse('http://localhost:3210/api/acceso/$userId/clave'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'claveActual': controllerActual.text.trim(),
          'nuevaClave': controllerNueva.text.trim(),
          'confirmarClave': controllerConfirmar.text.trim(),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Error al cambiar contraseña');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Cambiar contraseña",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controllerActual,
                    decoration: InputDecoration(
                      labelText: "Contraseña actual",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureActual
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscureActual = !_obscureActual),
                      ),
                    ),
                    obscureText: _obscureActual,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controllerNueva,
                    decoration: InputDecoration(
                      labelText: "Nueva contraseña",
                      hintText: "Mínimo 8 caracteres",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNueva
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscureNueva = !_obscureNueva),
                      ),
                    ),
                    obscureText: _obscureNueva,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controllerConfirmar,
                    decoration: InputDecoration(
                      labelText: "Confirmar nueva contraseña",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmar
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _obscureConfirmar = !_obscureConfirmar),
                      ),
                    ),
                    obscureText: _obscureConfirmar,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "• La contraseña debe tener al menos 8 caracteres\n• Debe ser diferente a tu contraseña actual",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _cambiarContrasena,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Guardar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controllerActual.dispose();
    controllerNueva.dispose();
    controllerConfirmar.dispose();
    super.dispose();
  }
}

// ===============================
//  OTROS DIALOGS
// ===============================

class AcercaDeDialog extends StatelessWidget {
  const AcercaDeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Acerca de Swallow"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              color: AppTheme.lightPrimary, size: 48),
          const SizedBox(height: 8),
          const Text(
            "Swallow v1.0.0\nLa app de empleo que conecta talentos",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Desarrollado por el Centro de Investigación y Extensión Universitaria de la Universidad del Magdalena.\n© 2025 CIEUniMagdalena. Todos los derechos reservados.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.lightTextSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}

class AyudaSoporteDialog extends StatelessWidget {
  const AyudaSoporteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Ayuda y soporte"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.email, color: AppTheme.lightPrimary),
            title: const Text("Contacto por email"),
            subtitle: const Text("soporte@swallow.co"),
            onTap: () {
              // Aquí puedes agregar lógica para abrir el cliente de email
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abriendo cliente de email...')),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}

class EliminarCuentaDialog extends StatelessWidget {
  const EliminarCuentaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Eliminar cuenta"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Esta función será implementada próximamente.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
