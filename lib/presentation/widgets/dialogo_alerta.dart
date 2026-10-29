import 'package:flutter/material.dart';
import '../core/design_system/sysquest_theme.dart';
import '../core/design_system/widgets/retro_panel_box.dart';
import '../core/design_system/widgets/retro_pixel_button.dart';
import '../theme/app_theme.dart';

/// Diálogo modal 16-bit retro para alertas y errores en SysQuest
class DialogoAlertaSysQuest extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final IconData icono;
  final Color colorPrimario;
  final String textoBoton;
  final VoidCallback? onAceptar;
  final String? textoBotonSecundario;
  final VoidCallback? onSecundario;

  const DialogoAlertaSysQuest({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.icono = Icons.error_outline,
    this.colorPrimario = AppTheme.rojoDanio,
    this.textoBoton = 'Entendido',
    this.onAceptar,
    this.textoBotonSecundario,
    this.onSecundario,
  });

  static Future<void> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    IconData icono = Icons.error_outline,
    Color colorPrimario = AppTheme.rojoDanio,
    String textoBoton = 'Entendido',
    VoidCallback? onAceptar,
    String? textoBotonSecundario,
    VoidCallback? onSecundario,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => DialogoAlertaSysQuest(
        titulo: titulo,
        mensaje: mensaje,
        icono: icono,
        colorPrimario: colorPrimario,
        textoBoton: textoBoton,
        onAceptar: onAceptar != null
            ? () {
                Navigator.of(ctx).pop();
                onAceptar();
              }
            : () => Navigator.of(ctx).pop(),
        textoBotonSecundario: textoBotonSecundario,
        onSecundario: onSecundario != null
            ? () {
                Navigator.of(ctx).pop();
                onSecundario();
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: RetroPanelBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: SysQuestColors.dungeonVoid,
                    border: Border.all(color: colorPrimario, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: SysQuestColors.shadowBlack,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icono, color: colorPrimario, size: 28),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: SysQuestTypography.h3.copyWith(
                  color: colorPrimario,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: SysQuestTypography.caption.copyWith(
                  color: SysQuestColors.parchmentText,
                  height: 1.5,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 20),
              RetroPixelButton(
                text: textoBoton.toUpperCase(),
                color: colorPrimario,
                textColor: SysQuestColors.dungeonVoid,
                onPressed: onAceptar ?? () => Navigator.of(context).pop(),
              ),
              if (textoBotonSecundario != null) ...[
                const SizedBox(height: 10),
                RetroPixelButton(
                  text: textoBotonSecundario!.toUpperCase(),
                  color: SysQuestColors.stonePanel,
                  textColor: SysQuestColors.parchmentText,
                  onPressed: onSecundario ?? () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
