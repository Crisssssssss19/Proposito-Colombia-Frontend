import 'package:flutter/material.dart';
import '../../../widgets/misc/golondrina.dart';

class RegisterCandidatoScreen extends StatefulWidget {
  const RegisterCandidatoScreen({super.key});

  @override
  State<RegisterCandidatoScreen> createState() => _RegisterCandidatoScreenState();
}

class _RegisterCandidatoScreenState extends State<RegisterCandidatoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _tipoDocCtrl = TextEditingController();
  final TextEditingController _numDocCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _claveCtrl = TextEditingController();
  final TextEditingController _confirmarClaveCtrl = TextEditingController();

  bool _verClave = false;
  bool _verConfirmarClave = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071739),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Golondrina(title: "Registro de Aspirante"),
              const SizedBox(height: 20),
              _buildForm(),
              const SizedBox(height: 20),
              _buildBottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _inputField("Nombre", _nombreCtrl),
          _inputField("Apellido", _apellidoCtrl),
          _inputField("Tipo de documento", _tipoDocCtrl),
          _inputField("Número de documento", _numDocCtrl),
          _inputField("Correo electrónico", _correoCtrl, icon: Icons.email),
          _inputField("Contraseña", _claveCtrl,
              icon: Icons.lock, isPassword: true, showPassword: _verClave, onToggle: () {
            setState(() => _verClave = !_verClave);
          }),
          _inputField("Confirmar contraseña", _confirmarClaveCtrl,
              icon: Icons.lock, isPassword: true, showPassword: _verConfirmarClave, onToggle: () {
            setState(() => _verConfirmarClave = !_verConfirmarClave);
          }),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {IconData? icon, bool isPassword = false, bool showPassword = false, VoidCallback? onToggle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !showPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                  onPressed: onToggle,
                )
              : null,
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Al registrarte, aceptas nuestros Términos y Condiciones y Política de Privacidad",
          style: TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Lógica de registro con backend
              Navigator.pushNamed(context, '/welcome-register', arguments: {'userType': 'candidato'});
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Registrarme como Aspirante", style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("← Volver", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
