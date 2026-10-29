import 'package:flutter/material.dart';
import '../sysquest_theme.dart';

/// Botón con estética pixel art de 16 bits, respuesta física de pulsado (4px)
/// y sombra dura negra ajustable de 6px a 2px.
class RetroPixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final String? leadingSpriteFile;
  final double? height;
  final double? width;
  final bool enabled;

  const RetroPixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = SysQuestColors.stonePanel,
    this.textColor = SysQuestColors.parchmentText,
    this.leadingSpriteFile,
    this.height = 48.0,
    this.width,
    this.enabled = true,
  });

  @override
  State<RetroPixelButton> createState() => _RetroPixelButtonState();
}

class _RetroPixelButtonState extends State<RetroPixelButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  String _resolveSpritePath(String sprite) {
    if (sprite.startsWith('assets/')) return sprite;
    if (sprite.startsWith('frames/')) return 'assets/sprites/$sprite';
    return 'assets/sprites/frames/$sprite';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.height == null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final buttonHeight =
              (constraints.maxHeight - 6.0).clamp(24.0, double.infinity);
          return _buildButton(buttonHeight, constraints.maxHeight);
        },
      );
    }
    return _buildButton(widget.height!, widget.height! + 6.0);
  }

  Widget _buildButton(double buttonHeight, double totalHeight) {
    final effectiveColor =
        widget.enabled ? widget.color : SysQuestColors.disabledGray;

    return SizedBox(
      width: widget.width,
      height: totalHeight,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 1. Sombra dura negra en la base (6px estática)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: buttonHeight,
              child: Container(
                color: SysQuestColors.shadowBlack,
              ),
            ),

            // 2. Cara frontal del botón (baja 4px al presionar, reduciendo sombra a 2px)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              top: _isPressed ? 4.0 : 0.0,
              left: 0,
              right: 0,
              height: buttonHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: effectiveColor,
                  border: Border.all(
                    color: SysQuestColors.borderBlack,
                    width: 3,
                  ),
                ),
                child: Stack(
                  children: [
                    // Bisel superior blanco semitransparente para efecto 3D
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 3,
                      child: Container(
                        color: SysQuestColors.bevelWhite,
                      ),
                    ),

                    // Contenido: icono opcional de tileset y texto
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.leadingSpriteFile != null) ...[
                              Image.asset(
                                _resolveSpritePath(widget.leadingSpriteFile!),
                                scale: 0.25,
                                filterQuality: FilterQuality.none,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
                                style: SysQuestTypography.button.copyWith(
                                  color: widget.textColor,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
