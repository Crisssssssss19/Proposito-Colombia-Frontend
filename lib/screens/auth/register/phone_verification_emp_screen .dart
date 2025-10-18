import 'package:flutter/material.dart';
import 'package:swallow_app/routes/route_names.dart';
import 'package:swallow_app/widgets/misc/golondrina.dart';
import 'package:provider/provider.dart';
import '../../../providers/pre_register_provider.dart';

class PhoneVerificationEmpScreen extends StatefulWidget {
  const PhoneVerificationEmpScreen({super.key});

  @override
  State<PhoneVerificationEmpScreen> createState() => _PhoneVerificationEmpScreenState();
}

class _PhoneVerificationEmpScreenState extends State<PhoneVerificationEmpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String countryCode = '+57';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1E40), // azul oscuro base
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo
              Golondrina(),

              const Text(
                '¿Puedes darnos tu número telefónico?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Te ayudará a recibir notificaciones importantes y mantener tu cuenta segura',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 25),

              // Campo de número telefónico
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.phone, color: Colors.white70),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF1B2C52),
                        value: countryCode,
                        items: const [
                          DropdownMenuItem(
                            value: '+57',
                            child: Text('+57', style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: '+1',
                            child: Text('+1', style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: '+52',
                            child: Text('+52', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => countryCode = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Número de teléfono',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Se enviará un código de verificación a este número para confirmar que es tuyo y mantener tu cuenta segura',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const Spacer(),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53A7F3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final numero = '${countryCode}${_phoneController.text.trim()}';
                    final preRegistro = context.read<PreRegistroProvider>();
                    final ok = await preRegistro.enviarCodigo(numero);
                    if(ok){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código enviado correctamente')),
                      );
                      Navigator.pushNamed(context, RouteNames.phone_code_emp, arguments: {'countryCode': countryCode, 'phoneNumber': _phoneController.text.trim()},);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(preRegistro.errorMessage ?? 'Error al enviar el código'), backgroundColor: Colors.red,),
                      );
                    }
                  },
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  '← Volver',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
