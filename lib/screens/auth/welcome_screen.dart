import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../routes/route_names.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF1E90FF), Color(0xFF4B0082)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Image.asset(
                  'assets/images/logo_nombre.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                '¿Cómo deseas continuar?',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Botón Iniciar sesión
              _UserTypeCard(
                icon: Icons.person,
                title: 'Iniciar sesión',
                subtitle: '¿Ya tienes una cuenta?',
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    RouteNames.login,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Botón registrarse
              _UserTypeCard(
                icon: Icons.business,
                title: 'Registrarse',
                subtitle: '¿Eres nuevo aquí?',
                color: AppTheme.accentYellow,
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    RouteNames.selectUserType,
                  );
                },
              ),

              const Spacer(),

              // Footer
              Text(
                'Powered by @CIEUniMagdalena2025',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}