import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/usuario.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/transitions/retro_page_route.dart';
import '../../core/design_system/widgets/dungeon_menu_backdrop.dart';
import '../../core/design_system/widgets/pixel_icon.dart';
import '../../core/design_system/widgets/retro_bottom_nav_bar.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';
import '../auth/auth_controller.dart';
import '../auth/login_screen.dart';
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
  final VoidCallback onIrAProgreso;
  final VoidCallback onIrAPerfil;

  const MazmorraMenuView({
    super.key,
    required this.usuario,
    required this.onIrAProgreso,
    required this.onIrAPerfil,
  });

  Future<void> _confirmarCerrarSesion(BuildContext context) async {
    final authController = context.read<AuthController>();
    final cerrarSesionUseCase = context.read<CerrarSesionUseCase>();

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: RetroPanelBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '¿ABANDONAR EL GREMIO?',
                    style: SysQuestTypography.h2.copyWith(
                      color: SysQuestColors.lifeRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Volverás a la pantalla de inicio.',
                    style: SysQuestTypography.body.copyWith(
                      fontSize: 10,
                      color: SysQuestColors.parchmentText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: RetroPixelButton(
                          text: 'CANCELAR',
                          color: SysQuestColors.disabledGray,
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RetroPixelButton(
                          text: 'SALIR',
                          color: SysQuestColors.lifeRed,
                          onPressed: () async {
                            Navigator.of(dialogCtx).pop();
                            await cerrarSesionUseCase.ejecutar();
                            authController.logout();
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              buildRetroRoute(const LoginScreen()),
                              (_) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SysQuest',
                style: SysQuestTypography.h1.copyWith(
                  color: SysQuestColors.gold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: () => _confirmarCerrarSesion(context),
                icon: const Icon(
                  Icons.logout,
                  color: SysQuestColors.parchmentText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MenuHubCard(
                icon: Icons.map_outlined,
                spriteFile: 'doors_leaf_open.png',
                accent: SysQuestColors.gold,
                title: 'Mapa de aventura',
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
              _MenuHubCard(
                icon: Icons.auto_awesome,
                spriteFile: 'chest_full_open_anim_f0.png',
                accent: SysQuestColors.successGreen,
                title: 'Nueva quest con IA',
                onTap: () => Navigator.push(
                  context,
                  buildRetroRoute(
                    GenerarQuestScreen(idUsuario: usuario.idUsuario),
                  ),
                ),
              ),
              _MenuHubCard(
                icon: Icons.insights_outlined,
                spriteFile: 'chest_empty_open_anim_f0.png',
                accent: SysQuestColors.manaCyan,
                title: 'Mi progreso',
                onTap: onIrAProgreso,
              ),
              _MenuHubCard(
                icon: Icons.person_outline,
                spriteFile: 'knight_m_idle_anim_f0.png',
                accent: SysQuestColors.gold,
                title: 'Mi perfil',
                onTap: onIrAPerfil,
              ),
            ],
          ),
          const SizedBox(height: 28),
          RetroPixelButton(
            text: 'CERRAR SESIÓN',
            color: SysQuestColors.lifeRed,
            leadingSpriteFile: 'lever_left.png',
            onPressed: () => _confirmarCerrarSesion(context),
          ),
        ],
      ),
    );
  }
}

class _MenuHubCard extends StatelessWidget {
  final IconData icon;
  final String? spriteFile;
  final Color accent;
  final String title;
  final VoidCallback onTap;

  const _MenuHubCard({
    required this.icon,
    this.spriteFile,
    required this.accent,
    required this.title,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SysQuestColors.dungeonVoid,
                border: Border.all(color: accent, width: 2),
              ),
              child: spriteFile != null
                  ? Center(child: PixelIcon(fileName: spriteFile!, size: 24))
                  : Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: SysQuestTypography.caption.copyWith(
                color: SysQuestColors.parchmentText,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
