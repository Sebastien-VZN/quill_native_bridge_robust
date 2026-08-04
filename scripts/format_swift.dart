import 'dart:io';

import 'package:flutter/foundation.dart';

void main(List<String> args) {
  const swiftPackages = [
    'quill_native_bridge_ios/ios/quill_native_bridge_ios',
    'quill_native_bridge_macos/macos/quill_native_bridge_macos',
  ];
  for (final swiftPackageDirectory in swiftPackages) {
    final result = Process.runSync('swift-format', [
      'format',
      '--recursive',
      '-i',
      swiftPackageDirectory,
    ]);
    debugPrint(result.stdout.toString());
  }
}
