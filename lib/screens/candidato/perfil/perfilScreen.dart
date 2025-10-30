import 'package:flutter/material.dart';
import 'package:swallow_app/config/theme.dart';
import 'package:swallow_app/screens/candidato/perfil/configuracion_general_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/datos_basicos_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/correo_electronico_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/telefono_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/MiCVScreen.dart';
import 'package:swallow_app/screens/candidato/perfil/habilidades_competencias_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/portafolioScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/services/storage_service.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static final GlobalKey<NavigatorState> perfilNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Navigator(
        key: perfilNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const PerfilMainContent(),
          );
        },
      ),
    );
  }
}

class PerfilMainContent extends StatefulWidget {
  const PerfilMainContent({super.key});

  @override
  State<PerfilMainContent> createState() => _PerfilMainContentState();
}

class _PerfilMainContentState extends State<PerfilMainContent> {
  Map<String, dynamic>? perfilData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPerfilData();
  }

  Future<void> _fetchPerfilData() async {
    try {
      final storage = StorageService();
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) throw Exception('Token o ID no disponibles');

      final response = await http.get(
        Uri.parse('http://localhost:3210/perfil/$userId/completo'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          perfilData = decoded['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener perfil');
      }
    } catch (e) {
      print('Error cargando perfil: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (perfilData == null) return const Center(child: Text('No se pudo cargar el perfil.'));

    final nombre = '${perfilData!['nombres']} ${perfilData!['apellidos']}';
    final correo = perfilData!['email'] ?? perfilData!['correoAcceso'] ?? 'Sin correo';
    final ubicacion = perfilData!['ubicacion'] ?? 'Ubicación no disponible';
    final habilidadPrincipal = perfilData!['HabilidadPrincipal'] ?? 'Sin habilidad principal';

    return RefreshIndicator(
      onRefresh: _fetchPerfilData,
      color: AppTheme.lightPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Perfil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightPrimary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 35, backgroundImage: AssetImage('assets/images/user.jpg')),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(habilidadPrincipal, style: const TextStyle(color: Colors.grey)),
                        Text(ubicacion, style: const TextStyle(color: Colors.grey)),
                        Text(correo, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _buildProfileOption('Datos básicos', context),
            _buildProfileOption('Correo electrónico', context, correo: correo),
            _buildProfileOption('Número de teléfono', context),
            _buildProfileOption('Mi CV', context),
            _buildProfileOption('Competencia y habilidades', context),
            _buildProfileOption('Portafolio', context),
            _buildProfileOption('Configuración general', context),
            _buildProfileOption('Cerrar sesión', context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(String title, BuildContext context, {String? correo}) {
    void _navigateTo(Widget screen) async {
      final navigator = PerfilScreen.perfilNavigatorKey.currentState;
      await (navigator ?? Navigator.of(context)).push(MaterialPageRoute(builder: (_) => screen));
    }

    return InkWell(
      onTap: () {
        if (title == 'Datos básicos') {
          _navigateTo(const DatosBasicosScreen());
        } else if (title == 'Correo electrónico') {
          _navigateTo(CorreoElectronicoScreen(email: correo ?? ''));
        } else if (title == 'Número de teléfono') {
          _navigateTo(const TelefonoScreen());
        } else if (title == 'Mi CV') {
          _navigateTo(const MiCVScreen());
        } else if (title == 'Competencia y habilidades') {
          _navigateTo(const CompetenciasScreen());
        } else if (title == 'Portafolio') {
          _navigateTo(const PortafolioScreen());
        } else if (title == 'Configuración general') {
          _navigateTo(const ConfiguracionGeneralScreen());
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightPrimary),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
