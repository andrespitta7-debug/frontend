import 'package:flutter/material.dart';

class AppTheme {
  static const fondoNoche = Color(0xFF0F111A); // Azul medianoche profundo, no negro plano
  static const superficieNoche = Color(0xFF1A1D2C); // Tarjeta estilizada
  static const superficieElevada = Color(0xFF282C40);
  static const doradoCritico = Color(0xFFFFD15C); // Dorado reluciente
  static const rojoDanio = Color(0xFFFF5964); // Rojo vibrante
  static const verdeVida = Color(0xFF35E88E); // Verde esmeralda neón
  static const azulTexto = Color(0xFFE2E8F0); // Texto blanco-azulado limpio
  static const purpuraMagico = Color(0xFFB388FF); // Púrpura RPG para mercaderes / magia

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: doradoCritico,
      onPrimary: fondoNoche,
      secondary: azulTexto,
      onSecondary: fondoNoche,
      error: rojoDanio,
      onError: Colors.white,
      surface: superficieNoche,
      onSurface: azulTexto,
    );

    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData.dark().copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: fondoNoche,
      canvasColor: fondoNoche,
      appBarTheme: const AppBarTheme(
        backgroundColor: fondoNoche,
        foregroundColor: azulTexto,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: doradoCritico,
          fontFamily: 'PressStart2P',
          fontSize: 18,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: azulTexto,
          fontFamily: 'PressStart2P',
          fontSize: 14,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: azulTexto,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: azulTexto),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: azulTexto),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: azulTexto,
          fontFamily: 'PressStart2P',
          fontSize: 10,
        ),
      ),
      cardTheme: CardThemeData(
        color: superficieNoche,
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: superficieElevada),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: doradoCritico,
          foregroundColor: fondoNoche,
          disabledBackgroundColor: superficieElevada,
          disabledForegroundColor: azulTexto.withValues(alpha: 0.55),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: doradoCritico,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficieNoche,
        labelStyle: const TextStyle(color: azulTexto),
        hintStyle: TextStyle(color: azulTexto.withValues(alpha: 0.6)),
        prefixIconColor: doradoCritico,
        suffixIconColor: doradoCritico,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: superficieElevada),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: superficieElevada),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: doradoCritico, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: rojoDanio),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: rojoDanio, width: 2),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: verdeVida,
        linearTrackColor: superficieElevada,
      ),
      dividerTheme: const DividerThemeData(color: superficieElevada),
    );
  }
}
