import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/presentation/core/design_system/sysquest_theme.dart';
import 'package:sysquest_app/presentation/core/design_system/widgets/retro_pixel_button.dart';
import 'package:sysquest_app/presentation/core/design_system/widgets/retro_panel_box.dart';
import 'package:sysquest_app/presentation/core/design_system/widgets/dungeon_menu_backdrop.dart';
import 'package:sysquest_app/presentation/core/design_system/widgets/retro_text_field.dart';
import 'package:sysquest_app/presentation/core/design_system/transitions/retro_page_route.dart';
import 'package:sysquest_app/domain/entities/wildcard.dart';
import 'package:sysquest_app/presentation/screens/mapa/mercader_tienda_dialog.dart';
import 'package:sysquest_app/presentation/widgets/dialogo_alerta.dart';

void main() {
  group('Design System - SysQuest Theme', () {
    test('SysQuestColors contiene los valores hex requeridos', () {
      expect(SysQuestColors.dungeonVoid, equals(const Color(0xFF141019)));
      expect(SysQuestColors.stonePanel, equals(const Color(0xFF221C2B)));
      expect(SysQuestColors.manaCyan, equals(const Color(0xFF00E5FF)));
      expect(SysQuestColors.gold, equals(const Color(0xFFFFB800)));
      expect(SysQuestColors.lifeRed, equals(const Color(0xFFFF3355)));
      expect(SysQuestColors.parchmentText, equals(const Color(0xFFF4EFE6)));
    });

    test('SysQuestTypography usa PressStart2P', () {
      expect(SysQuestTypography.h1.fontFamily, equals('PressStart2P'));
      expect(SysQuestTypography.body.fontFamily, equals('PressStart2P'));
      expect(SysQuestTypography.button.fontFamily, equals('PressStart2P'));
    });
  });

  group('Design System - RetroPixelButton', () {
    testWidgets('renderiza texto y ejecuta callback al presionar', (tester) async {
      bool pulsado = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RetroPixelButton(
                text: 'COMENZAR',
                onPressed: () => pulsado = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('COMENZAR'), findsOneWidget);

      // Simular pulsación completa
      await tester.tap(find.text('COMENZAR'));
      await tester.pump();
      expect(pulsado, isTrue);
    });

    testWidgets('baja físicamente 4px en onTapDown y se recupera en onTapUp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RetroPixelButton(
                text: 'ATACAR',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final gestorFinder = find.byType(GestureDetector);
      final centerInicial = tester.getCenter(find.text('ATACAR'));

      // Iniciar toque (onTapDown)
      final gesture = await tester.startGesture(tester.getCenter(gestorFinder));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 70));

      final centerPresionado = tester.getCenter(find.text('ATACAR'));
      expect(centerPresionado.dy, equals(centerInicial.dy + 4.0));

      // Levantar toque (onTapUp)
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 70));

      final centerLiberado = tester.getCenter(find.text('ATACAR'));
      expect(centerLiberado.dy, equals(centerInicial.dy));
    });
  });

  group('Design System - RetroPanelBox', () {
    testWidgets('renderiza contenido con doble borde característico', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: RetroPanelBox(
                child: Text('Panel de diálogo'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Panel de diálogo'), findsOneWidget);
      expect(find.byType(RetroPanelBox), findsOneWidget);
    });
  });

  group('Design System - DungeonMenuBackdrop', () {
    testWidgets('renderiza backdrop con soporte para actores y contenido', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DungeonMenuBackdrop(
              isDoorOpen: true,
              centerStageActors: Text('Héroe'),
              child: Text('Menú Principal'),
            ),
          ),
        ),
      );

      expect(find.text('Héroe'), findsOneWidget);
      expect(find.text('Menú Principal'), findsOneWidget);
    });
  });

  group('Design System - RetroPageRoute', () {
    testWidgets('construye una ruta retro con transición funcional', (tester) async {
      final route = buildRetroRoute<void>(
        const Scaffold(body: Text('Destino')),
      );

      expect(route, isA<PageRouteBuilder<void>>());
      expect(route.transitionDuration, equals(const Duration(milliseconds: 300)));
    });
  });

  group('Design System - RetroTextField', () {
    testWidgets('renderiza etiqueta, hint y contenido de texto', (tester) async {
      final controller = TextEditingController(text: 'caballero_sys');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetroTextField(
              controller: controller,
              labelText: 'NOMBRE DE HÉROE',
              hintText: 'Ingresa tu alias',
            ),
          ),
        ),
      );

      expect(find.text('NOMBRE DE HÉROE'), findsOneWidget);
      expect(find.text('caballero_sys'), findsOneWidget);
    });

    testWidgets('valida correctamente en un Form con retro styling', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: RetroTextField(
                controller: controller,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Campo requerido' : null,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Campo requerido'), findsNothing);

      final isValid = formKey.currentState!.validate();
      await tester.pump();

      expect(isValid, isFalse);
      expect(find.text('Campo requerido'), findsOneWidget);

      controller.text = 'Texto válido';
      await tester.pump();
      final isValidNow = formKey.currentState!.validate();
      await tester.pump();

      expect(isValidNow, isTrue);
      expect(find.text('Campo requerido'), findsNothing);
    });
  });

  group('Design System - DialogoAlertaSysQuest', () {
    testWidgets('usa RetroPanelBox y RetroPixelButton', (tester) async {
      bool aceptado = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => DialogoAlertaSysQuest.mostrar(
                  ctx,
                  titulo: 'ALERTA ARCADE',
                  mensaje: 'Peligro en el calabozo',
                  textoBoton: 'Aceptar',
                  onAceptar: () => aceptado = true,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('ALERTA ARCADE'), findsOneWidget);
      expect(find.text('Peligro en el calabozo'), findsOneWidget);
      expect(find.byType(RetroPanelBox), findsOneWidget);
      expect(find.byType(RetroPixelButton), findsOneWidget);

      await tester.tap(find.text('ACEPTAR'));
      await tester.pumpAndSettle();

      expect(aceptado, isTrue);
      expect(find.text('ALERTA ARCADE'), findsNothing);
    });
  });

  group('Design System - MercaderTiendaDialog', () {
    testWidgets('usa RetroPanelBox, RetroPixelButton y actualiza compras', (tester) async {
      TipoWildcard? comprado;
      int costoComprado = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MercaderTiendaDialog(
              scoreDisponible: 300,
              inventarioActual: const {
                TipoWildcard.pista: 1,
                TipoWildcard.golpeDoble: 0,
                TipoWildcard.roboDeVida: 0,
                TipoWildcard.cincuentaCincuenta: 0,
              },
              onComprar: (tipo, costo) {
                comprado = tipo;
                costoComprado = costo;
              },
            ),
          ),
        ),
      );

      expect(find.text('TIENDA DEL MERCADER'), findsOneWidget);
      expect(find.text('300 PTS'), findsOneWidget);
      expect(find.text('x1'), findsOneWidget); // Pergamino de pistas
      expect(find.byType(RetroPanelBox), findsOneWidget);

      // Comprar Pergamino de pistas (100 pts)
      final botonComprar100 = find.text('100');
      expect(botonComprar100, findsOneWidget);

      await tester.tap(botonComprar100);
      await tester.pump();

      expect(comprado, equals(TipoWildcard.pista));
      expect(costoComprado, equals(100));
      expect(find.text('200 PTS'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget); // Se actualizó a 2
    });
  });
}

