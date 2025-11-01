import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/config/paleta_colores.dart';
import 'package:swallow_app/services/storage_service.dart';

class CambiarContrasenaScreen extends StatefulWidget {
  const CambiarContrasenaScreen({super.key});

  @override
  State<CambiarContrasenaScreen> createState() =>
      _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState extends State<CambiarContrasenaScreen> {
  final controllerActual = TextEditingController();
  final controllerNueva = TextEditingController();
  final controllerConfirmar = TextEditingController();
  final storage = StorageService();

  bool _isLoading = false;
  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;

  Future<void> _cambiarContrasena() async {
    final actual = controllerActual.text.trim();
    final nueva = controllerNueva.text.trim();
    final confirmar = controllerConfirmar.text.trim();

    if (actual.isEmpty) return _mostrarError('Debes ingresar tu contraseña actual.');
    if (nueva.isEmpty) return _mostrarError('Debes ingresar una nueva contraseña.');
    if (nueva.length < 8) return _mostrarError('Debe tener al menos 8 caracteres.');
    if (nueva != confirmar) return _mostrarError('Las contraseñas no coinciden.');
    if (nueva == actual) return _mostrarError('La nueva contraseña debe ser diferente.');

    setState(() => _isLoading = true);

    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

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
          'claveActual': actual,
          'nuevaClave': nueva,
          'confirmarClave': confirmar,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada correctamente'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Error al cambiar contraseña');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Contraseña actual incorrecta');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: AppTheme.accentCoral),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actualiza tu contraseña de acceso',
              style: textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(Icons.lock_outline, 'Actualizar Contraseña'),
            const SizedBox(height: 12),
            _buildTextField(
              controllerActual,
              label: 'Contraseña actual',
              obscure: _obscureActual,
              toggle: () => setState(() => _obscureActual = !_obscureActual),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controllerNueva,
              label: 'Nueva contraseña',
              hint: 'Debe tener al menos 8 caracteres',
              obscure: _obscureNueva,
              toggle: () => setState(() => _obscureNueva = !_obscureNueva),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controllerConfirmar,
              label: 'Confirmar nueva contraseña',
              obscure: _obscureConfirmar,
              toggle: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(Icons.info_outline, 'Recomendaciones de seguridad'),
            const SizedBox(height: 10),
            _buildRecommendationsCard(isDark),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextTertiary,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _cambiarContrasena,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Cambiar Contraseña',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.white), // icono blanco para contraste
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white, // texto más visible
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String label,
    String? hint,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white), // texto blanco
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.5), // borde blanco
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 2), // borde más fuerte al enfocar
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkBackgroundSecondary
            : AppTheme.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppTheme.darkTextSecondary.withOpacity(0.3)
              : AppTheme.lightTextTertiary.withOpacity(0.3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Usa una combinación de letras, números y símbolos'),
          SizedBox(height: 4),
          Text('• Evita información personal fácil de adivinar'),
          SizedBox(height: 4),
          Text('• No compartas tu contraseña con nadie'),
          SizedBox(height: 4),
          Text('• Cámbiala periódicamente'),
        ],
      ),
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
