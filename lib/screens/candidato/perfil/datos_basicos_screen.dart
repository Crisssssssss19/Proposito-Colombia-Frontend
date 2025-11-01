import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swallow_app/config/paleta_colores.dart';
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
          cargoController.text = perfilData!['profesion'] ?? 'Sin profesión';
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
          nuevaImagen = null;
        });
      } else {
        setState(() {
          nuevaImagen = File(image.path);
          nuevaImagenBytes = null;
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

      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'File',
          bytes,
          filename: image.name,
        ),
      );

      request.fields['favorita'] = 'true';
      request.fields['categoria'] = '1';

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

      if (nombreController.text.trim().isEmpty) {
        throw Exception('El nombre es obligatorio');
      }

      if (apellidoController.text.trim().isEmpty) {
        throw Exception('El apellido es obligatorio');
      }

      if (cedulaController.text.trim().isEmpty) {
        throw Exception('El documento es obligatorio');
      }

      final body = {
        'documento': cedulaController.text.trim(),
        'nombres': nombreController.text.trim(),
        'apellidos': apellidoController.text.trim(),
        'idUbicacion': idUbicacionOriginal,
        'profesion': cargoController.text.trim().isEmpty
            ? null
            : cargoController.text.trim(),
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

  Widget _buildUbicacionInput(bool isDark, ColorScheme colors) {
    final primaryColor = colors.primary;
    final textColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final surfaceColor = isDark ? Colors.grey[800] : Colors.grey[50];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ubicacionController,
          focusNode: ubicacionFocusNode,
          readOnly: !isEditing,
          onChanged: isEditing ? _onUbicacionChanged : null,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isEditing ? backgroundColor : surfaceColor,
            hintText: isEditing ? 'Ej: Bogotá, Medellín...' : null,
            hintStyle: TextStyle(color: secondaryTextColor),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: isEditing
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ubicacionController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear,
                              size: 18, color: secondaryTextColor),
                          onPressed: () {
                            ubicacionController.clear();
                            setState(() {
                              mostrarSugerencias = false;
                              ubicacionesSugeridas = [];
                              idUbicacionOriginal = null;
                            });
                          },
                        ),
                      Icon(Icons.location_on,
                          size: 18, color: secondaryTextColor),
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
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor, width: 2),
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
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
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
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ubicacion['nombre'] ?? 'Sin nombre',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor,
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

      await _actualizarDatosPersonales();
      cambiosRealizados = true;

      await _cargarDatos();

      setState(() {
        isEditing = false;
        nuevaImagen = null;
        nuevaImagenBytes = null;

        if (perfilData != null) {
          nombreController.text = perfilData!['nombres'] ?? '';
          apellidoController.text = perfilData!['apellidos'] ?? '';
          cedulaController.text = perfilData!['documento'] ?? '';
          cargoController.text = perfilData!['profesion'] ?? '';
          ubicacionController.text = perfilData!['ubicacion'] ?? '';
        }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;
    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final surfaceColor = isDark ? Colors.grey[800] : Colors.grey[50];

    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Básicos',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Información personal y profesional',
              style: TextStyle(color: secondaryTextColor, fontSize: 13),
            ),
          ],
        ),
        actions: [
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: textColor),
              onPressed: () {
                setState(() => isEditing = true);
              },
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => isEditing = false);
                    _cargarDatos();
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ),
                TextButton(
                  onPressed: _guardarCambios,
                  child: Text(
                    'Guardar',
                    style: TextStyle(
                      color: primaryColor,
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
                border: Border.all(color: primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt_outlined, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Foto de Perfil',
                        style: TextStyle(
                          color: textColor,
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
                            color: primaryColor.withOpacity(0.1),
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
                                              return Icon(
                                                Icons.person,
                                                size: 45,
                                                color: secondaryTextColor,
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
                                                  color: primaryColor,
                                                ),
                                              );
                                            },
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 45,
                                            color: secondaryTextColor,
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
                                              return Icon(
                                                Icons.person,
                                                size: 45,
                                                color: secondaryTextColor,
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
                                                  color: primaryColor,
                                                ),
                                              );
                                            },
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 45,
                                            color: secondaryTextColor,
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
                                color: primaryColor,
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
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.person_outline,
              title: 'Información Personal',
              isDark: isDark,
              colors: colors,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('Nombres', nombreController,
                      enabled: isEditing, isDark: isDark, colors: colors),
                  const SizedBox(height: 10),
                  _buildInput('Apellidos', apellidoController,
                      enabled: isEditing, isDark: isDark, colors: colors),
                  const SizedBox(height: 10),
                  _buildInput('Número de Cédula', cedulaController,
                      enabled: isEditing, isDark: isDark, colors: colors),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.work_outline,
              title: 'Información Profesional',
              isDark: isDark,
              colors: colors,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('Profesión/Cargo', cargoController,
                      enabled: isEditing, isDark: isDark, colors: colors),
                  const SizedBox(height: 10),
                  _buildUbicacionInput(isDark, colors),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estos datos son utilizados únicamente para procesos de verificación y contacto relacionados con oportunidades laborales. Tu información está protegida según nuestras políticas de privacidad.',
                      style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13.5,
                          height: 1.4),
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
    required bool isDark,
    required ColorScheme colors,
  }) {
    final primaryColor = colors.primary;
    final textColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor,
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

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool enabled = false,
    required bool isDark,
    required ColorScheme colors,
  }) {
    final primaryColor = colors.primary;
    final textColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final surfaceColor = isDark ? Colors.grey[800] : Colors.grey[50];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: !enabled,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? backgroundColor : surfaceColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: enabled
                ? Icon(Icons.edit, size: 18, color: secondaryTextColor)
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
    ubicacionFocusNode.dispose();
    super.dispose();
  }
}
