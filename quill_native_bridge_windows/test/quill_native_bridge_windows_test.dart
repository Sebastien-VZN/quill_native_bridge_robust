import 'package:flutter_test/flutter_test.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';
import 'package:quill_native_bridge_windows/quill_native_bridge_windows.dart';

/// Regression guards for the Windows platform implementation.
///
/// These tests do not exercise the real Win32 clipboard (that is the job of
/// the integration tests in `example/integration_test/`). They guard against
/// two regressions that previously disabled every clipboard feature on
/// Windows:
///
/// 1. `registerWith()` must never throw — if it does, the generated
///    `dart_plugin_registrant.dart` swallows the error and
///    `QuillNativeBridgePlatform.instance` stays on `PlaceholderImplementation`,
///    which reports every feature as unsupported.
/// 2. `isSupported()` must return `true` for the six clipboard features when
///    the FFI bindings load successfully. A `false` here means
///    `_ensureInitialized()` silently failed (e.g. a symbol looked up in the
///    wrong DLL, as happened with `GetLastError` being resolved from
///    `user32.dll` instead of `kernel32.dll`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('registerWith', () {
    test('does not throw and installs the Windows implementation', () {
      expect(QuillNativeBridgeWindows.registerWith, returnsNormally);
      expect(QuillNativeBridgePlatform.instance, isA<QuillNativeBridgeWindows>());
    });
  });

  group('isSupported', () {
    final plugin = QuillNativeBridgeWindows();

    final clipboardFeatures = {
      QuillNativeBridgeFeature.getClipboardHtml,
      QuillNativeBridgeFeature.copyHtmlToClipboard,
      QuillNativeBridgeFeature.getClipboardText,
      QuillNativeBridgeFeature.copyTextToClipboard,
      QuillNativeBridgeFeature.getClipboardMarkdown,
      QuillNativeBridgeFeature.copyMarkdownToClipboard,
    };

    for (final feature in clipboardFeatures) {
      test('$feature is supported on Windows', () async {
        final result = await plugin.isSupported(feature);
        expect(
          result,
          isTrue,
          reason:
              '$feature should be supported on Windows. A `false` result means '
              '_ensureInitialized() failed — check that every FFI symbol is '
              'looked up from the correct DLL (e.g. GetLastError is in '
              'kernel32.dll, not user32.dll).',
        );
      });
    }

    test('isIOSSimulator is not supported on Windows', () async {
      final result = await plugin.isSupported(QuillNativeBridgeFeature.isIOSSimulator);
      expect(result, isFalse);
    });

    test('isAppleSafari is not supported on Windows', () async {
      final result = await plugin.isSupported(QuillNativeBridgeFeature.isAppleSafari);
      expect(result, isFalse);
    });
  });

  group('clipboard methods are safe when FFI init fails', () {
    test('getClipboardHtml returns null instead of throwing', () async {
      final plugin = QuillNativeBridgeWindows();
      // On Windows the init should succeed, so this mainly asserts the method
      // returns a nullable String and never throws synchronously.
      expect(await plugin.getClipboardHtml(), isA<String?>());
    });

    test('getClipboardText returns null instead of throwing', () async {
      final plugin = QuillNativeBridgeWindows();
      expect(await plugin.getClipboardText(), isA<String?>());
    });

    test('getClipboardMarkdown returns null instead of throwing', () async {
      final plugin = QuillNativeBridgeWindows();
      expect(await plugin.getClipboardMarkdown(), isA<String?>());
    });
  });
}
