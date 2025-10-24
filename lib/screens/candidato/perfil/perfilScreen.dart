import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    // 🔹 Obtén el token y el ID guardados al iniciar sesión
    final token = await storage.getToken();
    final userId = await storage.getUserId();

    if (token == null || userId == null) {
      throw Exception('Token o ID de usuario no disponibles');
    }

    // 🔹 Llama al backend con el token
    final response = await http.get(
      Uri.parse('http://localhost:3210/perfil/$userId/completo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        perfilData = decoded['data'];
        isLoading = false;
      });
    } else {
      throw Exception('Error al obtener perfil (${response.statusCode})');
    }
  } catch (e) {
    print('❌ Error cargando perfil: $e');
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (perfilData == null) {
      return const Center(
        child: Text('No se pudo cargar la información del perfil.'),
      );
    }

    final nombre = '${perfilData!['nombres']} ${perfilData!['apellidos']}';
    final ubicacion = perfilData!['ubicacion'] ?? 'Ubicación no disponible';
    final palabrasClave = (perfilData!['palabrasClave'] as List?)?.map((e) => e['nombre']).toList() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Perfil',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🔷 CUADRO PRINCIPAL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.lightPrimary, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completar perfil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Completar perfil',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '75%',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.75,
                    color: AppTheme.lightPrimary,
                    backgroundColor: Colors.grey,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Datos usuario ----
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          'Desarrolladora Frontend', // Temporal
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          ubicacion,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ---- Palabras clave + botón editar ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '# Palabras Claves',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        _showEditKeywordsDialog(context, palabrasClave);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ---- Chips ----
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: palabrasClave.isNotEmpty
                      ? palabrasClave.map((e) => Chip(label: Text(e))).toList()
                      : [const Text('Sin palabras clave')],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 🔹 OPCIONES DE PERFIL ABAJO
          _buildProfileOption('Datos básicos', context),
          _buildProfileOption('Correo electrónico', context),
          _buildProfileOption('Número de teléfono', context),
          _buildProfileOption('Mi CV', context),
          _buildProfileOption('Competencia y habilidades', context),
          _buildProfileOption('Portafolio', context),
          _buildProfileOption('Configuración general', context),
          _buildProfileOption('Cerrar sesión', context),
        ],
      ),
    );
  }

  Widget _buildProfileOption(String title, BuildContext context) {
    void _navigateTo(Widget screen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = PerfilScreen.perfilNavigatorKey.currentState;
        (navigator ?? Navigator.of(context)).push(
          MaterialPageRoute(builder: (_) => screen),
        );
      });
    }

    return InkWell(
      onTap: () {
        if (title == 'Datos básicos') {
          _navigateTo(const DatosBasicosScreen());
        } else if (title == 'Correo electrónico') {
          _navigateTo(const CorreoElectronicoScreen());
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
          border: Border.all(color: AppTheme.lightPrimary, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _showEditKeywordsDialog(BuildContext context, List<dynamic> currentKeywords) {
    final TextEditingController keywordController = TextEditingController();
    final List<String> keywords = List<String>.from(currentKeywords);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              title: const Center(
                child: Text(
                  'Editar Palabras Clave',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Agrega o elimina palabras clave que describan tus habilidades técnicas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Agregar nueva palabra clave',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: keywordController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Ej: Node.js',
                              hintStyle: TextStyle(color: AppTheme.lightTextSecondary),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppTheme.lightPrimary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: AppTheme.lightPrimary, size: 32),
                          onPressed: () {
                            final newKeyword = keywordController.text.trim();
                            if (newKeyword.isNotEmpty && !keywords.contains(newKeyword)) {
                              setState(() {
                                keywords.add(newKeyword);
                              });
                              keywordController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Palabras clave actuales (${keywords.length})',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.lightPrimary),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: keywords.map((word) {
                          return Chip(
                            label: Text(word),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                keywords.remove(word);
                              });
                            },
                            backgroundColor: AppTheme.lightSecondary.withOpacity(0.2),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightPrimary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Guardar y cerrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
