import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/services/storage_service.dart';
import 'package:swallow_app/config/paleta_colores.dart';

class EditarPalabrasClaveScreen extends StatefulWidget {
  final List<String> palabrasClaveActuales;

  const EditarPalabrasClaveScreen({
    super.key,
    required this.palabrasClaveActuales,
  });

  @override
  State<EditarPalabrasClaveScreen> createState() =>
      _EditarPalabrasClaveScreenState();
}

class _EditarPalabrasClaveScreenState
    extends State<EditarPalabrasClaveScreen> {
  final TextEditingController _keywordController = TextEditingController();
  late List<String> _keywords;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _keywords = List.from(widget.palabrasClaveActuales);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
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

  void _agregarPalabraClave() {
    final newKeyword = _keywordController.text.trim();
    if (newKeyword.isNotEmpty) {
      final formatted = _formatKeyword(newKeyword);
      if (!_keywords.contains(formatted)) {
        setState(() {
          _keywords.add(formatted);
        });
        _keywordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La palabra clave ya existe.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _eliminarPalabraClave(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  Future<void> _guardarCambios() async {
    bool huboChangios = _keywords.length != widget.palabrasClaveActuales.length ||
        !_keywords.every((k) => widget.palabrasClaveActuales.contains(k));

    if (!huboChangios) {
      Navigator.pop(context, false);
      return;
    }

    if (_keywords.isEmpty && widget.palabrasClaveActuales.isNotEmpty) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirmar'),
          content: const Text(
            '¿Estás seguro de eliminar todas las palabras clave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar todas',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = StorageService();
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no disponibles');
      }

      final response = await http.put(
        Uri.parse('http://localhost:3210/perfil/$userId/palabras-clave'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(_keywords),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _keywords.isEmpty
                    ? 'Palabras clave eliminadas correctamente.'
                    : 'Palabras clave guardadas correctamente.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Error al guardar (${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;
    
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textoPrincipal = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textoSecundario = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final textoTerciario = isDark 
        ? const Color(0xFF7D8CA1)
        : const Color(0xFF667388);
    final fondoAzul2 = isDark 
        ? const Color(0xFF152238) // darkBackgroundSecondary
        : const Color(0xFFE6F0FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textoPrincipal),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Palabras Clave',
          style: TextStyle(
            color: textoPrincipal,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestiona tus habilidades y tecnologías',
                    style: TextStyle(
                      color: textoSecundario,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sección: Agregar nueva palabra clave
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
                        Row(
                          children: [
                            Icon(Icons.add_circle_outline,
                                color: primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Agregar Palabra Clave',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textoPrincipal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nueva habilidad o tecnología',
                          style: TextStyle(
                            color: textoSecundario,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _keywordController,
                                style: TextStyle(color: textoPrincipal),
                                textCapitalization: TextCapitalization.words,
                                onSubmitted: (_) => _agregarPalabraClave(),
                                decoration: InputDecoration(
                                  hintText: 'Ej: React, Python, Diseño UX',
                                  hintStyle: TextStyle(color: textoTerciario),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _agregarPalabraClave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Agregar',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: fondoAzul2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: textoSecundario, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Las palabras clave ayudan a los empleadores a encontrar tu perfil cuando buscan candidatos con habilidades específicas.',
                                  style: TextStyle(
                                    color: textoSecundario,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sección: Mis palabras clave
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.tag,
                                    color: primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Mis Palabras Clave',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textoPrincipal,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_keywords.length}',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _keywords.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.label_off_outlined,
                                        size: 48,
                                        color: textoTerciario,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No hay palabras clave',
                                        style: TextStyle(
                                          color: textoTerciario,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Agrega al menos 3 para mejorar tu perfil',
                                        style: TextStyle(
                                          color: textoTerciario,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _keywords.map((word) {
                                  return Chip(
                                    label: Text(
                                      word,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    onDeleted: () =>
                                        _eliminarPalabraClave(word),
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    side: BorderSide.none,
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón guardar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}