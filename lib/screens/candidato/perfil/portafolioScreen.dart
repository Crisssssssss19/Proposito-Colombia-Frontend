import 'package:flutter/material.dart';
import '/config/theme.dart';

class PortafolioScreen extends StatelessWidget {
  const PortafolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorAzulCielo = Colors.blue;
    final colorAzulOscuro = const Color(0xFF0A1F44);
    final colorVerde = const Color(0xFF00A86B);
    final colorFondoImagen = const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Portafolio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.camera_alt_outlined, color: Colors.blueAccent, size: 28),
            const SizedBox(height: 8),
            const Text(
              "Muestra tus mejores proyectos y trabajos realizados",
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ====== PROYECTOS ======
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 0.72, // más compacto
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildProyectoCard("App Móvil de Finanzas", "Diseño UI/UX completo", "Mobile", colorFondoImagen, colorAzulCielo),
                _buildProyectoCard("Dashboard Analytics", "Interfaz web responsive", "Web", colorFondoImagen, colorAzulCielo),
                _buildProyectoCard("Sistema E-commerce", "Desarrollo full-stack", "Full-Stack", colorFondoImagen, colorAzulCielo),
                _buildProyectoCard("Identidad Corporativa", "Branding y logotipos", "Diseño", colorFondoImagen, colorAzulCielo),
              ],
            ),

            const SizedBox(height: 20),

            // ====== AGREGAR NUEVO PROYECTO ======
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorAzulCielo),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.add, color: Colors.blueAccent, size: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Agregar nuevo proyecto",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Sube imágenes y detalles de tu trabajo",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ====== ESTADÍSTICAS ======
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("4", "Proyectos", colorAzulOscuro, colorAzulCielo),
                _buildStatCard("3", "Categorías", colorVerde, colorAzulCielo),
                _buildStatCard("24", "Visualizaciones", colorAzulCielo, colorAzulCielo, tituloFontSize: 11),
              ],
            ),

            const SizedBox(height: 16),

            // ====== BOTONES ======
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOutlinedButton(Icons.edit, "Editar portafolio", colorAzulCielo),
                _buildOutlinedButton(Icons.share_outlined, "Compartir", colorAzulCielo),
              ],
            ),

            const SizedBox(height: 20),

            // ====== TIP PROFESIONAL ======
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorAzulCielo),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Recomendación",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Mantén tu portafolio actualizado con tus proyectos más recientes y destacados para mostrar tu evolución profesional.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ====== TARJETA DE PROYECTO ======
  Widget _buildProyectoCard(String titulo, String subtitulo, String etiqueta, Color colorFondo, Color colorBorde) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorBorde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área gris (simula imagen)
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: colorFondo,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, color: Colors.grey, size: 36),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 4),
                Text(subtitulo, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(etiqueta,
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const Icon(Icons.remove_red_eye_outlined, color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ====== TARJETAS DE ESTADÍSTICAS ======
Widget _buildStatCard(
  String numero,
  String titulo,
  Color colorTexto,
  Color colorBorde, {
  double tituloFontSize = 12, // <-- nuevo parámetro opcional
}) {
  return Container(
    width: 105,
    decoration: BoxDecoration(
      border: Border.all(color: colorBorde),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        Text(
          numero,
          style: TextStyle(
            color: colorTexto,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          maxLines: 1,                    // <-- evita salto
          overflow: TextOverflow.ellipsis, // <-- si no alcanza, agrega "…"
          style: TextStyle(
            color: Colors.black54,
            fontSize: tituloFontSize,      // <-- usa el tamaño recibido
          ),
        ),
      ],
    ),
  );
}

  // ====== BOTONES BLANCOS CON BORDE AZUL ======
  Widget _buildOutlinedButton(IconData icon, String texto, Color bordeColor) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: bordeColor, width: 1.5),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: Icon(icon, color: Colors.black, size: 18),
      label: Text(
        texto,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
