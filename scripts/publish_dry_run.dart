import 'dart:io';
import 'package:flutter/foundation.dart';
import 'packages.dart';

void main(List<String> args) {
  for (final package in packages) {
    final result = Process.runSync('flutter', ['pub', 'publish', '--dry-run'], workingDirectory: package);
    debugPrint(result.stdout.toString());
  }
}
