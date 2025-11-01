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
      print('Error cargando imágenes: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar imágenes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _agregarImagen() async {
    if (_imagenes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Has alcanzado el límite de 5 imágenes en tu portafolio'),
          backgroundColor: Colors.red,
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

      // Lee los bytes de la imagen
      final bytes = await image.readAsBytes();

      // Crea el MultipartFile desde bytes (funciona en web y móvil)
      request.files.add(
        http.MultipartFile.fromBytes(
          'File',
          bytes,
          filename: image.name, // Nombre del archivo
        ),
      );

      request.fields['favorita'] = 'false';
      request.fields['categoria'] = '2'; // PORTAFOLIO

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await _cargarImagenes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen agregada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al subir imagen: ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error al subir imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarImagen(int idImagen) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: const Text(
          '¿Estás seguro de eliminar esta imagen?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen eliminada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        throw Exception('Error al eliminar');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error al eliminar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorAzulCielo = AppTheme.lightPrimary;
    final colorVerde = const Color(0xFF00A86B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Portafolio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarImagenes,
              color: AppTheme.lightPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Icon(Icons.camera_alt_outlined,
                        color: Colors.blueAccent, size: 28),
                    const SizedBox(height: 8),
                    const Text(
                      "Muestra tus mejores proyectos y trabajos realizados",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    //  PROYECTOS
                    _imagenes.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: const [
                                Icon(Icons.photo_library_outlined,
                                    size: 80, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No tienes imágenes en tu portafolio',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
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
                              childAspectRatio:
                                  0.65, // Ajustado para el nuevo diseño
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _imagenes.length,
                            itemBuilder: (context, index) {
                              final imagen = _imagenes[index];
                              return _buildProyectoCard(imagen, colorAzulCielo);
                            },
                          ),

                    const SizedBox(height: 20),

                    //  AGREGAR NUEVO PROYECTO
                    GestureDetector(
                      onTap: _agregarImagen,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colorAzulCielo),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EAF6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.add,
                                  color: Colors.blueAccent, size: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _imagenes.length >= 5
                                  ? "Límite alcanzado (5/5)"
                                  : "Agregar nuevo proyecto (${_imagenes.length}/5)",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Sube imágenes y detalles de tu trabajo",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ESTADÍSTICAS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                            "${_imagenes.length}",
                            "Imágenes de\nproyectos",
                            colorVerde,
                            colorAzulCielo),
                        _buildStatCard("5", "Máximo de\nfotos", colorAzulCielo,
                            colorAzulCielo),
                      ],
                    ),

                    const SizedBox(height: 20),

                    //  TIP PROFESIONAL
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorAzulCielo),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.blue, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Recomendación",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Mantén tu portafolio actualizado con tus proyectos más recientes y destacados para mostrar tu evolución profesional.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

// TARJETA DE PROYECTO
  Widget _buildProyectoCard(dynamic imagen, Color colorBorde) {
    final imageUrl = imagen['url'] ?? '';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorBorde),
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
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    headers: {'Authorization': 'Bearer ${token ?? ""}'},
                    errorBuilder: (context, error, stackTrace) {
                      print('Error cargando imagen: $error');
                      return Container(
                        height: 110,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            size: 36, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 110,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    height: 110,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_outlined,
                        size: 36, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _limpiarNombreImagen(imagen['nombrePublico'] ?? 'Sin nombre'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  imagen['tamanio'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),

                // Fila con etiqueta y botón de ver
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.label,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (imagen['tipo'] ?? '')
                                    .split('/')
                                    .last
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Botón de ver
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.visibility_outlined,
                            color: Colors.black87, size: 18),
                        onPressed: () => _verImagenCompleta(imageUrl),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        tooltip: 'Ver imagen',
                      ),
                    ),

                    // Botón de eliminar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                        onPressed: () => _eliminarImagen(imagen['id']),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        tooltip: 'Eliminar imagen',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Limpia el nombre de la imagen quitando "scaled_" y la extensión
  String _limpiarNombreImagen(String nombre) {
    String nombreLimpio = nombre;

    // Quita "scaled_" del inicio
    if (nombreLimpio.startsWith('scaled_')) {
      nombreLimpio = nombreLimpio.substring(7);
    }

    // Quita la extensión (.png, .jpg, .jpeg, etc.)
    final extensiones = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'];
    for (var ext in extensiones) {
      if (nombreLimpio.toLowerCase().endsWith(ext)) {
        nombreLimpio =
            nombreLimpio.substring(0, nombreLimpio.length - ext.length);
        break;
      }
    }

    return nombreLimpio;
  }

// Muestra la imagen en tamaño completo
  void _verImagenCompleta(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  headers: {'Authorization': 'Bearer ${token ?? ""}'},
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Error al cargar la imagen'),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//  TARJETAS DE ESTADÍSTICAS
  Widget _buildStatCard(
      String numero, String titulo, Color colorTexto, Color colorBorde) {
    return Container(
      width: 140, // Aumentado para el texto más largo
      decoration: BoxDecoration(
        border: Border.all(color: colorBorde),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            numero,
            style: TextStyle(
                color: colorTexto, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  //  BOTONES 
  Widget _buildOutlinedButton(
      IconData icon, String texto, Color bordeColor, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: bordeColor, width: 1.5),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: Icon(icon, color: Colors.black, size: 18),
      label: Text(texto, style: const TextStyle(color: Colors.black)),
    );
  }
}
