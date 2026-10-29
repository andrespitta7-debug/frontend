/// Categoría a la que pertenece la mejora roguelite.
enum PerkCategory {
  weapon,
  armor,
  relic,
}

/// Mejora acumulable estilo roguelite (Vampire Survivors) que altera los atributos,
/// modificadores de combate y aspecto del héroe durante la partida.
class RoguelitePerk {
  final String id;
  final String nombre;
  final String descripcion;
  final String sprite;
  final String? weaponSprite;
  final PerkCategory category;
  final String? heroPrefixOverride;
  final bool isEvolution;

  const RoguelitePerk({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.sprite,
    this.weaponSprite,
    this.category = PerkCategory.relic,
    this.heroPrefixOverride,
    this.isEvolution = false,
  });

  static const List<RoguelitePerk> allPerks = [
    // --- ARMAS (6) ---
    RoguelitePerk(
      id: 'iron_sword',
      nombre: 'Espada de Hierro',
      descripcion: 'Espada base inicial forjada en hierro',
      sprite: 'weapon_regular_sword.png',
      weaponSprite: 'weapon_regular_sword.png',
      category: PerkCategory.weapon,
    ),
    RoguelitePerk(
      id: 'knight_broadsword',
      nombre: 'Mandoble Real',
      descripcion: '+20% de daño base con hoja templada',
      sprite: 'weapon_knight_sword.png',
      weaponSprite: 'weapon_knight_sword.png',
      category: PerkCategory.weapon,
    ),
    RoguelitePerk(
      id: 'swift_katana',
      nombre: 'Katana de Compilación',
      descripcion: '+25% de daño y crítico al responder rápido',
      sprite: 'weapon_katana.png',
      weaponSprite: 'weapon_katana.png',
      category: PerkCategory.weapon,
    ),
    RoguelitePerk(
      id: 'vampire_rapier',
      nombre: 'Estoque Carmesí',
      descripcion: '+35% de daño y roba +6 HP al acertar',
      sprite: 'weapon_red_gem_sword.png',
      weaponSprite: 'weapon_red_gem_sword.png',
      category: PerkCategory.weapon,
    ),
    RoguelitePerk(
      id: 'boss_cleaver',
      nombre: 'Hacha Rompe-Escudos',
      descripcion: '+50% de daño contra jefes',
      sprite: 'weapon_double_axe.png',
      weaponSprite: 'weapon_double_axe.png',
      category: PerkCategory.weapon,
    ),
    RoguelitePerk(
      id: 'golden_excalibur',
      nombre: 'Excalibur Dorada (SINERGIA)',
      descripcion: '+65% daño y crítico garantizado (Requiere 1 Arma y 1 Reliquia)',
      sprite: 'weapon_golden_sword.png',
      weaponSprite: 'weapon_golden_sword.png',
      category: PerkCategory.weapon,
      isEvolution: true,
    ),

    // --- ARMADURAS / CLASES VISIBLES (4) ---
    RoguelitePerk(
      id: 'paladin_helm',
      nombre: 'Armadura de Paladín',
      descripcion: 'Equipa el Yelmo con Penacho y reduce 25% el daño recibido',
      sprite: 'knight_f_idle_anim_f0.png',
      heroPrefixOverride: 'knight_f',
      category: PerkCategory.armor,
    ),
    RoguelitePerk(
      id: 'dwarven_plate',
      nombre: 'Coraza Rúnica Enana',
      descripcion: 'Reduce 45% el daño recibido al fallar',
      sprite: 'dwarf_m_idle_anim_f0.png',
      heroPrefixOverride: 'dwarf_m',
      category: PerkCategory.armor,
    ),
    RoguelitePerk(
      id: 'elven_cloak',
      nombre: 'Manto Élfico',
      descripcion: '25% de probabilidad de esquivar contraataques enemigos',
      sprite: 'elf_m_idle_anim_f0.png',
      heroPrefixOverride: 'elf_m',
      category: PerkCategory.armor,
    ),
    RoguelitePerk(
      id: 'archmage_robe',
      nombre: 'Túnica de Archimago',
      descripcion: 'Regenera +1 comodín cada 2 enemigos derrotados',
      sprite: 'wizzard_m_idle_anim_f0.png',
      heroPrefixOverride: 'wizzard_m',
      category: PerkCategory.armor,
    ),

    // --- RELIQUIAS / ELIXIRES (5) ---
    RoguelitePerk(
      id: 'troll_blood',
      nombre: 'Sangre Regenerativa',
      descripcion: 'Cura +10 HP tras acertar',
      sprite: 'flask_big_red.png',
      category: PerkCategory.relic,
    ),
    RoguelitePerk(
      id: 'titan_vitality',
      nombre: 'Elixir de Titán',
      descripcion: '+25 HP Máximo y cura +25 HP al instante',
      sprite: 'flask_big_green.png',
      category: PerkCategory.relic,
    ),
    RoguelitePerk(
      id: 'oracle_essence',
      nombre: 'Esencia del Oráculo',
      descripcion: 'Otorga +1 uso de Pista y +1 uso de 50/50 inmediatamente',
      sprite: 'flask_big_yellow.png',
      category: PerkCategory.relic,
    ),
    RoguelitePerk(
      id: 'berserker_brew',
      nombre: 'Brebaje Berserker',
      descripcion: 'Daño x2 cuando tu vida está por debajo del 50%',
      sprite: 'flask_big_blue.png',
      category: PerkCategory.relic,
    ),
    RoguelitePerk(
      id: 'greed_coin',
      nombre: 'Moneda Maldita',
      descripcion: '+40% daño total, pero los enemigos hacen +10% de daño',
      sprite: 'coin_anim_f0.png',
      category: PerkCategory.relic,
    ),
  ];
}
