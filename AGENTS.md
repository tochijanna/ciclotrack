# AGENTS.md

## Project state
- **Phase 1 done (db + prediction).** On `develop`. Drift schema (7 tables), feature DAOs and prediction engine are implemented and tested. Business UI starts in Phase 2.
- Active gitflow branches: `main` (release history) and `develop` (integration). `feature/*` branches are created per phase task and merged into `develop`.
- **Toolchain lives inside the repo at `.toolchain/` and is git-ignored:** Flutter 3.32.7 + Android SDK 34 + OpenJDK 17 (system). Before any Flutter command, source the env:
  ```bash
  source .toolchain/env.sh
  ```
- **Codegen:** after editing drift tables or DAOs, regenerate before testing:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Deleting `.toolchain/` fully uninstalls Flutter/SDK (no system-wide changes).
- Drift version pinned to `2.31.0` (Dart 3.8.1); newer drift/riverpod require Dart ≥3.10 — do not bump without a Dart upgrade.

## Reference docs (in priority order, all in Spanish)
1. `Especificaciones.md` — functional requirements (source of truth for the business domain).
2. `planDeDesarrollo.md` — architecture and phases 0–10.
3. `BUENAS_PRACTICAS.md` — coding conventions, Gitflow, and commit rules.

## Decided stack
- Flutter (installed) + SQLite via **drift** (2.31.0), state management with **Riverpod** (flutter_riverpod 2.6.1, already in pubspec).
- Feature-first architecture, 3 layers per feature: `presentation/` (UI) → `domain/` (pure Dart logic, no Flutter, unit-testable) → `data/` (drift). Shared code lives in `lib/core/`. Unidirectional flow: UI → Notifier → Repository → drift.
- Prediction engine lives in `lib/features/prediction/domain/`; estimated ovulation = average cycle − 14 (standard luteal phase), fertility window = ovulation −5 / +2, defaults 24–32/28.
- The app is 100 % local/offline, no cloud. No secrets, no sensitive data in logs.

## Mandatory conventions (from BUENAS_PRACTICAS.md)
- Commits follow **Conventional Commits**: `type(scope): description`, imperative lowercase. Types: feat, fix, refactor, test, docs, chore, style, perf, build, ci. Project scopes: `profiles`, `tracking`, `encounters`, `prediction`, `alerts`, `calendar`, `reports`, `backup`, `db`, `settings`.
- **Full Gitflow**: branches `feature/<desc>`, `release/<version>`, `hotfix/<desc>`; `main` is only touched by release/hotfix (no direct merges); SemVer tags `vX.Y.Z`; delete branches after merge.
- Before any commit: `dart format` + clean `flutter analyze` + green tests.
- `domain/` requires mandatory unit tests (prediction engine).
- All UI copy and project docs are in Spanish.

## Working rule
- Follow the phases in `planDeDesarrollo.md` in order; each phase maps to a `feature/...` branch and closes with `test`/`docs` commits.