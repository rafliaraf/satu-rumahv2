// ponytail: minimal wrapper over file_picker package for native Android file selection
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FilePickerUtil {
  /// Membuka pemilih berkas bawaan Android (Document Picker / Files app) untuk memilih 1 file.
  static Future<PlatformFile?> pickSingleFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: (allowedExtensions != null && allowedExtensions.isNotEmpty)
            ? FileType.custom
            : type,
        allowedExtensions: allowedExtensions,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
    } catch (e) {
      debugPrint('Error picking single file: $e');
    }
    return null;
  }

  /// Membuka pemilih berkas bawaan Android untuk memilih beberapa file sekaligus (batch upload).
  static Future<List<PlatformFile>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: (allowedExtensions != null && allowedExtensions.isNotEmpty)
            ? FileType.custom
            : type,
        allowedExtensions: allowedExtensions,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files;
      }
    } catch (e) {
      debugPrint('Error picking multiple files: $e');
    }
    return [];
  }
}
