import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/presentation/utils/dungeon_lore_translator.dart';

void main() {
  group('DungeonLoreTranslator', () {
    test('traduce tags técnicos requeridos a nombres inmersivos', () {
      expect(
        translateEventTitle('trap_triggered'),
        equals('¡TRAMPA ARCANA ACTIVADA!'),
      );
      expect(
        translateEventTitle('dungeon_crypt'),
        equals('Cripta de Datos'),
      );
      expect(
        translateEventTitle('subtle_glitch'),
        equals('Distorsión Mágica'),
      );
    });

    test('traduce tags con espacios o mayúsculas de manera insensible a mayúsculas', () {
      expect(
        translateEventTitle('  TRAP_TRIGGERED  '),
        equals('¡TRAMPA ARCANA ACTIVADA!'),
      );
      expect(
        translateEventTitle('Dungeon_Crypt'),
        equals('Cripta de Datos'),
      );
    });

    test('reemplaza guiones bajos por espacios en mayúsculas para tags desconocidos', () {
      expect(
        translateEventTitle('strange_anomaly'),
        equals('STRANGE ANOMALY'),
      );
    });

    test('devuelve título por defecto para entradas vacías', () {
      expect(
        translateEventTitle(''),
        equals('¡EVENTO DEL DESTINO!'),
      );
      expect(
        translateEventTitle('   '),
        equals('¡EVENTO DEL DESTINO!'),
      );
    });

    test('elimina emojis antes de evaluar tags genéricos', () {
      expect(
        translateEventTitle('🏺 Códice Antiguo'),
        equals('Códice Antiguo'),
      );
    });
  });
}

