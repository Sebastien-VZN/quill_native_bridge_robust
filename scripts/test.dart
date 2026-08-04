import 'dart:io';

import 'packages.dart';

void main(List<String> args) {
  var hasFailure = false;

  for (final package in packages) {
    stdout.writeln('\n━━━ Tests: $package ━━━');

    final result = Process.runSync('flutter', ['test'], workingDirectory: package, runInShell: true);

    stdout.write(result.stdout);
    stderr.write(result.stderr);

    if (result.exitCode != 0) {
      stderr.writeln('❌ ÉCHEC: $package (exit code ${result.exitCode})');
      hasFailure = true;
    } else {
      stdout.writeln('✅ OK: $package');
    }
  }

  if (hasFailure) {
    stderr.writeln('\n❌ Au moins un package a des tests en échec.');
    exit(1);
  }

  stdout.writeln('\n✅ Tous les tests sont passés.');
}
