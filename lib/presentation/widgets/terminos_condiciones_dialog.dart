import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal para mostrar los Términos y Condiciones y Políticas de Privacidad de SysQuest
class TerminosCondicionesDialog extends StatelessWidget {
  const TerminosCondicionesDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const TerminosCondicionesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.doradoCritico, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.doradoCritico.withValues(alpha: 0.25),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          children: [
            // Cabecera
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.superficieElevada),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: AppTheme.doradoCritico, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'TÉRMINOS Y CONDICIONES',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 11,
                        color: AppTheme.doradoCritico,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Contenido con scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'SysQuest — Plataforma Educativa Gamificada',
                      style: TextStyle(
                        color: AppTheme.doradoCritico,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Facultad de Ingeniería, Universidad de Cundinamarca (UDeC)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 16),
                    _SeccionTermino(
                      numero: '1',
                      titulo: 'Naturaleza y Propósito Académico',
                      contenido:
                          'SysQuest es un proyecto integrador desarrollado con fines estrictamente formativos y educativos para la comunidad de Ingeniería de Sistemas y Computación. El servicio ofrece prácticas de refuerzo técnico mediante mecánicas de RPG y generación asistida por Inteligencia Artificial.',
                    ),
                    _SeccionTermino(
                      numero: '2',
                      titulo: 'Uso de Cuentas y Credenciales',
                      contenido:
                          'El usuario se compromete a proporcionar información veraz para el registro y resguardar la seguridad de sus credenciales. SysQuest almacena contraseñas mediante hashing criptográfico robusto y tokens seguros JWT.',
                    ),
                    _SeccionTermino(
                      numero: '3',
                      titulo: 'Generación de Contenido Asistida por IA',
                      contenido:
                          'Las misiones, retos y preguntas técnicas son formulados a través de modelos de lenguaje en la nube (Groq / Gemini) o respaldados por el catálogo curado institucional. El contenido busca simular entornos de resolución técnica real y está sujeto a revisión docente.',
                    ),
                    _SeccionTermino(
                      numero: '4',
                      titulo: 'Privacidad y Protección de Datos',
                      contenido:
                          'Los datos recopilados (progreso, puntuaciones y estadísticas de juego) se emplean exclusivamente con propósitos de seguimiento de aprendizaje y métricas analíticas académicas. Ningún dato será comercializado con terceros.',
                    ),
                    _SeccionTermino(
                      numero: '5',
                      titulo: 'Conducta y Respeto',
                      contenido:
                          'Queda prohibido el intento de vulneración de las APIs del sistema, inyección maliciosa o la suplantación de identidad de docentes o compañeros de estudio.',
                    ),
                  ],
                ),
              ),
            ),
            // Pie con botón de cierre
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.superficieElevada),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.doradoCritico,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Entendido y aceptado',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionTermino extends StatelessWidget {
  final String numero;
  final String titulo;
  final String contenido;

  const _SeccionTermino({
    required this.numero,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$numero. $titulo',
            style: const TextStyle(
              color: AppTheme.verdeVida,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            contenido,
            style: const TextStyle(
              color: AppTheme.azulTexto,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
