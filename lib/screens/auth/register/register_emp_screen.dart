import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/misc/golondrina.dart';
import '../../../routes/route_names.dart';

class RegisterEmpresaScreen extends StatefulWidget {
  final String phoneNumber;
  const RegisterEmpresaScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<RegisterEmpresaScreen> createState() => _RegisterEmpresaScreenState();
}

class _RegisterEmpresaScreenState extends State<RegisterEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _claveCtrl = TextEditingController();
  final TextEditingController _confirmarClaveCtrl = TextEditingController();

  bool _verClave = false;
  bool _verConfirmarClave = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
              if (authProvider.isLoading)
                const CircularProgressIndicator(color: Colors.white),
              if (!authProvider.isLoading)
                _buildBottomButtons(context, authProvider),
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

  Widget _buildBottomButtons(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final telefono = widget.phoneNumber;
              final ok = await authProvider.register(
                nombres: _nombreCtrl.text.trim(),
                apellidos: "XXX_EMPRESA",
                correoAcceso: _correoCtrl.text.trim(),
                claveAcceso: _claveCtrl.text.trim(),
                telefono: telefono,
                isEmpresa: true,
              );

              if (ok) {
                Navigator.pushNamed(context, RouteNames.welcome_register,
                    arguments: {'userType': 'empresa'});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(authProvider.errorMessage ?? 'Error')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Registrarme como Empresa"),
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
