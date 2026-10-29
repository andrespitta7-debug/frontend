class VisualAssetResolver {
  static const String assetPorDefecto = 'assets/sprites/ambient_mystery.png';

  /// Mapea un [visualTag] del catálogo a su ruta ficticia de asset.
  /// Si el tag no está reconocido, retorna 'assets/sprites/ambient_mystery.png'.
  static String obtenerAssetPath(String visualTag) {
    switch (visualTag.trim().toLowerCase()) {
      case 'door_opening':
        return 'assets/sprites/door_opening.png';
      case 'npc_mentor':
        return 'assets/sprites/npc_mentor.png';
      case 'trap_triggered':
        return 'assets/sprites/trap_triggered.png';
      case 'chest_treasure':
        return 'assets/sprites/chest_treasure.png';
      case 'altar_shrine':
        return 'assets/sprites/altar_shrine.png';
      case 'merchant_shop':
        return 'assets/sprites/merchant_shop.png';
      case 'portal_teleport':
        return 'assets/sprites/portal_teleport.png';
      case 'campfire_rest':
        return 'assets/sprites/campfire_rest.png';
      case 'library_codex':
        return 'assets/sprites/library_codex.png';
      case 'crystal_pylon':
        return 'assets/sprites/crystal_pylon.png';
      case 'ruins_ancient':
        return 'assets/sprites/ruins_ancient.png';
      case 'boss_appearance':
        return 'assets/sprites/boss_appearance.png';
      case 'corrupted_node':
        return 'assets/sprites/corrupted_node.png';
      case 'magic_barrier':
        return 'assets/sprites/magic_barrier.png';
      case 'statue_monument':
        return 'assets/sprites/statue_monument.png';
      case 'cavern_entrance':
        return 'assets/sprites/cavern_entrance.png';
      case 'waterfall_fountain':
        return 'assets/sprites/waterfall_fountain.png';
      case 'battle_aftermath':
        return 'assets/sprites/battle_aftermath.png';
      case 'mystic_runes':
        return 'assets/sprites/mystic_runes.png';
      case 'ambient_mystery':
        return 'assets/sprites/ambient_mystery.png';
      default:
        return assetPorDefecto;
    }
  }
}

