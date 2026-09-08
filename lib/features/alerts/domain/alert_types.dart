/// Tipos de alerta según la especificación.
enum AlertType {
  fertilidadInminente,
  diaDeRiesgo,
  periodoInminente,
  fertilidadCombinada,
  encuentroFertilidad,
  advertenciaPostEncuentro,
  multiplesMujeresFertilidad,
  ventanaCombinada,
}

/// Etiqueta legible en español para cada tipo.
String alertTypeLabel(AlertType type) {
  switch (type) {
    case AlertType.fertilidadInminente:
      return 'Fertilidad inminente';
    case AlertType.diaDeRiesgo:
      return 'Día de riesgo';
    case AlertType.periodoInminente:
      return 'Periodo inminente';
    case AlertType.fertilidadCombinada:
      return 'Fertilidad combinada';
    case AlertType.encuentroFertilidad:
      return 'Encuentro + fertilidad';
    case AlertType.advertenciaPostEncuentro:
      return 'Advertencia post-encuentro';
    case AlertType.multiplesMujeresFertilidad:
      return 'Múltiples mujeres + fertilidad';
    case AlertType.ventanaCombinada:
      return 'Ventana combinada';
  }
}

/// Descripción corta para la UI de ajustes.
String alertTypeDescription(AlertType type) {
  switch (type) {
    case AlertType.fertilidadInminente:
      return 'Notifica cuando la ovulación es al día siguiente';
    case AlertType.diaDeRiesgo:
      return 'Notifica si hoy estás en ventana fértil';
    case AlertType.periodoInminente:
      return 'Notifica cuando el periodo empieza al día siguiente';
    case AlertType.fertilidadCombinada:
      return 'Resumen semanal de mujeres fértiles';
    case AlertType.encuentroFertilidad:
      return 'Avisa si tuviste un encuentro y ella está fértil';
    case AlertType.advertenciaPostEncuentro:
      return 'Avisa si pasaron ~14 días desde un encuentro';
    case AlertType.multiplesMujeresFertilidad:
      return 'Avisa si un encuentro múltiple coincide con fertilidad';
    case AlertType.ventanaCombinada:
      return 'Resumen semanal de ventanas de todas las mujeres';
  }
}

/// Todos los tipos en orden.
const allAlertTypes = AlertType.values;
