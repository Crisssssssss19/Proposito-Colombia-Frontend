import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swallow_app/services/storage_service.dart';

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

  // Colores oficiales - Aspirante
  static const Color _aspirantePrimario = Color(0xFF1A43FF);
  static const Color _fondoPrincipal = Color(0xFFFFFFFF);
  static const Color _textoPrincipal = Color(0xFF1E293B);
  static const Color _textoSecundario = Color(0xFF475569);
  static const Color _textoTerciario = Color(0xFF667388);
  static const Color _superficie = Color(0xFFFAFAFA);
  static const Color _fondoAzul2 = Color(0xFFE6F0FA);

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
    // Verificar si hubo cambios
    bool huboChangios = _keywords.length != widget.palabrasClaveActuales.length ||
        !_keywords.every((k) => widget.palabrasClaveActuales.contains(k));

    if (!huboChangios) {
      Navigator.pop(context, false);
      return;
    }

    // Confirmar si va a eliminar todas
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
          Navigator.pop(context, true); // true = hubo cambios
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
    return Scaffold(
      backgroundColor: _fondoPrincipal,
      appBar: AppBar(
        backgroundColor: _fondoPrincipal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textoPrincipal),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Palabras Clave',
          style: TextStyle(
            color: _textoPrincipal,
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
                  // Subtítulo
                  Text(
                    'Gestiona tus habilidades y tecnologías',
                    style: TextStyle(
                      color: _textoSecundario,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sección: Agregar nueva palabra clave
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _fondoPrincipal,
                      border: Border.all(color: _aspirantePrimario, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_circle_outline,
                                color: _aspirantePrimario, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Agregar Palabra Clave',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nueva habilidad o tecnología',
                          style: TextStyle(
                            color: _textoSecundario,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _keywordController,
                                style: const TextStyle(color: _textoPrincipal),
                                textCapitalization: TextCapitalization.words,
                                onSubmitted: (_) => _agregarPalabraClave(),
                                decoration: InputDecoration(
                                  hintText: 'Ej: React, Python, Diseño UX',
                                  hintStyle: TextStyle(color: _textoTerciario),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _aspirantePrimario,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _aspirantePrimario,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _agregarPalabraClave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _aspirantePrimario,
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
                            color: _fondoAzul2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: _textoSecundario, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Las palabras clave ayudan a los empleadores a encontrar tu perfil cuando buscan candidatos con habilidades específicas.',
                                  style: TextStyle(
                                    color: _textoSecundario,
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
                      color: _fondoPrincipal,
                      border: Border.all(color: _aspirantePrimario, width: 1),
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
                                    color: _aspirantePrimario, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Mis Palabras Clave',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _textoPrincipal,
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
                                color: _aspirantePrimario.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_keywords.length}',
                                style: TextStyle(
                                  color: _aspirantePrimario,
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
                                        color: _textoTerciario,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No hay palabras clave',
                                        style: TextStyle(
                                          color: _textoTerciario,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Agrega al menos 3 para mejorar tu perfil',
                                        style: TextStyle(
                                          color: _textoTerciario,
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
                                    backgroundColor: _aspirantePrimario,
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

          // Botón guardar (fijo abajo)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _fondoPrincipal,
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
                    backgroundColor: _aspirantePrimario,
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