import '../core/design_system/utils/text_sanitizer.dart';

/// Helper para traducir tags técnicos y mecánicos de backend a títulos
/// inmersivos y de fantasía oscura para la Mazmorra de SysQuest.
String translateEventTitle(String rawTag) {
  final clean = rawTag.trim().toLowerCase();

  switch (clean) {
    case 'trap_triggered':
      return '¡TRAMPA ARCANA ACTIVADA!';
    case 'dungeon_crypt':
      return 'Cripta de Datos';
    case 'subtle_glitch':
      return 'Distorsión Mágica';
    case 'door_opening':
      return 'Portal Desbloqueado';
    case 'npc_mentor':
      return 'Consejo del Sabio';
    case 'chest_treasure':
      return 'Cofre de Reliquias';
    case 'altar_shrine':
      return 'Santuario Ancestral';
    case 'merchant_shop':
      return 'Tienda Mística';
    case 'portal_teleport':
      return 'Portal Dimensional';
    case 'campfire_rest':
      return 'Hoguera de Descanso';
    case 'library_codex':
      return 'Códice Prohibido';
    case 'crystal_pylon':
      return 'Pilón de Cristal';
    case 'ruins_ancient':
      return 'Ruinas Olvidadas';
    case 'boss_appearance':
      return '¡Jefe de Mazmorra!';
    case 'corrupted_node':
      return 'Nodo Corrupto';
    case 'magic_barrier':
      return 'Barrera Mágica';
    case 'statue_monument':
      return 'Monumento Titánico';
    case 'cavern_entrance':
      return 'Entrada a la Caverna';
    case 'waterfall_fountain':
      return 'Fuente Restauradora';
    case 'battle_aftermath':
      return 'Vestigios de Batalla';
    case 'mystic_runes':
      return 'Runas de Poder';
    case 'ambient_mystery':
      return 'Misterio de la Penumbra';
    case 'abyss_market':
      return 'Mercado del Abismo';
    case 'evt_codice_arcano':
      return 'Códice Arcano';
    case 'evt_mercader_abismo':
      return 'Mercader del Abismo';
    default:
      final sanitized = sanitizeRetroText(rawTag).trim();
      if (sanitized.isEmpty) {
        return '¡EVENTO DEL DESTINO!';
      }
      if (sanitized.contains('_')) {
        return sanitized.replaceAll('_', ' ').toUpperCase();
      }
      return sanitized;
  }
}

