# AGENTS.md

## Project state
- **Phases 0–9 done** (scaffold + gitflow, drift schema + prediction engine, profiles, tracking, encounters, alerts with local notifications, consolidated calendar views, reports and statistics, manual backup). On `develop`.
- Drift schema **v3, 10 tables**: `women`, `tags`, `woman_tags`, `period_logs`, `ovulation_logs`, `symptoms`, `encounters`, `encounter_women`, `reminders`, `alert_settings`. Feature DAOs, prediction engine, business UI and notification scheduling are implemented and tested.
- Consolidated views live in `lib/features/calendar/`: week/month grid on `table_calendar`, fertility and encounters views, opened from the calendar icon in the profile list. `CycleTimeline` (`lib/features/prediction/domain/cycle_timeline.dart`) answers phase/fertile window for **any** date, and flags projected cycles as estimated.
- Reports live in `lib/features/reports/`: pure aggregation in `domain/report_builder.dart` over the calendar board (extended with each woman's period logs) and fl_chart graphs in `presentation/`, opened from the insights icon. Charts are not asserted pixel-wise: the numbers are tested in the domain and the widgets only as present.
- Backup lives in `lib/features/backup/`: full JSON export/import (with confirmation), a ZIP of one CSV per table and an A4 PDF report, opened from the backup icon. JSON is the only lossless format; CSV/PDF are human-readable only. Restores replace everything inside one transaction.
- **Open work: phase 10** (medication + polish). See `planDeDesarrollo.md`.
- Active gitflow branches: `main` (release history) and `develop` (integration). `feature/*` branches are created per phase task and merged into `develop`.
- **Toolchain lives inside the repo at `.toolchain/` and is git-ignored:** Flutter 3.32.7 + Android SDK platforms 34/35 (build-tools 34.0.0) + OpenJDK 17 (system, `/usr/lib/jvm/java-17-openjdk`). Before any Flutter command, source the env:
  ```bash
  source .toolchain/env.sh
  ```
- **Codegen:** after editing drift tables or DAOs, regenerate before testing:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Deleting `.toolchain/` fully uninstalls Flutter/SDK (no system-wide changes).
- Drift version pinned to `2.31.0` (Dart 3.8.1); newer drift/riverpod require Dart ≥3.10 — do not bump without a Dart upgrade. Same for `fl_chart`: exactly `1.0.0`, because 1.1.x resolves but **does not compile** against the `vector_math 2.1.4` the SDK pins. Version solving and `flutter analyze` are not enough: verify every new dependency by compiling a widget test **and** `flutter build apk`.

## Reference docs (in priority order, all in Spanish)
1. `Especificaciones.md` — functional requirements (source of truth for the business domain).
2. `planDeDesarrollo.md` — architecture and phases 0–10.
3. `BUENAS_PRACTICAS.md` — coding conventions, Gitflow, and commit rules.
4. `fixs.md` — historical fix backlog (F-01…F-19) plus the coverage plan; every item is resolved. Read it for past decisions and test-harness rules, not as pending work.

## Decided stack
- Flutter + SQLite via **drift** (2.31.0), state management with **Riverpod** (flutter_riverpod 2.6.1, already in pubspec).
- Feature-first architecture, 3 layers per feature: `presentation/` (UI) → `domain/` (pure Dart logic, no Flutter, unit-testable) → `data/` (drift). Shared code lives in `lib/core/`. Unidirectional flow: UI → Notifier → Repository → drift.
- Prediction engine lives in `lib/features/prediction/domain/`; estimated ovulation = average cycle − 14 (standard luteal phase), fertility window = ovulation −5 / +2, defaults 24–32/28.
- Local notifications via **flutter_local_notifications 20.1.0** + **timezone / flutter_timezone**; pending alerts are recomputed at start-up and after any period, encounter or settings change.
- Shared runtime helpers: `lib/core/db/` (database + providers) and `lib/core/time/clock.dart` (`clockProvider`, injectable clock for tests).
- Not installed yet, added per phase: `go_router` only if needed. Backup uses `csv` 6.0.0 + `pdf` 3.11.3 + `archive` 3.6.1 + `file_picker` 11.0.3 (no `share_plus`: the system picker already writes anywhere). `pdf` must stay below 3.12 (needs `vector_math ^2.2`) and `archive` below 4.1 (what `pdf` allows).
- The app is 100 % local/offline, no cloud. No secrets, no sensitive data in logs.

## Mandatory conventions (from BUENAS_PRACTICAS.md)
- Commits follow **Conventional Commits**: `type(scope): description`, imperative lowercase. Types: feat, fix, refactor, test, docs, chore, style, perf, build, ci. Project scopes: `profiles`, `tracking`, `encounters`, `prediction`, `alerts`, `calendar`, `reports`, `backup`, `db`, `settings`.
- **Full Gitflow**: branches `feature/<desc>`, `release/<version>`, `hotfix/<desc>`; `main` is only touched by release/hotfix (no direct merges); SemVer tags `vX.Y.Z`; delete branches after merge.
- Before any commit: `dart format` + clean `flutter analyze` + green tests.
- `domain/` requires mandatory unit tests (prediction engine).
- Widget tests touching drift must close the database with `closeTestDatabase` / `await tester.runAsync(() => db.close())` inside the test body, **never** `addTearDown(db.close)`, and seed/read the DB inside `tester.runAsync`. Reuse `test/support/widget_harness.dart` (seeds for women, periods, encounters, ovulation and symptoms) and `fixedClock(DateTime)` to pin "today"; details and rationale in `fixs.md`.
- All UI copy and project docs are in Spanish.

## Working rule
- Follow the phases in `planDeDesarrollo.md` in order; each phase maps to a `feature/...` branch merged into `develop` and closes with `test`/`docs` commits. Phases 0–9 are closed; **phase 10 is the open work**.
- Remoto `origin` en GitHub: `https://github.com/tochijanna/ciclotrack.git`. Las ramas `main` y `develop` ya han sido pushadas.
