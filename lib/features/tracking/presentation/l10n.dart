import 'package:ciclotrack/l10n/app_localizations.dart';

import '../domain/tracking_event.dart';

/// Etiqueta localizada de un tipo de síntoma persistido.
String localizedSymptomType(AppLocalizations l10n, String type) {
  switch (type) {
    case 'Acné':
      return l10n.symptomAcne;
    case 'Dolor de pecho':
      return l10n.symptomBreastPain;
    case 'Cansancio':
      return l10n.symptomFatigue;
    case 'Humor':
      return l10n.symptomMood;
    case 'Antojos':
      return l10n.symptomCravings;
    case 'Dolor abdominal':
      return l10n.symptomAbdominalPain;
    default:
      // Valor desconocido persistido: se muestra tal cual (no es un tipo conocido).
      return type;
  }
}

/// Icono de un tipo de síntoma persistido.
String symptomIcon(String type) {
  switch (type) {
    case 'Acné':
      return '🔴';
    case 'Dolor de pecho':
      return '💔';
    case 'Cansancio':
      return '😴';
    case 'Humor':
      return '😤';
    case 'Antojos':
      return '🍫';
    case 'Dolor abdominal':
      return '🤕';
    default:
      return '📋';
  }
}

/// Etiqueta localizada de un valor de moco cervical persistido.
String localizedCervicalMucus(AppLocalizations l10n, String? value) {
  switch (value) {
    case 'Seco':
      return l10n.mucusDry;
    case 'Pegajoso':
      return l10n.mucusSticky;
    case 'Cremoso':
      return l10n.mucusCreamy;
    case 'Acuoso':
      return l10n.mucusWatery;
    case 'Elástico':
      return l10n.mucusStretchy;
    case 'Clara de huevo':
      return l10n.mucusEggWhite;
    default:
      return value ?? '';
  }
}

/// Icono de un evento de la timeline.
String trackingEventIcon(TrackingEvent event) {
  switch (event.type) {
    case TrackingEventType.period:
      return '🩸';
    case TrackingEventType.ovulation:
      return '🥚';
    case TrackingEventType.symptom:
      return symptomIcon(event.symptomType ?? '');
  }
}

/// Título localizado de un evento de la timeline.
String trackingEventTitle(AppLocalizations l10n, TrackingEvent event) {
  switch (event.type) {
    case TrackingEventType.period:
      return l10n.trackingPeriod;
    case TrackingEventType.ovulation:
      return l10n.trackingOvulation;
    case TrackingEventType.symptom:
      return localizedSymptomType(l10n, event.symptomType ?? '');
  }
}

/// Subtítulo localizado de un evento de la timeline.
String trackingEventSubtitle(AppLocalizations l10n, TrackingEvent event) {
  switch (event.type) {
    case TrackingEventType.period:
      final parts = <String>[];
      if (event.endDate != null) {
        final days = event.endDate!.difference(event.date).inDays + 1;
        parts.add(l10n.daysCount(days));
      }
      if (event.flowLevel != null) {
        parts.add(l10n.flowLevel(event.flowLevel!));
      }
      return parts.join(' · ');
    case TrackingEventType.ovulation:
      final parts = <String>[];
      if (event.temperature != null) {
        parts.add('${event.temperature!.toStringAsFixed(1)}°C');
      }
      final mucus = localizedCervicalMucus(l10n, event.cervicalMucus);
      if (mucus.isNotEmpty) parts.add(mucus);
      if (event.lhTest == true) parts.add('LH +');
      return parts.join(' · ');
    case TrackingEventType.symptom:
      return l10n.intensityLevel(event.severity ?? 1);
  }
}
