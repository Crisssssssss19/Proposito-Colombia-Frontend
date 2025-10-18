import 'dart:async';
import 'package:flutter/material.dart';
import 'package:swallow_app/widgets/misc/golondrina.dart';
import 'package:swallow_app/routes/route_names.dart';
import 'package:provider/provider.dart';
import '../../../providers/pre_register_provider.dart';

class PhoneCodeCanScreen extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;
  const PhoneCodeCanScreen({super.key, required this.countryCode, required this.phoneNumber});

  @override
  State<PhoneCodeCanScreen> createState() => _PhoneCodeCanScreenState();
}

class _PhoneCodeCanScreenState extends State<PhoneCodeCanScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  late Timer _timer;
  int _secondsRemaining = 34;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _enteredCode =>
      _controllers.map((c) => c.text).join();

  Future<void> _verifyCode() async {
    if (_enteredCode.length == 6) {
      final codigo = _enteredCode;
      final numero = '${widget.countryCode}${widget.phoneNumber}';
      final preRegistro = context.read<PreRegistroProvider>();

      final ok = await preRegistro.validarCodigo(numero, codigo);
      if(ok){
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código verificado correctamente ✅')),
        );
        Navigator.pushNamed(context, RouteNames.registerCandidato, arguments: {'phoneNumber': numero},);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(preRegistro.errorMessage ?? 'Error al verificar el código'), backgroundColor: Colors.red,),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa los 6 dígitos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1E40),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),

              // 🕊️ Logo
              Golondrina(),

              const Text(
                'Verifica tu número de teléfono',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF53A7F3),
                child: const Icon(Icons.phone, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),

              const Text(
                'Enviamos un código de 6 dígitos a:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              const Text(
                '+57 3001234567',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Ingresa el código para continuar',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 🔢 Cajas de código OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _controllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white10,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF53A7F3)),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              // 🟦 Botón verificar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Verificar código',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: _canResend
                    ? () {
                        setState(() {
                          _secondsRemaining = 34;
                          _canResend = false;
                        });
                        _startTimer();
                      }
                    : null,
                child: Text(
                  _canResend
                      ? 'Reenviar código'
                      : 'Reenviar código en 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _canResend
                        ? Colors.lightBlueAccent
                        : Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
