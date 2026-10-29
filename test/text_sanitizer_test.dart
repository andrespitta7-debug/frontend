import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/presentation/core/design_system/utils/text_sanitizer.dart';

void main() {
  group('sanitizeRetroText', () {
    test('elimina emojis comunes y mantiene el texto intacto', () {
      const input = '⚔️ ¡Aventura Épica! 🧙‍♂️';
      final result = sanitizeRetroText(input);
      expect(result, '¡Aventura Épica!');
    });

    test('colapsa espacios dobles y múltiples a uno solo', () {
      const input = 'Texto   con     muchos   espacios';
      final result = sanitizeRetroText(input);
      expect(result, 'Texto con muchos espacios');
    });

    test('elimina emojis de cara, banderas y símbolos diversos', () {
      const input = '🎮 Nivel 5 🏆 Superado 🇨🇴';
      final result = sanitizeRetroText(input);
      expect(result, 'Nivel 5 Superado');
    });

    test('maneja cadenas vacías o sin emojis', () {
      expect(sanitizeRetroText(''), '');
      expect(sanitizeRetroText('SysQuest RPG'), 'SysQuest RPG');
    });
  });
}

