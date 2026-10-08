# AGENTS.md

## Project state
- **Phases 0–10 done; current release is v1.2.0** (`version: 1.2.0+4`; tags `v1.0.0`, `v1.0.1`, `v1.1.0`, `v1.1.1`, `v1.2.0` on `main`; `develop` is the integration branch). Scope: scaffold + gitflow, drift schema + prediction engine, profiles, tracking, encounters, alerts with local notifications, consolidated calendar views, reports and statistics, manual backup, medication, personalized reminders and settings/polish.
- Drift schema **v4, 11 tables**: `women`, `tags`, `woman_tags`, `period_logs`, `ovulation_logs`, `symptoms`, `encounters`, `encounter_women`, `reminders`, `alert_settings`, `medications`. Migration v3 → v4 creates `medications`; a JSON backup written in the v3 format still imports (its `medications` table arrives empty).
- Consolidated views live in `lib/features/calendar/`: week/month grid on `table_calendar`, fertility and encounters views, opened from the calendar icon in the profile list. `CycleTimeline` (`lib/features/prediction/domain/cycle_timeline.dart`) answers phase/fertile window for **any** date, and flags projected cycles as estimated.
- Reports live in `lib/features/reports/`: pure aggregation in `domain/report_builder.dart` over the calendar board (extended with each woman's period logs) and fl_chart graphs in `presentation/`, opened from the insights icon. Charts are not asserted pixel-wise: the numbers are tested in the domain and the widgets only as present.
- Backup lives in `lib/features/backup/`: full JSON export/import (with confirmation), a ZIP of one CSV per table and an A4 PDF report, opened from the backup icon. JSON is the only lossless format; CSV/PDF are human-readable only. Restores replace everything inside one transaction.
- Medication lives in `lib/features/medications/` (per-woman daily dose + time) and adds `AlertType.medicacion`. Personalized reminders live in `lib/features/settings/` (per-woman cycle-day range, one notification per cycle) and do not depend on the alerts master switch. Alert notification ids are reserved to `[100000, 999999]` and reminder ids start at `1000000` (`lib/features/alerts/domain/alert_item.dart`, `lib/features/settings/data/reminder_notifier.dart`).
- Since v1.1.0: optional app lock in `lib/features/settings/presentation/` (`app_lock_provider.dart`, `app_lock_screen.dart`) using the system PIN/biometrics via `local_auth`, with the on/off flag in `shared_preferences`; Android backup is disabled (`android:allowBackup="false"`); notification bodies show initials instead of names and the channels use secret lock-screen visibility; release builds are signed with a dedicated keystore.
- Since v1.2.0: English localization with Spanish fallback. Strings live in `lib/l10n/` (`app_es.arb`, `app_en.arb`, generated `app_localizations*.dart`); add new UI copy to both ARB files instead of hard-coding it.
- **No open phase.** The only unverified area is on-device behaviour (real delivery/timing of notifications, Android permissions, SAF picker, icon and label): it needs a physical Android device or an emulator with a system image, and neither exists in this environment (`adb devices` empty, no `emulator/` or `system-images/` under the SDK). See `planDeDesarrollo.md`.
- Active gitflow branches: `main` (release history) and `develop` (integration). `feature/*` branches are created per phase task and merged into `develop`.
- **The toolchain is git-ignored and normally lives outside the checkout:** the canonical install is `/home/tochi/Proyectos/CalendarioMenstrual/.toolchain/` (Flutter 3.47.4 + Android SDK platform 36.0.0, build-tools 36.0.0) with OpenJDK 17 from the system (`/usr/lib/jvm/java-17-openjdk`; JDK 17+ — Jenkins usa JDK 21). Fresh clones and Orca worktrees do not carry it, so source the absolute env script before any Flutter/Dart command (adjust the path if your checkout keeps it elsewhere):
  ```bash
  source /home/tochi/Proyectos/CalendarioMenstrual/.toolchain/env.sh
  ```
- **Codegen:** after editing drift tables or DAOs, regenerate before testing:
  ```bash
  dart run build_runner build
  ```
- Deleting `.toolchain/` fully uninstalls Flutter/SDK (no system-wide changes) (in this checkout, deleting it means deleting that absolute directory).
- Dependencies aligned to Dart 3.13.3: `drift 2.35.1` (+ `drift_flutter 0.3.1`), `sqlite3 3.7.0` (native assets/build hooks), `fl_chart 1.2.0`, `pdf 3.12.0`, `archive 4.0.9`, `csv 8.0.0`, `file_picker 13.1.0`. Version solving and `flutter analyze` are not enough: verify every new dependency by compiling a widget test **and** `flutter build apk`.

## Reference docs (in priority order, all in Spanish)
1. `Especificaciones.md` — functional requirements (source of truth for the business domain).
2. `planDeDesarrollo.md` — architecture and phases 0–10.
3. `BUENAS_PRACTICAS.md` — coding conventions, Gitflow, and commit rules.
4. `fixs.md` — historical fix backlog (F-01…F-19) plus the coverage plan; every item is resolved. Read it for past decisions and test-harness rules, not as pending work.

## Decided stack
- Flutter + SQLite via **drift** (2.35.1), state management with **Riverpod** (flutter_riverpod 2.6.1, already in pubspec).
- Feature-first architecture, 3 layers per feature: `presentation/` (UI) → `domain/` (pure Dart logic, no Flutter, unit-testable) → `data/` (drift). Shared code lives in `lib/core/`. Unidirectional flow: UI → Notifier → Repository → drift.
- Prediction engine lives in `lib/features/prediction/domain/`; estimated ovulation = average cycle − 14 (standard luteal phase), fertility window = ovulation −5 / +2, defaults 24–32/28.
- Local notifications via **flutter_local_notifications 20.1.0** + **timezone / flutter_timezone**; pending alerts are recomputed at start-up and after any period, encounter or settings change.
- Shared runtime helpers: `lib/core/db/` (database + providers) and `lib/core/time/clock.dart` (`clockProvider`, injectable clock for tests).
- Navigation uses plain `MaterialPageRoute` throughout (the settings hub and the profile-list overflow menu): `go_router` was never needed and is not installed. Backup uses `csv` 8.0.0 + `pdf` 3.12.0 + `archive` 4.0.9 + `file_picker` 13.1.0 (no `share_plus`: the system picker already writes anywhere). `pdf` stays below 3.13 (3.13+ requires `xml 7.x`, incompatible with `flutter_local_notifications 20.1.0`) and `archive` below 4.1 (what `pdf` 3.12 allows).
- The app is 100 % local/offline, no cloud. No secrets, no sensitive data in logs.

## Mandatory conventions (from BUENAS_PRACTICAS.md)
- Commits follow **Conventional Commits**: `type(scope): description`, imperative lowercase. Types: feat, fix, refactor, test, docs, chore, style, perf, build, ci. Project scopes: `profiles`, `tracking`, `encounters`, `prediction`, `alerts`, `calendar`, `reports`, `backup`, `db`, `settings`.
- **Full Gitflow**: branches `feature/<desc>`, `release/<version>`, `hotfix/<desc>`; `main` is only touched by release/hotfix (no direct merges); SemVer tags `vX.Y.Z`; delete branches after merge.
- Before any commit: `dart format` + clean `flutter analyze` + green tests.
- `domain/` requires mandatory unit tests (prediction engine).
- Widget tests touching drift must close the database with `closeTestDatabase` / `await tester.runAsync(() => db.close())` inside the test body, **never** `addTearDown(db.close)`, and seed/read the DB inside `tester.runAsync`. Reuse `test/support/widget_harness.dart` (seeds for women, periods, encounters, ovulation and symptoms) and `fixedClock(DateTime)` to pin "today"; details and rationale in `fixs.md`.
- All UI copy and project docs are in Spanish.

## Working rule
- Follow the phases in `planDeDesarrollo.md` in order; each phase maps to a `feature/...` branch merged into `develop` and closes with `test`/`docs` commits. Phases 0–10 are closed (first released as `v1.0.0`; current release `v1.2.0`); new work starts on a `feature/` branch from `develop` and reaches `main` only through `release/` or `hotfix/` plus a tag.
- Remoto `origin` en GitHub: `https://github.com/tochijanna/ciclotrack.git`. Las ramas `main` y `develop` ya han sido pushadas.
