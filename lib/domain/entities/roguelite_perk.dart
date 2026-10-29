/// Mejora acumulable estilo roguelite (Vampire Survivors) que altera los atributos,
/// modificadores de combate y aspecto del héroe durante la partida.
class RoguelitePerk {
  final String id;
  final String nombre;
  final String descripcion;
  final String sprite;
  final String? weaponSprite;

  const RoguelitePerk({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.sprite,
    this.weaponSprite,
  });

  static const List<RoguelitePerk> allPerks = [
    RoguelitePerk(
      id: 'crimson_edge',
      nombre: 'Filo Carmesí',
      descripcion: '+35% de daño al acertar y equipa la Espada de Gema Roja',
      sprite: 'weapon_red_gem_sword.png',
      weaponSprite: 'weapon_red_gem_sword.png',
    ),
    RoguelitePerk(
      id: 'academic_vampirism',
      nombre: 'Vampirismo Académico',
      descripcion: 'Recupera +8 HP con cada respuesta correcta',
      sprite: 'flask_big_red.png',
    ),
    RoguelitePerk(
      id: 'compile_frenzy',
      nombre: 'Frenesí de Compilación',
      descripcion: 'Acertar rápido otorga probabilidad de Golpe Crítico y equipa la Katana',
      sprite: 'weapon_katana.png',
      weaponSprite: 'weapon_katana.png',
    ),
    RoguelitePerk(
      id: 'alchemical_refill',
      nombre: 'Recarga Alquímica',
      descripcion: 'Recarga +1 uso de Pista o 50/50 inmediatamente',
      sprite: 'flask_big_yellow.png',
    ),
    RoguelitePerk(
      id: 'dwarven_armor',
      nombre: 'Armadura Enana',
      descripcion: 'Reduce un 40% el daño recibido al fallar',
      sprite: 'dwarf_m_idle_anim_f0.png',
    ),
  ];
}

