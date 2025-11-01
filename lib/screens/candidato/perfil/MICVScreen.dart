import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/config/paleta_colores.dart';
import 'package:swallow_app/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swallow_app/core/utils/file_download.dart';

class MiCVScreen extends StatefulWidget {
  const MiCVScreen({super.key});

  @override
  State<MiCVScreen> createState() => _MiCVScreenState();
}

class _MiCVScreenState extends State<MiCVScreen> {
  final storage = StorageService();
  bool isLoading = true;
  Map<String, dynamic>? cvActual;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null).then((_) {
      _cargarCV();
    });
  }

  Future<void> _cargarCV() async {
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('http://localhost:3210/usuarios/$userId/archivos/verArchivos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> archivos = decoded['data'] ?? [];

        setState(() {
          cvActual = archivos.isNotEmpty ? archivos.last : null;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error cargando CV: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _seleccionarYSubirCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      final file = result.files.first;

      if (file.size > 5 * 1024 * 1024) {
        _mostrarError('El archivo es muy grande. Máximo 5MB.');
        return;
      }

      setState(() => isLoading = true);

      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('No hay sesión activa');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3210/usuarios/$userId/archivos/subir'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _cargarCV();
        _mostrarExito('CV actualizado correctamente');
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
      } else {
        throw Exception('Error al subir el CV (${response.statusCode})');
      }
    } catch (e) {
      print('Error subiendo CV: $e');
      _mostrarError('Error al subir el CV: ${e.toString().replaceFirst('Exception: ', '')}');
      setState(() => isLoading = false);
    }
  }

  Future<void> _descargarCV() async {
    if (cvActual == null) return;

    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();
      if (token == null || userId == null) throw Exception('No hay sesión activa');

      final archivoId = cvActual!['id'];
      final nombreArchivo = cvActual!['nombrePublico'] ?? 'CV.pdf';
      final url = 'http://localhost:3210/usuarios/$userId/archivos/$archivoId/descargar';

      if (kIsWeb) {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          downloadFileWeb(bytes, nombreArchivo);
          _mostrarExito('Descarga iniciada en el navegador');
        } else {
          _mostrarError('Error al descargar el archivo');
        }
        return;
      }

      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _mostrarError('Permiso de almacenamiento denegado');
          return;
        }
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('No se pudo obtener el directorio');
      }

      final filePath = '${directory.path}/$nombreArchivo';
      await dio.download(url, filePath);
      
      _mostrarExito('Descargado: $nombreArchivo');

      final abrir = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Descarga completa'),
          content: Text('¿Deseas abrir $nombreArchivo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Abrir'),
            ),
          ],
        ),
      );

      if (abrir == true) {
        await OpenFile.open(filePath);
      }
    } catch (e) {
      print('Error descargando CV: $e');
      _mostrarError('Error al descargar el CV');
    }
  }

  void _verCV() async {
    if (cvActual == null) return;

    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();
      final archivoId = cvActual!['id'];
      final url = 'http://localhost:3210/usuarios/$userId/archivos/$archivoId/ver';
      final nombreArchivo = cvActual!['nombrePublico'] ?? 'CV.pdf';

      if (kIsWeb) {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          openFileWeb(bytes, 'application/pdf');
          _mostrarExito('Mostrando CV...');
        } else {
          _mostrarError('Error al abrir el archivo');
        }
        return;
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$nombreArchivo';

      await dio.download(url, filePath);
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error al abrir PDF: $e');
      _mostrarError('Error al abrir el PDF');
    }
  }

  String _formatFecha(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) return 'Fecha desconocida';
    try {
      final regex = RegExp(r'^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})');
      final match = regex.firstMatch(fechaStr);
      if (match == null) return 'Fecha desconocida';

      final cleaned = match.group(1)!;
      final fecha = DateTime.parse(cleaned).toLocal();

      return DateFormat('d \'de\' MMMM, yyyy', 'es').format(fecha);
    } catch (e) {
      print('Error parseando fecha: $fechaStr ($e)');
      return 'Fecha desconocida';
    }
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;
    
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textoPrincipal = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textoSecundario = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[300];

    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(isDark, textoPrincipal),
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isDark, textoPrincipal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              "Gestiona tu currículum vitae",
              style: TextStyle(
                color: textoSecundario,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),

            if (cvActual != null)
              _buildCVCard(isDark, primaryColor, textoPrincipal, textoSecundario)
            else
              _buildNoCVCard(isDark, textoPrincipal, textoSecundario, borderColor!),

            const SizedBox(height: 25),

            _buildActionButtons(isDark, primaryColor, textoPrincipal),

            const SizedBox(height: 25),

            _buildRecommendationCard(isDark, primaryColor, textoPrincipal, textoSecundario),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, Color textColor) {
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        "Mi CV",
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildCVCard(
    bool isDark,
    Color primaryColor,
    Color textoPrincipal,
    Color textoSecundario,
  ) {
    final nombreArchivo = cvActual!['nombrePublico'] ?? 'CV.pdf';
    final tamanio = cvActual!['tamanio'] ?? 'Tamaño desconocido';
    final fechaSubida = cvActual!['fechaSubida'];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf,
            color: Colors.redAccent,
            size: 40,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreArchivo,
                  style: TextStyle(
                    color: textoPrincipal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  fechaSubida != null
                      ? 'Subido el ${_formatFecha(fechaSubida)}'
                      : 'Fecha no disponible',
                  style: TextStyle(color: textoSecundario),
                ),
                const SizedBox(height: 3),
                Text(
                  '$tamanio · PDF',
                  style: TextStyle(color: textoSecundario),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _verCV,
            icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
            label: const Text("Ver"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNoCVCard(
    bool isDark,
    Color textoPrincipal,
    Color textoSecundario,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.upload_file, size: 60, color: textoSecundario),
          const SizedBox(height: 10),
          Text(
            'No has subido tu CV',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textoPrincipal,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Sube tu currículum para postularte a ofertas',
            textAlign: TextAlign.center,
            style: TextStyle(color: textoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    bool isDark,
    Color primaryColor,
    Color textoPrincipal,
  ) {
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _seleccionarYSubirCV,
            icon: const Icon(Icons.upload_file),
            label: Text(cvActual != null ? "Actualizar CV" : "Subir CV"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (cvActual != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _descargarCV,
              icon: const Icon(Icons.download),
              label: const Text("Descargar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textoPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecommendationCard(
    bool isDark,
    Color primaryColor,
    Color textoPrincipal,
    Color textoSecundario,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primaryColor, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recomendación",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Mantén tu CV actualizado para mejorar tus oportunidades de encontrar el trabajo ideal. Formato PDF, máximo 5MB.",
                  style: TextStyle(
                    color: textoSecundario,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}