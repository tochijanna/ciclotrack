# Buenas Prácticas del Proyecto

Este documento define las buenas prácticas del proyecto **Calendario Menstrual** en tres apartados:

1. [Buenas prácticas de programación](#1-buenas-prácticas-de-programación)
2. [Gitflow para la gestión de ramas](#2-gitflow-para-la-gestión-de-ramas)
3. [Estructura de los commits (Conventional Commits)](#3-estructura-de-los-commits-conventional-commits)

---

## 1. Buenas prácticas de programación

### 1.1 Arquitectura

- Se sigue el patrón **feature-first** con 3 capas por feature, tal y como define `planDeDesarrollo.md`:

```
lib/features/<feature>/
├── presentation/  → UI (screens, widgets), widgets conectados a Riverpod
├── domain/        → lógica pura de negocio, SIN dependencias de Flutter
└── data/          → drift (SQLite), repositorios que exponen streams
```

- **Una feature no debe importar las capas internas de otra**; si hay código compartido vive en `lib/core/`.
- La capa `domain/` es 100 % pura (testeable sin Flutter) y contiene reglas como el motor de predicción.

### 1.2 Estado y flujo de datos

- Estado gestionado exclusivamente con **Riverpod** (`Notifier`/`Provider`). Prohibido el uso de `setState` para estado global.
- El flujo es siempre **unidireccional**: UI → `Notifier` → `Repository` → drift (SQLite) → stream → UI.
- Las consultas de drift se exponen como `Stream`s a través de los repositorios; la UI nunca accede a los DAOs directamente.

### 1.3 Estilo de código Dart

- Nombrado: clases/enums **PascalCase**; métodos, atributos y variables **camelCase**; privados con prefijo `_`.
- Preferir la **inmutabilidad**: `final` por defecto, colecciones inmutables, evitar variables mutables cuando no sea necesario.
- **Sin comentarios de relleno** (evitar `// getter` o explicar lo obvio). El código debe ser autoexplicativo con nombres expresivos. Si hace falta documentar el "por qué", usa `///` en doc-comments.
- Organización de imports: primero `dart:` → después `package:` → finalmente relativos; cada grupo separado por una línea en blanco.
- Ejecutar `dart format` tras cada cambio antes de commitear.

### 1.4 Análisis estático y linting

- Mantener `flutter analyze` **sin warnings ni errores** antes de todo commit.
- Usar `flutter_lints` (lints oficiales) como base; ampliar el set de lints si se acuerda en equipo.

### 1.5 Testing

- **El `domain/` es sagrado:** tests unitarios obligatorios (p. ej. motor de predicción: caso 28 días 24–32 de la spec, extremos, ausencia de datos).
- Cada fase del plan de desarrollo se cierra con sus tests (`test` para lógica, `widget tests` para UI crítica).
- Nuevas funcionalidades sin tests no se consideran terminadas.

### 1.6 Privacidad y seguridad de datos

- **Los datos son 100 % locales** (diseño por specs): nada de logs que contengan contenido sensible (nombres, notas privadas, registros de encuentros).
- El backup es siempre **manual y explícito** (export), nunca automático (según specs).
- No se introducen secretos ni claves en el código; nada apunta a servicios en la nube.

---

## 2. Gitflow para la gestión de ramas

### 2.1 Ramas permanentes

| Rama | Finalidad |
|---|---|
| `main` | Producción. Siempre estable, cada versión etiquetada con `vX.Y.Z`. |
| `develop` | Integración. Todas las features confluyen aquí hasta formar una release. |

### 2.2 Ramas temporales

| Rama | Origen | Destino | Convención de nombre |
|---|---|---|---|
| Feature | `develop` | `develop` | `feature/<id-o-descripcion-corta>` |
| Release | `develop` | `main` | `release/<version>` (ej. `release/1.0.0`) |
| Hotfix | `main` | `main` **y** `develop` | `hotfix/<id-o-descripcion-corta>` |

### 2.3 Reglas de flujo

1. **Nunca** se integra directamente sobre `main`. Solo `release/*` o `hotfix/*` tocan `main`.
2. Toda funcionalidad nueva (cada fase o tarea de `planDeDesarrollo.md`) se desarrolla en su propia rama `feature/*` y se fusiona a `develop`.
3. Antes del merge de una feature: `flutter analyze` limpio, tests verdes, `dart format` aplicado y auto-revisión completada.
4. Al publicar una versión: crear rama `release/<version>`, estabilizarla (regresiones, último pulido) y fusionar a `main` con tag `v<version>`.
5. Un error crítico en producción se corrige con `hotfix/*` desde `main`; se fusiona a `main` (con tag de patch) **y** a `develop` para no perder el fix.
6. Las ramas temporales se **borran tras ser fusionadas**; no se dejan ramas sin limpiar.
7. No se fuerza push a `main` ni a `develop`; los merges siempre por pull request o revisión explícita.

### 2.4 Versionado

- **SemVer** (`MAJOR.MINOR.PATCH`):
  - `MAJOR`: cambios incompatibles o hitos grandes.
  - `MINOR`: funcionalidades nuevas compatibles.
  - `PATCH`: correcciones de errores.
- Los tags siguen el patrón `vX.Y.Z` (ej. `v1.0.0`) sobre `main`.
- Un hotfix que se fusiona incrementa el `PATCH`.

### 2.5 Check-list de auto-revisión (pre-merge)

- [ ] `flutter analyze` sin errores ni warnings.
- [ ] Unittests/widget tests en verde (se ejecuta el suite completo).
- [ ] `dart format` aplicado.
- [ ] Sin secretos ni datos sensibles (revisar diffs).
- [ ] Descripción del PR y commits coherentes con Conventional Commits.

---

## 3. Estructura de los commits (Conventional Commits)

### 3.1 Formato

```
tipo(alcance): descripción
```

- **tipo**: categoría del cambio (ver tabla).
- **alcance** (opcional): parte de la app afectada (ver lista de alcances del proyecto).
- **descripción**: verbo en imperativo, minúsculas, ≤ 72 caracteres.

### 3.2 Tipos permitidos

| Tipo | Uso |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de un error |
| `refactor` | Cambio de código sin alterar comportamiento |
| `test` | Añadir o modificar tests |
| `docs` | Documentación |
| `chore` | Tareas de mantenimiento |
| `style` | Formato, estilo, sin cambio de lógica |
| `perf` | Mejoras de rendimiento |
| `build` | Cambios en el build/sistema de build |
| `ci` | Configuración de CI |

- Cambios que rompen compatibilidad añaden `!` tras el tipo/alcance: `feat(encounters)!: ...`

### 3.3 Alcances del proyecto

| Alcance | Ámbito |
|---|---|
| `profiles` | Gestión de perfiles de mujeres |
| `tracking` | Periodos, ovulación, síntomas, historial |
| `encounters` | Registro de encuentros sexuales |
| `prediction` | Motor de predicción de fertilidad |
| `alerts` | Alertas y notificaciones |
| `calendar` | Vistas semana/mes/fertilidad/encuentros |
| `reports` | Estadísticas y reportes |
| `backup` | Export/import (JSON/CSV/PDF) |
| `db` | Esquema/migraciones de la base de datos |
| `settings` | Ajustes y personalización |

### 3.4 Reglas de redacción

- **Imperativo**, como una orden: `feat(profiles): add drag-and-drop ordening`, no `added` ni `adding`.
- **Minúsculas** al inicio de la descripción.
- **1 commit = 1 cambio atómico** (una idea lógica por commit).
- El **cuerpo** (tras línea en blanco) explica **qué y por qué**, no el cómo. Si hace falta, incluye footer con referencias a issues/PRs.
- Línea de asunto «`tipo(alcance): descripción`» ≤ 72 caracteres.
- **No** commitear a la vez múltiples tipos o alcances distintos; dividir en commits separados.

### 3.5 Ejemplos

Validados:

```
feat(profiles): add woman profile creation form

feat(db): create period_logs table

fix(prediction): correct ovulation range for short cycles

test(prediction): cover 28-day cycle with 24-32 range

refactor(encounters): extract protection enum

docs: add BUENAS_PRACTICAS.md

feat(alerts): add post-encounter warning notification
```

Inválidos (y por qué):

```
añadido el formulario de perfiles          → no imperativo, idioma mezclado
feat(profiles, tracking): add two things    → mezcla de alcances
fix bug on ovulation                        → sin tipo
FEAT(PROFILES): Add Form                    → mayúsculas
refactor:                          → descripción vacía
```

### 3.6 Correlación con las fases

- Cada fase de `planDeDesarrollo.md` se desarrolla con una rama `feature/fase-N-*` y commits `feat` incrementales por unidad funcional.
- La fase se considera cerrada cuando su último commit es de tipo `test` + `docs` (documentación/ajustes de la fase).
- Un `fix` encontrado durante el desarrollo de una feature va en la misma rama; un fallo de producción va en `hotfix/*`.