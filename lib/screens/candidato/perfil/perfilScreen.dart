import 'package:flutter/material.dart';
import 'package:swallow_app/screens/candidato/perfil/configuracion_general_screen.dart';
import '/../config/theme.dart';
import '/../screens/candidato/perfil/datos_basicos_screen.dart';
import '/../screens/candidato/perfil/correo_electronico_screen.dart';
import '/../screens/candidato/perfil/telefono_screen.dart';
import '/../screens/candidato/perfil/MiCVScreen.dart';
import '/../screens/candidato/perfil/habilidades_competencias_screen.dart';
import '/../screens/candidato/perfil/portafolioScreen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static final GlobalKey<NavigatorState> perfilNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      /* appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ), */
      // 👇 Navigator interno para manejar las rutas dentro de Perfil
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

class PerfilMainContent extends StatelessWidget {
  const PerfilMainContent({super.key});

  @override
  Widget build(BuildContext context) {
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
                      children: const [
                        Text(
                          'Ana María González',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Desarrolladora Frontend',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Bogotá, Colombia',
                          style: TextStyle(color: Colors.grey),
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
                        _showEditKeywordsDialog(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ---- Chips ----
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    Chip(label: Text('HTML5')),
                    Chip(label: Text('CSS3')),
                    Chip(label: Text('JavaScript (ES6+)')),
                    Chip(label: Text('TypeScript')),
                    Chip(label: Text('React')),
                    Chip(label: Text('Responsive Design')),
                    Chip(label: Text('SEO On-Page')),
                  ],
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
      } else if (title == 'Mi CV'){
        _navigateTo(const MiCVScreen());
      } else if (title == 'Competencia y habilidades'){
        _navigateTo(const CompetenciasScreen());
      } else if (title == 'Portafolio'){
        _navigateTo(const PortafolioScreen());
      } else if (title == 'Configuración general'){
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

  void _showEditKeywordsDialog(BuildContext context) {
    final TextEditingController keywordController = TextEditingController();
    final List<String> keywords = [
      'HTML5',
      'CSS3',
      'JavaScript (ES6+)',
      'TypeScript',
      'React',
      'Responsive Design',
      'Web Accessibility (A11Y)',
      'SEO On-Page',
      'DOM Manipulation',
    ];

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
                              hintStyle: TextStyle(
                                  color: AppTheme.lightTextSecondary),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: AppTheme.lightPrimary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add_circle,
                              color: AppTheme.lightPrimary, size: 32),
                          onPressed: () {
                            final newKeyword = keywordController.text.trim();
                            if (newKeyword.isNotEmpty &&
                                !keywords.contains(newKeyword)) {
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
                            backgroundColor:
                                AppTheme.lightSecondary.withOpacity(0.2),
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
