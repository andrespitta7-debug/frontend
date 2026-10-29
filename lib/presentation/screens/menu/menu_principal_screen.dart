import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/usuario.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../auth/login_screen.dart';
import '../combate/combate_screen.dart';
import '../generar/generar_quest_screen.dart';
import '../mapa/mapa_mundo_screen.dart';
import '../perfil/perfil_screen.dart';
import '../progreso/progreso_screen.dart';

class MenuPrincipalScreen extends StatelessWidget {
  final Usuario usuario;

  const MenuPrincipalScreen({super.key, required this.usuario});

  Future<void> _cerrarSesion(BuildContext context) async {
    await context.read<CerrarSesionUseCase>().ejecutar();
    if (!context.mounted) return;
    context.read<AuthController>().cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = usuario.nombre.trim().isEmpty
        ? usuario.nombreUsuario
        : usuario.nombre;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SysQuest'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hola, $nombre',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                '¿Qué aventura quieres jugar hoy?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MenuCard(
                    icon: Icons.map_outlined,
                    accent: AppTheme.doradoCritico,
                    title: 'Mapa de aventura',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapaMundo2DScreen(
                          idUsuario: usuario.idUsuario,
                          onSeleccionarQuest: (idQuest) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CombateScreen(
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
                  _MenuCard(
                    icon: Icons.auto_awesome,
                    accent: AppTheme.verdeVida,
                    title: 'Nueva quest con IA',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GenerarQuestScreen(idUsuario: usuario.idUsuario),
                      ),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.insights_outlined,
                    accent: AppTheme.azulTexto,
                    title: 'Mi progreso',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProgresoScreen(idUsuario: usuario.idUsuario),
                      ),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.person_outline,
                    accent: AppTheme.azulTexto,
                    title: 'Mi perfil',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfilScreen(usuario: usuario),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => _cerrarSesion(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
