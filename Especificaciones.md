📅 Aplicación de Calendario Menstrual para Hombre (Uso Personal — Sin Nube)
🧠 Concepto Central

Un solo usuario que gestiona los ciclos menstruales de varias mujeres de forma privada. Todo los datos se quedan en el dispositivo local. Sin compartir ni sincronizar con la nube.
📋 Funcionalidades Principales
1. 📇 Gestión de Perfiles de Mujeres

    Añadir perfil: Nombre, iniciales, foto (avatar genérico — no foto real de la persona)
    Etiquetas: Relacionada, amiga, ex, etc.
    Notas privadas: Notas internas (ej: “alergia a condón con látex”)
    Filtro de visualización: Ver todos, uno a la vez, o en grupo

2. 🩸 Tracking Individual por Mujer

    Registro de periodo: Inicio, fin, duración, flujo, síntomas
    Registro de ovulación: Temperatura, cervical mucus, LH test
    Síntomas: Acné, dolor de pecho, cansancio, humor, antojos, dolor abdominal
    Historial completo: Línea de tiempo por cada mujer individualmente

3. 👥 Registro de Encuentros Sexuales (MÚLTIPLES MUJERES)

    Fecha y hora del encuentro
    Mujeres involucradas: Seleccionar una o varias del perfil (checkbox multi-selección)
    Tipo de protección: Condón, pastilla, natural, ninguno
    Tipo de relación (vaginal, oral, anal, etc.) — por cada mujer o global
    Resultado (si se conoce): embarazo, abortado, nada, etc.
    Notas: Ej: “condón roto”, “deseo intenso”, etc.

    ⚠️ Cada encuentro puede registrar varias mujeres simultáneamente (ej: sexo vaginal con A, sexo oral con B, sexo anal con C en la misma cita).

4. 🧠 Predicción de Fertilidad (por mujer)

    Día de ovulación estimado (basado en ciclos pasados)
    Ventana de fertilidad (días fértiles calculados)
    Días seguros / días de riesgo
    Predicción de periodo (fecha estimada de sangrado)
    
    Logica de Predicción:
    
    Inicio del rango de ovulación = Día 11 - (días mínimos del ciclo - 10)
    Fin del rango de ovulación = Día 17 + (días máximos del ciclo - 14)
    
    Explicación visual:
    
    Ciclo de 28 días (rango: 24-32 días):
    Día 1   Día 5   Día 11    Día 17    Día 21    Día 27
    ────┬─────┬────────┬─────────┬─────────┬─────────────┐
        │     │         │         │         │             │
        │     │         ▼         ▼         ▼             │
        │     │       ────────   ───────   ───────────────│
        │     │       OVL        OVL        OVL          │
        │     │       (rango)  (rango)    (rango)       │
        │     │       11-17     12-19     17-23         │
        │     │                   ──────────────────────┐
        │     │                   Ventana de fertilidad   │
        │     │                   -5 días hasta +2 días   │
        │     │                   del ovulación estimada   │
        └─────┴───────────────────────────────────────────┘



5. ⚠️ Alertas e Notificaciones (CORREGIDAS)
Tipo de alerta 	Ejemplo
Fertilidad inminente 	“Mañana es día de ovulación de María. Ventana de fertilidad: 3 días”
Día de riesgo 	“Hoy es día de riesgo con Ana. Su ventana de fertilidad termina mañana.”
Periodo inminente 	“El periodo de María empieza mañana”
Medicación 	“Es hora de la pastilla para María”
Fertilidad combinada 	“Esta semana hay fertilidad con María y Sofía”
Encuentro + fertilidad 	“Te acostaste con Ana el martes y su ventana de fertilidad es hoy + 2 días”
Advertencia post-encuentro 	“Te acostaste con Ana el martes. Su periodo debería empezar el 15. Si no hay embarazo, es probable que tenga sangrado a esa fecha.”
Múltiples mujeres + fertilidad 	“Te acostaste con María y Ana el lunes. Ambas tienen ventana de fertilidad activa. Alto riesgo.”
Múltiples mujeres + ventana combinada 	“Sofía es fértil los días 5-10. Ana los días 12-17. María los días 22-28.”
6. 📊 Vista Consolidada

    Vista “Semana”: Ver todos los perfiles en un mismo calendario
    Vista “Mes”: Ver todos los perfiles en un mismo mes
    Vista “Fertilidad”: Ver qué mujeres están en ventana de fertilidad esta semana
    Vista “Encuentros”: Ver encuentros por mujer (quién se acostó con quién)

7. 🔒 Privacidad Local (Sin Nube)

    Todo los datos se quedan en el dispositivo
    Importar/Exportar: Opción de copiar toda la base de datos a un archivo local (JSON, CSV, PDF) para backup manual. Se hace manualmente, no automático.
    Modo offline: Funcionamiento completo sin internet (necesario por diseño, no por necesidad).

8. 🎨 Personalización

    Colores por perfil: Cada mujer con un color distintivo
    Iconos por perfil: Emoji o símbolo genérico (no fotos)
    Orden de perfiles: Arrastrar y soltar para priorizar
    Recordatorios personalizados: “Mejor evitar sexo con María los días 5-7 del ciclo”

9. 📈 Reportes y Estadísticas

    Por mujer: Gráficos de ciclos, duración media, síntomas recurrentes
    Por encuentro: Resumen de encuentros por mujer (quién participó)
    Por mes: Resumen de fertilidad y encuentros
    Estadísticas globales: Días de fertilidad total, encuentros sin protección, etc.

10. 🛠️ Funcionalidades Técnicas

    Almacenamiento local: SQLite o similar dentro del dispositivo
    Importar/Exportar: Botón para exportar todo a un archivo local o importar desde uno (backup manual)
    Notificaciones push: Alertas diarias y semanales
    Integración con wearables: Apple Health, Google Fit, Oura, etc.
    Modo offline: Funcionamiento completo sin internet

💡 Resumen de Cambios
Cambio 	Anterior 	Nuevo
Privacidad 	Permisos por perfil 	Todo privado por defecto
Fotos/avatares 	Fotos reales de las mujeres 	Emojis/símbolos genéricos
Sincronización 	Cloud sync automático 	Importar/Exportar manual (backup)
Alertas de fertilidad 	“Día seguro para sexo sin protección” 	“Día de riesgo” / “Ventana de fertilidad” (más conservador)
Encuentros 	Una mujer por encuentro 	Una o varias mujeres por encuentro
