import 'package:flutter/material.dart';
import 'package:swallow_app/config/paleta_colores.dart';
import 'package:swallow_app/screens/candidato/perfil/datos_basicos_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/correo_electronico_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/telefono_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/MiCVScreen.dart';
import 'package:swallow_app/screens/candidato/perfil/habilidades_competencias_screen.dart';
import 'package:swallow_app/screens/candidato/perfil/portafolioScreen.dart';
import 'package:swallow_app/screens/candidato/perfil/editar_palabras_clave_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/services/storage_service.dart';
import 'package:swallow_app/screens/candidato/perfil/cambiar_contraseña_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static final GlobalKey<NavigatorState> perfilNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
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
  String? token;

  @override
  void initState() {
    super.initState();
    _fetchPerfilData();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatKeyword(String text) {
    final siglas = {
      'html',
      'css',
      'sql',
      'api',
      'ui',
      'ux',
      'rest',
      'oop',
      'js',
      'c#',
      'c++'
    };

    final lower = text.toLowerCase();

    if (siglas.contains(lower)) {
      return lower.toUpperCase();
    }

    return _capitalize(lower);
  }

  double _calcularProgresoPerfil() {
    if (perfilData == null) return 0.0;

    int camposCompletados = 0;
    int totalCampos = 11;

    if (perfilData!['nombres'] != null &&
        perfilData!['nombres'].toString().isNotEmpty) {
      camposCompletados++;
    }

    if (perfilData!['apellidos'] != null &&
        perfilData!['apellidos'].toString().isNotEmpty) {
      camposCompletados++;
    }

    if (perfilData!['email'] != null &&
        perfilData!['email'].toString().isNotEmpty) {
      camposCompletados++;
    }

    if (perfilData!['telefono'] != null &&
        perfilData!['telefono'].toString().isNotEmpty) {
      camposCompletados++;
    }

    if (perfilData!['ubicacion'] != null &&
        perfilData!['ubicacion'].toString().isNotEmpty &&
        perfilData!['ubicacion'] != 'Ubicación no disponible') {
      camposCompletados++;
    }

    if (perfilData!['fotoPerfil'] != null &&
        perfilData!['fotoPerfil'].toString().isNotEmpty) {
      camposCompletados++;
    }

    if (perfilData!['profesion'] != null &&
        perfilData!['profesion'].toString().isNotEmpty &&
        perfilData!['profesion'] != 'Sin profesión') {
      camposCompletados++;
    }

    final palabrasClave = perfilData!['palabrasClave'] as List?;
    if (palabrasClave != null && palabrasClave.length >= 3) {
      camposCompletados++;
    }

    final habilidades = perfilData!['habilidades'] as List?;
    if (habilidades != null && habilidades.length >= 2) {
      camposCompletados++;
    }

    final archivos = perfilData!['archivos'] as List?;
    if (archivos != null && archivos.isNotEmpty) {
      camposCompletados++;
    }

    final imagenes = perfilData!['imagenes'] as List?;
    if (imagenes != null && imagenes.length >= 3) {
      camposCompletados++;
    }

    return camposCompletados / totalCampos;
  }

  Future<void> _fetchPerfilData() async {
    try {
      final storage = StorageService();
      final fetchedToken = await storage.getToken();
      final userId = await storage.getUserId();

      if (fetchedToken == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      token = fetchedToken;

      final response = await http.get(
        Uri.parse('http://localhost:3210/perfil/$userId/completo'),
        headers: {
          'Authorization': 'Bearer $fetchedToken',
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
      print(' Error cargando perfil: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;

    // Colores según el tema
    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textoPrincipal =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textoSecundario =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final textoTerciario = isDark
        ? const Color(0xFF7D8CA1) // darkTextTertiary
        : const Color(0xFF667388); // lightTextTertiary
    final surfaceColor = isDark
        ? const Color(0xFF1E293B) // darkSurface
        : Colors.grey[300];

    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (perfilData == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'No se pudo cargar el perfil.',
            style: TextStyle(color: textoPrincipal),
          ),
        ),
      );
    }

    final nombre = '${perfilData!['nombres']} ${perfilData!['apellidos']}';
    final ubicacion = perfilData!['ubicacion'] ?? 'Ubicación no disponible';
    final palabrasClave = (perfilData!['palabrasClave'] as List?)
            ?.where((e) => e != null && e['textoPalabraClave'] != null)
            .map((e) => _formatKeyword(e['textoPalabraClave'] as String))
            .toList() ??
        [];
    final profesion = perfilData!['profesion'] ?? 'Sin profesión';
    final fotoPerfil = perfilData!['fotoPerfil'];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchPerfilData,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textoPrincipal,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // CUADRO PRINCIPAL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Completar perfil
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completar perfil',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textoSecundario,
                          ),
                        ),
                        Text(
                          '${(_calcularProgresoPerfil() * 100).toInt()}%',
                          style: TextStyle(
                            color: textoPrincipal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _calcularProgresoPerfil(),
                        color: primaryColor,
                        backgroundColor: surfaceColor,
                        minHeight: 8,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Datos usuario
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: Container(
                            width: 70,
                            height: 70,
                            color: surfaceColor,
                            child: (fotoPerfil != null && fotoPerfil.isNotEmpty)
                                ? Image.network(
                                    fotoPerfil,
                                    fit: BoxFit.cover,
                                    headers: {
                                      'Authorization': 'Bearer ${token ?? ""}',
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 35,
                                        color: textoTerciario,
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          color: primaryColor,
                                        ),
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 35,
                                    color: textoTerciario,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textoPrincipal,
                                ),
                              ),
                              Text(
                                profesion,
                                style: TextStyle(color: textoSecundario),
                              ),
                              Text(
                                ubicacion,
                                style: TextStyle(color: textoSecundario),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Palabras clave + botón editar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '# Palabras Claves',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textoPrincipal,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditarPalabrasClaveScreen(
                                  palabrasClaveActuales: palabrasClave,
                                ),
                              ),
                            );

                            if (result == true) {
                              _fetchPerfilData();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: primaryColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Editar',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: palabrasClave.isNotEmpty
                          ? palabrasClave
                              .map((e) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      e,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList()
                          : [
                              Text(
                                'Sin palabras clave',
                                style: TextStyle(color: textoTerciario),
                              )
                            ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // OPCIONES DE PERFIL
              _buildProfileOption(
                  'Datos básicos', context, primaryColor, textoPrincipal),
              _buildProfileOption(
                  'Correo electrónico', context, primaryColor, textoPrincipal),
              _buildProfileOption(
                  'Número de teléfono', context, primaryColor, textoPrincipal),
              _buildProfileOption(
                  'Cambiar contraseña', context, primaryColor, textoPrincipal),
              _buildProfileOption(
                  'Mi CV', context, primaryColor, textoPrincipal),
              _buildProfileOption('Competencia y habilidades', context,
                  primaryColor, textoPrincipal),
              _buildProfileOption(
                  'Portafolio', context, primaryColor, textoPrincipal),
              _buildProfileOption(
                  'Eliminar cuenta', context, primaryColor, textoPrincipal),
              _buildProfileOption(
                  'Cerrar sesión', context, primaryColor, textoPrincipal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    String title,
    BuildContext context,
    Color borderColor,
    Color textColor,
  ) {
    final correo =
        perfilData!['email'] ?? perfilData!['correoAcceso'] ?? 'Sin correo';

    void _navigateTo(Widget screen) async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final navigator = PerfilScreen.perfilNavigatorKey.currentState;

        await (navigator ?? Navigator.of(context)).push(
          MaterialPageRoute(builder: (_) => screen),
        );

        if (title == 'Datos básicos' ||
            title == 'Competencia y habilidades' ||
            title == 'Portafolio' ||
            title == 'Mi CV') {
          _fetchPerfilData();
        }
      });
    }

    return InkWell(
      onTap: () {
        if (title == 'Datos básicos') {
          _navigateTo(const DatosBasicosScreen());
        } else if (title == 'Correo electrónico') {
          _navigateTo(CorreoElectronicoScreen(email: correo));
        } else if (title == 'Número de teléfono') {
          _navigateTo(const TelefonoScreen());
        } else if (title == 'Cambiar contraseña') {
          _navigateTo(const CambiarContrasenaScreen());
        } else if (title == 'Mi CV') {
          _navigateTo(const MiCVScreen());
        } else if (title == 'Competencia y habilidades') {
          _navigateTo(const CompetenciasScreen());
        } else if (title == 'Portafolio') {
          _navigateTo(const PortafolioScreen());
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
