import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../widgets/dialogo_alerta.dart';
import '../../widgets/terminos_condiciones_dialog.dart';
import '../menu/menu_principal_screen.dart';
import 'auth_controller.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();

  final _apellidoFocus = FocusNode();
  final _usuarioFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmarFocus = FocusNode();

  bool _mostrarPassword = false;
  bool _mostrarConfirmacion = false;
  bool _aceptaTerminos = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _usuarioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    _apellidoFocus.dispose();
    _usuarioFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmarFocus.dispose();
    super.dispose();
  }

  String? _validarTexto(String? value, String etiqueta) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return '$etiqueta es obligatorio.';
    if (texto.length < 2 || texto.length > 50) {
      return '$etiqueta debe tener entre 2 y 50 caracteres.';
    }
    return null;
  }

  String? _validarUsuario(String? value) {
    final usuario = value?.trim() ?? '';
    if (usuario.isEmpty) return 'El nombre de usuario es obligatorio.';
    if (usuario.length < 3 || usuario.length > 20) {
      return 'Debe tener entre 3 y 20 caracteres.';
    }
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(usuario)) {
      return 'Usa solo letras, números y guion bajo.';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'El correo es obligatorio.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Escribe un correo válido.';
    }
    return null;
  }

  String? _validarPassword(String? value) {
    final password = value ?? '';
    if (password.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Usa mínimo 8 caracteres, una letra y un número.';
    }
    return null;
  }

  String? _validarConfirmacion(String? value) {
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  Future<void> _registrar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthController>();
    final ok = await auth.registrar(
      email: _emailController.text,
      nombreUsuario: _usuarioController.text,
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (!ok && auth.error != null) {
      await DialogoAlertaSysQuest.mostrar(
        context,
        titulo: 'ERROR DE REGISTRO',
        mensaje: auth.error!,
        icono: Icons.error_outline,
        colorPrimario: AppTheme.rojoDanio,
      );
      return;
    }

    if (ok) {
      final usuario = auth.usuarioActual;
      if (usuario == null) return;

      await DialogoAlertaSysQuest.mostrar(
        context,
        titulo: '¡CUENTA CREADA!',
        mensaje:
            'Bienvenido a SysQuest, ${usuario.nombre}. Hemos vinculado tu correo (${usuario.email}) y enviado la confirmación de activación. ¡Prepárate para la aventura!',
        icono: Icons.mark_email_read_outlined,
        colorPrimario: AppTheme.verdeVida,
        textoBoton: 'Iniciar Aventura',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MenuPrincipalScreen(usuario: usuario),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Crea tu aventurero', style: textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Completa tus datos para guardar tu progreso.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _nombreController,
                      enabled: !auth.cargando,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _validarTexto(value, 'El nombre'),
                      onFieldSubmitted: (_) => _apellidoFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _apellidoController,
                      focusNode: _apellidoFocus,
                      enabled: !auth.cargando,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _validarTexto(value, 'El apellido'),
                      onFieldSubmitted: (_) => _usuarioFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _usuarioController,
                      focusNode: _usuarioFocus,
                      enabled: !auth.cargando,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: _validarUsuario,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      enabled: !auth.cargando,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _validarEmail,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      enabled: !auth.cargando,
                      obscureText: !_mostrarPassword,
                      textInputAction: TextInputAction.next,
                      validator: _validarPassword,
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) => _confirmarFocus.requestFocus(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _mostrarPassword
                              ? 'Ocultar contraseña'
                              : 'Mostrar contraseña',
                          onPressed: auth.cargando
                              ? null
                              : () => setState(
                                  () => _mostrarPassword = !_mostrarPassword,
                                ),
                          icon: Icon(
                            _mostrarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FortalezaPassword(password: _passwordController.text),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmarController,
                      focusNode: _confirmarFocus,
                      enabled: !auth.cargando,
                      obscureText: !_mostrarConfirmacion,
                      textInputAction: TextInputAction.done,
                      validator: _validarConfirmacion,
                      onFieldSubmitted: auth.cargando
                          ? null
                          : (_) => _registrar(),
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: const Icon(Icons.verified_user_outlined),
                        suffixIcon: IconButton(
                          tooltip: _mostrarConfirmacion
                              ? 'Ocultar contraseña'
                              : 'Mostrar contraseña',
                          onPressed: auth.cargando
                              ? null
                              : () => setState(
                                  () => _mostrarConfirmacion =
                                      !_mostrarConfirmacion,
                                ),
                          icon: Icon(
                            _mostrarConfirmacion
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormField<bool>(
                      initialValue: false,
                      validator: (_) => _aceptaTerminos
                          ? null
                          : 'Debes aceptar los términos para continuar.',
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: _aceptaTerminos,
                            onChanged: auth.cargando
                                ? null
                                : (value) {
                                    setState(
                                      () => _aceptaTerminos = value ?? false,
                                    );
                                    field.didChange(_aceptaTerminos);
                                  },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('Acepto los '),
                                InkWell(
                                  onTap: () =>
                                      TerminosCondicionesDialog.mostrar(context),
                                  child: const Text(
                                    'términos y condiciones',
                                    style: TextStyle(
                                      color: AppTheme.doradoCritico,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                field.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 8),
                      _ErrorBanner(mensaje: auth.error!),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.cargando ? null : _registrar,
                        child: auth.cargando
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Crear cuenta'),
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

class _FortalezaPassword extends StatelessWidget {
  final String password;
  const _FortalezaPassword({required this.password});

  @override
  Widget build(BuildContext context) {
    final tieneLongitud = password.length >= 8;
    final tieneLetra = RegExp(r'[A-Za-z]').hasMatch(password);
    final tieneNumero = RegExp(r'[0-9]').hasMatch(password);
    final puntos = [
      tieneLongitud,
      tieneLetra,
      tieneNumero,
    ].where((v) => v).length;
    final progreso = puntos / 3;
    final color = puntos == 3
        ? AppTheme.verdeVida
        : puntos == 2
        ? AppTheme.doradoCritico
        : AppTheme.rojoDanio;
    final texto = password.isEmpty
        ? 'Fortaleza de contraseña'
        : puntos == 3
        ? 'Contraseña fuerte'
        : puntos == 2
        ? 'Contraseña media'
        : 'Contraseña débil';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(texto, style: TextStyle(color: color, fontSize: 12)),
            if (password.isNotEmpty)
              Text('$puntos/3', style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: password.isEmpty ? 0 : progreso,
            color: color,
            backgroundColor: AppTheme.superficieElevada,
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
