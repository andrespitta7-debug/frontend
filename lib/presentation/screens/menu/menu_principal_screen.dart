import 'package:flutter/material.dart';

import '../../../domain/entities/usuario.dart';
import 'main_hub_screen.dart';

/// Pantalla de Menú Principal compatible que delega en [MainHubScreen]
/// para ofrecer navegación integrada y unificada entre Mazmorra, Códice y Perfil.
class MenuPrincipalScreen extends StatelessWidget {
  final Usuario usuario;
  final int initialIndex;

  const MenuPrincipalScreen({
    super.key,
    required this.usuario,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return MainHubScreen(
      usuario: usuario,
      initialIndex: initialIndex,
    );
  }
}
