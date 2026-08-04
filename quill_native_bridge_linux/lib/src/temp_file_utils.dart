import 'dart:io' show Directory;

import 'package:quill_native_bridge_linux/src/constants.dart';

/// Create a path in the system's temporary directory for a given file name.
///
/// - [fileName] The name of the file to be stored.
///
/// Returns: The path where the file will be located.
String generateTempFilePath(String fileName) =>
    '${Directory.systemTemp.path}/$kPackageName/$fileName';
