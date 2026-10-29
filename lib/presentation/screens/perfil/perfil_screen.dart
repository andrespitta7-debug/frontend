import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/usuario.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/perfil_usecases.dart';
import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/transitions/retro_page_route.dart';
import '../../core/design_system/widgets/dungeon_menu_backdrop.dart';
import '../../core/design_system/widgets/pixel_icon.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../auth/login_screen.dart';

class PerfilScreen extends StatefulWidget {
  final Usuario usuario;
  final bool enHub;

  const PerfilScreen({
    super.key,
    required this.usuario,
    this.enHub = false,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late Usuario _usuario;
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _nombreUsuarioController;

  late final TextEditingController _passwordActualController;
  late final TextEditingController _passwordNuevaController;
  late final TextEditingController _passwordConfirmacionController;

  bool _editando = false;
  bool _guardando = false;
  String? _error;

  bool _cambiandoPassword = false;
  bool _guardandoPassword = false;
  bool _ocultarActual = true;
  bool _ocultarNueva = true;
  bool _ocultarConfirmacion = true;
  String? _errorPassword;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
    _nombreController = TextEditingController(text: _usuario.nombre);
    _apellidoController = TextEditingController(text: _usuario.apellido);
    _nombreUsuarioController = TextEditingController(
      text: _usuario.nombreUsuario,
    );
    _passwordActualController = TextEditingController();
    _passwordNuevaController = TextEditingController();
    _passwordConfirmacionController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _nombreUsuarioController.dispose();
    _passwordActualController.dispose();
    _passwordNuevaController.dispose();
    _passwordConfirmacionController.dispose();
    super.dispose();
  }

  String? _validarTexto(String? value, String etiqueta) {
    final texto = value?.trim() ?? '';
    if (texto.length < 2 || texto.length > 50) {
      return '$etiqueta es obligatorio y debe tener entre 2 y 50 caracteres.';
    }
    return null;
  }

  String? _validarNombreUsuario(String? value) {
    final nombreUsuario = value?.trim() ?? '';
    if (nombreUsuario.length < 3 ||
        nombreUsuario.length > 20 ||
        !RegExp(r'^[A-Za-z0-9_]+$').hasMatch(nombreUsuario)) {
      return 'El nombre de usuario debe tener entre 3 y 20 caracteres y solo puede contener letras, números y guion bajo.';
    }
    return null;
  }

  void _activarEdicion() {
    setState(() {
      _error = null;
      _editando = true;
      _cambiandoPassword = false;
    });
  }

  void _cancelarEdicion() {
    _nombreController.text = _usuario.nombre;
    _apellidoController.text = _usuario.apellido;
    _nombreUsuarioController.text = _usuario.nombreUsuario;
    setState(() {
      _error = null;
      _editando = false;
    });
  }

  void _limpiarFormularioPassword() {
    _passwordActualController.clear();
    _passwordNuevaController.clear();
    _passwordConfirmacionController.clear();
    _ocultarActual = true;
    _ocultarNueva = true;
    _ocultarConfirmacion = true;
    _errorPassword = null;
  }

  void _activarCambioPassword() {
    setState(() {
      _limpiarFormularioPassword();
      _editando = false;
      _cambiandoPassword = true;
    });
  }

  void _cancelarCambioPassword() {
    setState(() {
      _limpiarFormularioPassword();
      _cambiandoPassword = false;
    });
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    final nuevoNombre = _nombreController.text.trim();
    final nuevoApellido = _apellidoController.text.trim();
    final nuevoUsuario = _nombreUsuarioController.text.trim();

    if (nuevoNombre == _usuario.nombre &&
        nuevoApellido == _usuario.apellido &&
        nuevoUsuario == _usuario.nombreUsuario) {
      setState(() {
        _guardando = false;
        _error = 'No has editado nada en tu perfil.';
      });
      return;
    }

    try {
      final usuarioActualizado = await context
          .read<ActualizarPerfilUseCase>()
          .ejecutar(
            usuarioActual: _usuario,
            nombre: nuevoNombre,
            apellido: nuevoApellido,
            nombreUsuario: nuevoUsuario,
          );
      if (!mounted) return;
      setState(() {
        _usuario = usuarioActualizado;
        _editando = false;
        _guardando = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = error is RegistroInvalidoException
            ? error.mensaje
            : 'No se pudo actualizar el perfil, intenta de nuevo.';
      });
    }
  }

  Future<void> _guardarPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      _guardandoPassword = true;
      _errorPassword = null;
    });

    try {
      await context.read<CambiarPasswordUseCase>().ejecutar(
            usuario: _usuario,
            passwordActual: _passwordActualController.text,
            passwordNueva: _passwordNuevaController.text,
            passwordConfirmacion: _passwordConfirmacionController.text,
          );
      if (!mounted) return;
      _limpiarFormularioPassword();
      setState(() {
        _cambiandoPassword = false;
        _guardandoPassword = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _guardandoPassword = false;
        _errorPassword = error is RegistroInvalidoException
            ? error.mensaje
            : 'No se pudo cambiar la contraseña, intenta de nuevo.';
      });
    }
  }

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

  Future<void> _confirmarEliminarCuenta(BuildContext context) async {
    final passwordController = TextEditingController();
    bool ocultarPassword = true;
    bool eliminando = false;
    String? errorEliminar;

    await showDialog<void>(
      context: context,
      barrierDismissible: !eliminando,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: SysQuestColors.stonePanel,
              title: Text(
                'ELIMINAR CUENTA',
                style: SysQuestTypography.h2.copyWith(
                  color: SysQuestColors.lifeRed,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Esta acción es permanente e irreversible. Se borrarán todos tus datos de progreso y partidas.',
                      style: SysQuestTypography.caption.copyWith(
                        color: SysQuestColors.parchmentText.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      enabled: !eliminando,
                      obscureText: ocultarPassword,
                      style: const TextStyle(color: SysQuestColors.parchmentText),
                      decoration: InputDecoration(
                        labelText: 'Contraseña actual',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              ocultarPassword = !ocultarPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    if (errorEliminar != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(mensaje: errorEliminar!),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: eliminando
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'CANCELAR',
                    style: SysQuestTypography.caption.copyWith(
                      color: SysQuestColors.parchmentText,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: eliminando
                      ? null
                      : () async {
                          final password = passwordController.text;
                          if (password.isEmpty) {
                            setDialogState(() {
                              errorEliminar =
                                  'Ingresa tu contraseña para confirmar.';
                            });
                            return;
                          }

                          final eliminarCuentaUseCase =
                              context.read<EliminarCuentaUseCase>();
                          final cerrarSesionUseCase =
                              context.read<CerrarSesionUseCase>();
                          final authController =
                              context.read<AuthController>();
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          setDialogState(() {
                            eliminando = true;
                            errorEliminar = null;
                          });

                          try {
                            await eliminarCuentaUseCase.ejecutar(
                              usuario: _usuario,
                              passwordActual: password,
                            );
                            await cerrarSesionUseCase.ejecutar();
                            authController.logout();

                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            navigator.pushAndRemoveUntil(
                              buildRetroRoute(const LoginScreen()),
                              (route) => false,
                            );
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Tu cuenta fue eliminada'),
                              ),
                            );
                          } catch (error) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              eliminando = false;
                              errorEliminar = error is RegistroInvalidoException
                                  ? error.mensaje
                                  : 'No se pudo eliminar la cuenta.';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SysQuestColors.lifeRed,
                    foregroundColor: Colors.white,
                  ),
                  child: eliminando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'ELIMINAR',
                          style: SysQuestTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    final content = SingleChildScrollView(
      padding: EdgeInsets.only(
        top: (widget.enHub ? topPadding : 8) + 16,
        bottom: 32,
        left: 20,
        right: 20,
      ),
      child: _editando
          ? _buildFormulario(context)
          : _cambiandoPassword
              ? _buildFormularioPassword(context)
              : _buildLectura(context),
    );

    if (widget.enHub) {
      return content;
    }

    return Scaffold(
      backgroundColor: SysQuestColors.dungeonVoid,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: SysQuestColors.stonePanel,
        leading: const BackButton(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DungeonMenuBackdrop(
              isDoorOpen: false,
            ),
          ),
          Positioned.fill(
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildLectura(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.enHub) ...[
          Text(
            'PERFIL DE AVENTURERO',
            style: SysQuestTypography.h2.copyWith(
              color: SysQuestColors.gold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
        ],
        const _PerfilAvatar(),
        const SizedBox(height: 18),
        Text(
          '${_usuario.nombre} ${_usuario.apellido}',
          textAlign: TextAlign.center,
          style: SysQuestTypography.h2.copyWith(
            color: SysQuestColors.parchmentText,
          ),
        ),
        const SizedBox(height: 20),
        RetroPanelBox(
          child: Column(
            children: [
              _DatoPerfil(label: 'Nombre', valor: _usuario.nombre),
              _DatoPerfil(label: 'Apellido', valor: _usuario.apellido),
              _DatoPerfil(
                label: 'Nombre de usuario',
                valor: _usuario.nombreUsuario,
              ),
              _DatoPerfil(label: 'Correo', valor: _usuario.email),
              const SizedBox(height: 6),
              Text(
                'El correo no se puede cambiar por ahora',
                style: SysQuestTypography.caption.copyWith(
                  color: SysQuestColors.manaCyan,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RetroPixelButton(
          onPressed: _activarEdicion,
          color: SysQuestColors.stoneHighlight,
          text: 'EDITAR PERFIL',
        ),
        const SizedBox(height: 12),
        RetroPixelButton(
          onPressed: _activarCambioPassword,
          color: SysQuestColors.stonePanel,
          leadingSpriteFile: 'chest_empty_open_anim_f0.png',
          text: 'CAMBIAR CONTRASEÑA',
        ),
        const SizedBox(height: 12),
        RetroPixelButton(
          text: 'CERRAR SESIÓN',
          color: SysQuestColors.lifeRed,
          leadingSpriteFile: 'lever_left.png',
          onPressed: () => _confirmarCerrarSesion(context),
        ),
        const SizedBox(height: 24),
        const Divider(color: SysQuestColors.stoneHighlight),
        const SizedBox(height: 12),
        RetroPixelButton(
          onPressed: () => _confirmarEliminarCuenta(context),
          color: SysQuestColors.dungeonVoid,
          textColor: SysQuestColors.lifeRed,
          leadingSpriteFile: 'skull.png',
          text: 'ELIMINAR CUENTA',
        ),
      ],
    );
  }

  Widget _buildFormulario(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: RetroPanelBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'EDITAR PERFIL',
              style: SysQuestTypography.h2.copyWith(
                color: SysQuestColors.gold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              enabled: !_guardando,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) => _validarTexto(value, 'El nombre'),
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _apellidoController,
              enabled: !_guardando,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) => _validarTexto(value, 'El apellido'),
              decoration: const InputDecoration(
                labelText: 'Apellido',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nombreUsuarioController,
              enabled: !_guardando,
              textInputAction: TextInputAction.done,
              validator: _validarNombreUsuario,
              decoration: const InputDecoration(
                labelText: 'Nombre de usuario',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _ErrorBanner(mensaje: _error!),
            ],
            const SizedBox(height: 20),
            RetroPixelButton(
              onPressed: _guardando ? null : _guardar,
              color: SysQuestColors.successGreen,
              textColor: SysQuestColors.dungeonVoid,
              text: _guardando ? 'GUARDANDO...' : 'GUARDAR CAMBIOS',
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _guardando ? null : _cancelarEdicion,
              child: Text(
                'CANCELAR',
                style: SysQuestTypography.caption.copyWith(
                  color: SysQuestColors.parchmentText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioPassword(BuildContext context) {
    return Form(
      key: _passwordFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: RetroPanelBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CAMBIAR CONTRASEÑA',
              style: SysQuestTypography.h2.copyWith(
                color: SysQuestColors.gold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordActualController,
              enabled: !_guardandoPassword,
              obscureText: _ocultarActual,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña actual.';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarActual
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _ocultarActual = !_ocultarActual;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordNuevaController,
              enabled: !_guardandoPassword,
              obscureText: _ocultarNueva,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa la nueva contraseña.';
                }
                if (value.length < 8 ||
                    !RegExp(r'[A-Za-z]').hasMatch(value) ||
                    !RegExp(r'[0-9]').hasMatch(value)) {
                  return 'La contraseña debe tener al menos 8 caracteres, una letra y un número.';
                }
                if (value == _passwordActualController.text) {
                  return 'La nueva contraseña no puede ser igual a la actual.';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarNueva
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _ocultarNueva = !_ocultarNueva;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordConfirmacionController,
              enabled: !_guardandoPassword,
              obscureText: _ocultarConfirmacion,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu nueva contraseña.';
                }
                if (value != _passwordNuevaController.text) {
                  return 'Las contraseñas no coinciden.';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: const Icon(Icons.check_circle_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarConfirmacion
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _ocultarConfirmacion = !_ocultarConfirmacion;
                    });
                  },
                ),
              ),
            ),
            if (_errorPassword != null) ...[
              const SizedBox(height: 16),
              _ErrorBanner(mensaje: _errorPassword!),
            ],
            const SizedBox(height: 20),
            RetroPixelButton(
              onPressed: _guardandoPassword ? null : _guardarPassword,
              color: SysQuestColors.gold,
              textColor: SysQuestColors.dungeonVoid,
              text: _guardandoPassword
                  ? 'GUARDANDO...'
                  : 'GUARDAR CONTRASEÑA',
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _guardandoPassword ? null : _cancelarCambioPassword,
              child: Text(
                'CANCELAR',
                style: SysQuestTypography.caption.copyWith(
                  color: SysQuestColors.parchmentText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfilAvatar extends StatelessWidget {
  const _PerfilAvatar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: SysQuestColors.stonePanel,
          border: Border.all(color: SysQuestColors.gold, width: 3),
          boxShadow: const [
            BoxShadow(
              color: SysQuestColors.shadowBlack,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: PixelIcon(
            fileName: 'knight_m_idle_anim_f0.png',
            size: 48,
          ),
        ),
      ),
    );
  }
}

class _DatoPerfil extends StatelessWidget {
  final String label;
  final String valor;

  const _DatoPerfil({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SysQuestColors.dungeonVoid.withValues(alpha: 0.5),
        border: Border.all(color: SysQuestColors.stoneHighlight, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SysQuestTypography.caption.copyWith(
              color: SysQuestColors.parchmentText.withValues(alpha: 0.8),
            ),
          ),
          Flexible(
            child: Text(
              valor,
              style: SysQuestTypography.caption.copyWith(
                color: SysQuestColors.gold,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String mensaje;

  const _ErrorBanner({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.rojoDanio.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.rojoDanio.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.rojoDanio),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: AppTheme.azulTexto),
            ),
          ),
        ],
      ),
    );
  }
}
