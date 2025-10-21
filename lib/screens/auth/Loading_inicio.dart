import 'package:flutter/material.dart';
import '../../routes/route_names.dart';
import '../../widgets/misc/golondrina.dart';
import '../../widgets/misc/progress_bar.dart';

class LoadingInicioScreen extends StatefulWidget {
  const LoadingInicioScreen({super.key});

  @override
  State<LoadingInicioScreen> createState() => _LoadingInicioScreenState();
}

class _LoadingInicioScreenState extends State<LoadingInicioScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Golondrina(
                    title: 'Volando hacia\nnuevas oportunidades',
                  ),
                  SizedBox(height: 20),
                  CustomProgressBar(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Image.asset(
              'assets/images/from_md.png',
              width: 210,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}