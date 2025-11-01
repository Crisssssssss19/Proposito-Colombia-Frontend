import 'package:flutter/material.dart';
import 'package:swallow_app/config/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:swallow_app/services/storage_service.dart';

class PortafolioScreen extends StatefulWidget {
  const PortafolioScreen({super.key});

  @override
  State<PortafolioScreen> createState() => _PortafolioScreenState();
}

class _PortafolioScreenState extends State<PortafolioScreen> {
  List<dynamic> _imagenes = [];
  bool _isLoading = true;
  String? token;
  int? userId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarImagenes();
  }

  Future<void> _cargarImagenes() async {
    try {
      final storage = StorageService();
      final fetchedToken = await storage.getToken();
      final fetchedUserId = await storage.getUserId();

      if (fetchedToken == null || fetchedUserId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      token = fetchedToken;
      userId = fetchedUserId;

      final response = await http.get(
        Uri.parse(
            'http://localhost:3210/usuarios/$userId/imagenes/verPortafolio'),
        headers: {
          'Authorization': 'Bearer $fetchedToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          _imagenes = decoded['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar imágenes (${response.statusCode})');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar imágenes: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _agregarImagen() async {
    if (_imagenes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Has alcanzado el límite de 5 imágenes en tu portafolio'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3210/usuarios/$userId/imagenes/subir'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      final bytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'File',
          bytes,
          filename: image.name,
        ),
      );

      request.fields['favorita'] = 'false';
      request.fields['categoria'] = '2';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await _cargarImagenes();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Imagen agregada correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        throw Exception('Error al subir imagen: ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _eliminarImagen(int idImagen) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta imagen?'),
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

    if (confirmar != true) return;

    try {
      setState(() => _isLoading = true);

      final response = await http.delete(
        Uri.parse('http://localhost:3210/usuarios/$userId/imagenes/$idImagen'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _cargarImagenes();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Imagen eliminada'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception('Error al eliminar');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color textPrimary = theme.textTheme.bodyLarge!.color!;
    final Color borderColor = theme.dividerColor;
    final Color background = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Portafolio',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarImagenes,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Icon(Icons.camera_alt_outlined,
                        color: theme.colorScheme.primary, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      "Muestra tus mejores proyectos y trabajos realizados",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium!.color,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    _imagenes.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.photo_library_outlined,
                                    size: 80,
                                    color: theme.textTheme.bodyMedium!.color),
                                const SizedBox(height: 16),
                                Text(
                                  'No tienes imágenes en tu portafolio',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium!.color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _imagenes.length,
                            itemBuilder: (context, index) {
                              final imagen = _imagenes[index];
                              return _buildProyectoCard(
                                  imagen, borderColor, textPrimary);
                            },
                          ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: _agregarImagen,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.add_circle_outline,
                                color: theme.colorScheme.primary, size: 30),
                            const SizedBox(height: 10),
                            Text(
                              _imagenes.length >= 5
                                  ? "Límite alcanzado (5/5)"
                                  : "Agregar nuevo proyecto (${_imagenes.length}/5)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Sube imágenes y detalles de tu trabajo",
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium!.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProyectoCard(dynamic imagen, Color borderColor, Color textColor) {
    final imageUrl = imagen['url'] ?? '';
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    headers: {'Authorization': 'Bearer ${token ?? ""}'},
                  )
                : Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_outlined,
                        color: Colors.grey, size: 36),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              imagen['nombrePublico'] ?? 'Sin nombre',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
