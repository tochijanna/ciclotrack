# AGENTS.md

## Project state
- **Phase 0 done (base scaffold).** Flutter project `ciclotrack` (Android only) plus feature-folder structure; business features start in Phase 1.
- Active gitflow branches: `main` (initial scaffold) and `develop` (integration). Do not create `feature/*` branches until a real task starts.
- **Toolchain lives inside the repo at `.toolchain/` and is git-ignored:** Flutter 3.32.7 + Android SDK 34 + OpenJDK 17 (system). Before any Flutter command, source the env:
  ```bash
  source .toolchain/env.sh
  ```
- Deleting `.toolchain/` fully uninstalls Flutter/SDK (no system-wide changes).

## Reference docs (in priority order, all in Spanish)
1. `Especificaciones.md` — functional requirements (source of truth for the business domain).
2. `planDeDesarrollo.md` — architecture and phases 0–10.
3. `BUENAS_PRACTICAS.md` — coding conventions, Gitflow, and commit rules.

## Decided stack
- Flutter (installed) + SQLite via **drift**, state management with **Riverpod** (not yet added to pubspec).
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