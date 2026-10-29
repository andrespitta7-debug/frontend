import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/transitions/retro_page_route.dart';
import '../../core/design_system/widgets/dungeon_menu_backdrop.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';
import '../../core/design_system/widgets/retro_text_field.dart';
import '../../widgets/dialogo_alerta.dart';
import '../menu/menu_principal_screen.dart';
import 'auth_controller.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _mostrarPassword = false;
  bool _mantenerSesion = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final auth = context.read<AuthController>();
    final ok = await auth.iniciarSesion(
      _emailController.text,
      _passwordController.text,
      mantenerSesion: _mantenerSesion,
    );
    if (!mounted) return;

    if (!ok && auth.error != null) {
      await DialogoAlertaSysQuest.mostrar(
        context,
        titulo: 'FALLO DE ACCESO',
        mensaje: auth.error!,
        icono: Icons.lock_clock_outlined,
        colorPrimario: SysQuestColors.lifeRed,
      );
      return;
    }

    if (ok) {
      final usuario = auth.usuarioActual;
      if (usuario == null) return;
      Navigator.pushReplacement(
        context,
        buildRetroRoute(MenuPrincipalScreen(usuario: usuario)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: SysQuestColors.dungeonVoid,
      body: SafeArea(
        child: DungeonMenuBackdrop(
          isDoorOpen: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SysQuestLogo(),
                    const SizedBox(height: 20),
                    RetroPanelBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'INICIAR SESIÓN',
                            style: SysQuestTypography.h2.copyWith(
                              color: SysQuestColors.gold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Continúa tu aventura técnica.',
                            style: SysQuestTypography.caption.copyWith(
                              color: SysQuestColors.parchmentText
                                  .withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          RetroTextField(
                            controller: _emailController,
                            enabled: !auth.cargando,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.email,
                              AutofillHints.username,
                            ],
                            labelText: 'CORREO O USUARIO',
                            hintText: 'usuario@correo.com',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          const SizedBox(height: 14),
                          RetroTextField(
                            controller: _passwordController,
                            enabled: !auth.cargando,
                            obscureText: !_mostrarPassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            labelText: 'CONTRASEÑA',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            onSubmitted: auth.cargando
                                ? null
                                : (_) => _iniciarSesion(),
                            suffixIcon: IconButton(
                              tooltip: _mostrarPassword
                                  ? 'Ocultar contraseña'
                                  : 'Mostrar contraseña',
                              onPressed: auth.cargando
                                  ? null
                                  : () => setState(
                                        () => _mostrarPassword =
                                            !_mostrarPassword,
                                      ),
                              icon: Icon(
                                _mostrarPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor:
                                  SysQuestColors.stoneHighlight,
                            ),
                            child: CheckboxListTile(
                              value: _mantenerSesion,
                              onChanged: auth.cargando
                                  ? null
                                  : (value) => setState(
                                        () =>
                                            _mantenerSesion = value ?? false,
                                      ),
                              activeColor: SysQuestColors.gold,
                              checkColor: SysQuestColors.dungeonVoid,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              title: Text(
                                'Mantener sesión',
                                style: SysQuestTypography.caption.copyWith(
                                  color: SysQuestColors.parchmentText,
                                ),
                              ),
                            ),
                          ),
                          if (auth.error != null) ...[
                            const SizedBox(height: 8),
                            _ErrorBanner(mensaje: auth.error!),
                          ],
                          const SizedBox(height: 16),
                          RetroPixelButton(
                            text: auth.cargando ? 'CARGANDO...' : 'ENTRAR',
                            color: SysQuestColors.manaCyan,
                            textColor: SysQuestColors.dungeonVoid,
                            leadingSpriteFile: 'weapon_knight_sword.png',
                            enabled: !auth.cargando,
                            onPressed: _iniciarSesion,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: SysQuestColors.stoneHighlight,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'O continúa con',
                                  style: SysQuestTypography.caption.copyWith(
                                    fontSize: 8,
                                    color: SysQuestColors.parchmentText
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: SysQuestColors.stoneHighlight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _BotonOAuth(
                                icono: Icons.g_mobiledata,
                                label: 'Google',
                                color: const Color(0xFFEA4335),
                                onTap: () => DialogoAlertaSysQuest.mostrar(
                                  context,
                                  titulo: 'AUTENTICACIÓN GOOGLE',
                                  mensaje:
                                      'Redireccionando al portal seguro de Google OAuth. Configura tu Client ID en el panel docente para acceso instantáneo.',
                                  icono: Icons.mail_outline,
                                  colorPrimario: const Color(0xFFEA4335),
                                ),
                              ),
                              _BotonOAuth(
                                icono: Icons.window,
                                label: 'Outlook',
                                color: const Color(0xFF0078D4),
                                onTap: () => DialogoAlertaSysQuest.mostrar(
                                  context,
                                  titulo: 'AUTENTICACIÓN OUTLOOK',
                                  mensaje:
                                      'Conexión con cuenta institucional Microsoft / Outlook lista para enlazar con Supabase Auth.',
                                  icono: Icons.business,
                                  colorPrimario: const Color(0xFF0078D4),
                                ),
                              ),
                              _BotonOAuth(
                                icono: Icons.facebook,
                                label: 'Facebook',
                                color: const Color(0xFF1877F2),
                                onTap: () => DialogoAlertaSysQuest.mostrar(
                                  context,
                                  titulo: 'AUTENTICACIÓN FACEBOOK',
                                  mensaje:
                                      'Módulo de inicio de sesión con Meta / Facebook disponible para vincular a tu perfil de aventurero.',
                                  icono: Icons.facebook,
                                  colorPrimario: const Color(0xFF1877F2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: auth.cargando
                          ? null
                          : () => Navigator.push(
                                context,
                                buildRetroRoute(const RegistroScreen()),
                              ),
                      child: Text(
                        '¿NO TIENES CUENTA? REGÍSTRATE',
                        style: SysQuestTypography.caption.copyWith(
                          color: SysQuestColors.manaCyan,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SysQuestLogo extends StatelessWidget {
  const _SysQuestLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: SysQuestColors.stonePanel,
            border: Border.all(color: SysQuestColors.borderBlack, width: 3),
            boxShadow: const [
              BoxShadow(
                color: SysQuestColors.shadowBlack,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome,
              color: SysQuestColors.gold,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'SYSQUEST',
          style: SysQuestTypography.h1.copyWith(
            color: SysQuestColors.gold,
            letterSpacing: 3.0,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String mensaje;
  const _ErrorBanner({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SysQuestColors.lifeRed.withValues(alpha: 0.15),
        border: Border.all(color: SysQuestColors.lifeRed, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline,
              color: SysQuestColors.lifeRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: SysQuestTypography.caption.copyWith(
                color: SysQuestColors.parchmentText,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonOAuth extends StatefulWidget {
  final IconData icono;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BotonOAuth({
    required this.icono,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_BotonOAuth> createState() => _BotonOAuthState();
}

class _BotonOAuthState extends State<_BotonOAuth> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin:
            EdgeInsets.only(top: _pressed ? 3 : 0, bottom: _pressed ? 0 : 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: SysQuestColors.stonePanel,
          border: Border.all(color: SysQuestColors.borderBlack, width: 2),
          boxShadow: _pressed
              ? null
              : const [
                  BoxShadow(
                    color: SysQuestColors.shadowBlack,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: SysQuestColors.dungeonVoid,
                border: Border.all(color: widget.color, width: 2),
              ),
              child: Center(
                child: Icon(
                  widget.icono,
                  color: widget.color,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.label.toUpperCase(),
              style: SysQuestTypography.caption.copyWith(
                color: SysQuestColors.parchmentText,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
