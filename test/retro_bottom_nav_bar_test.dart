import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/presentation/core/design_system/widgets/retro_bottom_nav_bar.dart';

void main() {
  group('RetroBottomNavBar Widget Tests', () {
    testWidgets('renderiza las tres pestañas MAZMORRA, CÓDICE y PERFIL y responde a eventos onTap', (tester) async {
      int pestanaActual = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return RetroBottomNavBar(
                  currentIndex: pestanaActual,
                  onTap: (index) {
                    setState(() {
                      pestanaActual = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // 1. Verificar que las tres pestañas están visibles con sus etiquetas
      expect(find.text('MAZMORRA'), findsOneWidget);
      expect(find.text('CÓDICE'), findsOneWidget);
      expect(find.text('PERFIL'), findsOneWidget);

      // 2. Tocar pestaña CÓDICE (index 1)
      await tester.tap(find.text('CÓDICE'));
      await tester.pump();
      expect(pestanaActual, equals(1));

      // 3. Tocar pestaña PERFIL (index 2)
      await tester.tap(find.text('PERFIL'));
      await tester.pump();
      expect(pestanaActual, equals(2));

      // 4. Tocar pestaña MAZMORRA (index 0)
      await tester.tap(find.text('MAZMORRA'));
      await tester.pump();
      expect(pestanaActual, equals(0));
    });
  });
}

