import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '/../config/theme.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; 

class PerfilFotoScreen extends StatefulWidget {
  const PerfilFotoScreen({super.key});

  @override
  State<PerfilFotoScreen> createState() => _PerfilFotoScreenState();
}

class _PerfilFotoScreenState extends State<PerfilFotoScreen> {
  File? _imagen;
  final ImagePicker _picker = ImagePicker();
  bool _fotoSubida = false;

  // Estados de la vista
  bool _mostrarDatos = false;         // Formación y ubicación (obligatorios)
  bool _mostrarCvKeywords = false;    // CV y Palabras clave (opcionales)

  // ---------- Formación y ubicación (OBLIGATORIOS) ----------
  final _formKey = GlobalKey<FormState>();
  final _habilidadesCtrl = TextEditingController();
  final _competenciasCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();

  bool get _isFormValid =>
      _habilidadesCtrl.text.trim().isNotEmpty &&
      _competenciasCtrl.text.trim().isNotEmpty &&
      _ciudadCtrl.text.trim().isNotEmpty;

  // ---------- CV & Keywords (OPCIONALES) ----------
  String? _cvNombre; 
  String? _cvPath;  
  Uint8List? _cvBytes;  
  final _keywordInputCtrl = TextEditingController();
  final List<String> _keywords = [];

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios del form obligatorio
    _habilidadesCtrl.addListener(_onFormChanged);
    _competenciasCtrl.addListener(_onFormChanged);
    _ciudadCtrl.addListener(_onFormChanged);
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    // Obligatorios
    _habilidadesCtrl.dispose();
    _competenciasCtrl.dispose();
    _ciudadCtrl.dispose();
    // Opcionales
    _keywordInputCtrl.dispose();
    super.dispose();
  }

  // ----------------- Foto -----------------
  Future<void> _seleccionarFoto() async {
    final XFile? imagenSeleccionada =
        await _picker.pickImage(source: ImageSource.gallery);
    if (imagenSeleccionada != null) {
      setState(() {
        _imagen = File(imagenSeleccionada.path);
      });
    }
  }

  void _subirFoto() {
    if (_imagen != null) {
      setState(() => _fotoSubida = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una foto.')),
      );
    }
  }

  // Éxito de foto -> Formación y ubicación
  void _continuar() {
    setState(() {
      _mostrarDatos = true;
      _mostrarCvKeywords = false;
    });
  }

  void _omitirRegistro() {
    Navigator.pushNamedAndRemoveUntil(context, '/home-candidato', (r) => false);
  }

  void _saltarPorAhora() {
    setState(() {
      // Reset total
      _fotoSubida = false;
      _imagen = null;
      _mostrarDatos = false;
      _mostrarCvKeywords = false;

      // Limpiamos todos los campos
      _habilidadesCtrl.clear();
      _competenciasCtrl.clear();
      _ciudadCtrl.clear();
      _cvNombre = null;
      _keywords.clear();
      _keywordInputCtrl.clear();
    });
  }

  // ----------------- Formación y ubicación (OBLIGATORIO) -----------------
  void _continuarDatos() {
    if (_formKey.currentState?.validate() ?? false) {
      // Sin SnackBar: pasamos a CV & Keywords
      setState(() {
        _mostrarCvKeywords = true;
      });
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  // ----------------- CV y Keywords (OPCIONAL) -----------------
  Future<void> _seleccionarCV() async {
  
    if (_cvNombre != null) {
      setState(() {
        _cvNombre = null;
        _cvPath = null;
        _cvBytes = null;
      });
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'PDF'],
      allowMultiple: false,
      withData: kIsWeb, // en mobile no hace falta leer bytes aquí
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty){
        debugPrint('[CV] Selección cancelada');
        return;
      }

      final file = result.files.single;
      debugPrint('[CV] name=${file.name} path=${file.path} bytes=${file.bytes?.length}');

      setState(() {
        _cvNombre = file.name;
        _cvPath = file.path;
        _cvBytes = file.bytes;
      });
    } catch (e, st) {
      debugPrint('[CV] Error al selecionar: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el CV: $e')),
      );
    }
  }

  void _agregarKeywordsDesdeInput() {
    final raw = _keywordInputCtrl.text;
    if (raw.trim().isEmpty) return;

    final nuevos = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Evitar duplicados (case-insensitive)
    for (final k in nuevos) {
      final existe = _keywords.any((x) => x.toLowerCase() == k.toLowerCase());
      if (!existe) _keywords.add(k);
    }
    _keywordInputCtrl.clear();
    setState(() {});
  }

  void _removerKeyword(String k) {
    _keywords.removeWhere((x) => x.toLowerCase() == k.toLowerCase());
    setState(() {});
  }

  void _continuarCvKeywords() {
    // Avance permitido aunque no haya CV ni keywords (son opcionales)
    // TODO: aquí puedes guardar en backend y navegar a la siguiente etapa real.
    Navigator.pushNamedAndRemoveUntil(context, '/home-candidato', (r) => false);
  }

  // ----------------- Atrás paso a paso -----------------
  Future<bool> _handleBack() async {
    if (_mostrarCvKeywords) {
      // CV & Keywords -> Formación y ubicación
      setState(() => _mostrarCvKeywords = false);
      return false;
    } else if (_mostrarDatos) {
      // Formación & Ubicación -> Éxito de foto
      setState(() => _mostrarDatos = false);
      return false;
    } else if (_fotoSubida) {
      // Éxito de foto -> Subir foto
      setState(() => _fotoSubida = false);
      return false;
    } else {
      // Estado inicial -> home
      Navigator.pushNamedAndRemoveUntil(context, '/home-candidato', (r) => false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme; // mantenemos tu tema Light forzado

    // Progreso dinámico según el estado
    double progreso = 0.2;
    String progresoTxt = '20%';
    if (_mostrarDatos && !_mostrarCvKeywords) {
      progreso = 0.4;
      progresoTxt = '40%';
    } else if (_mostrarCvKeywords) {
      progreso = 0.6;
      progresoTxt = '60%';
    }

    return Theme(
      data: theme,
      child: WillPopScope(
        onWillPop: _handleBack,
        child: Scaffold(
          backgroundColor: theme.colorScheme.background,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 100,
            leading: TextButton.icon(
              onPressed: _handleBack,
              icon: const Icon(Icons.arrow_back, color: AppTheme.lightPrimary),
              label: const Text(
                'Atrás',
                style: TextStyle(color: AppTheme.lightPrimary, fontSize: 16),
              ),
            ),
            title: const Text(
              'Progreso del perfil',
              style: TextStyle(
                color: AppTheme.lightPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  progresoTxt,
                  style: const TextStyle(color: AppTheme.lightPrimary, fontSize: 16),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progreso,
                  color: AppTheme.lightPrimary,
                  backgroundColor: const Color(0xFFE5E7EB),
                ),
                const SizedBox(height: 30),
                Image.asset(
                  'assets/images/logo_nombre.png',
                  height: 80,
                  color: AppTheme.lightPrimary,
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(height: 20),

                // =============== ESTADO 1: Subir foto ===============
                if (!_fotoSubida && !_mostrarDatos && !_mostrarCvKeywords) ...[
                  const Text(
                    'Añade tu foto de perfil',
                    style: TextStyle(
                      color: AppTheme.lightPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Una buena foto aumenta tus posibilidades —\npreferible rostro claro y fondo neutro.',
                    style: TextStyle(color: AppTheme.lightTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _seleccionarFoto,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _imagen != null ? FileImage(_imagen!) : null,
                      child: _imagen == null
                          ? const Icon(Icons.person_add_alt_1,
                              color: AppTheme.lightPrimary, size: 40)
                          : null,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _subirFoto,
                    icon: const Icon(Icons.upload),
                    label: const Text('Subir foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _saltarPorAhora,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Saltar por ahora', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _omitirRegistro,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppTheme.accentCoral),
                    ),
                    child: const Text('Omitir registro de aspirante',
                        style: TextStyle(color: AppTheme.accentCoral)),
                  ),

                // =============== ESTADO 2: Foto subida (éxito) ===============
                ] else if (_fotoSubida && !_mostrarDatos && !_mostrarCvKeywords) ...[
                  const Text(
                    '¡Foto subida con éxito!',
                    style: TextStyle(
                      color: AppTheme.lightTextPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Una buena foto aumenta tus posibilidades —\npreferible rostro claro y fondo neutro.',
                    style: TextStyle(color: AppTheme.lightTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imagen != null ? FileImage(_imagen!) : null,
                      ),
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: OutlinedButton(
                      onPressed: _seleccionarFoto,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.lightPrimary),
                        minimumSize: const Size(180, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cambiar foto', style: TextStyle(color: AppTheme.lightPrimary)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _continuar, // pasa a formación/ubicación
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Continuar', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),

                // =============== ESTADO 3: Formación y ubicación (OBLIGATORIO) ===============
                ] else if (_mostrarDatos && !_mostrarCvKeywords) ...[
                  const Text(
                    'Tu formación y ubicación',
                    style: TextStyle(
                      color: AppTheme.lightPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _habilidadesCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Habilidades',
                            hintText: 'Ej. FullStack Developer, Arquitecto de Software',
                            border: OutlineInputBorder(),
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _competenciasCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Competencias',
                            hintText: 'Ej. Trabajo en equipo, gestión de proyecto',
                            border: OutlineInputBorder(),
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ciudadCtrl,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Ciudad, País',
                            hintText: 'Ej. Bogotá, Colombia',
                            border: OutlineInputBorder(),
                          ),
                          validator: _requiredValidator,
                          onFieldSubmitted: (_) {
                            if (_isFormValid) _continuarDatos();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isFormValid ? _continuarDatos : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Continuar'),
                  ),

                // =============== ESTADO 4: CV & Keywords (OPCIONAL) ===============
                ] else ...[
                  const Text(
                    'CV y palabras clave',
                    style: TextStyle(
                      color: AppTheme.lightPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Puedes continuar sin completar estos campos.',
                    style: TextStyle(color: AppTheme.lightTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Subir CV (opcional)',
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _cvNombre ?? 'Ningún archivo seleccionado',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _cvNombre == null ? Colors.grey : theme.colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () { 
                          debugPrint('[CV] onPressed');
                          _seleccionarCV();
                        },
                        icon: Icon(_cvNombre == null ? Icons.attach_file : Icons.close),
                        label: Text(_cvNombre == null ? 'Seleccionar CV' : 'Quitar'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- Keywords ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Palabras clave — opcional',
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _keywordInputCtrl,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Ej. Flutter, Dart, Firebase',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _agregarKeywordsDesdeInput(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _agregarKeywordsDesdeInput,
                        child: const Text('Añadir'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Separa por comas, luego pulsa “Añadir”.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _keywords
                          .map((k) => Chip(
                                label: Text(k),
                                onDeleted: () => _removerKeyword(k),
                              ))
                          .toList(),
                    ),
                  ),

                  const Spacer(),
                  ElevatedButton(
                    onPressed: _continuarCvKeywords, // Siempre habilitado
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Continuar'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

