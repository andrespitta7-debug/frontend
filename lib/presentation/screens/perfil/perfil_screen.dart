import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/usuario.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/perfil_usecases.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class PerfilScreen extends StatefulWidget {
  final Usuario usuario;

  const PerfilScreen({super.key, required this.usuario});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: _editando
              ? _buildFormulario(context)
              : _cambiandoPassword
                  ? _buildFormularioPassword(context)
                  : _buildLectura(context),
        ),
      ),
    );
  }

  Widget _buildLectura(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PerfilAvatar(),
        const SizedBox(height: 18),
        Text(
          '${_usuario.nombre} ${_usuario.apellido}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        _DatoPerfil(label: 'Nombre', valor: _usuario.nombre),
        _DatoPerfil(label: 'Apellido', valor: _usuario.apellido),
        _DatoPerfil(label: 'Nombre de usuario', valor: _usuario.nombreUsuario),
        _DatoPerfil(label: 'Correo', valor: _usuario.email),
        const SizedBox(height: 4),
        const Text(
          'El correo no se puede cambiar por ahora',
          style: TextStyle(color: AppTheme.azulTexto, fontSize: 12),
        ),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: _activarEdicion,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar perfil'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _activarCambioPassword,
          icon: const Icon(Icons.lock_outline),
          label: const Text('Cambiar contraseña'),
        ),
        const SizedBox(height: 32),
        const Divider(color: AppTheme.superficieElevada),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _confirmarEliminarCuenta(context),
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Eliminar cuenta'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.rojoDanio,
            foregroundColor: Colors.white,
          ),
        ),
      ],
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
              title: const Text('Eliminar cuenta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Esta acción es permanente e irreversible. Se borrarán todos tus datos de progreso y partidas.',
                      style: TextStyle(color: AppTheme.azulTexto),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      enabled: !eliminando,
                      obscureText: ocultarPassword,
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
                  child: const Text('Cancelar'),
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

                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
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
                    backgroundColor: AppTheme.rojoDanio,
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
                      : const Text('Eliminar cuenta'),
                ),
              ],
            );
          },
        );
      },
    );
    passwordController.dispose();
  }

  Widget _buildFormulario(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Editar perfil',
                style: Theme.of(context).textTheme.headlineSmall,
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
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Guardar'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _guardando ? null : _cancelarEdicion,
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormularioPassword(BuildContext context) {
    return Form(
      key: _passwordFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cambiar contraseña',
                style: Theme.of(context).textTheme.headlineSmall,
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
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardandoPassword ? null : _guardarPassword,
                  child: _guardandoPassword
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Guardar contraseña'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _guardandoPassword ? null : _cancelarCambioPassword,
                child: const Text('Cancelar'),
              ),
            ],
          ),
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
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppTheme.superficieElevada,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.azulTexto, width: 2),
        ),
        child: const Icon(
          Icons.person_outline,
          color: AppTheme.azulTexto,
          size: 42,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(title: Text(label), subtitle: Text(valor)),
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
        borderRadius: BorderRadius.circular(10),
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
