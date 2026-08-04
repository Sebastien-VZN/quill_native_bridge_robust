import 'dart:io';
import 'package:flutter/foundation.dart';

void main(List<String> args) {
  final result = Process.runSync('ktlint', ['--format']);
  debugPrint(result.stdout.toString());
}
