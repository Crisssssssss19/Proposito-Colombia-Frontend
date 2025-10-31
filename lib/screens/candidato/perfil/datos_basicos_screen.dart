import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/../config/theme.dart';
import 'package:swallow_app/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class DatosBasicosScreen extends StatefulWidget {
  const DatosBasicosScreen({Key? key}) : super(key: key);

  @override
  State<DatosBasicosScreen> createState() => _DatosBasicosScreenState();
}

class _DatosBasicosScreenState extends State<DatosBasicosScreen> {
  final storage = StorageService();
  final ImagePicker _picker = ImagePicker();
  File? nuevaImagen;
  Uint8List? nuevaImagenBytes;
  String? token;
  List<Map<String, dynamic>> ubicacionesSugeridas = [];
  bool mostrarSugerencias = false;
  final FocusNode ubicacionFocusNode = FocusNode();

  Map<String, dynamic>? perfilData;
  List<Map<String, dynamic>> imagenes = [];
  String? imagenFavoritaUrl;
  bool isLoading = true;
  bool isEditing = false;

  int? idUbicacionOriginal;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController cargoController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final fetchedToken = await storage.getToken();
      final userId = await storage.getUserId();

      if (fetchedToken == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      token = fetchedToken;

      final perfilResponse = await http.get(
        Uri.parse('http://localhost:3210/perfil/$userId/completo'),
        headers: {
          'Authorization': 'Bearer $fetchedToken',
          'Content-Type': 'application/json',
        },
      );

      if (perfilResponse.statusCode == 200) {
        final decoded = json.decode(perfilResponse.body);
        setState(() {
          perfilData = decoded['data'];
          nombreController.text = perfilData!['nombres'] ?? '';
          apellidoController.text = perfilData!['apellidos'] ?? '';
          cedulaController.text = perfilData!['documento'] ?? '';
          cargoController.text = perfilData!['HabilidadPrincipal'] ?? '';
          ubicacionController.text = perfilData!['ubicacion'] ?? '';

          imagenFavoritaUrl = perfilData!['fotoPerfil'];

          imagenes =
              List<Map<String, dynamic>>.from(perfilData!['imagenes'] ?? []);

          isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _seleccionarImagen() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(source: source);

      if (image == null) return;

      // Para web, leer los bytes de la imagen
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          nuevaImagenBytes = bytes;
          nuevaImagen = null; // Limpiar File para web
        });
      } else {
        setState(() {
          nuevaImagen = File(image.path);
          nuevaImagenBytes = null; // Limpiar bytes para móvil
        });
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _subirImagen(XFile image) async {
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3210/usuarios/$userId/imagenes/subir'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Leer los bytes de la imagen (funciona para web y móvil)
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'File',
          bytes,
          filename: image.name,
        ),
      );

      request.fields['favorita'] = 'true'; // ← Marcar como favorita
      request.fields['categoria'] = '1'; // ← 1 = PERFIL

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _cargarDatos();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error subiendo imagen: $e');
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

  void _onUbicacionChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        mostrarSugerencias = false;
        ubicacionesSugeridas = [];
      });
      return;
    }

    if (value.length < 3) {
      setState(() {
        mostrarSugerencias = false;
        ubicacionesSugeridas = [];
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3210/api/ubicacion/buscar?nombre=$value'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List ubicaciones = data['datos'] ?? [];
        setState(() {
          ubicacionesSugeridas = ubicaciones
              .map<Map<String, dynamic>>((u) => {
                    'id': u['idUbicacion'],
                    'nombre': u['nombreUbicacion'],
                  })
              .toList();
          mostrarSugerencias = ubicacionesSugeridas.isNotEmpty;
        });
      } else {
        setState(() {
          mostrarSugerencias = false;
          ubicacionesSugeridas = [];
        });
      }
    } catch (e) {
      setState(() {
        mostrarSugerencias = false;
        ubicacionesSugeridas = [];
      });
    }
  }

  void _seleccionarUbicacion(int id, String nombre) {
    setState(() {
      ubicacionController.text = nombre;
      idUbicacionOriginal = id;
      mostrarSugerencias = false;
      ubicacionesSugeridas = [];
    });
    ubicacionFocusNode.unfocus();
  }

  Future<void> _actualizarDatosPersonales() async {
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      // Validaciones básicas
      if (nombreController.text.trim().isEmpty) {
        throw Exception('El nombre es obligatorio');
      }

      if (apellidoController.text.trim().isEmpty) {
        throw Exception('El apellido es obligatorio');
      }

      if (cedulaController.text.trim().isEmpty) {
        throw Exception('El documento es obligatorio');
      }

      // Construir el body
      final body = {
        'documento': cedulaController.text.trim(),
        'nombres': nombreController.text.trim(),
        'apellidos': apellidoController.text.trim(),
        'idUbicacion': idUbicacionOriginal,
      };

      final response = await http.patch(
        Uri.parse('http://localhost:3210/usuarios/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Datos actualizados correctamente');
      } else {
        String errorMsg = 'Error al actualizar datos';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData['message'] ?? errorMsg;
        } catch (e) {
          errorMsg = 'Error ${response.statusCode}';
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Error actualizando datos: $e');
      rethrow;
    }
  }

  Widget _buildUbicacionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ubicacionController,
          focusNode: ubicacionFocusNode,
          readOnly: !isEditing,
          onChanged: isEditing ? _onUbicacionChanged : null,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isEditing ? Colors.white : Colors.grey[50],
            hintText: isEditing ? 'Ej: Bogotá, Medellín...' : null,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.lightPrimary),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.lightPrimary, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: isEditing
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ubicacionController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: Colors.grey),
                          onPressed: () {
                            ubicacionController.clear();
                            setState(() {
                              mostrarSugerencias = false;
                              ubicacionesSugeridas = [];
                              idUbicacionOriginal = null;
                            });
                          },
                        ),
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                    ],
                  )
                : null,
          ),
        ),
        if (mostrarSugerencias && ubicacionesSugeridas.isNotEmpty && isEditing)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.lightPrimary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: ubicacionesSugeridas.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[300],
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final ubicacion = ubicacionesSugeridas[index];
                  return InkWell(
                    onTap: () {
                      _seleccionarUbicacion(
                        ubicacion['id'] as int,
                        ubicacion['nombre'] as String,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.lightPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ubicacion['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _guardarCambios() async {
    try {
      bool cambiosRealizados = false;

      // 1. Actualizar foto si cambió
      if (nuevaImagen != null || nuevaImagenBytes != null) {
        XFile? xfile;
        if (kIsWeb && nuevaImagenBytes != null) {
          xfile = XFile.fromData(
            nuevaImagenBytes!,
            name: 'profile_image.jpg',
          );
        } else if (nuevaImagen != null) {
          xfile = XFile(nuevaImagen!.path);
        }

        if (xfile != null) {
          await _subirImagen(xfile);
          cambiosRealizados = true;
        }
      }

      // 2. Actualizar datos personales
      await _actualizarDatosPersonales();
      cambiosRealizados = true;

      // 3. Recargar datos
      await _cargarDatos();

      setState(() {
        isEditing = false;
        nuevaImagen = null;
        nuevaImagenBytes = null;
      });

      if (cambiosRealizados && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cambios guardados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error guardando cambios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
        actions: [
          // Botón cambia entre Editar y Guardar
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
              onPressed: () {
                setState(() => isEditing = true);
              },
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // Cancelar y recargar datos originales
                    setState(() => isEditing = false);
                    _cargarDatos();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: _guardarCambios,
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: AppTheme.lightPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightPrimary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          color: AppTheme.lightPrimary),
                      const SizedBox(width: 8),
                      const Text(
                        'Foto de Perfil',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: isEditing ? _seleccionarImagen : null,
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 90,
                            height: 90,
                            color: AppTheme.lightSecondary.withOpacity(0.3),
                            child: kIsWeb
                                ? (nuevaImagenBytes != null
                                    ? Image.memory(
                                        nuevaImagenBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : (imagenFavoritaUrl != null &&
                                            imagenFavoritaUrl!.isNotEmpty)
                                        ? Image.network(
                                            imagenFavoritaUrl!,
                                            fit: BoxFit.cover,
                                            headers: {
                                              'Authorization':
                                                  'Bearer ${token ?? ""}',
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'Error cargando imagen: $error');
                                              return const Icon(
                                                Icons.person,
                                                size: 45,
                                                color: Colors.grey,
                                              );
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                  strokeWidth: 2,
                                                  color: AppTheme.lightPrimary,
                                                ),
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 45,
                                            color: Colors.grey,
                                          ))
                                : (nuevaImagen != null
                                    ? Image.file(
                                        nuevaImagen!,
                                        fit: BoxFit.cover,
                                      )
                                    : (imagenFavoritaUrl != null &&
                                            imagenFavoritaUrl!.isNotEmpty)
                                        ? Image.network(
                                            imagenFavoritaUrl!,
                                            fit: BoxFit.cover,
                                            headers: {
                                              'Authorization':
                                                  'Bearer ${token ?? ""}',
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'Error cargando imagen: $error');
                                              return const Icon(
                                                Icons.person,
                                                size: 45,
                                                color: Colors.grey,
                                              );
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                  strokeWidth: 2,
                                                  color: AppTheme.lightPrimary,
                                                ),
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 45,
                                            color: Colors.grey,
                                          )),
                          ),
                        ),
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.lightPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEditing ? 'Toca para cambiar' : '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // INFORMACIÓN PERSONAL
            _buildSection(
              icon: Icons.person_outline,
              title: 'Información Personal',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('Nombres', nombreController, enabled: isEditing),
                  const SizedBox(height: 10),
                  _buildInput('Apellidos', apellidoController,
                      enabled: isEditing),
                  const SizedBox(height: 10),
                  _buildInput('Número de Cédula', cedulaController,
                      enabled: isEditing),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // INFORMACIÓN PROFESIONAL
            _buildSection(
              icon: Icons.work_outline,
              title: 'Información Profesional',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('Profesión/Cargo', cargoController,
                      enabled: false),
                  const SizedBox(height: 10),
                  _buildUbicacionInput(), 
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TEXTO INFORMATIVO
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightPrimary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estos datos son utilizados únicamente para procesos de verificación y contacto relacionados con oportunidades laborales. Tu información está protegida según nuestras políticas de privacidad.',
                      style: TextStyle(
                          color: Colors.grey[800], fontSize: 13.5, height: 1.4),
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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

  Widget _buildInput(String label, TextEditingController controller,
      {bool enabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: !enabled,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.lightPrimary),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.lightPrimary, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: enabled
                ? const Icon(Icons.edit, size: 18, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    cedulaController.dispose();
    cargoController.dispose();
    ubicacionController.dispose();
    super.dispose();
  }
}
