class VisualScene {
  final String biomeTag;
  final String visualTag;
  final String animationMode;
  final String screenEffect;
  final String tintHex;

  const VisualScene({
    required this.biomeTag,
    required this.visualTag,
    required this.animationMode,
    required this.screenEffect,
    required this.tintHex,
  });

  factory VisualScene.fromJson(Map<String, dynamic> json) {
    return VisualScene(
      biomeTag: json['biome_tag'] as String? ?? json['biomeTag'] as String? ?? '',
      visualTag: json['visual_tag'] as String? ?? json['visualTag'] as String? ?? '',
      animationMode: json['animation_mode'] as String? ?? json['animationMode'] as String? ?? 'idle',
      screenEffect: json['screen_effect'] as String? ?? json['screenEffect'] as String? ?? 'none',
      tintHex: json['tint_hex'] as String? ?? json['tintHex'] as String? ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toJson() => {
    'biome_tag': biomeTag,
    'visual_tag': visualTag,
    'animation_mode': animationMode,
    'screen_effect': screenEffect,
    'tint_hex': tintHex,
  };
}

class NarrativeData {
  final String title;
  final String storyText;
  final String educationalHint;

  const NarrativeData({
    required this.title,
    required this.storyText,
    required this.educationalHint,
  });

  factory NarrativeData.fromJson(Map<String, dynamic> json) {
    return NarrativeData(
      title: json['title'] as String? ?? '',
      storyText: json['story_text'] as String? ?? json['storyText'] as String? ?? '',
      educationalHint: json['educational_hint'] as String? ?? json['educationalHint'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'story_text': storyText,
    'educational_hint': educationalHint,
  };
}

class EventChoice {
  final String id;
  final String label;
  final String consequenceType;

  const EventChoice({
    required this.id,
    required this.label,
    required this.consequenceType,
  });

  factory EventChoice.fromJson(Map<String, dynamic> json) {
    return EventChoice(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      consequenceType: json['consequence_type'] as String? ?? json['consequenceType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'consequence_type': consequenceType,
  };
}

class GameEvent {
  final String eventId;
  final VisualScene visualScene;
  final NarrativeData narrative;
  final List<EventChoice> choices;

  const GameEvent({
    required this.eventId,
    required this.visualScene,
    required this.narrative,
    required this.choices,
  });

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'] as List<dynamic>?;
    final choicesList = rawChoices != null
        ? rawChoices
            .map((e) => EventChoice.fromJson(e as Map<String, dynamic>))
            .toList()
        : <EventChoice>[];

    final visualSceneMap = json['visual_scene'] as Map<String, dynamic>? ??
        json['visualScene'] as Map<String, dynamic>?;
    final narrativeMap = json['narrative'] as Map<String, dynamic>?;

    return GameEvent(
      eventId: json['event_id'] as String? ?? json['eventId'] as String? ?? '',
      visualScene: visualSceneMap != null
          ? VisualScene.fromJson(visualSceneMap)
          : const VisualScene(
              biomeTag: '',
              visualTag: '',
              animationMode: 'idle',
              screenEffect: 'none',
              tintHex: '#FFFFFF',
            ),
      narrative: narrativeMap != null
          ? NarrativeData.fromJson(narrativeMap)
          : const NarrativeData(
              title: '',
              storyText: '',
              educationalHint: '',
            ),
      choices: choicesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'visual_scene': visualScene.toJson(),
    'narrative': narrative.toJson(),
    'choices': choices.map((c) => c.toJson()).toList(),
  };
}

