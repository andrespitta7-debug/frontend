# AGENTS.md - SysQuest Frontend

This file is the permanent working manual for code agents contributing to the SysQuest frontend repository.

## Project Context

SysQuest is an educational gamified application for university students. The MVP direction is a 2D pixel-art turn-based RPG where a user enters a technical topic and receives a dynamically generated quest.

Core product loop:

1. User signs up or logs in.
2. User enters a technical topic.
3. Backend generates or retrieves a quest for that topic.
4. The quest contains encounters.
5. Each encounter presents a multiple-choice question.
6. The player answers.
7. Answer quality affects combat.
8. Enemies scale in difficulty.
9. A basic boss appears at the end.
10. Player progress is saved.

## Stack

Frontend repository:

- Flutter.
- Dart.
- Android target for the current cycle.
- Local persistence with SQLite through `sqflite`.

Backend repository:

- Supabase.
- PostgreSQL.
- Supabase Auth.
- Server-side AI generation through Gemini or Groq.

Important rule: the frontend must never call the AI provider directly. AI keys and provider calls belong only behind backend-controlled services.

## Frontend Architecture

Use this responsibility flow:

```text
Flutter UI
  -> Presentation / Controllers
  -> Application / Services
  -> Repositories
  -> Local DB / Remote API
```

Recommended frontend areas:

- `presentation`: screens, widgets, controllers, and view models.
- `application`: use cases for auth, quest loading, combat flow, and progress sync.
- `domain`: entities and value objects for quests, encounters, player state, enemies, items, and progress.
- `data`: repository implementations, Supabase client, backend API client, and SQLite data sources.
- `core`: configuration, routing, errors, constants, and shared utilities.

Quest generation flow:

```text
Flutter
  -> Backend
  -> AI Provider
  -> Quest JSON
  -> Backend
  -> Flutter
```

Fallback flow:

```text
Flutter
  -> Backend
  -> Fallback local/pre-generated content
  -> Quest JSON
  -> Flutter
```

## Coding Rules

- Keep changes small and tied to one Jira issue.
- Do not implement future-scope features without explicit approval.
- Separate UI, controllers, application logic, repositories, and data sources.
- Keep widgets focused and avoid embedding business logic directly in UI code.
- Validate backend responses before applying gameplay state changes.
- Prefer simple, testable modules over broad abstractions.
- Document significant architecture decisions before implementing them.
- Do not remove existing code automatically when requirements conflict; document the contradiction first.

## Security Rules

- Never hardcode API keys, passwords, tokens, Supabase keys beyond safe public anon config, or AI provider credentials.
- Use environment variables or platform-safe configuration for sensitive values.
- Commit `.env.example`, not `.env`.
- Do not call Gemini, Groq, or any AI provider directly from Flutter.
- Treat remote quest data as untrusted until validated.
- Avoid logging tokens, user data, or generated content that may contain sensitive text.

## Git Rules

- Never work directly on `main`.
- Use one branch per Jira task.
- Branch format: `feature/SQ-XXX-description`.
- Commit messages must include the Jira id, for example: `SQ-001 add frontend audit docs`.
- Keep commits small and reviewable.
- Pull requests must include:
  - Summary.
  - Changes made.
  - Tests run.
  - Possible risks.
  - Related Jira tasks.

## Testing Rules

- Add or update tests for any frontend behavior.
- For scaffold-only or documentation-only changes, state that no runtime tests were applicable.
- Add unit tests around controllers/use cases before gameplay rules become complex.
- Add repository/data-source tests for local SQLite persistence.
- Add contract tests or fixtures for quest JSON before integrating AI-generated content.
- Do not merge feature code without at least basic automated validation.

## Current MVP Scope

Included:

- Register/login.
- App/web synchronization through Supabase Auth.
- Functional turn-based combat.
- AI-generated quest from a free topic.
- Local fallback content.
- Local and remote progress.
- 2-3 character skins by gender.
- Basic boss.
- Basic hints/items.
- Bilingual informational web page.
- Basic admin panel.

Out of scope:

- Local multiplayer.
- Complete layered equipment system.
- Advanced animations.
- iOS.
- Complete monetization.

## Ambiguous Decisions

When a decision is unclear:

1. Check this file and `docs/INITIAL_TECHNICAL_AUDIT.md` first.
2. If the decision affects architecture, security, cost, provider choice, data contracts, or repository ownership, document the options.
3. Do not silently choose a path that creates lock-in or exposes credentials.
4. Ask for human confirmation when the tradeoff materially affects product direction.

## Documentation Rules

- Keep architecture decisions in `docs/`.
- Update documentation in the same branch as the related change.
- Record assumptions when requirements are incomplete.
- Keep setup instructions current whenever dependencies or environment variables change.

## First Recommended Slice

Start with authentication/session foundation:

```text
Register/Login
  -> Flutter
  -> Supabase Auth
  -> local session persistence
  -> main screen
```

Frontend responsibilities for that slice are limited to Flutter scaffold, register/login UI, Supabase Auth integration, local session persistence, and main-screen routing. Do not begin quest generation, combat, or admin features until the slice is reviewed and accepted.
