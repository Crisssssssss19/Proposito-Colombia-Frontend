import 'package:flutter/material.dart';
import '/config/theme.dart';

class CompetenciasScreen extends StatelessWidget {
  const CompetenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textPrimary = AppTheme.lightTextPrimary;
    final Color textSecondary = AppTheme.lightTextSecondary;
    final Color borderColor = AppTheme.lightSecondary; // azul cielo

    final List<Map<String, String>> competencias = [
      {"nombre": "Comunicación efectiva", "nivel": "Avanzado"},
      {"nombre": "Liderazgo de equipos", "nivel": "Intermedio"},
      {"nombre": "Gestión de proyectos", "nivel": "Avanzado"},
      {"nombre": "Análisis de datos", "nivel": "Intermedio"},
      {"nombre": "Trabajo en equipo", "nivel": "Avanzado"},
      {"nombre": "Resolución de problemas", "nivel": "Intermedio"},
      {"nombre": "Adaptabilidad", "nivel": "Básico"},
      {"nombre": "Pensamiento crítico", "nivel": "Intermedio"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.lightBackgroundSecondary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.lightPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Competencias Y Habilidades",
          style: TextStyle(
            color: AppTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Gestiona tus habilidades profesionales y niveles de dominio",
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Lista de competencias
            ...competencias.map((c) => _buildCompetenciaCard(c, textPrimary, borderColor)),

            const SizedBox(height: 16),

            // Botón Agregar nueva competencia
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightSecondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.add, color: AppTheme.lightPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Agregar nueva competencia",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Añade una nueva habilidad a tu perfil profesional",
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("8", "Total Competencias", AppTheme.lightPrimary, borderColor),
                _buildStatCard("3", "Nivel Avanzado", AppTheme.success, borderColor),
              ],
            ),

            const SizedBox(height: 16),

            // Tip profesional
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tip profesional",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mantén actualizadas tus competencias y agrega nuevas habilidades según evoluciona tu carrera profesional.",
                          style: TextStyle(color: textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetenciaCard(Map<String, String> c, Color textPrimary, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(c["nombre"]!, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  c["nivel"]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert, color: AppTheme.lightTextSecondary),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, Color numberColor, Color borderColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                color: numberColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppTheme.lightTextSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
