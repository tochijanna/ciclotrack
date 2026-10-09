import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @errorLabel.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @daysCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 día} other{{count} días}}'**
  String daysCount(int count);

  /// No description provided for @encountersCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 encuentro} other{{count} encuentros}}'**
  String encountersCount(int count);

  /// No description provided for @menuSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get menuSettings;

  /// No description provided for @menuMoreOptions.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get menuMoreOptions;

  /// No description provided for @menuViews.
  ///
  /// In es, this message translates to:
  /// **'Vistas'**
  String get menuViews;

  /// No description provided for @menuReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get menuReports;

  /// No description provided for @menuBackup.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get menuBackup;

  /// No description provided for @menuAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get menuAlerts;

  /// No description provided for @menuRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get menuRefresh;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get filterAll;

  /// No description provided for @newProfile.
  ///
  /// In es, this message translates to:
  /// **'Nuevo perfil'**
  String get newProfile;

  /// No description provided for @newEncounter.
  ///
  /// In es, this message translates to:
  /// **'Nuevo encuentro'**
  String get newEncounter;

  /// No description provided for @viewEncounters.
  ///
  /// In es, this message translates to:
  /// **'Ver encuentros'**
  String get viewEncounters;

  /// No description provided for @addNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get addNew;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChanges;

  /// No description provided for @createProfile.
  ///
  /// In es, this message translates to:
  /// **'Crear perfil'**
  String get createProfile;

  /// No description provided for @changeEmoji.
  ///
  /// In es, this message translates to:
  /// **'Cambiar emoji'**
  String get changeEmoji;

  /// No description provided for @colorLabel.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get nameLabel;

  /// No description provided for @initialsLabel.
  ///
  /// In es, this message translates to:
  /// **'Iniciales *'**
  String get initialsLabel;

  /// No description provided for @initialsHelper.
  ///
  /// In es, this message translates to:
  /// **'Se generan automáticamente si las dejas vacías'**
  String get initialsHelper;

  /// No description provided for @privateNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas privadas'**
  String get privateNotes;

  /// No description provided for @tagsLabel.
  ///
  /// In es, this message translates to:
  /// **'Etiquetas'**
  String get tagsLabel;

  /// No description provided for @addCustomTag.
  ///
  /// In es, this message translates to:
  /// **'+ Personalizada'**
  String get addCustomTag;

  /// No description provided for @chooseEmoji.
  ///
  /// In es, this message translates to:
  /// **'Elige un emoji'**
  String get chooseEmoji;

  /// No description provided for @profileSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el perfil'**
  String get profileSaveError;

  /// No description provided for @emptyProfilesTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay perfiles'**
  String get emptyProfilesTitle;

  /// No description provided for @emptyProfilesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Añade tu primer perfil para empezar'**
  String get emptyProfilesSubtitle;

  /// No description provided for @addProfile.
  ///
  /// In es, this message translates to:
  /// **'Añadir perfil'**
  String get addProfile;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar perfil'**
  String get deleteProfileTitle;

  /// No description provided for @deleteProfileBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar a {name}? Se borrarán todos sus datos.'**
  String deleteProfileBody(String name);

  /// No description provided for @womanNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get womanNameRequired;

  /// No description provided for @womanNameTooShort.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 2 caracteres'**
  String get womanNameTooShort;

  /// No description provided for @womanInitialsRequired.
  ///
  /// In es, this message translates to:
  /// **'Las iniciales son obligatorias'**
  String get womanInitialsRequired;

  /// No description provided for @womanInitialsTooLong.
  ///
  /// In es, this message translates to:
  /// **'Las iniciales no pueden tener más de 4 caracteres'**
  String get womanInitialsTooLong;

  /// No description provided for @trackingPeriod.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get trackingPeriod;

  /// No description provided for @trackingOvulation.
  ///
  /// In es, this message translates to:
  /// **'Ovulación'**
  String get trackingOvulation;

  /// No description provided for @trackingSymptom.
  ///
  /// In es, this message translates to:
  /// **'Síntoma'**
  String get trackingSymptom;

  /// No description provided for @trackingEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin registros'**
  String get trackingEmptyTitle;

  /// No description provided for @trackingEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Añade tu primer registro de tracking'**
  String get trackingEmptySubtitle;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar registro'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{title}\"?'**
  String deleteRecordBody(String title);

  /// No description provided for @flowLevel.
  ///
  /// In es, this message translates to:
  /// **'Flujo: {level}/5'**
  String flowLevel(int level);

  /// No description provided for @intensityLevel.
  ///
  /// In es, this message translates to:
  /// **'Intensidad: {level}/5'**
  String intensityLevel(int level);

  /// No description provided for @notesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notesLabel;

  /// No description provided for @dateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get dateLabel;

  /// No description provided for @cervicalMucusLabel.
  ///
  /// In es, this message translates to:
  /// **'Moco cervical'**
  String get cervicalMucusLabel;

  /// No description provided for @lhTestLabel.
  ///
  /// In es, this message translates to:
  /// **'Test LH'**
  String get lhTestLabel;

  /// No description provided for @symptomTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de síntoma'**
  String get symptomTypeLabel;

  /// No description provided for @periodFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar periodo'**
  String get periodFormTitle;

  /// No description provided for @editPeriodTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar periodo'**
  String get editPeriodTitle;

  /// No description provided for @ovulationFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar ovulación'**
  String get ovulationFormTitle;

  /// No description provided for @editOvulationTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar ovulación'**
  String get editOvulationTitle;

  /// No description provided for @symptomFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar síntoma'**
  String get symptomFormTitle;

  /// No description provided for @editSymptomTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar síntoma'**
  String get editSymptomTitle;

  /// No description provided for @periodSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el periodo'**
  String get periodSaveError;

  /// No description provided for @ovulationSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la ovulación'**
  String get ovulationSaveError;

  /// No description provided for @symptomSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el síntoma'**
  String get symptomSaveError;

  /// No description provided for @symptomAcne.
  ///
  /// In es, this message translates to:
  /// **'Acné'**
  String get symptomAcne;

  /// No description provided for @symptomBreastPain.
  ///
  /// In es, this message translates to:
  /// **'Dolor de pecho'**
  String get symptomBreastPain;

  /// No description provided for @symptomFatigue.
  ///
  /// In es, this message translates to:
  /// **'Cansancio'**
  String get symptomFatigue;

  /// No description provided for @symptomMood.
  ///
  /// In es, this message translates to:
  /// **'Humor'**
  String get symptomMood;

  /// No description provided for @symptomCravings.
  ///
  /// In es, this message translates to:
  /// **'Antojos'**
  String get symptomCravings;

  /// No description provided for @symptomAbdominalPain.
  ///
  /// In es, this message translates to:
  /// **'Dolor abdominal'**
  String get symptomAbdominalPain;

  /// No description provided for @mucusDry.
  ///
  /// In es, this message translates to:
  /// **'Seco'**
  String get mucusDry;

  /// No description provided for @mucusSticky.
  ///
  /// In es, this message translates to:
  /// **'Pegajoso'**
  String get mucusSticky;

  /// No description provided for @mucusCreamy.
  ///
  /// In es, this message translates to:
  /// **'Cremoso'**
  String get mucusCreamy;

  /// No description provided for @mucusWatery.
  ///
  /// In es, this message translates to:
  /// **'Acuoso'**
  String get mucusWatery;

  /// No description provided for @mucusStretchy.
  ///
  /// In es, this message translates to:
  /// **'Elástico'**
  String get mucusStretchy;

  /// No description provided for @mucusEggWhite.
  ///
  /// In es, this message translates to:
  /// **'Clara de huevo'**
  String get mucusEggWhite;

  /// No description provided for @lhNegative.
  ///
  /// In es, this message translates to:
  /// **'Negativo'**
  String get lhNegative;

  /// No description provided for @lhPositive.
  ///
  /// In es, this message translates to:
  /// **'Positivo'**
  String get lhPositive;

  /// No description provided for @lhNotDone.
  ///
  /// In es, this message translates to:
  /// **'No realizado'**
  String get lhNotDone;

  /// No description provided for @protectionCondom.
  ///
  /// In es, this message translates to:
  /// **'Condón'**
  String get protectionCondom;

  /// No description provided for @protectionPill.
  ///
  /// In es, this message translates to:
  /// **'Pastilla'**
  String get protectionPill;

  /// No description provided for @protectionNatural.
  ///
  /// In es, this message translates to:
  /// **'Natural'**
  String get protectionNatural;

  /// No description provided for @protectionNone.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get protectionNone;

  /// No description provided for @relationshipVaginal.
  ///
  /// In es, this message translates to:
  /// **'Vaginal'**
  String get relationshipVaginal;

  /// No description provided for @relationshipOral.
  ///
  /// In es, this message translates to:
  /// **'Oral'**
  String get relationshipOral;

  /// No description provided for @relationshipAnal.
  ///
  /// In es, this message translates to:
  /// **'Anal'**
  String get relationshipAnal;

  /// No description provided for @relationshipOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get relationshipOther;

  /// No description provided for @outcomeNothing.
  ///
  /// In es, this message translates to:
  /// **'Nada'**
  String get outcomeNothing;

  /// No description provided for @outcomePregnancy.
  ///
  /// In es, this message translates to:
  /// **'Embarazo'**
  String get outcomePregnancy;

  /// No description provided for @outcomeAbortion.
  ///
  /// In es, this message translates to:
  /// **'Aborto'**
  String get outcomeAbortion;

  /// No description provided for @outcomeUnknown.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get outcomeUnknown;

  /// No description provided for @encountersTitle.
  ///
  /// In es, this message translates to:
  /// **'Encuentros'**
  String get encountersTitle;

  /// No description provided for @deleteEncounterTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar encuentro'**
  String get deleteEncounterTitle;

  /// No description provided for @deleteEncounterBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este encuentro?'**
  String get deleteEncounterBody;

  /// No description provided for @emptyEncountersTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin encuentros'**
  String get emptyEncountersTitle;

  /// No description provided for @emptyEncountersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tu primer encuentro'**
  String get emptyEncountersSubtitle;

  /// No description provided for @encounterFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo encuentro'**
  String get encounterFormTitle;

  /// No description provided for @editEncounterTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar encuentro'**
  String get editEncounterTitle;

  /// No description provided for @dateTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora'**
  String get dateTimeLabel;

  /// No description provided for @protectionLabel.
  ///
  /// In es, this message translates to:
  /// **'Protección'**
  String get protectionLabel;

  /// No description provided for @participantsLabel.
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get participantsLabel;

  /// No description provided for @outcomeLabel.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get outcomeLabel;

  /// No description provided for @applyToAll.
  ///
  /// In es, this message translates to:
  /// **'Aplicar a todas:'**
  String get applyToAll;

  /// No description provided for @encounterSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el encuentro'**
  String get encounterSaveError;

  /// No description provided for @encounterTimeFuture.
  ///
  /// In es, this message translates to:
  /// **'La fecha no puede ser futura'**
  String get encounterTimeFuture;

  /// No description provided for @encounterProtectionInvalid.
  ///
  /// In es, this message translates to:
  /// **'Protección no válida'**
  String get encounterProtectionInvalid;

  /// No description provided for @encounterParticipantsRequired.
  ///
  /// In es, this message translates to:
  /// **'Debe haber al menos una participante'**
  String get encounterParticipantsRequired;

  /// No description provided for @encounterParticipantsDuplicate.
  ///
  /// In es, this message translates to:
  /// **'No se pueden repetir participantes'**
  String get encounterParticipantsDuplicate;

  /// No description provided for @encounterRelationshipInvalid.
  ///
  /// In es, this message translates to:
  /// **'Tipo de relación no válido'**
  String get encounterRelationshipInvalid;

  /// No description provided for @encounterOutcomeInvalid.
  ///
  /// In es, this message translates to:
  /// **'Resultado no válido'**
  String get encounterOutcomeInvalid;

  /// No description provided for @riskPeriodInProgress.
  ///
  /// In es, this message translates to:
  /// **'Periodo en curso'**
  String get riskPeriodInProgress;

  /// No description provided for @riskRiskDay.
  ///
  /// In es, this message translates to:
  /// **'Día de riesgo'**
  String get riskRiskDay;

  /// No description provided for @riskPossibleDelay.
  ///
  /// In es, this message translates to:
  /// **'Posible retraso'**
  String get riskPossibleDelay;

  /// No description provided for @riskOutsideWindow.
  ///
  /// In es, this message translates to:
  /// **'Fuera de ventana fértil'**
  String get riskOutsideWindow;

  /// No description provided for @riskNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get riskNoData;

  /// No description provided for @phaseMenstruation.
  ///
  /// In es, this message translates to:
  /// **'Menstruación'**
  String get phaseMenstruation;

  /// No description provided for @phaseFollicular.
  ///
  /// In es, this message translates to:
  /// **'Folicular'**
  String get phaseFollicular;

  /// No description provided for @phaseFertileWindow.
  ///
  /// In es, this message translates to:
  /// **'Ventana fértil'**
  String get phaseFertileWindow;

  /// No description provided for @phaseOvulation.
  ///
  /// In es, this message translates to:
  /// **'Ovulación'**
  String get phaseOvulation;

  /// No description provided for @phaseLuteal.
  ///
  /// In es, this message translates to:
  /// **'Lútea'**
  String get phaseLuteal;

  /// No description provided for @phaseLateLuteal.
  ///
  /// In es, this message translates to:
  /// **'Lútea tardía (PMS)'**
  String get phaseLateLuteal;

  /// No description provided for @phaseDelayed.
  ///
  /// In es, this message translates to:
  /// **'Retraso'**
  String get phaseDelayed;

  /// No description provided for @moodMenstruationHumor.
  ///
  /// In es, this message translates to:
  /// **'Bajo / cansancio'**
  String get moodMenstruationHumor;

  /// No description provided for @moodMenstruationLibido.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get moodMenstruationLibido;

  /// No description provided for @moodMenstruationTip.
  ///
  /// In es, this message translates to:
  /// **'Déjala tranquila'**
  String get moodMenstruationTip;

  /// No description provided for @moodFollicularHumor.
  ///
  /// In es, this message translates to:
  /// **'Buen humor'**
  String get moodFollicularHumor;

  /// No description provided for @moodFollicularLibido.
  ///
  /// In es, this message translates to:
  /// **'En aumento'**
  String get moodFollicularLibido;

  /// No description provided for @moodFollicularTip.
  ///
  /// In es, this message translates to:
  /// **'Buen momento para planes'**
  String get moodFollicularTip;

  /// No description provided for @moodFertileHumor.
  ///
  /// In es, this message translates to:
  /// **'Bueno'**
  String get moodFertileHumor;

  /// No description provided for @moodFertileLibido.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get moodFertileLibido;

  /// No description provided for @moodFertileTip.
  ///
  /// In es, this message translates to:
  /// **'Días de riesgo'**
  String get moodFertileTip;

  /// No description provided for @moodOvulationHumor.
  ///
  /// In es, this message translates to:
  /// **'Muy bueno'**
  String get moodOvulationHumor;

  /// No description provided for @moodOvulationLibido.
  ///
  /// In es, this message translates to:
  /// **'Cachonda (pico)'**
  String get moodOvulationLibido;

  /// No description provided for @moodOvulationTip.
  ///
  /// In es, this message translates to:
  /// **'Riesgo máximo'**
  String get moodOvulationTip;

  /// No description provided for @moodLutealHumor.
  ///
  /// In es, this message translates to:
  /// **'Variable'**
  String get moodLutealHumor;

  /// No description provided for @moodLutealLibido.
  ///
  /// In es, this message translates to:
  /// **'En descenso'**
  String get moodLutealLibido;

  /// No description provided for @moodLateLutealHumor.
  ///
  /// In es, this message translates to:
  /// **'Irritable / mal humor'**
  String get moodLateLutealHumor;

  /// No description provided for @moodLateLutealLibido.
  ///
  /// In es, this message translates to:
  /// **'Variable'**
  String get moodLateLutealLibido;

  /// No description provided for @moodLateLutealTip.
  ///
  /// In es, this message translates to:
  /// **'Paciencia, mejor no discutir'**
  String get moodLateLutealTip;

  /// No description provided for @moodDelayedHumor.
  ///
  /// In es, this message translates to:
  /// **'Imprevisible'**
  String get moodDelayedHumor;

  /// No description provided for @moodDelayedLibido.
  ///
  /// In es, this message translates to:
  /// **'—'**
  String get moodDelayedLibido;

  /// No description provided for @moodDelayedTip.
  ///
  /// In es, this message translates to:
  /// **'Posible retraso, comprueba registro'**
  String get moodDelayedTip;

  /// No description provided for @phaseLabel.
  ///
  /// In es, this message translates to:
  /// **'Fase: {phase}'**
  String phaseLabel(String phase);

  /// No description provided for @moodLabel.
  ///
  /// In es, this message translates to:
  /// **'Humor: {mood}'**
  String moodLabel(String mood);

  /// No description provided for @libidoLabel.
  ///
  /// In es, this message translates to:
  /// **'Libido: {libido}'**
  String libidoLabel(String libido);

  /// No description provided for @estimatedOvulation.
  ///
  /// In es, this message translates to:
  /// **'Ovulación estimada'**
  String get estimatedOvulation;

  /// No description provided for @fertileWindowRisk.
  ///
  /// In es, this message translates to:
  /// **'Ventana fértil (riesgo)'**
  String get fertileWindowRisk;

  /// No description provided for @expectedPeriod.
  ///
  /// In es, this message translates to:
  /// **'Periodo previsto'**
  String get expectedPeriod;

  /// No description provided for @upcomingDays.
  ///
  /// In es, this message translates to:
  /// **'Próximos días'**
  String get upcomingDays;

  /// No description provided for @cycleDay.
  ///
  /// In es, this message translates to:
  /// **'Día {day}'**
  String cycleDay(int day);

  /// No description provided for @cycleStats.
  ///
  /// In es, this message translates to:
  /// **'Ciclos: {cycles} · Min {min} / Max {max} / Media {avg} días'**
  String cycleStats(int cycles, int min, int max, String avg);

  /// No description provided for @defaultEstimationWarning.
  ///
  /// In es, this message translates to:
  /// **'⚠ Estimación por defecto (registra más periodos para mayor precisión)'**
  String get defaultEstimationWarning;

  /// No description provided for @orientationDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'Estimación orientativa según la fase del ciclo'**
  String get orientationDisclaimer;

  /// No description provided for @noDataCardBody.
  ///
  /// In es, this message translates to:
  /// **'Registra un periodo para ver la predicción'**
  String get noDataCardBody;

  /// No description provided for @alertTypeFertilityImminent.
  ///
  /// In es, this message translates to:
  /// **'Fertilidad inminente'**
  String get alertTypeFertilityImminent;

  /// No description provided for @alertTypeRiskDay.
  ///
  /// In es, this message translates to:
  /// **'Día de riesgo'**
  String get alertTypeRiskDay;

  /// No description provided for @alertTypePeriodImminent.
  ///
  /// In es, this message translates to:
  /// **'Periodo inminente'**
  String get alertTypePeriodImminent;

  /// No description provided for @alertTypeCombinedFertility.
  ///
  /// In es, this message translates to:
  /// **'Fertilidad combinada'**
  String get alertTypeCombinedFertility;

  /// No description provided for @alertTypeEncounterFertility.
  ///
  /// In es, this message translates to:
  /// **'Encuentro + fertilidad'**
  String get alertTypeEncounterFertility;

  /// No description provided for @alertTypePostEncounter.
  ///
  /// In es, this message translates to:
  /// **'Advertencia post-encuentro'**
  String get alertTypePostEncounter;

  /// No description provided for @alertTypeMultiFertility.
  ///
  /// In es, this message translates to:
  /// **'Múltiples mujeres + fertilidad'**
  String get alertTypeMultiFertility;

  /// No description provided for @alertTypeCombinedWindow.
  ///
  /// In es, this message translates to:
  /// **'Ventana combinada'**
  String get alertTypeCombinedWindow;

  /// No description provided for @alertTypeMedication.
  ///
  /// In es, this message translates to:
  /// **'Medicación'**
  String get alertTypeMedication;

  /// No description provided for @alertDescFertilityImminent.
  ///
  /// In es, this message translates to:
  /// **'Notifica cuando la ovulación es al día siguiente'**
  String get alertDescFertilityImminent;

  /// No description provided for @alertDescRiskDay.
  ///
  /// In es, this message translates to:
  /// **'Notifica si hoy estás en ventana fértil'**
  String get alertDescRiskDay;

  /// No description provided for @alertDescPeriodImminent.
  ///
  /// In es, this message translates to:
  /// **'Notifica cuando el periodo empieza al día siguiente'**
  String get alertDescPeriodImminent;

  /// No description provided for @alertDescCombinedFertility.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal de mujeres fértiles'**
  String get alertDescCombinedFertility;

  /// No description provided for @alertDescEncounterFertility.
  ///
  /// In es, this message translates to:
  /// **'Avisa si tuviste un encuentro y ella está fértil'**
  String get alertDescEncounterFertility;

  /// No description provided for @alertDescPostEncounter.
  ///
  /// In es, this message translates to:
  /// **'Avisa si pasaron ~14 días desde un encuentro'**
  String get alertDescPostEncounter;

  /// No description provided for @alertDescMultiFertility.
  ///
  /// In es, this message translates to:
  /// **'Avisa si un encuentro múltiple coincide con fertilidad'**
  String get alertDescMultiFertility;

  /// No description provided for @alertDescCombinedWindow.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal de ventanas de todas las mujeres'**
  String get alertDescCombinedWindow;

  /// No description provided for @alertDescMedication.
  ///
  /// In es, this message translates to:
  /// **'Recuerda la toma de los medicamentos de cada mujer'**
  String get alertDescMedication;

  /// No description provided for @notificationChannelName.
  ///
  /// In es, this message translates to:
  /// **'Alertas de CicloTrack'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones de fertilidad y ciclo'**
  String get notificationChannelDescription;

  /// No description provided for @alertBodyFertilityImminent.
  ///
  /// In es, this message translates to:
  /// **'Mañana es día de ovulación de {initials}. Ventana de fertilidad: {days} días'**
  String alertBodyFertilityImminent(String initials, int days);

  /// No description provided for @alertBodyRiskDayEndsTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Hoy es día de riesgo con {initials}. Su ventana de fertilidad termina mañana'**
  String alertBodyRiskDayEndsTomorrow(String initials);

  /// No description provided for @alertBodyRiskDayEndsOn.
  ///
  /// In es, this message translates to:
  /// **'Hoy es día de riesgo con {initials}. Su ventana de fertilidad termina el {date}'**
  String alertBodyRiskDayEndsOn(String initials, String date);

  /// No description provided for @alertBodyPeriodImminent.
  ///
  /// In es, this message translates to:
  /// **'El periodo de {initials} empieza mañana'**
  String alertBodyPeriodImminent(String initials);

  /// No description provided for @alertBodyCombinedFertility.
  ///
  /// In es, this message translates to:
  /// **'Esta semana hay fertilidad con {names}'**
  String alertBodyCombinedFertility(String names);

  /// No description provided for @alertBodyEncounterFertilityToday.
  ///
  /// In es, this message translates to:
  /// **'Encuentro con {initials} el {weekday} y su ventana de fertilidad es hoy'**
  String alertBodyEncounterFertilityToday(String initials, String weekday);

  /// No description provided for @alertBodyEncounterFertilityPlus.
  ///
  /// In es, this message translates to:
  /// **'Encuentro con {initials} el {weekday} y su ventana de fertilidad es hoy + {days} días'**
  String alertBodyEncounterFertilityPlus(
    String initials,
    String weekday,
    int days,
  );

  /// No description provided for @alertBodyPostEncounter.
  ///
  /// In es, this message translates to:
  /// **'Encuentro con {initials} el {weekday}. Su periodo debería empezar el {date}. Si no hay embarazo, es probable que tenga sangrado a esa fecha.'**
  String alertBodyPostEncounter(String initials, String weekday, String date);

  /// No description provided for @alertBodyMultiFertility.
  ///
  /// In es, this message translates to:
  /// **'Encuentro con {names} el {weekday}. Ambas tienen ventana de fertilidad activa. Alto riesgo.'**
  String alertBodyMultiFertility(String names, String weekday);

  /// No description provided for @alertBodyCombinedWindow.
  ///
  /// In es, this message translates to:
  /// **'{entries}.'**
  String alertBodyCombinedWindow(String entries);

  /// No description provided for @alertEntryFertileRange.
  ///
  /// In es, this message translates to:
  /// **'{initials} es fértil del {from} al {to}'**
  String alertEntryFertileRange(String initials, String from, String to);

  /// No description provided for @alertBodyMedication.
  ///
  /// In es, this message translates to:
  /// **'Es hora de tu medicación ({time})'**
  String alertBodyMedication(String time);

  /// No description provided for @alertsTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get alertsTitle;

  /// No description provided for @alertsMedicationTooltip.
  ///
  /// In es, this message translates to:
  /// **'Medicación'**
  String get alertsMedicationTooltip;

  /// No description provided for @alertsEnabled.
  ///
  /// In es, this message translates to:
  /// **'Alertas activadas'**
  String get alertsEnabled;

  /// No description provided for @alertsEnabledSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activa o desactiva todas las notificaciones'**
  String get alertsEnabledSubtitle;

  /// No description provided for @alertsPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso de notificaciones no concedido'**
  String get alertsPermissionDenied;

  /// No description provided for @alertsNotifyTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de notificación'**
  String get alertsNotifyTime;

  /// No description provided for @alertsTypesTitle.
  ///
  /// In es, this message translates to:
  /// **'Tipos de alerta'**
  String get alertsTypesTitle;

  /// No description provided for @alertsUpcomingTitle.
  ///
  /// In es, this message translates to:
  /// **'Próximas alertas'**
  String get alertsUpcomingTitle;

  /// No description provided for @alertsUpcomingEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay alertas programadas para los próximos 7 días'**
  String get alertsUpcomingEmpty;

  /// No description provided for @alertsRecalculate.
  ///
  /// In es, this message translates to:
  /// **'Recalcular ahora'**
  String get alertsRecalculate;

  /// No description provided for @alertsRecalculated.
  ///
  /// In es, this message translates to:
  /// **'Alertas recalculadas'**
  String get alertsRecalculated;

  /// No description provided for @calendarViewsTitle.
  ///
  /// In es, this message translates to:
  /// **'Vistas'**
  String get calendarViewsTitle;

  /// No description provided for @calendarWeekTab.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get calendarWeekTab;

  /// No description provided for @calendarMonthTab.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get calendarMonthTab;

  /// No description provided for @calendarFertilityTab.
  ///
  /// In es, this message translates to:
  /// **'Fertilidad'**
  String get calendarFertilityTab;

  /// No description provided for @calendarEncountersTab.
  ///
  /// In es, this message translates to:
  /// **'Encuentros'**
  String get calendarEncountersTab;

  /// No description provided for @calendarLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las vistas.'**
  String get calendarLoadError;

  /// No description provided for @calendarEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin perfiles. Crea uno para ver el calendario.'**
  String get calendarEmpty;

  /// No description provided for @legendMenstruation.
  ///
  /// In es, this message translates to:
  /// **'Menstruación'**
  String get legendMenstruation;

  /// No description provided for @legendFertileWindow.
  ///
  /// In es, this message translates to:
  /// **'Ventana fértil'**
  String get legendFertileWindow;

  /// No description provided for @legendOvulation.
  ///
  /// In es, this message translates to:
  /// **'Ovulación'**
  String get legendOvulation;

  /// No description provided for @legendRegisteredOvulation.
  ///
  /// In es, this message translates to:
  /// **'Ovulación registrada'**
  String get legendRegisteredOvulation;

  /// No description provided for @legendSymptom.
  ///
  /// In es, this message translates to:
  /// **'Síntoma'**
  String get legendSymptom;

  /// No description provided for @legendEncounter.
  ///
  /// In es, this message translates to:
  /// **'Encuentro'**
  String get legendEncounter;

  /// No description provided for @legendProjectionNote.
  ///
  /// In es, this message translates to:
  /// **'Las marcas atenuadas son proyecciones a partir de la media de ciclos.'**
  String get legendProjectionNote;

  /// No description provided for @dayNoCycleData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de ciclo'**
  String get dayNoCycleData;

  /// No description provided for @dayFertileSuffix.
  ///
  /// In es, this message translates to:
  /// **'· ventana fértil'**
  String get dayFertileSuffix;

  /// No description provided for @fertilityWeekEmpty.
  ///
  /// In es, this message translates to:
  /// **'Ninguna mujer en ventana fértil esta semana.'**
  String get fertilityWeekEmpty;

  /// No description provided for @fertilityEstimated.
  ///
  /// In es, this message translates to:
  /// **'estimado'**
  String get fertilityEstimated;

  /// No description provided for @reportsTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get reportsTitle;

  /// No description provided for @reportsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los reportes.'**
  String get reportsLoadError;

  /// No description provided for @reportsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin perfiles. Crea uno para ver los reportes.'**
  String get reportsEmpty;

  /// No description provided for @reportsAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get reportsAll;

  /// No description provided for @reportsGlobal.
  ///
  /// In es, this message translates to:
  /// **'Global'**
  String get reportsGlobal;

  /// No description provided for @kpiProfiles.
  ///
  /// In es, this message translates to:
  /// **'Perfiles'**
  String get kpiProfiles;

  /// No description provided for @kpiCycles.
  ///
  /// In es, this message translates to:
  /// **'Ciclos registrados'**
  String get kpiCycles;

  /// No description provided for @kpiAvgCycle.
  ///
  /// In es, this message translates to:
  /// **'Duración media del ciclo'**
  String get kpiAvgCycle;

  /// No description provided for @kpiAvgMenstruation.
  ///
  /// In es, this message translates to:
  /// **'Duración media de la menstruación'**
  String get kpiAvgMenstruation;

  /// No description provided for @kpiEncounters.
  ///
  /// In es, this message translates to:
  /// **'Encuentros'**
  String get kpiEncounters;

  /// No description provided for @kpiUnprotected.
  ///
  /// In es, this message translates to:
  /// **'Sin protección'**
  String get kpiUnprotected;

  /// No description provided for @kpiFertileDays.
  ///
  /// In es, this message translates to:
  /// **'Días fértiles'**
  String get kpiFertileDays;

  /// No description provided for @kpiMostEncounters.
  ///
  /// In es, this message translates to:
  /// **'Más encuentros'**
  String get kpiMostEncounters;

  /// No description provided for @kpiNextPeriod.
  ///
  /// In es, this message translates to:
  /// **'Próximo periodo'**
  String get kpiNextPeriod;

  /// No description provided for @hintHistory.
  ///
  /// In es, this message translates to:
  /// **'histórico'**
  String get hintHistory;

  /// No description provided for @hintClosedPeriods.
  ///
  /// In es, this message translates to:
  /// **'periodos cerrados'**
  String get hintClosedPeriods;

  /// No description provided for @hintMonths12.
  ///
  /// In es, this message translates to:
  /// **'12 meses'**
  String get hintMonths12;

  /// No description provided for @hintFertile12.
  ///
  /// In es, this message translates to:
  /// **'12 meses, con proyecciones'**
  String get hintFertile12;

  /// No description provided for @hintProjected.
  ///
  /// In es, this message translates to:
  /// **'proyectado'**
  String get hintProjected;

  /// No description provided for @hintUnprotected.
  ///
  /// In es, this message translates to:
  /// **'«Ninguno»: {unprotected} de {total}'**
  String hintUnprotected(int unprotected, int total);

  /// No description provided for @reportsPerMonth.
  ///
  /// In es, this message translates to:
  /// **'Por mes'**
  String get reportsPerMonth;

  /// No description provided for @reportsEncountersByWoman.
  ///
  /// In es, this message translates to:
  /// **'Encuentros por mujer'**
  String get reportsEncountersByWoman;

  /// No description provided for @reportsProtection.
  ///
  /// In es, this message translates to:
  /// **'Protección'**
  String get reportsProtection;

  /// No description provided for @reportsCycleEvolution.
  ///
  /// In es, this message translates to:
  /// **'Evolución del ciclo'**
  String get reportsCycleEvolution;

  /// No description provided for @reportsRecurringSymptoms.
  ///
  /// In es, this message translates to:
  /// **'Síntomas recurrentes'**
  String get reportsRecurringSymptoms;

  /// No description provided for @reportsMonthDetail.
  ///
  /// In es, this message translates to:
  /// **'{month} · {encounters} encuentros · {unprotected} sin protección · {fertile} días fértiles · {periods} periodos'**
  String reportsMonthDetail(
    String month,
    int encounters,
    int unprotected,
    int fertile,
    int periods,
  );

  /// No description provided for @chartNeedTwoCycles.
  ///
  /// In es, this message translates to:
  /// **'Hacen falta al menos dos ciclos cerrados para dibujar la evolución.'**
  String get chartNeedTwoCycles;

  /// No description provided for @chartNoSymptoms.
  ///
  /// In es, this message translates to:
  /// **'Sin síntomas registrados en los últimos 12 meses.'**
  String get chartNoSymptoms;

  /// No description provided for @chartNoEncounters.
  ///
  /// In es, this message translates to:
  /// **'Sin encuentros registrados en los últimos 12 meses.'**
  String get chartNoEncounters;

  /// No description provided for @chartLegendEncounters.
  ///
  /// In es, this message translates to:
  /// **'Encuentros'**
  String get chartLegendEncounters;

  /// No description provided for @chartLegendUnprotected.
  ///
  /// In es, this message translates to:
  /// **'Sin protección'**
  String get chartLegendUnprotected;

  /// No description provided for @backupTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get backupTitle;

  /// No description provided for @backupSaved.
  ///
  /// In es, this message translates to:
  /// **'Copia guardada'**
  String get backupSaved;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Restaurar copia'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Reemplazar todos los datos actuales? Se borrarán los {actuales} perfiles actuales y todos sus registros. La copia contiene {entrantes}.'**
  String backupRestoreConfirm(int actuales, int entrantes);

  /// No description provided for @pdfDocumentTitle.
  ///
  /// In es, this message translates to:
  /// **'CicloTrack — copia de seguridad'**
  String get pdfDocumentTitle;

  /// No description provided for @pdfFooterPage.
  ///
  /// In es, this message translates to:
  /// **'Página {page} de {total}'**
  String pdfFooterPage(int page, int total);

  /// No description provided for @pdfGeneratedOn.
  ///
  /// In es, this message translates to:
  /// **'Informe generado el {date}'**
  String pdfGeneratedOn(String date);

  /// No description provided for @pdfSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get pdfSummary;

  /// No description provided for @pdfRegisteredPeriods.
  ///
  /// In es, this message translates to:
  /// **'Periodos registrados'**
  String get pdfRegisteredPeriods;

  /// No description provided for @pdfSymptoms12.
  ///
  /// In es, this message translates to:
  /// **'Síntomas (12 meses)'**
  String get pdfSymptoms12;

  /// No description provided for @pdfMedication.
  ///
  /// In es, this message translates to:
  /// **'Medicación'**
  String get pdfMedication;

  /// No description provided for @pdfEncounters.
  ///
  /// In es, this message translates to:
  /// **'Encuentros'**
  String get pdfEncounters;

  /// No description provided for @pdfColStart.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get pdfColStart;

  /// No description provided for @pdfColEnd.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get pdfColEnd;

  /// No description provided for @pdfColFlow.
  ///
  /// In es, this message translates to:
  /// **'Flujo'**
  String get pdfColFlow;

  /// No description provided for @pdfColNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get pdfColNotes;

  /// No description provided for @pdfColType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get pdfColType;

  /// No description provided for @pdfColFrequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get pdfColFrequency;

  /// No description provided for @pdfColWoman.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get pdfColWoman;

  /// No description provided for @pdfColMedication.
  ///
  /// In es, this message translates to:
  /// **'Medicamento'**
  String get pdfColMedication;

  /// No description provided for @pdfColDose.
  ///
  /// In es, this message translates to:
  /// **'Dosis'**
  String get pdfColDose;

  /// No description provided for @pdfColTime.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get pdfColTime;

  /// No description provided for @pdfColState.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get pdfColState;

  /// No description provided for @pdfColDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get pdfColDate;

  /// No description provided for @pdfColWomen.
  ///
  /// In es, this message translates to:
  /// **'Mujeres'**
  String get pdfColWomen;

  /// No description provided for @pdfColProtection.
  ///
  /// In es, this message translates to:
  /// **'Protección'**
  String get pdfColProtection;

  /// No description provided for @pdfColOutcome.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get pdfColOutcome;

  /// No description provided for @pdfShowsLast.
  ///
  /// In es, this message translates to:
  /// **'Se muestran los últimos {shown} de {total} encuentros.'**
  String pdfShowsLast(int shown, int total);

  /// No description provided for @pdfProfiles.
  ///
  /// In es, this message translates to:
  /// **'Perfiles: {count}'**
  String pdfProfiles(int count);

  /// No description provided for @pdfCycles.
  ///
  /// In es, this message translates to:
  /// **'Ciclos registrados: {count}'**
  String pdfCycles(int count);

  /// No description provided for @pdfAvgCycle.
  ///
  /// In es, this message translates to:
  /// **'Duración media del ciclo: {value}'**
  String pdfAvgCycle(String value);

  /// No description provided for @pdfAvgMenstruation.
  ///
  /// In es, this message translates to:
  /// **'Duración media de la menstruación: {value}'**
  String pdfAvgMenstruation(String value);

  /// No description provided for @pdfEncounters12.
  ///
  /// In es, this message translates to:
  /// **'Encuentros (12 meses): {count}'**
  String pdfEncounters12(int count);

  /// No description provided for @pdfUnprotected.
  ///
  /// In es, this message translates to:
  /// **'Sin protección: {percent} % ({unprotected} de {total})'**
  String pdfUnprotected(int percent, int unprotected, int total);

  /// No description provided for @pdfFertileDays12.
  ///
  /// In es, this message translates to:
  /// **'Días fértiles (12 meses, con proyecciones): {count}'**
  String pdfFertileDays12(int count);

  /// No description provided for @pdfMostEncounters.
  ///
  /// In es, this message translates to:
  /// **'Más encuentros: {name} ({count})'**
  String pdfMostEncounters(String name, int count);

  /// No description provided for @pdfNextPeriod.
  ///
  /// In es, this message translates to:
  /// **'Próximo periodo: {date}'**
  String pdfNextPeriod(String date);

  /// No description provided for @medicationTitle.
  ///
  /// In es, this message translates to:
  /// **'Medicación'**
  String get medicationTitle;

  /// No description provided for @medicationAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir medicamento'**
  String get medicationAdd;

  /// No description provided for @medicationProfilesError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los perfiles'**
  String get medicationProfilesError;

  /// No description provided for @medicationLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la medicación'**
  String get medicationLoadError;

  /// No description provided for @medicationEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar medicamento'**
  String get medicationEdit;

  /// No description provided for @medicationNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Medicamento'**
  String get medicationNameLabel;

  /// No description provided for @medicationWomanLabel.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get medicationWomanLabel;

  /// No description provided for @medicationEnabledLabel.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get medicationEnabledLabel;

  /// No description provided for @medicationEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay medicamentos registrados'**
  String get medicationEmpty;

  /// No description provided for @medicationDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar medicamento'**
  String get medicationDeleteTitle;

  /// No description provided for @medicationDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar {name}?'**
  String medicationDeleteBody(String name);

  /// No description provided for @medicationSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el medicamento'**
  String get medicationSaveError;

  /// No description provided for @medicationNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce el nombre del medicamento'**
  String get medicationNameRequired;

  /// No description provided for @medicationNameTooLong.
  ///
  /// In es, this message translates to:
  /// **'El nombre admite hasta 80 caracteres'**
  String get medicationNameTooLong;

  /// No description provided for @medicationDoseTooLong.
  ///
  /// In es, this message translates to:
  /// **'La dosis admite hasta 60 caracteres'**
  String get medicationDoseTooLong;

  /// No description provided for @medicationHourRange.
  ///
  /// In es, this message translates to:
  /// **'La hora debe estar entre 0 y 23'**
  String get medicationHourRange;

  /// No description provided for @medicationMinuteRange.
  ///
  /// In es, this message translates to:
  /// **'El minuto debe estar entre 0 y 59'**
  String get medicationMinuteRange;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get settingsAlerts;

  /// No description provided for @settingsBackup.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get settingsBackup;

  /// No description provided for @settingsViews.
  ///
  /// In es, this message translates to:
  /// **'Vistas'**
  String get settingsViews;

  /// No description provided for @settingsReports.
  ///
  /// In es, this message translates to:
  /// **'Informes'**
  String get settingsReports;

  /// No description provided for @settingsMedication.
  ///
  /// In es, this message translates to:
  /// **'Medicación'**
  String get settingsMedication;

  /// No description provided for @settingsAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String settingsVersion(String version);

  /// No description provided for @appLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Acceso bloqueado'**
  String get appLockedTitle;

  /// No description provided for @appLockedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea con tu PIN o huella para continuar.'**
  String get appLockedSubtitle;

  /// No description provided for @appUnlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get appUnlock;

  /// No description provided for @appLockAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea CicloTrack para continuar'**
  String get appLockAuthReason;

  /// No description provided for @appLockLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo comprobar si el bloqueo está activado. Desbloquea o reinténtalo.'**
  String get appLockLoadError;

  /// No description provided for @appLockRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get appLockRetry;

  /// No description provided for @remindersOf.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de {name}'**
  String remindersOf(String name);

  /// No description provided for @remindersLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los recordatorios'**
  String get remindersLoadError;

  /// No description provided for @remindersNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo recordatorio'**
  String get remindersNew;

  /// No description provided for @remindersEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin recordatorios'**
  String get remindersEmpty;

  /// No description provided for @remindersDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar recordatorio'**
  String get remindersDeleteTitle;

  /// No description provided for @remindersDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{message}\"?'**
  String remindersDeleteBody(String message);

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderChannelName.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios personalizados por día del ciclo'**
  String get reminderChannelDescription;

  /// No description provided for @reminderFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo recordatorio'**
  String get reminderFormTitle;

  /// No description provided for @reminderEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar recordatorio'**
  String get reminderEditTitle;

  /// No description provided for @reminderMessageLabel.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get reminderMessageLabel;

  /// No description provided for @reminderStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Día inicial del ciclo'**
  String get reminderStartLabel;

  /// No description provided for @reminderEndLabel.
  ///
  /// In es, this message translates to:
  /// **'Día final del ciclo (opcional)'**
  String get reminderEndLabel;

  /// No description provided for @reminderEnabledLabel.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get reminderEnabledLabel;

  /// No description provided for @reminderPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio guardado, pero sin permiso de notificaciones no recibirás el aviso'**
  String get reminderPermissionDenied;

  /// No description provided for @reminderSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el recordatorio'**
  String get reminderSaveError;

  /// No description provided for @reminderMessageRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje'**
  String get reminderMessageRequired;

  /// No description provided for @reminderMessageTooLong.
  ///
  /// In es, this message translates to:
  /// **'Máximo {max} caracteres'**
  String reminderMessageTooLong(int max);

  /// No description provided for @reminderStartRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce un día del ciclo'**
  String get reminderStartRequired;

  /// No description provided for @reminderStartTooSmall.
  ///
  /// In es, this message translates to:
  /// **'El día inicial debe ser 1 o mayor'**
  String get reminderStartTooSmall;

  /// No description provided for @reminderStartTooLarge.
  ///
  /// In es, this message translates to:
  /// **'El día inicial no puede superar {max}'**
  String reminderStartTooLarge(int max);

  /// No description provided for @reminderEndRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce un día del ciclo'**
  String get reminderEndRequired;

  /// No description provided for @reminderEndBeforeStart.
  ///
  /// In es, this message translates to:
  /// **'El día final no puede ser anterior al inicial'**
  String get reminderEndBeforeStart;

  /// No description provided for @reminderEndTooLarge.
  ///
  /// In es, this message translates to:
  /// **'El día final no puede superar {max}'**
  String reminderEndTooLarge(int max);

  /// No description provided for @reminderDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Día {day} del ciclo'**
  String reminderDayLabel(int day);

  /// No description provided for @reminderDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Días {start}-{end} del ciclo'**
  String reminderDaysLabel(int start, int end);

  /// No description provided for @reminderBodyRange.
  ///
  /// In es, this message translates to:
  /// **'{message} (días {start}-{end} del ciclo)'**
  String reminderBodyRange(String message, int start, int end);

  /// No description provided for @dayNoProfiles.
  ///
  /// In es, this message translates to:
  /// **'Sin perfiles.'**
  String get dayNoProfiles;

  /// No description provided for @saving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get saving;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get register;

  /// No description provided for @remindersTooltip.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios'**
  String get remindersTooltip;

  /// No description provided for @tagRelated.
  ///
  /// In es, this message translates to:
  /// **'Relacionada'**
  String get tagRelated;

  /// No description provided for @tagFriend.
  ///
  /// In es, this message translates to:
  /// **'Amiga'**
  String get tagFriend;

  /// No description provided for @tagEx.
  ///
  /// In es, this message translates to:
  /// **'Ex'**
  String get tagEx;

  /// No description provided for @tagCoworker.
  ///
  /// In es, this message translates to:
  /// **'Compañera'**
  String get tagCoworker;

  /// No description provided for @tagCasual.
  ///
  /// In es, this message translates to:
  /// **'Casual'**
  String get tagCasual;

  /// No description provided for @tagOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get tagOther;

  /// No description provided for @newTagTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva etiqueta'**
  String get newTagTitle;

  /// No description provided for @tagNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la etiqueta'**
  String get tagNameHint;

  /// No description provided for @medicationNoProfiles.
  ///
  /// In es, this message translates to:
  /// **'Crea un perfil para añadir medicación'**
  String get medicationNoProfiles;

  /// No description provided for @medicationWomanRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una mujer'**
  String get medicationWomanRequired;

  /// No description provided for @medicationDoseOptional.
  ///
  /// In es, this message translates to:
  /// **'Dosis (opcional)'**
  String get medicationDoseOptional;

  /// No description provided for @medicationTakeTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de la toma'**
  String get medicationTakeTime;

  /// No description provided for @reminderMessageHint.
  ///
  /// In es, this message translates to:
  /// **'Mejor evitar sexo estos días'**
  String get reminderMessageHint;

  /// No description provided for @reminderCycleNote.
  ///
  /// In es, this message translates to:
  /// **'El día 1 es el inicio del último periodo registrado. Recibirás un aviso por ciclo, el día inicial.'**
  String get reminderCycleNote;

  /// No description provided for @reminderCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear recordatorio'**
  String get reminderCreate;

  /// No description provided for @reminderDisabled.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get reminderDisabled;

  /// No description provided for @remindersEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea un aviso para unos días concretos del ciclo'**
  String get remindersEmptySubtitle;

  /// No description provided for @encounterNoProfiles.
  ///
  /// In es, this message translates to:
  /// **'No hay perfiles disponibles'**
  String get encounterNoProfiles;

  /// No description provided for @relationshipTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de relación'**
  String get relationshipTypeLabel;

  /// No description provided for @outcomeNoneOption.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get outcomeNoneOption;

  /// No description provided for @registerEncounter.
  ///
  /// In es, this message translates to:
  /// **'Registrar encuentro'**
  String get registerEncounter;

  /// No description provided for @registerPeriod.
  ///
  /// In es, this message translates to:
  /// **'Registrar periodo'**
  String get registerPeriod;

  /// No description provided for @registerOvulation.
  ///
  /// In es, this message translates to:
  /// **'Registrar ovulación'**
  String get registerOvulation;

  /// No description provided for @registerSymptom.
  ///
  /// In es, this message translates to:
  /// **'Registrar síntoma'**
  String get registerSymptom;

  /// No description provided for @dateStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get dateStartLabel;

  /// No description provided for @dateEndOptionalLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin (opcional)'**
  String get dateEndOptionalLabel;

  /// No description provided for @undefinedDate.
  ///
  /// In es, this message translates to:
  /// **'Sin definir'**
  String get undefinedDate;

  /// No description provided for @durationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get durationLabel;

  /// No description provided for @flowLevelLabel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de flujo'**
  String get flowLevelLabel;

  /// No description provided for @temperatureBasalLabel.
  ///
  /// In es, this message translates to:
  /// **'Temperatura basal (°C)'**
  String get temperatureBasalLabel;

  /// No description provided for @periodStartFuture.
  ///
  /// In es, this message translates to:
  /// **'La fecha de inicio no puede ser futura'**
  String get periodStartFuture;

  /// No description provided for @periodEndBeforeStart.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin no puede ser anterior al inicio'**
  String get periodEndBeforeStart;

  /// No description provided for @periodFlowRange.
  ///
  /// In es, this message translates to:
  /// **'Flujo debe estar entre 1 y 5'**
  String get periodFlowRange;

  /// No description provided for @dateFuture.
  ///
  /// In es, this message translates to:
  /// **'La fecha no puede ser futura'**
  String get dateFuture;

  /// No description provided for @temperatureInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce una temperatura válida entre 34 y 40 °C'**
  String get temperatureInvalid;

  /// No description provided for @symptomTypeInvalid.
  ///
  /// In es, this message translates to:
  /// **'Tipo de síntoma no válido'**
  String get symptomTypeInvalid;

  /// No description provided for @severityRange.
  ///
  /// In es, this message translates to:
  /// **'Intensidad debe estar entre 1 y 5'**
  String get severityRange;

  /// No description provided for @calendarWeekRange.
  ///
  /// In es, this message translates to:
  /// **'Semana del {from} al {to}'**
  String calendarWeekRange(String from, String to);

  /// No description provided for @fertilityWindowLabel.
  ///
  /// In es, this message translates to:
  /// **'Ventana: {from} – {to}'**
  String fertilityWindowLabel(String from, String to);

  /// No description provided for @ovulationDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Ovulación: {date}'**
  String ovulationDateLabel(String date);

  /// No description provided for @fertilityEstimatedF.
  ///
  /// In es, this message translates to:
  /// **'estimada'**
  String get fertilityEstimatedF;

  /// No description provided for @fertilityStartsTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Empieza mañana'**
  String get fertilityStartsTomorrow;

  /// No description provided for @fertilityStartsIn.
  ///
  /// In es, this message translates to:
  /// **'Empieza en {count, plural, one{1 día} other{{count} días}}'**
  String fertilityStartsIn(int count);

  /// No description provided for @fertilityLastDay.
  ///
  /// In es, this message translates to:
  /// **'Último día de ventana'**
  String get fertilityLastDay;

  /// No description provided for @fertilityInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso, termina en {count, plural, one{1 día} other{{count} días}}'**
  String fertilityInProgress(int count);

  /// No description provided for @encountersFilterAllCount.
  ///
  /// In es, this message translates to:
  /// **'Todas ({count})'**
  String encountersFilterAllCount(int count);

  /// No description provided for @encountersNone.
  ///
  /// In es, this message translates to:
  /// **'Sin encuentros registrados.'**
  String get encountersNone;

  /// No description provided for @encountersNoneFor.
  ///
  /// In es, this message translates to:
  /// **'Sin encuentros con {name}.'**
  String encountersNoneFor(String name);

  /// No description provided for @active.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get inactive;

  /// No description provided for @medicationSaveChangeError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el cambio'**
  String get medicationSaveChangeError;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsAppLockTitle.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo de acceso (PIN/huella)'**
  String get settingsAppLockTitle;

  /// No description provided for @settingsAppLockSupported.
  ///
  /// In es, this message translates to:
  /// **'Pide PIN o huella al abrir la app y tras 1 minuto en segundo plano. Controla el acceso; no cifra los datos.'**
  String get settingsAppLockSupported;

  /// No description provided for @settingsDiscreetNoticesTitle.
  ///
  /// In es, this message translates to:
  /// **'Avisos discretos'**
  String get settingsDiscreetNoticesTitle;

  /// No description provided for @settingsDiscreetNoticesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las notificaciones no muestran iniciales, fechas ni el texto de los recordatorios'**
  String get settingsDiscreetNoticesSubtitle;

  /// No description provided for @discreetNoticeBody.
  ///
  /// In es, this message translates to:
  /// **'Tienes un aviso nuevo. Abre la app para verlo.'**
  String get discreetNoticeBody;

  /// No description provided for @settingsAppLockUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible en este dispositivo'**
  String get settingsAppLockUnavailable;

  /// No description provided for @settingsAppLockSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el bloqueo de acceso. Inténtalo de nuevo.'**
  String get settingsAppLockSaveError;

  /// No description provided for @settingsAppLockAuthRequired.
  ///
  /// In es, this message translates to:
  /// **'El bloqueo sigue activado: hay que desbloquear con PIN o huella para desactivarlo.'**
  String get settingsAppLockAuthRequired;

  /// No description provided for @settingsLocalTitle.
  ///
  /// In es, this message translates to:
  /// **'100 % local y sin nube'**
  String get settingsLocalTitle;

  /// No description provided for @settingsLocalSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Todos los datos se guardan solo en este dispositivo: no hay cuentas, sincronización ni servidores.'**
  String get settingsLocalSubtitle;

  /// No description provided for @settingsMedicationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Pastillas y horas de aviso, por mujer'**
  String get settingsMedicationSubtitle;

  /// No description provided for @settingsAlertsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Avisos locales y hora de notificación'**
  String get settingsAlertsSubtitle;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Exportar y restaurar los datos'**
  String get settingsBackupSubtitle;

  /// No description provided for @settingsReportsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas y gráficos'**
  String get settingsReportsSubtitle;

  /// No description provided for @settingsViewsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Calendario, fertilidad y encuentros'**
  String get settingsViewsSubtitle;

  /// No description provided for @backupSectionExport.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get backupSectionExport;

  /// No description provided for @backupSectionImport.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get backupSectionImport;

  /// No description provided for @backupExportJsonTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia completa (JSON)'**
  String get backupExportJsonTitle;

  /// No description provided for @backupExportJsonSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Todos los datos en un archivo JSON'**
  String get backupExportJsonSubtitle;

  /// No description provided for @backupExportCsvTitle.
  ///
  /// In es, this message translates to:
  /// **'Tablas (CSV)'**
  String get backupExportCsvTitle;

  /// No description provided for @backupExportCsvSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Un CSV por tabla, comprimidos en un ZIP'**
  String get backupExportCsvSubtitle;

  /// No description provided for @backupExportPdfTitle.
  ///
  /// In es, this message translates to:
  /// **'Informe (PDF)'**
  String get backupExportPdfTitle;

  /// No description provided for @backupExportPdfSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen imprimible de perfiles, ciclos y encuentros'**
  String get backupExportPdfSubtitle;

  /// No description provided for @backupImportJsonTitle.
  ///
  /// In es, this message translates to:
  /// **'Restaurar desde JSON'**
  String get backupImportJsonTitle;

  /// No description provided for @backupImportJsonSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reemplaza todos los datos actuales'**
  String get backupImportJsonSubtitle;

  /// No description provided for @backupNotReady.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar: los datos aún se están cargando'**
  String get backupNotReady;

  /// No description provided for @backupCancelled.
  ///
  /// In es, this message translates to:
  /// **'Exportación cancelada'**
  String get backupCancelled;

  /// No description provided for @backupImportCancelled.
  ///
  /// In es, this message translates to:
  /// **'Importación cancelada'**
  String get backupImportCancelled;

  /// No description provided for @backupRestoreAction.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get backupRestoreAction;

  /// No description provided for @backupUnencryptedTitle.
  ///
  /// In es, this message translates to:
  /// **'Archivo sin cifrar'**
  String get backupUnencryptedTitle;

  /// No description provided for @backupUnencryptedWarning.
  ///
  /// In es, this message translates to:
  /// **'El archivo se guardará sin cifrar: cualquiera que lo abra podrá leer todos los datos. El bloqueo de acceso de la app no lo protege. Guárdalo en un lugar seguro.'**
  String get backupUnencryptedWarning;

  /// No description provided for @backupUnencryptedAction.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get backupUnencryptedAction;

  /// No description provided for @backupSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar: {reason}'**
  String backupSaveFailed(String reason);

  /// No description provided for @backupImportFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo importar: {reason}'**
  String backupImportFailed(String reason);

  /// No description provided for @backupRestoredSummary.
  ///
  /// In es, this message translates to:
  /// **'Copia restaurada: {profiles} perfiles, {periods} periodos, {encounters} encuentros'**
  String backupRestoredSummary(int profiles, int periods, int encounters);

  /// No description provided for @pdfProfileFallback.
  ///
  /// In es, this message translates to:
  /// **'Perfil {id}'**
  String pdfProfileFallback(int id);

  /// No description provided for @backupInvalidJson.
  ///
  /// In es, this message translates to:
  /// **'El archivo no es un JSON válido'**
  String get backupInvalidJson;

  /// No description provided for @backupNotCicloTrack.
  ///
  /// In es, this message translates to:
  /// **'El archivo no es una copia de CicloTrack'**
  String get backupNotCicloTrack;

  /// No description provided for @backupUnsupportedVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión de copia no soportada (v{version})'**
  String backupUnsupportedVersion(String version);

  /// No description provided for @backupInvalidExportDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de exportación inválida'**
  String get backupInvalidExportDate;

  /// No description provided for @backupNoTables.
  ///
  /// In es, this message translates to:
  /// **'El archivo no contiene tablas'**
  String get backupNoTables;

  /// No description provided for @backupMissingTable.
  ///
  /// In es, this message translates to:
  /// **'Falta la tabla {table}'**
  String backupMissingTable(String table);

  /// No description provided for @backupInvalidRow.
  ///
  /// In es, this message translates to:
  /// **'Fila inválida en {table}'**
  String backupInvalidRow(String table);

  /// No description provided for @backupInvalidValue.
  ///
  /// In es, this message translates to:
  /// **'Valor inválido en {column}'**
  String backupInvalidValue(String column);

  /// No description provided for @backupPeriodOverlap.
  ///
  /// In es, this message translates to:
  /// **'La copia contiene periodos solapados'**
  String get backupPeriodOverlap;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
