import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/domain/entities/visual_scene.dart';
import 'package:sysquest_app/presentation/utils/visual_asset_resolver.dart';

void main() {
  group('VisualScene y modelos de narrativa', () {
    test('VisualScene fromJson parsea correctamente snake_case', () {
      final json = {
        'biome_tag': 'cyber_grid',
        'visual_tag': 'door_opening',
        'animation_mode': 'once',
        'screen_effect': 'neon_scanline',
        'tint_hex': '#00FFAA',
      };

      final scene = VisualScene.fromJson(json);

      expect(scene.biomeTag, equals('cyber_grid'));
      expect(scene.visualTag, equals('door_opening'));
      expect(scene.animationMode, equals('once'));
      expect(scene.screenEffect, equals('neon_scanline'));
      expect(scene.tintHex, equals('#00FFAA'));
      expect(scene.toJson()['visual_tag'], equals('door_opening'));
    });

    test('GameEvent fromJson y toJson mapean estructura completa', () {
      final json = {
        'event_id': 'evt-101',
        'visual_scene': {
          'biome_tag': 'abyss',
          'visual_tag': 'npc_mentor',
          'animation_mode': 'float',
          'screen_effect': 'mist',
          'tint_hex': '#9B51E0',
        },
        'narrative': {
          'title': 'El Oráculo',
          'story_text': 'Un ser misterioso aparece.',
          'educational_hint': 'Presta atención a las variables.',
        },
        'choices': [
          {
            'id': 'op-1',
            'label': 'Escuchar',
            'consequence_type': 'hint',
          },
        ],
      };

      final event = GameEvent.fromJson(json);

      expect(event.eventId, equals('evt-101'));
      expect(event.visualScene.visualTag, equals('npc_mentor'));
      expect(event.narrative.title, equals('El Oráculo'));
      expect(event.choices.length, equals(1));
      expect(event.choices.first.id, equals('op-1'));
    });
  });

  group('VisualAssetResolver', () {
    test('devuelve el path esperado para tags conocidos', () {
      expect(
        VisualAssetResolver.obtenerAssetPath('door_opening'),
        equals('assets/sprites/door_opening.png'),
      );
      expect(
        VisualAssetResolver.obtenerAssetPath('npc_mentor'),
        equals('assets/sprites/npc_mentor.png'),
      );
      expect(
        VisualAssetResolver.obtenerAssetPath('trap_triggered'),
        equals('assets/sprites/trap_triggered.png'),
      );
    });

    test('devuelve ambient_mystery.png para tags desconocidos', () {
      expect(
        VisualAssetResolver.obtenerAssetPath('desconocido_123'),
        equals('assets/sprites/ambient_mystery.png'),
      );
      expect(
        VisualAssetResolver.obtenerAssetPath(''),
        equals('assets/sprites/ambient_mystery.png'),
      );
    });
  });
}

