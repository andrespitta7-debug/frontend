# Continuación SysQuest

Este archivo guarda el estado actual del proyecto para poder continuar sin repetir todo el contexto.

## Estado actual
- Fecha: 2026-09-21
- Último punto validado: flutter test test/progreso_usecase_test.dart
- Proyecto: SysQuest
- Estado funcional: lógica de progresión y combate corregida y validada
- Qué quedó hecho:
  - se corrigió la lógica de progreso y partidas
  - se añadió manejo consistente de partidas jugadas
  - se reforzó la lógica de daño en combate y boss
  - se validó con pruebas del dominio
- Qué falta:
  - generación de quests por tema
  - fallback local si falla la IA
  - conectar la quest generada al flujo real de combate
  - seguir priorizando lógica funcional antes que UI
- Próximo paso:
  - crear caso de uso para generar quest por tema
  - definir fallback local de preguntas
  - conectar la quest a combate real
- Archivos clave:
  - [lib/main.dart](lib/main.dart)
  - [lib/domain/usecases/finalizar_partida_usecase.dart](lib/domain/usecases/finalizar_partida_usecase.dart)
  - [lib/domain/usecases/responder_encuentro_usecase.dart](lib/domain/usecases/responder_encuentro_usecase.dart)
  - [lib/presentation/screens/combate/combate_controller.dart](lib/presentation/screens/combate/combate_controller.dart)
  - [SysQuest_Arquitectura.md](SysQuest_Arquitectura.md)
  - [SysQuest_Contexto_Maestro.md](SysQuest_Contexto_Maestro.md)
- Observaciones:
  - la arquitectura debe seguirse estrictamente
  - no tocar Supabase, web admin ni multijugador todavía
  - el trabajo debe ser incremental y validado
- Bloqueadores:
  - ninguno funcional importante; pendiente siguiente bloque: quest generation

## Reglas vigentes
- Seguir [SysQuest_Arquitectura.md](SysQuest_Arquitectura.md)
- Seguir [SysQuest_Contexto_Maestro.md](SysQuest_Contexto_Maestro.md)
- Priorizar lógica funcional antes que estética
- No tocar web/admin ni Supabase todavía
- Validar con flutter analyze y pruebas pequeñas

## Historial de sesión
### 2026-09-21
- Estado: proyecto funcionando en lógica de progreso y combate
- Validado: flutter test test/progreso_usecase_test.dart
- Siguiente paso: generación de quests por tema con fallback local
- Notas: continuar desde aquí sin repetir todo el contexto

