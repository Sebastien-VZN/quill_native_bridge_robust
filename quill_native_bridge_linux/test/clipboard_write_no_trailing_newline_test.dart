import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for the trailing-newline bug.
///
/// `process.stdin.writeln(content)` appends a '\n' to the clipboard payload,
/// silently corrupting the copied data (e.g. "Hello" became "Hello\n").
/// The fix uses `process.stdin.write(content)` instead. This test scans the
/// Linux implementation source and fails if `writeln` is reintroduced on the
/// stdin of an xclip process, which would re-introduce the bug.
void main() {
  test(
    'clipboard write methods must not append a trailing newline (no stdin.writeln)',
    () {
      const sourcePath = 'lib/quill_native_bridge_linux.dart';
      final sourceFile = File(sourcePath);
      expect(
        sourceFile.existsSync(),
        isTrue,
        reason:
            'Source file not found: $sourcePath (run tests from package root)',
      );

      final source = sourceFile.readAsStringSync();

      // Any `stdin.writeln(` on the xclip process stdin re-introduces the bug.
      expect(
        source.contains('stdin.writeln'),
        isFalse,
        reason:
            '`stdin.writeln` was found in $sourcePath. '
            'It appends a trailing newline to the clipboard payload, corrupting '
            'the copied data. Use `stdin.write` instead.',
      );

      // Sanity check: the write methods must actually use stdin.write.
      expect(
        source.contains('stdin.write('),
        isTrue,
        reason:
            '`stdin.write(` not found in $sourcePath — expected for clipboard write methods.',
      );
    },
  );
}
