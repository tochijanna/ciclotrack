# CicloTrack 1.3.0

Versión Android prevista: `1.3.0+5`.

## Cambios respecto a 1.2.0

### Distribución Android

- Compilación de APK release con la clave de publicación custodiada en las credenciales de Jenkins.
- Verificación de la firma y de la huella SHA-256 del certificado esperado antes de archivar el APK.
- Configuración de firma temporal con permisos restringidos y limpieza al finalizar el script.
- Pruebas aisladas del flujo de compilación y verificación de firma.

### Privacidad y bloqueo

- Notificaciones discretas por defecto y aviso sobre copias exportadas sin cifrar.
- Bloqueo de la aplicación tras permanecer en segundo plano durante 60 segundos.
- Manejo de errores de carga y guardado del estado del bloqueo manteniendo el acceso protegido.
- Autenticación para desactivar el bloqueo de la aplicación.

### Copias de seguridad y datos

- Exportación de datos mediante una instantánea transaccional.
- Límite de tamaño al importar y validación de invariantes de negocio antes de restaurar.
- Distinción entre perfiles actuales y entrantes en el diálogo de restauración.
- Escrituras y reordenación de perfiles atómicas, con pruebas de rollback ante errores.
- Normalización de etiquetas en la capa de datos.
- Ampliación de pruebas de restauración y migración desde esquemas históricos.

### Predicciones, informes y alertas

- Correcciones en la aritmética de días de calendario, incluidos cambios de horario y duplicados.
- Cálculo de indicadores globales de ciclos sobre el historial completo.
- Exposición de errores del programador de notificaciones y recuperación tras fallos transitorios.

## Instalación desde una versión de pruebas

Una instalación firmada con una clave debug puede no aceptar la actualización directa al APK firmado con la clave de publicación. No desinstalar una aplicación con datos sin disponer antes de una copia JSON guardada fuera de sus datos privados y haber comprobado su restauración.

Las copias exportadas contienen información sensible y no están cifradas por la aplicación. Guardarlas de forma segura y no publicarlas en el repositorio ni adjuntarlas a incidencias.

## Evidencia y estado de validación

Antes del cambio de versión se verificó el commit `b1a5c095f220944ad314c662e8bd37ae32530043`:

- Formato Dart sin cambios y análisis estático sin incidencias.
- 486 pruebas Flutter superadas.
- 10 pruebas aisladas del script de firma superadas; estas usan dobles y no sustituyen la compilación real.
- Compilación real en Jenkins, verificación de firma v2 y coincidencia del certificado de publicación, archivado del APK y eliminación de `android/key.properties`.
- Instalación en otro dispositivo Android e importación satisfactoria de una copia JSON, confirmadas por el usuario.

Persisten advertencias de PDF y Drift en los tests; no impidieron superar la suite. No se declara aquí una validación exhaustiva de biometría ni de entrega de notificaciones en dispositivos.

### Comprobaciones pendientes del candidato 1.3.0+5

- [x] Validación local después del cambio de versión.
- [ ] Compilación y verificación del candidato de la rama `release/1.3.0` en Jenkins.
- [ ] Comprobación de versión e instalación o actualización del APK candidato firmado.
- [ ] PR de release aprobado e integrado en `main` conforme a las protecciones de rama.
- [ ] Compilación y verificación del artefacto definitivo desde `main`, y tag `v1.3.0` asociado al commit correcto.

Actualizar esta lista solo con resultados comprobados. La validación del APK anterior no constituye por sí sola una publicación de 1.3.0.
