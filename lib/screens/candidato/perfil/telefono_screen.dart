import 'package:flutter/material.dart';
import '/config/theme.dart';
import '/../screens/candidato/perfil/verificarCódigoScreen.dart';

class TelefonoScreen extends StatefulWidget {
  const TelefonoScreen({Key? key}) : super(key: key);

  @override
  State<TelefonoScreen> createState() =>
      _TelefonoScreenState();
}

enum VerificationStatus { unverified, pending, verified }

class _TelefonoScreenState extends State<TelefonoScreen> {
  VerificationStatus status = VerificationStatus.unverified;
  final TextEditingController telefonoController = 
      TextEditingController(text: '300 123456');

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Text(
                  'Phone-Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )
              ),
              ),

              Container(
                color: Colors.white,
                padding: 
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black,),
                      onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Número de teléfono',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              'Gestiona y verifica tu número de teléfono',
                              style: 
                                    TextStyle(color: Colors.grey, fontSize: 13),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPhoneSection(),
                      const SizedBox(height: 16),
                      _buildWhyVerifySection(),
                      const SizedBox(height: 16),
                      _buildInfoBox(),
                    ],
                  ),
                ),
              ),
          ],
        )),
    );
  }

    Widget _buildPhoneSection() {
    Color borderColor;
    Color? fillColor;
    String? message;
    IconData? icon;
    Color? messageColor;

    switch (status) {
      case VerificationStatus.unverified:
        borderColor = AppTheme.lightPrimary;
        message = null;
        fillColor = Colors.white;
        break;
      case VerificationStatus.pending:
        borderColor = Colors.orange;
        fillColor = Colors.orange.withOpacity(0.05);
        message =
            'Hemos enviado un código de verificación por SMS '
            'a tu número de teléfono revisa tus mensajes';
        messageColor = Colors.orange;
        icon = Icons.info_outline;
        break;
      case VerificationStatus.verified:
        borderColor = Colors.green;
        fillColor = Colors.green.withOpacity(0.05);
        message = 'Teléfono verificado correctamente';
        messageColor = Colors.green[800];
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
        color: fillColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Número de Teléfono',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Número de contacto',
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: telefonoController,
            readOnly: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildStatusTag(),
              ),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 100),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildActionButtons(),
          if (message != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(icon, color: messageColor, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    message!,
                    style: TextStyle(
                        color: messageColor, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTag() {
    switch (status) {
      case VerificationStatus.unverified:
        return const Text('Sin verificar',
            style: TextStyle(color: Colors.grey, fontSize: 12));
      case VerificationStatus.pending:
        return const Text('Pendiente',
            style: TextStyle(color: Colors.orange, fontSize: 12));
      case VerificationStatus.verified:
        return const Text('Verificado',
            style: TextStyle(color: Colors.green, fontSize: 12));
    }
  }

  Widget _buildActionButtons() {
    switch (status) {
      case VerificationStatus.unverified:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send, color: Colors.white, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                status = VerificationStatus.pending;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Código de verificación enviado por SMS'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            label: const Text(
              'Verificar Teléfono',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

      case VerificationStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código reenviado'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Reenviar',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(width: 8),
Expanded(
  child: ElevatedButton(
    onPressed: () async {
      // Navegamos y esperamos el resultado
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const VerificarCodigoScreen(),
        ),
      );

      // Si la pantalla devolvió 'true', actualizamos el estado a verificado
      if (verified == true) {
        setState(() {
          status = VerificationStatus.verified;
        });
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: const Text(
      'Ya recibí el código',
      style: TextStyle(color: Colors.white),
    ),
  ),
),


          ],
        );

      case VerificationStatus.verified:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWhyVerifySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightPrimary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.black),
              SizedBox(width: 8),
              Text(
                '¿Por qué verificar tu teléfono?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Recibe notificaciones importantes sobre ofertas laborales por SMS.\n'
            '• Permite que los empleadores te contacten directamente.\n'
            '• Mejora la seguridad de tu cuenta con verificación en dos pasos.\n'
            '• Aumenta la credibilidad ante empleadores.',
            style: TextStyle(
              color: Color.fromARGB(255, 61, 61, 61),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightPrimary),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tu número de teléfono es utilizado únicamente para procesos de verificación y contacto relacionados con oportunidades laborales. '
              'Tu información está protegida según nuestras políticas de privacidad.',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}