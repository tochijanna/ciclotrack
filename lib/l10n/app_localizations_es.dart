// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get errorLabel => 'Error';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String encountersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encuentros',
      one: '1 encuentro',
    );
    return '$_temp0';
  }

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get menuMoreOptions => 'Más opciones';

  @override
  String get menuViews => 'Vistas';

  @override
  String get menuReports => 'Reportes';

  @override
  String get menuBackup => 'Copia de seguridad';

  @override
  String get menuAlerts => 'Alertas';

  @override
  String get menuRefresh => 'Actualizar';

  @override
  String get filterAll => 'Todas';

  @override
  String get newProfile => 'Nuevo perfil';

  @override
  String get newEncounter => 'Nuevo encuentro';

  @override
  String get viewEncounters => 'Ver encuentros';

  @override
  String get addNew => 'Nuevo';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get createProfile => 'Crear perfil';

  @override
  String get changeEmoji => 'Cambiar emoji';

  @override
  String get colorLabel => 'Color';

  @override
  String get nameLabel => 'Nombre *';

  @override
  String get initialsLabel => 'Iniciales *';

  @override
  String get initialsHelper => 'Se generan automáticamente si las dejas vacías';

  @override
  String get privateNotes => 'Notas privadas';

  @override
  String get tagsLabel => 'Etiquetas';

  @override
  String get addCustomTag => '+ Personalizada';

  @override
  String get chooseEmoji => 'Elige un emoji';

  @override
  String get profileSaveError => 'No se pudo guardar el perfil';

  @override
  String get emptyProfilesTitle => 'No hay perfiles';

  @override
  String get emptyProfilesSubtitle => 'Añade tu primer perfil para empezar';

  @override
  String get addProfile => 'Añadir perfil';

  @override
  String get deleteProfileTitle => 'Eliminar perfil';

  @override
  String deleteProfileBody(String name) {
    return '¿Eliminar a $name? Se borrarán todos sus datos.';
  }

  @override
  String get womanNameRequired => 'El nombre es obligatorio';

  @override
  String get womanNameTooShort => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get womanInitialsRequired => 'Las iniciales son obligatorias';

  @override
  String get womanInitialsTooLong =>
      'Las iniciales no pueden tener más de 4 caracteres';

  @override
  String get trackingPeriod => 'Periodo';

  @override
  String get trackingOvulation => 'Ovulación';

  @override
  String get trackingSymptom => 'Síntoma';

  @override
  String get trackingEmptyTitle => 'Sin registros';

  @override
  String get trackingEmptySubtitle => 'Añade tu primer registro de tracking';

  @override
  String get deleteRecordTitle => 'Eliminar registro';

  @override
  String deleteRecordBody(String title) {
    return '¿Eliminar \"$title\"?';
  }

  @override
  String flowLevel(int level) {
    return 'Flujo: $level/5';
  }

  @override
  String intensityLevel(int level) {
    return 'Intensidad: $level/5';
  }

  @override
  String get notesLabel => 'Notas';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get cervicalMucusLabel => 'Moco cervical';

  @override
  String get lhTestLabel => 'Test LH';

  @override
  String get symptomTypeLabel => 'Tipo de síntoma';

  @override
  String get periodFormTitle => 'Registrar periodo';

  @override
  String get editPeriodTitle => 'Editar periodo';

  @override
  String get ovulationFormTitle => 'Registrar ovulación';

  @override
  String get editOvulationTitle => 'Editar ovulación';

  @override
  String get symptomFormTitle => 'Registrar síntoma';

  @override
  String get editSymptomTitle => 'Editar síntoma';

  @override
  String get periodSaveError => 'No se pudo guardar el periodo';

  @override
  String get ovulationSaveError => 'No se pudo guardar la ovulación';

  @override
  String get symptomSaveError => 'No se pudo guardar el síntoma';

  @override
  String get symptomAcne => 'Acné';

  @override
  String get symptomBreastPain => 'Dolor de pecho';

  @override
  String get symptomFatigue => 'Cansancio';

  @override
  String get symptomMood => 'Humor';

  @override
  String get symptomCravings => 'Antojos';

  @override
  String get symptomAbdominalPain => 'Dolor abdominal';

  @override
  String get mucusDry => 'Seco';

  @override
  String get mucusSticky => 'Pegajoso';

  @override
  String get mucusCreamy => 'Cremoso';

  @override
  String get mucusWatery => 'Acuoso';

  @override
  String get mucusStretchy => 'Elástico';

  @override
  String get mucusEggWhite => 'Clara de huevo';

  @override
  String get lhNegative => 'Negativo';

  @override
  String get lhPositive => 'Positivo';

  @override
  String get lhNotDone => 'No realizado';

  @override
  String get protectionCondom => 'Condón';

  @override
  String get protectionPill => 'Pastilla';

  @override
  String get protectionNatural => 'Natural';

  @override
  String get protectionNone => 'Ninguno';

  @override
  String get relationshipVaginal => 'Vaginal';

  @override
  String get relationshipOral => 'Oral';

  @override
  String get relationshipAnal => 'Anal';

  @override
  String get relationshipOther => 'Otro';

  @override
  String get outcomeNothing => 'Nada';

  @override
  String get outcomePregnancy => 'Embarazo';

  @override
  String get outcomeAbortion => 'Aborto';

  @override
  String get outcomeUnknown => 'Desconocido';

  @override
  String get encountersTitle => 'Encuentros';

  @override
  String get deleteEncounterTitle => 'Eliminar encuentro';

  @override
  String get deleteEncounterBody => '¿Eliminar este encuentro?';

  @override
  String get emptyEncountersTitle => 'Sin encuentros';

  @override
  String get emptyEncountersSubtitle => 'Registra tu primer encuentro';

  @override
  String get encounterFormTitle => 'Nuevo encuentro';

  @override
  String get editEncounterTitle => 'Editar encuentro';

  @override
  String get dateTimeLabel => 'Fecha y hora';

  @override
  String get protectionLabel => 'Protección';

  @override
  String get participantsLabel => 'Participantes';

  @override
  String get outcomeLabel => 'Resultado';

  @override
  String get applyToAll => 'Aplicar a todas:';

  @override
  String get encounterSaveError => 'No se pudo guardar el encuentro';

  @override
  String get encounterTimeFuture => 'La fecha no puede ser futura';

  @override
  String get encounterProtectionInvalid => 'Protección no válida';

  @override
  String get encounterParticipantsRequired =>
      'Debe haber al menos una participante';

  @override
  String get encounterParticipantsDuplicate =>
      'No se pueden repetir participantes';

  @override
  String get encounterRelationshipInvalid => 'Tipo de relación no válido';

  @override
  String get encounterOutcomeInvalid => 'Resultado no válido';

  @override
  String get riskPeriodInProgress => 'Periodo en curso';

  @override
  String get riskRiskDay => 'Día de riesgo';

  @override
  String get riskPossibleDelay => 'Posible retraso';

  @override
  String get riskOutsideWindow => 'Fuera de ventana fértil';

  @override
  String get riskNoData => 'Sin datos';

  @override
  String get phaseMenstruation => 'Menstruación';

  @override
  String get phaseFollicular => 'Folicular';

  @override
  String get phaseFertileWindow => 'Ventana fértil';

  @override
  String get phaseOvulation => 'Ovulación';

  @override
  String get phaseLuteal => 'Lútea';

  @override
  String get phaseLateLuteal => 'Lútea tardía (PMS)';

  @override
  String get phaseDelayed => 'Retraso';

  @override
  String get moodMenstruationHumor => 'Bajo / cansancio';

  @override
  String get moodMenstruationLibido => 'Baja';

  @override
  String get moodMenstruationTip => 'Déjala tranquila';

  @override
  String get moodFollicularHumor => 'Buen humor';

  @override
  String get moodFollicularLibido => 'En aumento';

  @override
  String get moodFollicularTip => 'Buen momento para planes';

  @override
  String get moodFertileHumor => 'Bueno';

  @override
  String get moodFertileLibido => 'Alta';

  @override
  String get moodFertileTip => 'Días de riesgo';

  @override
  String get moodOvulationHumor => 'Muy bueno';

  @override
  String get moodOvulationLibido => 'Cachonda (pico)';

  @override
  String get moodOvulationTip => 'Riesgo máximo';

  @override
  String get moodLutealHumor => 'Variable';

  @override
  String get moodLutealLibido => 'En descenso';

  @override
  String get moodLateLutealHumor => 'Irritable / mal humor';

  @override
  String get moodLateLutealLibido => 'Variable';

  @override
  String get moodLateLutealTip => 'Paciencia, mejor no discutir';

  @override
  String get moodDelayedHumor => 'Imprevisible';

  @override
  String get moodDelayedLibido => '—';

  @override
  String get moodDelayedTip => 'Posible retraso, comprueba registro';

  @override
  String phaseLabel(String phase) {
    return 'Fase: $phase';
  }

  @override
  String moodLabel(String mood) {
    return 'Humor: $mood';
  }

  @override
  String libidoLabel(String libido) {
    return 'Libido: $libido';
  }

  @override
  String get estimatedOvulation => 'Ovulación estimada';

  @override
  String get fertileWindowRisk => 'Ventana fértil (riesgo)';

  @override
  String get expectedPeriod => 'Periodo previsto';

  @override
  String get upcomingDays => 'Próximos días';

  @override
  String cycleDay(int day) {
    return 'Día $day';
  }

  @override
  String cycleStats(int cycles, int min, int max, String avg) {
    return 'Ciclos: $cycles · Min $min / Max $max / Media $avg días';
  }

  @override
  String get defaultEstimationWarning =>
      '⚠ Estimación por defecto (registra más periodos para mayor precisión)';

  @override
  String get orientationDisclaimer =>
      'Estimación orientativa según la fase del ciclo';

  @override
  String get noDataCardBody => 'Registra un periodo para ver la predicción';

  @override
  String get alertTypeFertilityImminent => 'Fertilidad inminente';

  @override
  String get alertTypeRiskDay => 'Día de riesgo';

  @override
  String get alertTypePeriodImminent => 'Periodo inminente';

  @override
  String get alertTypeCombinedFertility => 'Fertilidad combinada';

  @override
  String get alertTypeEncounterFertility => 'Encuentro + fertilidad';

  @override
  String get alertTypePostEncounter => 'Advertencia post-encuentro';

  @override
  String get alertTypeMultiFertility => 'Múltiples mujeres + fertilidad';

  @override
  String get alertTypeCombinedWindow => 'Ventana combinada';

  @override
  String get alertTypeMedication => 'Medicación';

  @override
  String get alertDescFertilityImminent =>
      'Notifica cuando la ovulación es al día siguiente';

  @override
  String get alertDescRiskDay => 'Notifica si hoy estás en ventana fértil';

  @override
  String get alertDescPeriodImminent =>
      'Notifica cuando el periodo empieza al día siguiente';

  @override
  String get alertDescCombinedFertility =>
      'Resumen semanal de mujeres fértiles';

  @override
  String get alertDescEncounterFertility =>
      'Avisa si tuviste un encuentro y ella está fértil';

  @override
  String get alertDescPostEncounter =>
      'Avisa si pasaron ~14 días desde un encuentro';

  @override
  String get alertDescMultiFertility =>
      'Avisa si un encuentro múltiple coincide con fertilidad';

  @override
  String get alertDescCombinedWindow =>
      'Resumen semanal de ventanas de todas las mujeres';

  @override
  String get alertDescMedication =>
      'Recuerda la toma de los medicamentos de cada mujer';

  @override
  String get notificationChannelName => 'Alertas de CicloTrack';

  @override
  String get notificationChannelDescription =>
      'Notificaciones de fertilidad y ciclo';

  @override
  String alertBodyFertilityImminent(String initials, int days) {
    return 'Mañana es día de ovulación de $initials. Ventana de fertilidad: $days días';
  }

  @override
  String alertBodyRiskDayEndsTomorrow(String initials) {
    return 'Hoy es día de riesgo con $initials. Su ventana de fertilidad termina mañana';
  }

  @override
  String alertBodyRiskDayEndsOn(String initials, String date) {
    return 'Hoy es día de riesgo con $initials. Su ventana de fertilidad termina el $date';
  }

  @override
  String alertBodyPeriodImminent(String initials) {
    return 'El periodo de $initials empieza mañana';
  }

  @override
  String alertBodyCombinedFertility(String names) {
    return 'Esta semana hay fertilidad con $names';
  }

  @override
  String alertBodyEncounterFertilityToday(String initials, String weekday) {
    return 'Encuentro con $initials el $weekday y su ventana de fertilidad es hoy';
  }

  @override
  String alertBodyEncounterFertilityPlus(
    String initials,
    String weekday,
    int days,
  ) {
    return 'Encuentro con $initials el $weekday y su ventana de fertilidad es hoy + $days días';
  }

  @override
  String alertBodyPostEncounter(String initials, String weekday, String date) {
    return 'Encuentro con $initials el $weekday. Su periodo debería empezar el $date. Si no hay embarazo, es probable que tenga sangrado a esa fecha.';
  }

  @override
  String alertBodyMultiFertility(String names, String weekday) {
    return 'Encuentro con $names el $weekday. Ambas tienen ventana de fertilidad activa. Alto riesgo.';
  }

  @override
  String alertBodyCombinedWindow(String entries) {
    return '$entries.';
  }

  @override
  String alertEntryFertileRange(String initials, String from, String to) {
    return '$initials es fértil del $from al $to';
  }

  @override
  String alertBodyMedication(String time) {
    return 'Es hora de tu medicación ($time)';
  }

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get alertsMedicationTooltip => 'Medicación';

  @override
  String get alertsEnabled => 'Alertas activadas';

  @override
  String get alertsEnabledSubtitle =>
      'Activa o desactiva todas las notificaciones';

  @override
  String get alertsPermissionDenied => 'Permiso de notificaciones no concedido';

  @override
  String get alertsNotifyTime => 'Hora de notificación';

  @override
  String get alertsTypesTitle => 'Tipos de alerta';

  @override
  String get alertsUpcomingTitle => 'Próximas alertas';

  @override
  String get alertsUpcomingEmpty =>
      'No hay alertas programadas para los próximos 7 días';

  @override
  String get alertsRecalculate => 'Recalcular ahora';

  @override
  String get alertsRecalculated => 'Alertas recalculadas';

  @override
  String get calendarViewsTitle => 'Vistas';

  @override
  String get calendarWeekTab => 'Semana';

  @override
  String get calendarMonthTab => 'Mes';

  @override
  String get calendarFertilityTab => 'Fertilidad';

  @override
  String get calendarEncountersTab => 'Encuentros';

  @override
  String get calendarLoadError => 'No se pudieron cargar las vistas.';

  @override
  String get calendarEmpty => 'Sin perfiles. Crea uno para ver el calendario.';

  @override
  String get legendMenstruation => 'Menstruación';

  @override
  String get legendFertileWindow => 'Ventana fértil';

  @override
  String get legendOvulation => 'Ovulación';

  @override
  String get legendRegisteredOvulation => 'Ovulación registrada';

  @override
  String get legendSymptom => 'Síntoma';

  @override
  String get legendEncounter => 'Encuentro';

  @override
  String get legendProjectionNote =>
      'Las marcas atenuadas son proyecciones a partir de la media de ciclos.';

  @override
  String get dayNoCycleData => 'Sin datos de ciclo';

  @override
  String get dayFertileSuffix => '· ventana fértil';

  @override
  String get fertilityWeekEmpty =>
      'Ninguna mujer en ventana fértil esta semana.';

  @override
  String get fertilityEstimated => 'estimado';

  @override
  String get reportsTitle => 'Reportes';

  @override
  String get reportsLoadError => 'No se pudieron cargar los reportes.';

  @override
  String get reportsEmpty => 'Sin perfiles. Crea uno para ver los reportes.';

  @override
  String get reportsAll => 'Todas';

  @override
  String get reportsGlobal => 'Global';

  @override
  String get kpiProfiles => 'Perfiles';

  @override
  String get kpiCycles => 'Ciclos registrados';

  @override
  String get kpiAvgCycle => 'Duración media del ciclo';

  @override
  String get kpiAvgMenstruation => 'Duración media de la menstruación';

  @override
  String get kpiEncounters => 'Encuentros';

  @override
  String get kpiUnprotected => 'Sin protección';

  @override
  String get kpiFertileDays => 'Días fértiles';

  @override
  String get kpiMostEncounters => 'Más encuentros';

  @override
  String get kpiNextPeriod => 'Próximo periodo';

  @override
  String get hintHistory => 'histórico';

  @override
  String get hintClosedPeriods => 'periodos cerrados';

  @override
  String get hintMonths12 => '12 meses';

  @override
  String get hintFertile12 => '12 meses, con proyecciones';

  @override
  String get hintProjected => 'proyectado';

  @override
  String hintUnprotected(int unprotected, int total) {
    return '«Ninguno»: $unprotected de $total';
  }

  @override
  String get reportsPerMonth => 'Por mes';

  @override
  String get reportsEncountersByWoman => 'Encuentros por mujer';

  @override
  String get reportsProtection => 'Protección';

  @override
  String get reportsCycleEvolution => 'Evolución del ciclo';

  @override
  String get reportsRecurringSymptoms => 'Síntomas recurrentes';

  @override
  String reportsMonthDetail(
    String month,
    int encounters,
    int unprotected,
    int fertile,
    int periods,
  ) {
    return '$month · $encounters encuentros · $unprotected sin protección · $fertile días fértiles · $periods periodos';
  }

  @override
  String get chartNeedTwoCycles =>
      'Hacen falta al menos dos ciclos cerrados para dibujar la evolución.';

  @override
  String get chartNoSymptoms =>
      'Sin síntomas registrados en los últimos 12 meses.';

  @override
  String get chartNoEncounters =>
      'Sin encuentros registrados en los últimos 12 meses.';

  @override
  String get chartLegendEncounters => 'Encuentros';

  @override
  String get chartLegendUnprotected => 'Sin protección';

  @override
  String get backupTitle => 'Copia de seguridad';

  @override
  String get backupSaved => 'Copia guardada';

  @override
  String get backupRestoreTitle => 'Restaurar copia';

  @override
  String backupRestoreConfirm(int actuales, int entrantes) {
    return '¿Reemplazar todos los datos actuales? Se borrarán los $actuales perfiles actuales y todos sus registros. La copia contiene $entrantes.';
  }

  @override
  String get pdfDocumentTitle => 'CicloTrack — copia de seguridad';

  @override
  String pdfFooterPage(int page, int total) {
    return 'Página $page de $total';
  }

  @override
  String pdfGeneratedOn(String date) {
    return 'Informe generado el $date';
  }

  @override
  String get pdfSummary => 'Resumen';

  @override
  String get pdfRegisteredPeriods => 'Periodos registrados';

  @override
  String get pdfSymptoms12 => 'Síntomas (12 meses)';

  @override
  String get pdfMedication => 'Medicación';

  @override
  String get pdfEncounters => 'Encuentros';

  @override
  String get pdfColStart => 'Inicio';

  @override
  String get pdfColEnd => 'Fin';

  @override
  String get pdfColFlow => 'Flujo';

  @override
  String get pdfColNotes => 'Notas';

  @override
  String get pdfColType => 'Tipo';

  @override
  String get pdfColFrequency => 'Frecuencia';

  @override
  String get pdfColWoman => 'Mujer';

  @override
  String get pdfColMedication => 'Medicamento';

  @override
  String get pdfColDose => 'Dosis';

  @override
  String get pdfColTime => 'Hora';

  @override
  String get pdfColState => 'Estado';

  @override
  String get pdfColDate => 'Fecha';

  @override
  String get pdfColWomen => 'Mujeres';

  @override
  String get pdfColProtection => 'Protección';

  @override
  String get pdfColOutcome => 'Resultado';

  @override
  String pdfShowsLast(int shown, int total) {
    return 'Se muestran los últimos $shown de $total encuentros.';
  }

  @override
  String pdfProfiles(int count) {
    return 'Perfiles: $count';
  }

  @override
  String pdfCycles(int count) {
    return 'Ciclos registrados: $count';
  }

  @override
  String pdfAvgCycle(String value) {
    return 'Duración media del ciclo: $value';
  }

  @override
  String pdfAvgMenstruation(String value) {
    return 'Duración media de la menstruación: $value';
  }

  @override
  String pdfEncounters12(int count) {
    return 'Encuentros (12 meses): $count';
  }

  @override
  String pdfUnprotected(int percent, int unprotected, int total) {
    return 'Sin protección: $percent % ($unprotected de $total)';
  }

  @override
  String pdfFertileDays12(int count) {
    return 'Días fértiles (12 meses, con proyecciones): $count';
  }

  @override
  String pdfMostEncounters(String name, int count) {
    return 'Más encuentros: $name ($count)';
  }

  @override
  String pdfNextPeriod(String date) {
    return 'Próximo periodo: $date';
  }

  @override
  String get medicationTitle => 'Medicación';

  @override
  String get medicationAdd => 'Añadir medicamento';

  @override
  String get medicationProfilesError => 'No se pudieron cargar los perfiles';

  @override
  String get medicationLoadError => 'No se pudo cargar la medicación';

  @override
  String get medicationEdit => 'Editar medicamento';

  @override
  String get medicationNameLabel => 'Medicamento';

  @override
  String get medicationWomanLabel => 'Mujer';

  @override
  String get medicationEnabledLabel => 'Activo';

  @override
  String get medicationEmpty => 'No hay medicamentos registrados';

  @override
  String get medicationDeleteTitle => 'Eliminar medicamento';

  @override
  String medicationDeleteBody(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get medicationSaveError => 'No se pudo guardar el medicamento';

  @override
  String get medicationNameRequired => 'Introduce el nombre del medicamento';

  @override
  String get medicationNameTooLong => 'El nombre admite hasta 80 caracteres';

  @override
  String get medicationDoseTooLong => 'La dosis admite hasta 60 caracteres';

  @override
  String get medicationHourRange => 'La hora debe estar entre 0 y 23';

  @override
  String get medicationMinuteRange => 'El minuto debe estar entre 0 y 59';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsAlerts => 'Alertas';

  @override
  String get settingsBackup => 'Copia de seguridad';

  @override
  String get settingsViews => 'Vistas';

  @override
  String get settingsReports => 'Informes';

  @override
  String get settingsMedication => 'Medicación';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get appLockedTitle => 'Acceso bloqueado';

  @override
  String get appLockedSubtitle =>
      'Desbloquea con tu PIN o huella para continuar.';

  @override
  String get appUnlock => 'Desbloquear';

  @override
  String get appLockAuthReason => 'Desbloquea CicloTrack para continuar';

  @override
  String get appLockLoadError =>
      'No se pudo comprobar si el bloqueo está activado. Desbloquea o reinténtalo.';

  @override
  String get appLockRetry => 'Reintentar';

  @override
  String remindersOf(String name) {
    return 'Recordatorios de $name';
  }

  @override
  String get remindersLoadError => 'No se pudieron cargar los recordatorios';

  @override
  String get remindersNew => 'Nuevo recordatorio';

  @override
  String get remindersEmpty => 'Sin recordatorios';

  @override
  String get remindersDeleteTitle => 'Eliminar recordatorio';

  @override
  String remindersDeleteBody(String message) {
    return '¿Eliminar \"$message\"?';
  }

  @override
  String get reminderNotificationTitle => 'Recordatorio';

  @override
  String get reminderChannelName => 'Recordatorios';

  @override
  String get reminderChannelDescription =>
      'Recordatorios personalizados por día del ciclo';

  @override
  String get reminderFormTitle => 'Nuevo recordatorio';

  @override
  String get reminderEditTitle => 'Editar recordatorio';

  @override
  String get reminderMessageLabel => 'Mensaje';

  @override
  String get reminderStartLabel => 'Día inicial del ciclo';

  @override
  String get reminderEndLabel => 'Día final del ciclo (opcional)';

  @override
  String get reminderEnabledLabel => 'Activo';

  @override
  String get reminderPermissionDenied =>
      'Recordatorio guardado, pero sin permiso de notificaciones no recibirás el aviso';

  @override
  String get reminderSaveError => 'No se pudo guardar el recordatorio';

  @override
  String get reminderMessageRequired => 'Escribe un mensaje';

  @override
  String reminderMessageTooLong(int max) {
    return 'Máximo $max caracteres';
  }

  @override
  String get reminderStartRequired => 'Introduce un día del ciclo';

  @override
  String get reminderStartTooSmall => 'El día inicial debe ser 1 o mayor';

  @override
  String reminderStartTooLarge(int max) {
    return 'El día inicial no puede superar $max';
  }

  @override
  String get reminderEndRequired => 'Introduce un día del ciclo';

  @override
  String get reminderEndBeforeStart =>
      'El día final no puede ser anterior al inicial';

  @override
  String reminderEndTooLarge(int max) {
    return 'El día final no puede superar $max';
  }

  @override
  String reminderDayLabel(int day) {
    return 'Día $day del ciclo';
  }

  @override
  String reminderDaysLabel(int start, int end) {
    return 'Días $start-$end del ciclo';
  }

  @override
  String reminderBodyRange(String message, int start, int end) {
    return '$message (días $start-$end del ciclo)';
  }

  @override
  String get dayNoProfiles => 'Sin perfiles.';

  @override
  String get saving => 'Guardando…';

  @override
  String get add => 'Añadir';

  @override
  String get register => 'Registrar';

  @override
  String get remindersTooltip => 'Recordatorios';

  @override
  String get tagRelated => 'Relacionada';

  @override
  String get tagFriend => 'Amiga';

  @override
  String get tagEx => 'Ex';

  @override
  String get tagCoworker => 'Compañera';

  @override
  String get tagCasual => 'Casual';

  @override
  String get tagOther => 'Otro';

  @override
  String get newTagTitle => 'Nueva etiqueta';

  @override
  String get tagNameHint => 'Nombre de la etiqueta';

  @override
  String get medicationNoProfiles => 'Crea un perfil para añadir medicación';

  @override
  String get medicationWomanRequired => 'Selecciona una mujer';

  @override
  String get medicationDoseOptional => 'Dosis (opcional)';

  @override
  String get medicationTakeTime => 'Hora de la toma';

  @override
  String get reminderMessageHint => 'Mejor evitar sexo estos días';

  @override
  String get reminderCycleNote =>
      'El día 1 es el inicio del último periodo registrado. Recibirás un aviso por ciclo, el día inicial.';

  @override
  String get reminderCreate => 'Crear recordatorio';

  @override
  String get reminderDisabled => 'Desactivado';

  @override
  String get remindersEmptySubtitle =>
      'Crea un aviso para unos días concretos del ciclo';

  @override
  String get encounterNoProfiles => 'No hay perfiles disponibles';

  @override
  String get relationshipTypeLabel => 'Tipo de relación';

  @override
  String get outcomeNoneOption => 'Ninguno';

  @override
  String get registerEncounter => 'Registrar encuentro';

  @override
  String get registerPeriod => 'Registrar periodo';

  @override
  String get registerOvulation => 'Registrar ovulación';

  @override
  String get registerSymptom => 'Registrar síntoma';

  @override
  String get dateStartLabel => 'Fecha de inicio';

  @override
  String get dateEndOptionalLabel => 'Fecha de fin (opcional)';

  @override
  String get undefinedDate => 'Sin definir';

  @override
  String get durationLabel => 'Duración';

  @override
  String get flowLevelLabel => 'Nivel de flujo';

  @override
  String get temperatureBasalLabel => 'Temperatura basal (°C)';

  @override
  String get periodStartFuture => 'La fecha de inicio no puede ser futura';

  @override
  String get periodEndBeforeStart =>
      'La fecha de fin no puede ser anterior al inicio';

  @override
  String get periodFlowRange => 'Flujo debe estar entre 1 y 5';

  @override
  String get dateFuture => 'La fecha no puede ser futura';

  @override
  String get temperatureInvalid =>
      'Introduce una temperatura válida entre 34 y 40 °C';

  @override
  String get symptomTypeInvalid => 'Tipo de síntoma no válido';

  @override
  String get severityRange => 'Intensidad debe estar entre 1 y 5';

  @override
  String calendarWeekRange(String from, String to) {
    return 'Semana del $from al $to';
  }

  @override
  String fertilityWindowLabel(String from, String to) {
    return 'Ventana: $from – $to';
  }

  @override
  String ovulationDateLabel(String date) {
    return 'Ovulación: $date';
  }

  @override
  String get fertilityEstimatedF => 'estimada';

  @override
  String get fertilityStartsTomorrow => 'Empieza mañana';

  @override
  String fertilityStartsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return 'Empieza en $_temp0';
  }

  @override
  String get fertilityLastDay => 'Último día de ventana';

  @override
  String fertilityInProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return 'En curso, termina en $_temp0';
  }

  @override
  String encountersFilterAllCount(int count) {
    return 'Todas ($count)';
  }

  @override
  String get encountersNone => 'Sin encuentros registrados.';

  @override
  String encountersNoneFor(String name) {
    return 'Sin encuentros con $name.';
  }

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get medicationSaveChangeError => 'No se pudo guardar el cambio';

  @override
  String get settingsSectionSecurity => 'Seguridad';

  @override
  String get settingsAppLockTitle => 'Bloqueo de acceso (PIN/huella)';

  @override
  String get settingsAppLockSupported =>
      'Pide PIN o huella al abrir la app y tras 1 minuto en segundo plano. Controla el acceso; no cifra los datos.';

  @override
  String get settingsDiscreetNoticesTitle => 'Avisos discretos';

  @override
  String get settingsDiscreetNoticesSubtitle =>
      'Las notificaciones no muestran iniciales, fechas ni el texto de los recordatorios';

  @override
  String get discreetNoticeBody =>
      'Tienes un aviso nuevo. Abre la app para verlo.';

  @override
  String get settingsAppLockUnavailable => 'No disponible en este dispositivo';

  @override
  String get settingsAppLockSaveError =>
      'No se pudo guardar el bloqueo de acceso. Inténtalo de nuevo.';

  @override
  String get settingsAppLockAuthRequired =>
      'El bloqueo sigue activado: hay que desbloquear con PIN o huella para desactivarlo.';

  @override
  String get settingsLocalTitle => '100 % local y sin nube';

  @override
  String get settingsLocalSubtitle =>
      'Todos los datos se guardan solo en este dispositivo: no hay cuentas, sincronización ni servidores.';

  @override
  String get settingsMedicationSubtitle =>
      'Pastillas y horas de aviso, por mujer';

  @override
  String get settingsAlertsSubtitle => 'Avisos locales y hora de notificación';

  @override
  String get settingsBackupSubtitle => 'Exportar y restaurar los datos';

  @override
  String get settingsReportsSubtitle => 'Estadísticas y gráficos';

  @override
  String get settingsViewsSubtitle => 'Calendario, fertilidad y encuentros';

  @override
  String get backupSectionExport => 'Exportar';

  @override
  String get backupSectionImport => 'Importar';

  @override
  String get backupExportJsonTitle => 'Copia completa (JSON)';

  @override
  String get backupExportJsonSubtitle => 'Todos los datos en un archivo JSON';

  @override
  String get backupExportCsvTitle => 'Tablas (CSV)';

  @override
  String get backupExportCsvSubtitle =>
      'Un CSV por tabla, comprimidos en un ZIP';

  @override
  String get backupExportPdfTitle => 'Informe (PDF)';

  @override
  String get backupExportPdfSubtitle =>
      'Resumen imprimible de perfiles, ciclos y encuentros';

  @override
  String get backupImportJsonTitle => 'Restaurar desde JSON';

  @override
  String get backupImportJsonSubtitle => 'Reemplaza todos los datos actuales';

  @override
  String get backupNotReady =>
      'No se pudo guardar: los datos aún se están cargando';

  @override
  String get backupCancelled => 'Exportación cancelada';

  @override
  String get backupImportCancelled => 'Importación cancelada';

  @override
  String get backupRestoreAction => 'Restaurar';

  @override
  String get backupUnencryptedTitle => 'Archivo sin cifrar';

  @override
  String get backupUnencryptedWarning =>
      'El archivo se guardará sin cifrar: cualquiera que lo abra podrá leer todos los datos. El bloqueo de acceso de la app no lo protege. Guárdalo en un lugar seguro.';

  @override
  String get backupUnencryptedAction => 'Exportar';

  @override
  String backupSaveFailed(String reason) {
    return 'No se pudo guardar: $reason';
  }

  @override
  String backupImportFailed(String reason) {
    return 'No se pudo importar: $reason';
  }

  @override
  String backupRestoredSummary(int profiles, int periods, int encounters) {
    return 'Copia restaurada: $profiles perfiles, $periods periodos, $encounters encuentros';
  }

  @override
  String pdfProfileFallback(int id) {
    return 'Perfil $id';
  }

  @override
  String get backupInvalidJson => 'El archivo no es un JSON válido';

  @override
  String get backupNotCicloTrack => 'El archivo no es una copia de CicloTrack';

  @override
  String backupUnsupportedVersion(String version) {
    return 'Versión de copia no soportada (v$version)';
  }

  @override
  String get backupInvalidExportDate => 'Fecha de exportación inválida';

  @override
  String get backupNoTables => 'El archivo no contiene tablas';

  @override
  String backupMissingTable(String table) {
    return 'Falta la tabla $table';
  }

  @override
  String backupInvalidRow(String table) {
    return 'Fila inválida en $table';
  }

  @override
  String backupInvalidValue(String column) {
    return 'Valor inválido en $column';
  }
}
