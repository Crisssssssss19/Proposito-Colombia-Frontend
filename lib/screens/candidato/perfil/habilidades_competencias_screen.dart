import 'package:flutter/material.dart';
import 'package:swallow_app/config/theme.dart';
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
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar talentos: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _agregarTalento(String nombre, int nivelDominio, int tipo) async {
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) throw Exception('No autorizado');

      final talentoExiste = talentos.any((t) =>
          t['nombreTalento']?.toString().toLowerCase() == nombre.toLowerCase() &&
          t['tipo'] == tipo);

      if (talentoExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Ya tienes ${tipo == 1 ? "la habilidad" : "la competencia"} "$nombre" registrada'),
            backgroundColor: Colors.orange,
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
        final lista = json.decode(responseBuscar.body)['data'] ?? [];
        final talentoEncontrado = lista.firstWhere(
          (t) =>
              t['nombre'].toString().toLowerCase() == nombre.toLowerCase() &&
              t['tipo'] == tipo,
          orElse: () => null,
        );
        if (talentoEncontrado != null) idTalento = talentoEncontrado['id'];
      }

      if (idTalento == null) {
        final responseTalento = await http.post(
          Uri.parse('http://localhost:3210/talentos/crear'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({'nombre': nombre, 'tipo': tipo}),
        );

        if (responseTalento.statusCode == 200 ||
            responseTalento.statusCode == 201) {
          final data = json.decode(responseTalento.body);
          idTalento = data['data']?['id'] ?? data['id'];
        }
      }

      if (idTalento == null) throw Exception('Error creando talento');

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

      if (responseUsuarioTalento.statusCode == 200 ||
          responseUsuarioTalento.statusCode == 201) {
        _fetchTalentos();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${tipo == 1 ? "Habilidad" : "Competencia"} agregada correctamente'),
              backgroundColor: Theme.of(context).colorScheme.primary),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _eliminarTalento(int idUsuarioTalento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar talento'),
        content: const Text('¿Seguro que deseas eliminar este talento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCoral,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();
      if (token == null || userId == null) throw Exception('No autorizado');

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
          SnackBar(
            content: const Text('Talento eliminado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDialogoAgregar() {
    final TextEditingController nombreController = TextEditingController();
    int nivelSeleccionado = 1;
    int tipoSeleccionado = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialog) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Agregar Habilidad o Competencia"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: tipoSeleccionado,
                    decoration: const InputDecoration(labelText: "Tipo"),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text("Habilidad"),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("Competencia"),
                      ),
                    ],
                    onChanged: (v) => setDialog(() => tipoSeleccionado = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: nivelSeleccionado,
                    decoration: const InputDecoration(labelText: "Nivel"),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Básico")),
                      DropdownMenuItem(value: 2, child: Text("Intermedio")),
                      DropdownMenuItem(value: 3, child: Text("Avanzado")),
                    ],
                    onChanged: (v) => setDialog(() => nivelSeleccionado = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (nombreController.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _agregarTalento(nombreController.text.trim(),
                        nivelSeleccionado, tipoSeleccionado);
                  }
                },
                child: const Text("Agregar"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge!.color!;
    final borderColor = theme.dividerColor;

    final habilidades = talentos.where((t) => t['tipo'] == 1).toList();
    final competencias = talentos.where((t) => t['tipo'] == 2).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Habilidades y Competencias",
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (habilidades.isNotEmpty)
                    _buildSection(
                        "Habilidades", Icons.code, habilidades, Colors.blue),
                  if (competencias.isNotEmpty)
                    _buildSection(
                        "Competencias", Icons.people, competencias, Colors.purple),
                  if (talentos.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(Icons.info_outline,
                              size: 50, color: theme.textTheme.bodyMedium!.color),
                          const SizedBox(height: 8),
                          Text(
                            "No tienes habilidades ni competencias registradas",
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium!.color),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _mostrarDialogoAgregar,
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Habilidad o Competencia"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, IconData icon, List list, Color color) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge!.color!;
    final borderColor = theme.dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 10),
        ...list.map((t) => _buildTalentoCard(t, color, borderColor)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTalentoCard(Map<String, dynamic> talento, Color color, Color borderColor) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(talento['nombreTalento'] ?? '',
              style: TextStyle(
                  color: theme.textTheme.bodyLarge!.color,
                  fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getNivelTexto(talento['nivelDominio']),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _eliminarTalento(talento['id']),
          )
        ],
      ),
    );
  }

  String _getNivelTexto(int? nivel) {
    switch (nivel) {
      case 1:
        return "Básico";
      case 2:
        return "Intermedio";
      case 3:
        return "Avanzado";
      default:
        return "Básico";
    }
  }
}
