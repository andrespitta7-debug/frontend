import 'package:flutter/material.dart';

/// Paleta de colores 16-bit RPG para SysQuest.
class SysQuestColors {
  // Fondos y paneles principales
  static const Color dungeonVoid = Color(0xFF141019); // Fondo base RPG (#141019)
  static const Color stonePanel = Color(0xFF221C2B); // Paneles de piedra (#221C2B)
  static const Color stoneHighlight = Color(0xFF382F45); // Borde interior/resalte de piedra
  static const Color borderBlack = Color(0xFF000000); // Borde duro negro

  // Acentos retro
  static const Color manaCyan = Color(0xFF00E5FF); // Acento cian (#00E5FF)
  static const Color gold = Color(0xFFFFB800); // Oro (#FFB800)
  static const Color lifeRed = Color(0xFFFF3355); // Vida/daño (#FF3355)
  static const Color parchmentText = Color(0xFFF4EFE6); // Texto apergaminado (#F4EFE6)

  // Luces y sombras para bisel 3D
  static const Color bevelWhite = Color(0x40FFFFFF); // Bisel superior claro
  static const Color shadowBlack = Color(0xFF000000); // Sombra dura inferior

  // Estados secundarios
  static const Color successGreen = Color(0xFF35E88E); // Verde de acierto
  static const Color disabledGray = Color(0xFF5A5364); // Deshabilitado
}

/// Tipografía retro basada en la fuente 8-bit 'PressStart2P'.
class SysQuestTypography {
  static const String fontFamily = 'PressStart2P';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: SysQuestColors.parchmentText,
    letterSpacing: 1.0,
    height: 1.4,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: SysQuestColors.parchmentText,
    letterSpacing: 0.8,
    height: 1.4,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: SysQuestColors.parchmentText,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    color: SysQuestColors.parchmentText,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: SysQuestColors.parchmentText,
    letterSpacing: 0.8,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    color: SysQuestColors.parchmentText,
    letterSpacing: 0.4,
    height: 1.3,
  );
}

