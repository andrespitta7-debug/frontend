import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/usuario.dart';
import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/transitions/retro_page_route.dart';
import '../../core/design_system/widgets/dungeon_menu_backdrop.dart';
import '../../core/design_system/widgets/pixel_icon.dart';
import '../../core/design_system/widgets/retro_bottom_nav_bar.dart';
import '../combate/combate_screen.dart';
import '../generar/generar_quest_screen.dart';
import '../mapa/mapa_mundo_screen.dart';
import '../perfil/perfil_screen.dart';
import '../progreso/progreso_controller.dart';
import '../progreso/progreso_screen.dart';

/// Pantalla Hub Principal que unifica la navegación de la Mazmorra,
/// el Códice (Progreso) y el Perfil usando un único DungeonMenuBackdrop de fondo,
/// un [IndexedStack] y el [RetroBottomNavBar].
class MainHubScreen extends StatefulWidget {
  final Usuario usuario;
  final int initialIndex;

  const MainHubScreen({
    super.key,
    required this.usuario,
    this.initialIndex = 0,
  });

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  late int _currentIndex;
  bool _progresoVisitado = false;
  bool _perfilVisitado = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (_currentIndex == 1) _progresoVisitado = true;
    if (_currentIndex == 2) _perfilVisitado = true;
  }

  void _cambiarPestana(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      if (index == 1) _progresoVisitado = true;
      if (index == 2) _perfilVisitado = true;
    });

    // Disparar recarga de controladores existentes
    if (index == 1) {
      context.read<ProgresoController>().cargar(widget.usuario.idUsuario);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SysQuestColors.dungeonVoid,
      bottomNavigationBar: RetroBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _cambiarPestana,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // UN solo DungeonMenuBackdrop (Positioned.fill, sin SafeArea)
          const Positioned.fill(
            child: DungeonMenuBackdrop(
              isDoorOpen: false,
            ),
          ),
          // IndexedStack con las 3 vistas en primer plano
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                MazmorraMenuView(
                  usuario: widget.usuario,
                  onIrAProgreso: () => _cambiarPestana(1),
                  onIrAPerfil: () => _cambiarPestana(2),
                ),
                _progresoVisitado || _currentIndex == 1
                    ? ProgresoScreen(
                        idUsuario: widget.usuario.idUsuario,
                        enHub: true,
                      )
                    : const SizedBox.shrink(),
                _perfilVisitado || _currentIndex == 2
                    ? PerfilScreen(
                        usuario: widget.usuario,
                        enHub: true,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vista principal de la Mazmorra (Pestaña 0) con las opciones de aventura.
class MazmorraMenuView extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback? onIrAProgreso;
  final VoidCallback? onIrAPerfil;

  const MazmorraMenuView({
    super.key,
    required this.usuario,
    this.onIrAProgreso,
    this.onIrAPerfil,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = usuario.nombre.trim().isEmpty
        ? usuario.nombreUsuario
        : usuario.nombre;
    final topPadding = MediaQuery.paddingOf(context).top;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPadding + 16,
        bottom: 32,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Contenedor oscuro semi-transparente estilo ventana retro para el saludo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SysQuestColors.dungeonVoid.withValues(alpha: 0.85),
              border: Border.all(
                color: SysQuestColors.stoneHighlight,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: SysQuestColors.shadowBlack,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SysQuest',
                  style: SysQuestTypography.h1.copyWith(
                    color: SysQuestColors.gold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hola, $nombre',
                  style: SysQuestTypography.h2.copyWith(
                    fontSize: 13,
                    color: SysQuestColors.parchmentText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '¿Qué aventura quieres jugar hoy?',
                  style: SysQuestTypography.caption.copyWith(
                    color: SysQuestColors.parchmentText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 2 Tarjetas anchas e imponentes
          _MenuHubCard(
            spriteFile: 'chest_full_open_anim_f0.png',
            accent: SysQuestColors.gold,
            title: 'Nueva quest con IA',
            subtitle: 'Desafía mazmorras generadas por el Archimago Groq',
            onTap: () => Navigator.push(
              context,
              buildRetroRoute(
                GenerarQuestScreen(idUsuario: usuario.idUsuario),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuHubCard(
            spriteFile: 'doors_leaf_open.png',
            accent: SysQuestColors.manaCyan,
            title: 'Mapa de aventura',
            subtitle: 'Explora el Valle de Algoritmos y supera cada nodo',
            onTap: () => Navigator.push(
              context,
              buildRetroRoute(
                MapaMundo2DScreen(
                  idUsuario: usuario.idUsuario,
                  onSeleccionarQuest: (idQuest) {
                    Navigator.push(
                      context,
                      buildRetroRoute(
                        CombateScreen(
                          idQuest: idQuest,
                          idUsuario: usuario.idUsuario,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuHubCard extends StatelessWidget {
  final String spriteFile;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuHubCard({
    required this.spriteFile,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SysQuestColors.stonePanel,
          border: Border.all(
            color: SysQuestColors.stoneHighlight,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: SysQuestColors.shadowBlack,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: SysQuestColors.dungeonVoid,
                border: Border.all(color: accent, width: 2),
              ),
              child: Center(
                child: PixelIcon(fileName: spriteFile, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SysQuestTypography.button.copyWith(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: SysQuestTypography.caption.copyWith(
                      color: SysQuestColors.parchmentText.withValues(alpha: 0.8),
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: accent,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
