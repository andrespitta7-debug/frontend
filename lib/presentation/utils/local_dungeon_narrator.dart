import 'dart:math';

/// Generador determinista de narrativa y descripciones de mazmorra oscura
/// local para desacoplar a la IA de la generación de texto procedural.
class LocalDungeonNarrator {
  static final Random _rng = Random();

  static const List<String> _introTemplates = [
    'Caes por el portal hacia {title}. Domina {topic} para sobrevivir.',
    'El abismo arcano se abre ante ti en {title}. El dominio de {topic} es tu único escudo.',
    'Despiertas en las criptas olvidadas de {title}. Solo descifrando {topic} podrás regresar.',
    'Las puertas de {title} se sellan tras de ti. Aplica tus conocimientos en {topic} para salir con vida.',
  ];

  static const List<String> _walkingTemplates = [
    'Avanzas con cautela por el pasillo de piedra húmeda...',
    'Las antorchas parpadean mientras desciendes al siguiente sector...',
    'El eco de tus pasos resuena en las catacumbas silenciosas...',
    'Un viento gélido susurra secretos olvidados en la penumbra...',
    'Polvo ancestral cae de las bóvedas al compás de tu marcha...',
    'Runas arcanas brillan débilmente grabadas en los muros de piedra...',
    'Sortéas escombros y cadenas mohosas en busca de la salida...',
  ];

  static const List<String> _encounterTemplates = [
    '¡Un {enemy} emerge de las sombras y bloquea tu camino!',
    '¡Cuidado! Un {enemy} ruge sediento de combate.',
    '¡La silueta de un {enemy} se abalanza desde la penumbra!',
    '¡Un hostil {enemy} desenfunda sus garras frente a ti!',
  ];

  static const List<String> _victoryTemplates = [
    '¡El {enemy} se desploma! El camino queda despejado.',
    'Has purgado al {enemy} de la faz de la mazmorra.',
    'El alma corrupta del {enemy} se disuelve en cenizas oscuras.',
    '¡Victoria! El {enemy} cae derrotado ante tu destreza.',
  ];

  /// Genera una introducción inmersiva combinando el título y tema de la misión.
  static String getIntroText(String questTitle, String resolvedTopic) {
    final template = _introTemplates[_rng.nextInt(_introTemplates.length)];
    return template
        .replaceAll('{title}', questTitle)
        .replaceAll('{topic}', resolvedTopic);
  }

  /// Retorna un texto de transición para el pasillo de marcha.
  static String getWalkingText([int? seed]) {
    final random = seed != null ? Random(seed) : _rng;
    return _walkingTemplates[random.nextInt(_walkingTemplates.length)];
  }

  /// Retorna un texto al iniciar combate contra un enemigo específico.
  static String getEncounterText(String enemyName) {
    final template = _encounterTemplates[_rng.nextInt(_encounterTemplates.length)];
    return template.replaceAll('{enemy}', enemyName);
  }

  /// Retorna un texto al derrotar al enemigo.
  static String getVictoryText(String enemyName) {
    final template = _victoryTemplates[_rng.nextInt(_victoryTemplates.length)];
    return template.replaceAll('{enemy}', enemyName);
  }

  /// Genera un pool narrativo local completo con las 8 categorías esperadas
  /// para sustituir o rellenar si la API no entrega `pool_narrativo`.
  static Map<String, dynamic> generateDefaultPool({
    required String questTitle,
    required String resolvedTopic,
  }) {
    return {
      'intro': [
        'Caes por el portal hacia $questTitle. Domina $resolvedTopic para sobrevivir.',
        'El abismo arcano se abre en $questTitle. Comprender $resolvedTopic es tu única salvación.',
        'Las criptas de $questTitle retumban; tus conocimientos en $resolvedTopic serán puestos a prueba.',
      ],
      'entre_combates': [
        'Avanzas con cautela por el pasillo de piedra húmeda...',
        'Las antorchas parpadean mientras desciendes al siguiente sector...',
        'El eco de tus pasos resuena en las catacumbas silenciosas...',
      ],
      'jefe_avistado': [
        '¡Una presencia titánica distorsiona el aire! El guardián supremo despierta.',
        'Los muros tiemblan. La criatura más temible de la cripta te espera en la cámara principal.',
        'Ojos ardientes emergen del vacío: te enfrentas al desafío definitivo.',
      ],
      'ronda_completada': [
        '¡Has purgado a las aberraciones de este sector! Respira hondo.',
        'El aire se aclara momentáneamente tras abatir al guardián.',
        'Una calma tensa envuelve la cámara tras tu rotunda victoria.',
      ],
      'retirada': [
        'Decides retroceder hacia la superficie con los tesoros y conocimientos recolectados.',
        'Te repliegas a tiempo para conservar tus puntos y honores de batalla.',
        'Escapas por una grieta antes de que las sombras cierren tu camino.',
      ],
      'muerte': [
        'Tus fuerzas se extinguen en la oscuridad... La mazmorra reclama otra alma.',
        'Caes derrotado en el frío suelo de piedra.',
        'El eco de tu última batalla se desvanece en el olvido.',
      ],
      'critico': [
        '¡Un golpe certero e implacable hiere de gravedad al enemigo!',
        '¡Canalizas un impacto crítico devastador!',
        '¡Tu respuesta precisa atraviesa las defensas de la bestia!',
      ],
      'acierto': [
        'Tu razonamiento es certero y dañas al enemigo.',
        'El golpe conecta sólidamente.',
        'Un impacto limpio debilita a la criatura.',
      ],
    };
  }
}

