import 'package:shared_preferences/shared_preferences.dart';

/// Clave en `SharedPreferences` que guarda si los avisos son discretos.
const discreetNoticesPrefKey = 'discreet_notices';

/// Título de un aviso discreto: solo el nombre de la app.
const discreetNoticeTitle = 'CicloTrack';

/// Si las notificaciones deben mostrar un texto genérico (PRIV-04). Privado
/// por defecto: sin preferencia guardada o legible, el aviso es discreto.
Future<bool> readDiscreetNotices() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(discreetNoticesPrefKey) ?? true;
  } catch (_) {
    return true;
  }
}
