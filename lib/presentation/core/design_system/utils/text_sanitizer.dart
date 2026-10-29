/// Utilidad para sanitizar cadenas de texto eliminando emojis Unicode
/// y colapsando espacios dobles, preservando la legibilidad en fuentes Pixel Art (PressStart2P).
String sanitizeRetroText(String input) {
  if (input.isEmpty) return input;

  // Expresión regular que cubre los rangos Unicode de emojis, símbolos misceláneos, modificadores y joiners
  final emojiRegex = RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE00}-\u{FE0F}\u{1F1E0}-\u{1F1FF}\u{200D}\u{200C}]',
    unicode: true,
  );

  // Expresión regular para detectar secuencias de dos o más espacios
  final doubleSpaceRegex = RegExp(r' {2,}');

  final withoutEmojis = input.replaceAll(emojiRegex, '');
  return withoutEmojis.replaceAll(doubleSpaceRegex, ' ').trim();
}
