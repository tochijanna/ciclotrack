import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Fichero listo para guardar o recién leído.
class BackupFile {
  const BackupFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Escritura y lectura de ficheros del usuario (SAF en Android).
///
/// Es un *seam* para que los tests de widget no toquen el sistema de ficheros,
/// igual que `NotificationScheduler` en la feature `alerts`.
abstract class BackupFileGateway {
  /// Devuelve la URI elegida, o `null` si el usuario cancela.
  Future<Uri?> save({
    required String fileName,
    required Uint8List bytes,
    required List<String> extensions,
  });

  /// Devuelve el contenido elegido, o `null` si el usuario cancela.
  Future<Uint8List?> pick({required List<String> extensions});
}

/// Implementación real sobre el selector del sistema: nunca se manejan rutas
/// en disco, los bytes viajan en memoria en ambos sentidos.
class LocalBackupFileGateway implements BackupFileGateway {
  const LocalBackupFileGateway();

  @override
  Future<Uri?> save({
    required String fileName,
    required Uint8List bytes,
    required List<String> extensions,
  }) {
    return FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: extensions,
    );
  }

  @override
  Future<Uint8List?> pick({required List<String> extensions}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if (result.isEmpty) return null;
    return result.single.readAsBytes();
  }
}
