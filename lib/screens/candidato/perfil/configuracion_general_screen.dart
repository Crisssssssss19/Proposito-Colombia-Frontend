import 'package:flutter/material.dart';
import '/config/theme.dart';

class ConfiguracionGeneralScreen extends StatefulWidget {
  const ConfiguracionGeneralScreen({super.key});

  @override
  State<ConfiguracionGeneralScreen> createState() => _ConfiguracionGeneralScreenState();
}

class _ConfiguracionGeneralScreenState extends State<ConfiguracionGeneralScreen> {
  bool mostrarEnLinea = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuracion General"),
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
                SwitchListTile(
                  title: const Text("Mostrar estado en línea"),
                  subtitle: const Text("Indica cuando estás activo en la app"),
                  value: mostrarEnLinea,
                  onChanged: (value) => setState(() => mostrarEnLinea = value),
                  activeColor: AppTheme.lightSecondary,
                ),
                ListTile(
                  leading: const Icon(Icons.key_rounded, color: AppTheme.lightPrimary),
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
                  leading: const Icon(Icons.info_outline, color: AppTheme.lightPrimary),
                  title: const Text("Acerca de Swallow"),
                  subtitle: const Text("Versión 1.0.0"),
                  onTap: () => _mostrarAcercaDe(context),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppTheme.lightPrimary),
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
                  leading: const Icon(Icons.delete_forever, color: AppTheme.accentCoral),
                  title: const Text(
                    "Eliminar cuenta",
                    style: TextStyle(color: AppTheme.accentCoral, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text("Eliminar permanentemente tu cuenta"),
                  onTap: () => _mostrarEliminarCuenta(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Powered by ©CIEUniMagdalena-2025",
              style: TextStyle(color: AppTheme.lightTextSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required List<Widget> children}) {
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
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        )),
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
      builder: (_) => const CambiarContrasenaDialog(),
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
//  DIALOGOS PERSONALIZADOS
// ===============================

class CambiarContrasenaDialog extends StatelessWidget {
  const CambiarContrasenaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controllerActual = TextEditingController();
    final controllerNueva = TextEditingController();
    final controllerConfirmar = TextEditingController();

    return AlertDialog(
      title: const Text("Cambiar contraseña"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controllerActual,
            decoration: const InputDecoration(labelText: "Contraseña actual"),
            obscureText: true,
          ),
          TextField(
            controller: controllerNueva,
            decoration: const InputDecoration(labelText: "Nueva contraseña"),
            obscureText: true,
          ),
          TextField(
            controller: controllerConfirmar,
            decoration: const InputDecoration(labelText: "Confirmar nueva contraseña"),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Guardar"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
      ],
    );
  }
}

class AcercaDeDialog extends StatelessWidget {
  const AcercaDeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Acerca de Swallow"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: AppTheme.lightPrimary, size: 48),
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
      title: const Text("Ayuda y soporte"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Preguntas frecuentes"),
            subtitle: const Text("Encuentra respuestas a las dudas más comunes"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Chat de soporte"),
            subtitle: const Text("Habla con nuestro equipo en tiempo real"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Contacto por email"),
            subtitle: const Text("soporte@swallow.co"),
            onTap: () {},
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
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text("Eliminar cuenta"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Esta acción es irreversible. Se eliminarán todos tus datos permanentemente.",
            style: TextStyle(color: AppTheme.accentCoral),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(labelText: "Escribe ELIMINAR para confirmar"),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral),
          onPressed: () => Navigator.pop(context),
          child: const Text("Eliminar cuenta"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
      ],
    );
  }
}
