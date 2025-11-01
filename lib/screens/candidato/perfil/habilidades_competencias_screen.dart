import 'package:flutter/material.dart';
import 'package:swallow_app/config/paleta_colores.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/services/storage_service.dart';

class CompetenciasScreen extends StatefulWidget {
  const CompetenciasScreen({super.key});

  @override
  State<CompetenciasScreen> createState() => _CompetenciasScreenState();
}

class _CompetenciasScreenState extends State<CompetenciasScreen> {
  List<Map<String, dynamic>> talentos = [];
  bool isLoading = true;
  final storage = StorageService();

  @override
  void initState() {
    super.initState();
    _fetchTalentos();
  }

  Future<void> _fetchTalentos() async {
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      final response = await http.get(
        Uri.parse('http://localhost:3210/usuarios_talentos/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          talentos = List<Map<String, dynamic>>.from(decoded['data'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener talentos (${response.statusCode})');
      }
    } catch (e) {
      print('Error cargando talentos: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _agregarTalento(String nombre, int nivelDominio, int tipo) async {
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      final talentoExiste = talentos.any((t) => 
        t['nombreTalento']?.toString().toLowerCase() == nombre.toLowerCase() &&
        t['tipo'] == tipo
      );

      if (talentoExiste){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ya tienes ${tipo == 1 ? "la habilidad" : "la competencia"} "$nombre" registrada',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      int? idTalento;

      final responseBuscar = await http.get(
        Uri.parse('http://localhost:3210/talentos/listar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (responseBuscar.statusCode == 200) {
        final talentosExistentes = json.decode(responseBuscar.body);
        final List<dynamic> listaTalentos = talentosExistentes['data'] ?? [];

        final talentoEncontrado = listaTalentos.firstWhere(
          (talento) => talento['nombre'].toString().toLowerCase() == nombre.toLowerCase() && talento['tipo'] == tipo,
          orElse: () => null,
        );

        if (talentoEncontrado != null) {
          idTalento = talentoEncontrado['id'];
        }
      }

      if (idTalento == null) {
        final responseTalento = await http.post(
          Uri.parse('http://localhost:3210/talentos/crear'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'nombre': nombre,
            'tipo': tipo,
          }),
        );

        if (responseTalento.statusCode == 200 || responseTalento.statusCode == 201) {
          if (responseTalento.body.isNotEmpty) {
            final talentoCreado = json.decode(responseTalento.body);
            idTalento = talentoCreado['data']?['id'] ?? talentoCreado['id'];
          }
        } else {
          final decode = json.decode(responseTalento.body);
          throw Exception(decode['message'] ?? 'Error al crear talento');
        }

        if (idTalento == null) {
          throw Exception('No se pudo obtener el ID del talento creado');
        }
      }

      final responseUsuarioTalento = await http.post(
        Uri.parse('http://localhost:3210/usuarios_talentos/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'idTalento': idTalento,
          'nivelDominio': nivelDominio,
        }),
      );

      if (responseUsuarioTalento.statusCode == 200 || responseUsuarioTalento.statusCode == 201) {
        _fetchTalentos();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tipo == 1 ? "Habilidad" : "Competencia"} agregada correctamente')),
        );
      } else {
        final decoded = json.decode(responseUsuarioTalento.body);
        throw Exception(decoded['message'] ?? 'Error al asociar talento al usuario');
      }
    } catch (e) {
      print('❌ Error agregando talento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _eliminarTalento(int idUsuarioTalento) async {
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();
    
      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      final response = await http.delete(
        Uri.parse('http://localhost:3210/usuarios_talentos/$userId/$idUsuarioTalento'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _fetchTalentos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Talento eliminado')),
        );
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Error al eliminar talento');
      }
    } catch (e) {
      print('Error eliminando talento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _editarTalento(int idUsuarioTalento, int nivelDominio) async {
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      final response = await http.put(
        Uri.parse('http://localhost:3210/usuarios_talentos/$userId/$idUsuarioTalento'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nivelDominio': nivelDominio, 
        }),
      );

      if (response.statusCode == 200) {
        _fetchTalentos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Talento actualizado')),
        );
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Error al editar talento');
      }
    } catch (e) {
      print('Error editando talento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatearNombreTalento(String nombre) {
    if (nombre.isEmpty) return nombre;
    
    final acronimos = {
      'html', 'css', 'js', 'xml', 'json', 'api', 'rest', 'sql', 
      'nosql', 'aws', 'gcp', 'ios', 'ui', 'ux', 'seo', 'npm',
      'http', 'https', 'php', 'asp', 'mvc', 'sass', 'scss'
    };
    
    final nombreLower = nombre.toLowerCase().trim();
    
    if (acronimos.contains(nombreLower)) {
      return nombreLower.toUpperCase();
    }
    
    if (nombre.contains('.')) {
      return nombre.split('.').map((part) {
        if (part.isEmpty) return part;
        return part[0].toUpperCase() + part.substring(1).toLowerCase();
      }).join('.');
    }
    
    return nombre[0].toUpperCase() + nombre.substring(1).toLowerCase();
  }

  void _mostrarDialogoAgregar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;
    
    final TextEditingController nombreController = TextEditingController();
    int nivelSeleccionado = 1;
    int tipoSeleccionado = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Agregar Habilidad o Competencia',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: tipoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.code, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text('Habilidad'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(Icons.people, color: Colors.purple, size: 20),
                              SizedBox(width: 8),
                              Text('Competencia'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          tipoSeleccionado = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nombreController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: tipoSeleccionado == 1 
                            ? 'Ej: React, Python, HTML'
                            : 'Ej: Liderazgo, Comunicación',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        helperText: 'Usa mayúsculas para acrónimos (HTML, CSS, API)',
                        helperStyle: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      value: nivelSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Nivel de dominio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Básico')),
                        DropdownMenuItem(value: 2, child: Text('Intermedio')),
                        DropdownMenuItem(value: 3, child: Text('Avanzado')),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          nivelSeleccionado = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    String nombre = nombreController.text.trim();
                    if (nombre.isNotEmpty) {
                      nombre = _formatearNombreTalento(nombre);
                      Navigator.pop(context);
                      _agregarTalento(nombre, nivelSeleccionado, tipoSeleccionado);
                    }
                  },
                  child: const Text('Agregar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoEditar(Map<String, dynamic> talento) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;
    
    int nivelSeleccionado = talento['nivelDominio'] ?? 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Editar ${talento['tipo'] == 1 ? "Habilidad" : "Competencia"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: nivelSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Nivel',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Básico')),
                      DropdownMenuItem(value: 2, child: Text('Intermedio')),
                      DropdownMenuItem(value: 3, child: Text('Avanzado')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        nivelSeleccionado = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nivelSeleccionado != talento['nivelDominio']) {
                      Navigator.pop(context);
                      _editarTalento(talento['id'], nivelSeleccionado);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor selecciona un nivel diferente'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarOpcionesTalento(Map<String, dynamic> talento) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: primaryColor),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoEditar(talento);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar'),
                onTap: () {
                  Navigator.pop(context);
                  _eliminarTalento(talento['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getNivelTexto(int nivel) {
    switch (nivel) {
      case 1:
        return 'Básico';
      case 2:
        return 'Intermedio';
      case 3:
        return 'Avanzado';
      default:
        return 'Básico';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;
    
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final backgroundSecondary = isDark 
        ? const Color(0xFF152238) 
        : const Color(0xFFE6F0FA);
    final textoPrincipal = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textoSecundario = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundSecondary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Habilidades Y Competencias",
            style: TextStyle(
              color: textoPrincipal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final habilidades = talentos.where((t) => t['tipo'] == 1).toList();
    final competencias = talentos.where((t) => t['tipo'] == 2).toList();
    final totalTalentos = talentos.length;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundSecondary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Habilidades y competencias",
          style: TextStyle(
            color: textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Gestiona tus habilidades y competencias",
              textAlign: TextAlign.center,
              style: TextStyle(color: textoSecundario, fontSize: 14),
            ),
            const SizedBox(height: 20),

            if (habilidades.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.code, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Habilidades',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textoPrincipal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...habilidades.map((h) => _buildTalentoCard(h, textoPrincipal, textoSecundario, primaryColor, Colors.blue)),
              const SizedBox(height: 20),
            ],

            if (competencias.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Competencias',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textoPrincipal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...competencias.map((c) => _buildTalentoCard(c, textoPrincipal, textoSecundario, primaryColor, Colors.purple)),
              const SizedBox(height: 20),
            ],

            if (talentos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: textoSecundario),
                    const SizedBox(height: 8),
                    Text(
                      'No tienes habilidades ni competencias registradas',
                      style: TextStyle(color: textoSecundario),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            InkWell(
              onTap: _mostrarDialogoAgregar,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.add, color: primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Agregar habilidad o competencia",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Añade una nueva habilidad o competencia",
                      style: TextStyle(color: textoSecundario, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(totalTalentos.toString(), "Total", primaryColor, primaryColor, textoPrincipal),
                _buildStatCard(habilidades.length.toString(), "Habilidades", Colors.blue, primaryColor, textoPrincipal),
                _buildStatCard(competencias.length.toString(), "Competencias", Colors.purple, primaryColor, textoPrincipal),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tip profesional",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textoPrincipal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Las habilidades son conocimientos específicos (ej: React, Python). Las competencias son cualidades personales (ej: Liderazgo, Comunicación).",
                          style: TextStyle(color: textoSecundario, fontSize: 13),
                        ),
                      ],
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

  Widget _buildTalentoCard(
    Map<String, dynamic> talento,
    Color textoPrincipal,
    Color textoSecundario,
    Color borderColor,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  talento['nombreTalento'] ?? 'Sin nombre',
                  style: TextStyle(
                    color: textoPrincipal,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getNivelTexto(talento['nivelDominio'] ?? 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.more_vert, color: textoSecundario),
                onPressed: () => _mostrarOpcionesTalento(talento),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String number,
    String label,
    Color numberColor,
    Color borderColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                color: numberColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}