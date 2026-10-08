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
  medicacion,
}

/// Todos los tipos en orden.
const allAlertTypes = AlertType.values;
