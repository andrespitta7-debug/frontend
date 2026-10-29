import 'package:flutter/material.dart';
import '../sysquest_theme.dart';

/// Panel o caja de diálogo 16-bit RPG con doble borde:
/// exterior negro de 4px, interior en `stoneHighlight` de 3px y fondo `stonePanel`.
class RetroPanelBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color borderColor;
  final Color highlightColor;

  const RetroPanelBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.width,
    this.height,
    this.backgroundColor = SysQuestColors.stonePanel,
    this.borderColor = SysQuestColors.borderBlack,
    this.highlightColor = SysQuestColors.stoneHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: borderColor,
        border: Border.all(
          color: borderColor,
          width: 4,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: highlightColor,
            width: 3,
          ),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

