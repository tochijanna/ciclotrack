// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get errorLabel => 'Error';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String encountersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encounters',
      one: '1 encounter',
    );
    return '$_temp0';
  }

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuMoreOptions => 'More options';

  @override
  String get menuViews => 'Views';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuBackup => 'Backup';

  @override
  String get menuAlerts => 'Alerts';

  @override
  String get menuRefresh => 'Refresh';

  @override
  String get filterAll => 'All';

  @override
  String get newProfile => 'New profile';

  @override
  String get newEncounter => 'New encounter';

  @override
  String get viewEncounters => 'View encounters';

  @override
  String get addNew => 'New';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get createProfile => 'Create profile';

  @override
  String get changeEmoji => 'Change emoji';

  @override
  String get colorLabel => 'Color';

  @override
  String get nameLabel => 'Name *';

  @override
  String get initialsLabel => 'Initials *';

  @override
  String get initialsHelper =>
      'Generated automatically if you leave them blank';

  @override
  String get privateNotes => 'Private notes';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get addCustomTag => '+ Custom';

  @override
  String get chooseEmoji => 'Choose an emoji';

  @override
  String get profileSaveError => 'Could not save the profile';

  @override
  String get emptyProfilesTitle => 'No profiles';

  @override
  String get emptyProfilesSubtitle => 'Add your first profile to get started';

  @override
  String get addProfile => 'Add profile';

  @override
  String get deleteProfileTitle => 'Delete profile';

  @override
  String deleteProfileBody(String name) {
    return 'Delete $name? All their data will be deleted.';
  }

  @override
  String get womanNameRequired => 'Name is required';

  @override
  String get womanNameTooShort => 'Name must be at least 2 characters';

  @override
  String get womanInitialsRequired => 'Initials are required';

  @override
  String get womanInitialsTooLong => 'Initials cannot exceed 4 characters';

  @override
  String get trackingPeriod => 'Period';

  @override
  String get trackingOvulation => 'Ovulation';

  @override
  String get trackingSymptom => 'Symptom';

  @override
  String get trackingEmptyTitle => 'No records';

  @override
  String get trackingEmptySubtitle => 'Add your first tracking record';

  @override
  String get deleteRecordTitle => 'Delete record';

  @override
  String deleteRecordBody(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String flowLevel(int level) {
    return 'Flow: $level/5';
  }

  @override
  String intensityLevel(int level) {
    return 'Intensity: $level/5';
  }

  @override
  String get notesLabel => 'Notes';

  @override
  String get dateLabel => 'Date';

  @override
  String get cervicalMucusLabel => 'Cervical mucus';

  @override
  String get lhTestLabel => 'LH test';

  @override
  String get symptomTypeLabel => 'Symptom type';

  @override
  String get periodFormTitle => 'Log period';

  @override
  String get editPeriodTitle => 'Edit period';

  @override
  String get ovulationFormTitle => 'Log ovulation';

  @override
  String get editOvulationTitle => 'Edit ovulation';

  @override
  String get symptomFormTitle => 'Log symptom';

  @override
  String get editSymptomTitle => 'Edit symptom';

  @override
  String get periodSaveError => 'Could not save the period';

  @override
  String get ovulationSaveError => 'Could not save the ovulation';

  @override
  String get symptomSaveError => 'Could not save the symptom';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomBreastPain => 'Breast pain';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomMood => 'Mood';

  @override
  String get symptomCravings => 'Cravings';

  @override
  String get symptomAbdominalPain => 'Abdominal pain';

  @override
  String get mucusDry => 'Dry';

  @override
  String get mucusSticky => 'Sticky';

  @override
  String get mucusCreamy => 'Creamy';

  @override
  String get mucusWatery => 'Watery';

  @override
  String get mucusStretchy => 'Stretchy';

  @override
  String get mucusEggWhite => 'Egg white';

  @override
  String get lhNegative => 'Negative';

  @override
  String get lhPositive => 'Positive';

  @override
  String get lhNotDone => 'Not done';

  @override
  String get protectionCondom => 'Condom';

  @override
  String get protectionPill => 'Pill';

  @override
  String get protectionNatural => 'Natural';

  @override
  String get protectionNone => 'None';

  @override
  String get relationshipVaginal => 'Vaginal';

  @override
  String get relationshipOral => 'Oral';

  @override
  String get relationshipAnal => 'Anal';

  @override
  String get relationshipOther => 'Other';

  @override
  String get outcomeNothing => 'Nothing';

  @override
  String get outcomePregnancy => 'Pregnancy';

  @override
  String get outcomeAbortion => 'Abortion';

  @override
  String get outcomeUnknown => 'Unknown';

  @override
  String get encountersTitle => 'Encounters';

  @override
  String get deleteEncounterTitle => 'Delete encounter';

  @override
  String get deleteEncounterBody => 'Delete this encounter?';

  @override
  String get emptyEncountersTitle => 'No encounters';

  @override
  String get emptyEncountersSubtitle => 'Log your first encounter';

  @override
  String get encounterFormTitle => 'New encounter';

  @override
  String get editEncounterTitle => 'Edit encounter';

  @override
  String get dateTimeLabel => 'Date and time';

  @override
  String get protectionLabel => 'Protection';

  @override
  String get participantsLabel => 'Participants';

  @override
  String get outcomeLabel => 'Outcome';

  @override
  String get applyToAll => 'Apply to all:';

  @override
  String get encounterSaveError => 'Could not save the encounter';

  @override
  String get encounterTimeFuture => 'Date cannot be in the future';

  @override
  String get encounterProtectionInvalid => 'Invalid protection';

  @override
  String get encounterParticipantsRequired =>
      'There must be at least one participant';

  @override
  String get encounterParticipantsDuplicate =>
      'Participants cannot be repeated';

  @override
  String get encounterRelationshipInvalid => 'Invalid relationship type';

  @override
  String get encounterOutcomeInvalid => 'Invalid outcome';

  @override
  String get riskPeriodInProgress => 'Period in progress';

  @override
  String get riskRiskDay => 'Risk day';

  @override
  String get riskPossibleDelay => 'Possible delay';

  @override
  String get riskOutsideWindow => 'Outside fertile window';

  @override
  String get riskNoData => 'No data';

  @override
  String get phaseMenstruation => 'Menstruation';

  @override
  String get phaseFollicular => 'Follicular';

  @override
  String get phaseFertileWindow => 'Fertile window';

  @override
  String get phaseOvulation => 'Ovulation';

  @override
  String get phaseLuteal => 'Luteal';

  @override
  String get phaseLateLuteal => 'Late luteal (PMS)';

  @override
  String get phaseDelayed => 'Delayed';

  @override
  String get moodMenstruationHumor => 'Low / tired';

  @override
  String get moodMenstruationLibido => 'Low';

  @override
  String get moodMenstruationTip => 'Leave her alone';

  @override
  String get moodFollicularHumor => 'Good mood';

  @override
  String get moodFollicularLibido => 'Rising';

  @override
  String get moodFollicularTip => 'Good time for plans';

  @override
  String get moodFertileHumor => 'Good';

  @override
  String get moodFertileLibido => 'High';

  @override
  String get moodFertileTip => 'Risk days';

  @override
  String get moodOvulationHumor => 'Very good';

  @override
  String get moodOvulationLibido => 'Horny (peak)';

  @override
  String get moodOvulationTip => 'Maximum risk';

  @override
  String get moodLutealHumor => 'Variable';

  @override
  String get moodLutealLibido => 'Declining';

  @override
  String get moodLateLutealHumor => 'Irritable / bad mood';

  @override
  String get moodLateLutealLibido => 'Variable';

  @override
  String get moodLateLutealTip => 'Be patient, better not argue';

  @override
  String get moodDelayedHumor => 'Unpredictable';

  @override
  String get moodDelayedLibido => '—';

  @override
  String get moodDelayedTip => 'Possible delay, check your records';

  @override
  String phaseLabel(String phase) {
    return 'Phase: $phase';
  }

  @override
  String moodLabel(String mood) {
    return 'Mood: $mood';
  }

  @override
  String libidoLabel(String libido) {
    return 'Libido: $libido';
  }

  @override
  String get estimatedOvulation => 'Estimated ovulation';

  @override
  String get fertileWindowRisk => 'Fertile window (risk)';

  @override
  String get expectedPeriod => 'Expected period';

  @override
  String get upcomingDays => 'Upcoming days';

  @override
  String cycleDay(int day) {
    return 'Day $day';
  }

  @override
  String cycleStats(int cycles, int min, int max, String avg) {
    return 'Cycles: $cycles · Min $min / Max $max / Avg $avg days';
  }

  @override
  String get defaultEstimationWarning =>
      '⚠ Default estimate (log more periods for better accuracy)';

  @override
  String get orientationDisclaimer =>
      'Indicative estimate based on the cycle phase';

  @override
  String get noDataCardBody => 'Log a period to see the prediction';

  @override
  String get alertTypeFertilityImminent => 'Imminent fertility';

  @override
  String get alertTypeRiskDay => 'Risk day';

  @override
  String get alertTypePeriodImminent => 'Imminent period';

  @override
  String get alertTypeCombinedFertility => 'Combined fertility';

  @override
  String get alertTypeEncounterFertility => 'Encounter + fertility';

  @override
  String get alertTypePostEncounter => 'Post-encounter warning';

  @override
  String get alertTypeMultiFertility => 'Multiple women + fertility';

  @override
  String get alertTypeCombinedWindow => 'Combined window';

  @override
  String get alertTypeMedication => 'Medication';

  @override
  String get alertDescFertilityImminent =>
      'Notify when ovulation is the next day';

  @override
  String get alertDescRiskDay => 'Notify if you are in a fertile window today';

  @override
  String get alertDescPeriodImminent =>
      'Notify when the period starts the next day';

  @override
  String get alertDescCombinedFertility => 'Weekly summary of fertile women';

  @override
  String get alertDescEncounterFertility =>
      'Notify if you had an encounter and she is fertile';

  @override
  String get alertDescPostEncounter =>
      'Notify if ~14 days have passed since an encounter';

  @override
  String get alertDescMultiFertility =>
      'Notify if a multiple encounter coincides with fertility';

  @override
  String get alertDescCombinedWindow =>
      'Weekly summary of all women\'s windows';

  @override
  String get alertDescMedication => 'Remind to take each woman\'s medication';

  @override
  String get notificationChannelName => 'CicloTrack alerts';

  @override
  String get notificationChannelDescription =>
      'Fertility and cycle notifications';

  @override
  String alertBodyFertilityImminent(String initials, int days) {
    return 'Tomorrow is $initials\'s ovulation day. Fertile window: $days days';
  }

  @override
  String alertBodyRiskDayEndsTomorrow(String initials) {
    return 'Today is a risk day with $initials. Her fertile window ends tomorrow';
  }

  @override
  String alertBodyRiskDayEndsOn(String initials, String date) {
    return 'Today is a risk day with $initials. Her fertile window ends on $date';
  }

  @override
  String alertBodyPeriodImminent(String initials) {
    return '$initials\'s period starts tomorrow';
  }

  @override
  String alertBodyCombinedFertility(String names) {
    return 'There is fertility this week with $names';
  }

  @override
  String alertBodyEncounterFertilityToday(String initials, String weekday) {
    return 'Encounter with $initials on $weekday and her fertile window is today';
  }

  @override
  String alertBodyEncounterFertilityPlus(
    String initials,
    String weekday,
    int days,
  ) {
    return 'Encounter with $initials on $weekday and her fertile window is today + $days days';
  }

  @override
  String alertBodyPostEncounter(String initials, String weekday, String date) {
    return 'Encounter with $initials on $weekday. Her period should start on $date. If there is no pregnancy, she is likely to bleed around that date.';
  }

  @override
  String alertBodyMultiFertility(String names, String weekday) {
    return 'Encounter with $names on $weekday. Both have an active fertile window. High risk.';
  }

  @override
  String alertBodyCombinedWindow(String entries) {
    return '$entries.';
  }

  @override
  String alertEntryFertileRange(String initials, String from, String to) {
    return '$initials is fertile from $from to $to';
  }

  @override
  String alertBodyMedication(String time) {
    return 'It\'s time for your medication ($time)';
  }

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsMedicationTooltip => 'Medication';

  @override
  String get alertsEnabled => 'Alerts enabled';

  @override
  String get alertsEnabledSubtitle => 'Enable or disable all notifications';

  @override
  String get alertsPermissionDenied => 'Notification permission not granted';

  @override
  String get alertsNotifyTime => 'Notification time';

  @override
  String get alertsTypesTitle => 'Alert types';

  @override
  String get alertsUpcomingTitle => 'Upcoming alerts';

  @override
  String get alertsUpcomingEmpty => 'No alerts scheduled for the next 7 days';

  @override
  String get alertsRecalculate => 'Recalculate now';

  @override
  String get alertsRecalculated => 'Alerts recalculated';

  @override
  String get calendarViewsTitle => 'Views';

  @override
  String get calendarWeekTab => 'Week';

  @override
  String get calendarMonthTab => 'Month';

  @override
  String get calendarFertilityTab => 'Fertility';

  @override
  String get calendarEncountersTab => 'Encounters';

  @override
  String get calendarLoadError => 'Could not load the views.';

  @override
  String get calendarEmpty => 'No profiles. Create one to see the calendar.';

  @override
  String get legendMenstruation => 'Menstruation';

  @override
  String get legendFertileWindow => 'Fertile window';

  @override
  String get legendOvulation => 'Ovulation';

  @override
  String get legendRegisteredOvulation => 'Logged ovulation';

  @override
  String get legendSymptom => 'Symptom';

  @override
  String get legendEncounter => 'Encounter';

  @override
  String get legendProjectionNote =>
      'Dimmed marks are projections based on the average cycle.';

  @override
  String get dayNoCycleData => 'No cycle data';

  @override
  String get dayFertileSuffix => '· fertile window';

  @override
  String get fertilityWeekEmpty => 'No woman in a fertile window this week.';

  @override
  String get fertilityEstimated => 'estimated';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsLoadError => 'Could not load the reports.';

  @override
  String get reportsEmpty => 'No profiles. Create one to see the reports.';

  @override
  String get reportsAll => 'All';

  @override
  String get reportsGlobal => 'Global';

  @override
  String get kpiProfiles => 'Profiles';

  @override
  String get kpiCycles => 'Logged cycles';

  @override
  String get kpiAvgCycle => 'Average cycle length';

  @override
  String get kpiAvgMenstruation => 'Average menstruation length';

  @override
  String get kpiEncounters => 'Encounters';

  @override
  String get kpiUnprotected => 'Unprotected';

  @override
  String get kpiFertileDays => 'Fertile days';

  @override
  String get kpiMostEncounters => 'Most encounters';

  @override
  String get kpiNextPeriod => 'Next period';

  @override
  String get hintHistory => 'historical';

  @override
  String get hintClosedPeriods => 'closed periods';

  @override
  String get hintMonths12 => '12 months';

  @override
  String get hintFertile12 => '12 months, with projections';

  @override
  String get hintProjected => 'projected';

  @override
  String hintUnprotected(int unprotected, int total) {
    return '\"None\": $unprotected of $total';
  }

  @override
  String get reportsPerMonth => 'Per month';

  @override
  String get reportsEncountersByWoman => 'Encounters per woman';

  @override
  String get reportsProtection => 'Protection';

  @override
  String get reportsCycleEvolution => 'Cycle evolution';

  @override
  String get reportsRecurringSymptoms => 'Recurring symptoms';

  @override
  String reportsMonthDetail(
    String month,
    int encounters,
    int unprotected,
    int fertile,
    int periods,
  ) {
    return '$month · $encounters encounters · $unprotected unprotected · $fertile fertile days · $periods periods';
  }

  @override
  String get chartNeedTwoCycles =>
      'At least two closed cycles are needed to draw the evolution.';

  @override
  String get chartNoSymptoms => 'No symptoms logged in the last 12 months.';

  @override
  String get chartNoEncounters => 'No encounters logged in the last 12 months.';

  @override
  String get chartLegendEncounters => 'Encounters';

  @override
  String get chartLegendUnprotected => 'Unprotected';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get backupRestoreTitle => 'Restore backup';

  @override
  String backupRestoreConfirm(int count) {
    return 'Replace all current data? The $count profiles and all their records will be deleted.';
  }

  @override
  String get pdfDocumentTitle => 'CicloTrack — backup';

  @override
  String pdfFooterPage(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String pdfGeneratedOn(String date) {
    return 'Report generated on $date';
  }

  @override
  String get pdfSummary => 'Summary';

  @override
  String get pdfRegisteredPeriods => 'Logged periods';

  @override
  String get pdfSymptoms12 => 'Symptoms (12 months)';

  @override
  String get pdfMedication => 'Medication';

  @override
  String get pdfEncounters => 'Encounters';

  @override
  String get pdfColStart => 'Start';

  @override
  String get pdfColEnd => 'End';

  @override
  String get pdfColFlow => 'Flow';

  @override
  String get pdfColNotes => 'Notes';

  @override
  String get pdfColType => 'Type';

  @override
  String get pdfColFrequency => 'Frequency';

  @override
  String get pdfColWoman => 'Woman';

  @override
  String get pdfColMedication => 'Medication';

  @override
  String get pdfColDose => 'Dose';

  @override
  String get pdfColTime => 'Time';

  @override
  String get pdfColState => 'Status';

  @override
  String get pdfColDate => 'Date';

  @override
  String get pdfColWomen => 'Women';

  @override
  String get pdfColProtection => 'Protection';

  @override
  String get pdfColOutcome => 'Outcome';

  @override
  String pdfShowsLast(int shown, int total) {
    return 'Showing the last $shown of $total encounters.';
  }

  @override
  String pdfProfiles(int count) {
    return 'Profiles: $count';
  }

  @override
  String pdfCycles(int count) {
    return 'Logged cycles: $count';
  }

  @override
  String pdfAvgCycle(String value) {
    return 'Average cycle length: $value';
  }

  @override
  String pdfAvgMenstruation(String value) {
    return 'Average menstruation length: $value';
  }

  @override
  String pdfEncounters12(int count) {
    return 'Encounters (12 months): $count';
  }

  @override
  String pdfUnprotected(int percent, int unprotected, int total) {
    return 'Unprotected: $percent % ($unprotected of $total)';
  }

  @override
  String pdfFertileDays12(int count) {
    return 'Fertile days (12 months, with projections): $count';
  }

  @override
  String pdfMostEncounters(String name, int count) {
    return 'Most encounters: $name ($count)';
  }

  @override
  String pdfNextPeriod(String date) {
    return 'Next period: $date';
  }

  @override
  String get medicationTitle => 'Medication';

  @override
  String get medicationAdd => 'Add medication';

  @override
  String get medicationProfilesError => 'Could not load the profiles';

  @override
  String get medicationLoadError => 'Could not load the medication';

  @override
  String get medicationEdit => 'Edit medication';

  @override
  String get medicationNameLabel => 'Medication';

  @override
  String get medicationWomanLabel => 'Woman';

  @override
  String get medicationEnabledLabel => 'Active';

  @override
  String get medicationEmpty => 'No medications logged';

  @override
  String get medicationDeleteTitle => 'Delete medication';

  @override
  String medicationDeleteBody(String name) {
    return 'Delete $name?';
  }

  @override
  String get medicationSaveError => 'Could not save the medication';

  @override
  String get medicationNameRequired => 'Enter the medication name';

  @override
  String get medicationNameTooLong => 'Name allows up to 80 characters';

  @override
  String get medicationDoseTooLong => 'Dose allows up to 60 characters';

  @override
  String get medicationHourRange => 'Hour must be between 0 and 23';

  @override
  String get medicationMinuteRange => 'Minute must be between 0 and 59';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsAlerts => 'Alerts';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsViews => 'Views';

  @override
  String get settingsReports => 'Reports';

  @override
  String get settingsMedication => 'Medication';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get appLockedTitle => 'Access locked';

  @override
  String get appLockedSubtitle =>
      'Unlock with your PIN or fingerprint to continue.';

  @override
  String get appUnlock => 'Unlock';

  @override
  String get appLockAuthReason => 'Unlock CicloTrack to continue';

  @override
  String get appLockLoadError =>
      'Could not check whether the lock is enabled. Unlock or try again.';

  @override
  String get appLockRetry => 'Retry';

  @override
  String remindersOf(String name) {
    return 'Reminders for $name';
  }

  @override
  String get remindersLoadError => 'Could not load the reminders';

  @override
  String get remindersNew => 'New reminder';

  @override
  String get remindersEmpty => 'No reminders';

  @override
  String get remindersDeleteTitle => 'Delete reminder';

  @override
  String remindersDeleteBody(String message) {
    return 'Delete \"$message\"?';
  }

  @override
  String get reminderNotificationTitle => 'Reminder';

  @override
  String get reminderChannelName => 'Reminders';

  @override
  String get reminderChannelDescription =>
      'Personalized reminders by cycle day';

  @override
  String get reminderFormTitle => 'New reminder';

  @override
  String get reminderEditTitle => 'Edit reminder';

  @override
  String get reminderMessageLabel => 'Message';

  @override
  String get reminderStartLabel => 'Cycle start day';

  @override
  String get reminderEndLabel => 'Cycle end day (optional)';

  @override
  String get reminderEnabledLabel => 'Active';

  @override
  String get reminderPermissionDenied =>
      'Reminder saved, but without notification permission you won\'t get the alert';

  @override
  String get reminderSaveError => 'Could not save the reminder';

  @override
  String get reminderMessageRequired => 'Write a message';

  @override
  String reminderMessageTooLong(int max) {
    return 'Maximum $max characters';
  }

  @override
  String get reminderStartRequired => 'Enter a cycle day';

  @override
  String get reminderStartTooSmall => 'Start day must be 1 or greater';

  @override
  String reminderStartTooLarge(int max) {
    return 'Start day cannot exceed $max';
  }

  @override
  String get reminderEndRequired => 'Enter a cycle day';

  @override
  String get reminderEndBeforeStart => 'End day cannot be before the start day';

  @override
  String reminderEndTooLarge(int max) {
    return 'End day cannot exceed $max';
  }

  @override
  String reminderDayLabel(int day) {
    return 'Day $day of cycle';
  }

  @override
  String reminderDaysLabel(int start, int end) {
    return 'Days $start-$end of cycle';
  }

  @override
  String reminderBodyRange(String message, int start, int end) {
    return '$message (days $start-$end of cycle)';
  }

  @override
  String get dayNoProfiles => 'No profiles.';

  @override
  String get saving => 'Saving…';

  @override
  String get add => 'Add';

  @override
  String get register => 'Log';

  @override
  String get remindersTooltip => 'Reminders';

  @override
  String get tagRelated => 'Partner';

  @override
  String get tagFriend => 'Friend';

  @override
  String get tagEx => 'Ex';

  @override
  String get tagCoworker => 'Companion';

  @override
  String get tagCasual => 'Casual';

  @override
  String get tagOther => 'Other';

  @override
  String get newTagTitle => 'New tag';

  @override
  String get tagNameHint => 'Tag name';

  @override
  String get medicationNoProfiles => 'Create a profile to add medication';

  @override
  String get medicationWomanRequired => 'Select a woman';

  @override
  String get medicationDoseOptional => 'Dose (optional)';

  @override
  String get medicationTakeTime => 'Take time';

  @override
  String get reminderMessageHint => 'Better avoid sex these days';

  @override
  String get reminderCycleNote =>
      'Day 1 is the start of the last logged period. You\'ll get one notification per cycle, on the start day.';

  @override
  String get reminderCreate => 'Create reminder';

  @override
  String get reminderDisabled => 'Disabled';

  @override
  String get remindersEmptySubtitle =>
      'Create a reminder for specific days of the cycle';

  @override
  String get encounterNoProfiles => 'No profiles available';

  @override
  String get relationshipTypeLabel => 'Relationship type';

  @override
  String get outcomeNoneOption => 'None';

  @override
  String get registerEncounter => 'Log encounter';

  @override
  String get registerPeriod => 'Log period';

  @override
  String get registerOvulation => 'Log ovulation';

  @override
  String get registerSymptom => 'Log symptom';

  @override
  String get dateStartLabel => 'Start date';

  @override
  String get dateEndOptionalLabel => 'End date (optional)';

  @override
  String get undefinedDate => 'Not set';

  @override
  String get durationLabel => 'Duration';

  @override
  String get flowLevelLabel => 'Flow level';

  @override
  String get temperatureBasalLabel => 'Basal temperature (°C)';

  @override
  String get periodStartFuture => 'Start date cannot be in the future';

  @override
  String get periodEndBeforeStart => 'End date cannot be before the start date';

  @override
  String get periodFlowRange => 'Flow must be between 1 and 5';

  @override
  String get dateFuture => 'Date cannot be in the future';

  @override
  String get temperatureInvalid =>
      'Enter a valid temperature between 34 and 40 °C';

  @override
  String get symptomTypeInvalid => 'Invalid symptom type';

  @override
  String get severityRange => 'Intensity must be between 1 and 5';

  @override
  String calendarWeekRange(String from, String to) {
    return 'Week from $from to $to';
  }

  @override
  String fertilityWindowLabel(String from, String to) {
    return 'Window: $from – $to';
  }

  @override
  String ovulationDateLabel(String date) {
    return 'Ovulation: $date';
  }

  @override
  String get fertilityEstimatedF => 'estimated';

  @override
  String get fertilityStartsTomorrow => 'Starts tomorrow';

  @override
  String fertilityStartsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'Starts in $_temp0';
  }

  @override
  String get fertilityLastDay => 'Last day of window';

  @override
  String fertilityInProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'In progress, ends in $_temp0';
  }

  @override
  String encountersFilterAllCount(int count) {
    return 'All ($count)';
  }

  @override
  String get encountersNone => 'No encounters logged.';

  @override
  String encountersNoneFor(String name) {
    return 'No encounters with $name.';
  }

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get medicationSaveChangeError => 'Could not save the change';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsAppLockTitle => 'App lock (PIN/fingerprint)';

  @override
  String get settingsAppLockSupported =>
      'Asks for PIN or fingerprint when opening the app and after 1 minute in the background. It controls access; it does not encrypt the data.';

  @override
  String get settingsDiscreetNoticesTitle => 'Discreet notifications';

  @override
  String get settingsDiscreetNoticesSubtitle =>
      'Notifications do not show initials, dates or reminder text';

  @override
  String get discreetNoticeBody =>
      'You have a new notice. Open the app to see it.';

  @override
  String get settingsAppLockUnavailable => 'Not available on this device';

  @override
  String get settingsAppLockSaveError =>
      'Could not save the app lock setting. Try again.';

  @override
  String get settingsAppLockAuthRequired =>
      'The lock is still on: unlock with your PIN or fingerprint to turn it off.';

  @override
  String get settingsLocalTitle => '100% local and cloud-free';

  @override
  String get settingsLocalSubtitle =>
      'All data is stored only on this device: no accounts, sync or servers.';

  @override
  String get settingsMedicationSubtitle => 'Pills and alert times, per woman';

  @override
  String get settingsAlertsSubtitle => 'Local alerts and notification time';

  @override
  String get settingsBackupSubtitle => 'Export and restore data';

  @override
  String get settingsReportsSubtitle => 'Statistics and charts';

  @override
  String get settingsViewsSubtitle => 'Calendar, fertility and encounters';

  @override
  String get backupSectionExport => 'Export';

  @override
  String get backupSectionImport => 'Import';

  @override
  String get backupExportJsonTitle => 'Full backup (JSON)';

  @override
  String get backupExportJsonSubtitle => 'All data in a JSON file';

  @override
  String get backupExportCsvTitle => 'Tables (CSV)';

  @override
  String get backupExportCsvSubtitle =>
      'One CSV per table, compressed into a ZIP';

  @override
  String get backupExportPdfTitle => 'Report (PDF)';

  @override
  String get backupExportPdfSubtitle =>
      'Printable summary of profiles, cycles and encounters';

  @override
  String get backupImportJsonTitle => 'Restore from JSON';

  @override
  String get backupImportJsonSubtitle => 'Replaces all current data';

  @override
  String get backupNotReady => 'Could not save: data is still loading';

  @override
  String get backupCancelled => 'Export cancelled';

  @override
  String get backupImportCancelled => 'Import cancelled';

  @override
  String get backupRestoreAction => 'Restore';

  @override
  String get backupUnencryptedTitle => 'Unencrypted file';

  @override
  String get backupUnencryptedWarning =>
      'The file will be saved unencrypted: anyone who opens it can read all the data. The app lock does not protect it. Keep it somewhere safe.';

  @override
  String get backupUnencryptedAction => 'Export';

  @override
  String backupSaveFailed(String reason) {
    return 'Could not save: $reason';
  }

  @override
  String backupImportFailed(String reason) {
    return 'Could not import: $reason';
  }

  @override
  String backupRestoredSummary(int profiles, int periods, int encounters) {
    return 'Backup restored: $profiles profiles, $periods periods, $encounters encounters';
  }

  @override
  String pdfProfileFallback(int id) {
    return 'Profile $id';
  }

  @override
  String get backupInvalidJson => 'The file is not valid JSON';

  @override
  String get backupNotCicloTrack => 'The file is not a CicloTrack backup';

  @override
  String backupUnsupportedVersion(String version) {
    return 'Unsupported backup version (v$version)';
  }

  @override
  String get backupInvalidExportDate => 'Invalid export date';

  @override
  String get backupNoTables => 'The file contains no tables';

  @override
  String backupMissingTable(String table) {
    return 'Table $table is missing';
  }

  @override
  String backupInvalidRow(String table) {
    return 'Invalid row in $table';
  }

  @override
  String backupInvalidValue(String column) {
    return 'Invalid value in $column';
  }
}
