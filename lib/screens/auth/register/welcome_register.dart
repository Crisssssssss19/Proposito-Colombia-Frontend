import 'package:flutter/material.dart';
import '../../../widgets/misc/golondrina.dart';

class WelcomeRegisterScreen extends StatelessWidget {
  final String userType;

  const WelcomeRegisterScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071739),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Golondrina(title: "¡Bienvenido a Swallow!"),
            const SizedBox(height: 20),
            const Text(
              "Volando hacia\nnuevas oportunidades",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (userType == "empresa") {
                  Navigator.pushNamed(context, '/home-empresa');
                } else {
                  Navigator.pushNamed(context, '/home-candidato');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Continuar", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
