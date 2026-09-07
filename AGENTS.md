# AGENTS.md

## Project state
- **Pre-implementation:** documentation only, no source code.
- **Not a git repository yet** (no `git init` has been run). Do not run any git commands until Phase 0 of the plan.
- Flutter and the Android SDK are **not installed** on this system; running `flutter test` / `flutter analyze` requires installing them first. No valid build/test commands exist today.

## Reference docs (in priority order, all in Spanish)
1. `Especificaciones.md` — functional requirements (source of truth for the business domain).
2. `planDeDesarrollo.md` — architecture and phases 0–10.
3. `BUENAS_PRACTICAS.md` — coding conventions, Gitflow, and commit rules.

## Decided stack (not implemented yet)
- Flutter + SQLite via **drift**, state management with **Riverpod**.
- Feature-first architecture, 3 layers per feature: `presentation/` (UI) → `domain/` (pure Dart logic, no Flutter, unit-testable) → `data/` (drift). Shared code lives in `lib/core/`. Unidirectional flow: UI → Notifier → Repository → drift.
- The app is 100 % local/offline, no cloud. No secrets, no sensitive data in logs.

## Mandatory conventions (from BUENAS_PRACTICAS.md)
- Commits follow **Conventional Commits**: `type(scope): description`, imperative lowercase. Types: feat, fix, refactor, test, docs, chore, style, perf, build, ci. Project scopes: `profiles`, `tracking`, `encounters`, `prediction`, `alerts`, `calendar`, `reports`, `backup`, `db`, `settings`.
- **Full Gitflow**: branches `feature/<desc>`, `release/<version>`, `hotfix/<desc>`; `main` is only touched by release/hotfix (no direct merges); SemVer tags `vX.Y.Z`; delete branches after merge.
- Before any commit: `dart format` + clean `flutter analyze` + green tests.
- `domain/` requires mandatory unit tests (prediction engine).
- All UI copy and project docs are in Spanish.

## Working rule
- Follow the phases in `planDeDesarrollo.md` in order; each phase maps to a `feature/...` branch and closes with `test`/`docs` commits.