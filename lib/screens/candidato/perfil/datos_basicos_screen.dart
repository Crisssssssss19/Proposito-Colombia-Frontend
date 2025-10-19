import 'package:flutter/material.dart';
import '/../config/theme.dart';

class DatosBasicosScreen extends StatefulWidget {
  const DatosBasicosScreen({Key? key}) : super(key: key);

  @override
  State<DatosBasicosScreen> createState() => _DatosBasicosScreenState();
}

class _DatosBasicosScreenState extends State<DatosBasicosScreen> {
  final TextEditingController nombreController =
      TextEditingController(text: 'Ana María González');
  final TextEditingController cedulaController =
      TextEditingController(text: '1234567890');
  final TextEditingController profesionController =
      TextEditingController(text: 'Desarrolladora Frontend');
  final TextEditingController ubicacionController =
      TextEditingController(text: 'Bogotá, Colombia');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Básicos',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Información personal y profesional',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.edit, color: Colors.black),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🟣 FOTO DE PERFIL (centrada)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightPrimary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Foto de perfil',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          const AssetImage('assets/profile.jpg'),
                      backgroundColor:
                          AppTheme.lightSecondary.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.camera_alt_outlined,
                      color: Colors.grey, size: 28),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🟣 INFORMACIÓN PERSONAL
            _buildSection(
              icon: Icons.person_outline,
              title: 'Información personal',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('Nombre completo', nombreController),
                  const SizedBox(height: 10),
                  _buildInput('Número de cédula', cedulaController),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🟣 INFORMACIÓN PROFESIONAL
            _buildSection(
              icon: Icons.work_outline,
              title: 'Información profesional',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('Profesión / Cargo', profesionController),
                  const SizedBox(height: 10),
                  _buildInput('Ubicación', ubicacionController),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🟣 TEXTO INFORMATIVO DENTRO DE UN CUADRO
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightPrimary),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estos datos son utilizados únicamente para procesos de verificación y contacto relacionados con oportunidades laborales. '
                      'Tu información está protegida según nuestras políticas de privacidad.',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟩 Sección reutilizable (cuadro con ícono y título)
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightPrimary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.lightPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // 🟦 Campos de texto editables con borde visible
  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Escribe aquí...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.lightPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppTheme.lightPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
