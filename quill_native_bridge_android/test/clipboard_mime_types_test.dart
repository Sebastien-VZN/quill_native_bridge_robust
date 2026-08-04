import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guards for the Android clipboard Kotlin implementation.
///
/// These tests scan the Kotlin source of `ClipboardRichTextHandler` to catch
/// regressions that would not be detected by the existing (lifecycle-only)
/// Kotlin tests:
///
/// 1. `copyMarkdownToClipboard` must advertise both `text/markdown` AND
///    `text/plain` in its ClipDescription. A mono-MIME `text/markdown` clip is
///    invisible to most Android apps (which only look at `text/plain`), so the
///    copied Markdown could not be pasted anywhere.
/// 2. `copyHtmlToClipboard` must NOT pass the raw HTML as the plain-text
///    fallback of `ClipData.newHtmlText`. Doing so surfaces the HTML tags to
///    plain-text consumers (e.g. `<strong>Bold</strong>` instead of `Bold`).
void main() {
  const sourcePath =
      'android/src/main/kotlin/dev/flutterquill/quill_native_bridge/clipboard/ClipboardRichTextHandler.kt';

  late String source;

  setUp(() {
    final file = File(sourcePath);
    expect(
      file.existsSync(),
      isTrue,
      reason:
          'Kotlin source not found: $sourcePath (run tests from package root)',
    );
    source = file.readAsStringSync();
  });

  /// Extracts the body of a top-level `fun` declaration, from its signature up
  /// to the start of the next top-level `fun`/`private`/`object`/class marker
  /// or end of file.
  String funBody(String source, String funName) {
    final marker = 'fun $funName';
    final start = source.indexOf(marker);
    expect(start, greaterThanOrEqualTo(0), reason: '`$marker` not found');
    // Next top-level declaration after this function.
    final nextFun = source.indexOf(
      RegExp(r'\n(fun|private fun|object |class )'),
      start + marker.length,
    );
    final end = nextFun == -1 ? source.length : nextFun;
    return source.substring(start, end);
  }

  test(
    'copyMarkdownToClipboard advertises text/plain alongside text/markdown',
    () {
      final body = funBody(source, 'copyMarkdownToClipboard');

      // The Markdown MIME type is referenced via the MIME_TYPE_MARKDOWN constant
      // (defined elsewhere in the file), and text/plain is inlined.
      expect(body, contains('MIME_TYPE_MARKDOWN'));
      expect(
        body,
        contains('"text/plain"'),
        reason:
            'copyMarkdownToClipboard must advertise text/plain in addition to '
            'text/markdown, otherwise most Android apps cannot paste the copied '
            'Markdown.',
      );
    },
  );

  test(
    'copyHtmlToClipboard does not pass the raw HTML as the plain-text fallback',
    () {
      final body = funBody(source, 'copyHtmlToClipboard');

      // ClipData.newHtmlText(label, plainText, html). The 2nd arg is plain text.
      // Reject the regression where the same `html` variable is passed twice,
      // which would leak raw HTML tags to plain-text paste targets.
      expect(
        body.contains('newHtmlText("HTML", html, html)'),
        isFalse,
        reason:
            'copyHtmlToClipboard must not pass the raw HTML as plain-text fallback '
            '(would surface "<strong>...</strong>" to plain-text consumers). Pass '
            'an empty string or a stripped plain-text version instead.',
      );
    },
  );
}
