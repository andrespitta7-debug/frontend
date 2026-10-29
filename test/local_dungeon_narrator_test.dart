import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/presentation/utils/local_dungeon_narrator.dart';

void main() {
  group('LocalDungeonNarrator', () {
    test('getIntroText incluye questTitle y resolvedTopic', () {
      final intro = LocalDungeonNarrator.getIntroText('Cripta de Git', 'Control de Versiones');
      expect(intro.contains('Cripta de Git'), isTrue);
      expect(intro.contains('Control de Versiones'), isTrue);
    });

    test('getWalkingText devuelve texto atmosférico no vacío', () {
      final walking1 = LocalDungeonNarrator.getWalkingText(42);
      final walking2 = LocalDungeonNarrator.getWalkingText();
      expect(walking1.isNotEmpty, isTrue);
      expect(walking2.isNotEmpty, isTrue);
    });

    test('getEncounterText y getVictoryText incluyen el nombre del enemigo', () {
      final encounter = LocalDungeonNarrator.getEncounterText('Gárgola de Stack Overflow');
      final victory = LocalDungeonNarrator.getVictoryText('Gárgola de Stack Overflow');
      expect(encounter.contains('Gárgola de Stack Overflow'), isTrue);
      expect(victory.contains('Gárgola de Stack Overflow'), isTrue);
    });

    test('generateDefaultPool genera las 8 categorías esperadas con 3 variantes cada una', () {
      final pool = LocalDungeonNarrator.generateDefaultPool(
        questTitle: 'Torre de Redes',
        resolvedTopic: 'Protocolo TCP/IP',
      );

      const categoriasEsperadas = [
        'intro',
        'entre_combates',
        'jefe_avistado',
        'ronda_completada',
        'retirada',
        'muerte',
        'critico',
        'acierto',
      ];

      for (final cat in categoriasEsperadas) {
        expect(pool.containsKey(cat), isTrue, reason: 'Falta categoría $cat');
        final lista = pool[cat];
        expect(lista is List, isTrue);
        expect((lista as List).length, 3, reason: 'Categoría $cat debe tener 3 variantes');
      }
    });
  });
}

