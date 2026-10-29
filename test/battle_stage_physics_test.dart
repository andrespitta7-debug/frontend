import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/presentation/widgets/battle_fighter.dart';
import 'package:sysquest_app/presentation/widgets/battle_stage.dart';

void main() {
  group('BiomeData Tests', () {
    test('devuelve la configuración de sala esperada según el índice de encuentro', () {
      final sala1 = BiomeData.fromIndex(0);
      expect(sala1.colorFilter, isNull);
      expect(sala1.bannerSprite, equals('wall_banner_blue.png'));
      expect(sala1.extraWallProp, isNull);

      final sala2 = BiomeData.fromIndex(1);
      expect(
        sala2.colorFilter,
        equals(const ColorFilter.mode(Color(0xFFB5FFCC), BlendMode.modulate)),
      );
      expect(sala2.bannerSprite, equals('wall_banner_green.png'));
      expect(sala2.extraWallProp, equals('wall_goo.png'));

      final sala3 = BiomeData.fromIndex(2);
      expect(
        sala3.colorFilter,
        equals(const ColorFilter.mode(Color(0xFFFFB3B3), BlendMode.modulate)),
      );
      expect(sala3.bannerSprite, equals('wall_banner_red.png'));
      expect(
        sala3.extraWallProp,
        equals('wall_fountain_basin_red_anim_f0.png'),
      );

      final sala4 = BiomeData.fromIndex(3);
      expect(
        sala4.colorFilter,
        equals(const ColorFilter.mode(Color(0xFFB3E5FF), BlendMode.modulate)),
      );
      expect(sala4.bannerSprite, equals('wall_banner_yellow.png'));
      expect(sala4.extraWallProp, isNull);
    });
  });

  group('BattleFighterWidget Widget Tests', () {
    testWidgets('renderiza con soporte de isWalking y shieldSpriteFile sin lanzar excepciones', (tester) async {
      final key = GlobalKey<BattleFighterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BattleFighterWidget(
                key: key,
                characterPrefix: 'knight_m',
                weaponSprite: 'weapon_knight_sword.png',
                shieldSpriteFile: 'shield_small.png',
                isWalking: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(key.currentState, isNotNull);

      // Probar animación de ataque con GlobalKey
      bool impactoLlamado = false;
      key.currentState!.playAttack(onImpactMoment: () {
        impactoLlamado = true;
      });

      await tester.pump(const Duration(milliseconds: 150));
      expect(impactoLlamado, isTrue);
      await tester.pump(const Duration(milliseconds: 200));
    });
  });

  group('BattleStage Widget Tests', () {
    testWidgets('renderiza en modo estático y en modo caminata con props visuales', (tester) async {
      final biome = BiomeData.fromIndex(1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BattleStage(
              height: 160,
              scrollOffset: 120.0,
              biomeColorFilter: biome.colorFilter,
              bannerSprite: biome.bannerSprite,
              extraWallProp: biome.extraWallProp,
              playerActor: const SizedBox(width: 48, height: 68),
              enemyActor: const SizedBox(width: 48, height: 68),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(BattleStage), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
    });
  });
}

