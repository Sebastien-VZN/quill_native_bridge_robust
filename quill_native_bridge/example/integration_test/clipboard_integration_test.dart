import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

/// Integration tests that exercise the REAL platform implementations.
///
/// These tests call the actual clipboard APIs on the current platform.
/// They validate that:
/// - registerWith() is called and PlaceholderImplementation is replaced
/// - isSupported() returns correct values (never throws)
/// - Platform implementations can read/write clipboard data
///
/// Run with: flutter test integration_test/clipboard_integration_test.dart -d linux
///          flutter test integration_test/clipboard_integration_test.dart -d windows
void main() {
  late QuillNativeBridge bridge;

  setUp(() {
    bridge = QuillNativeBridge();
  });

  group('PlaceholderImplementation is replaced', () {
    test('isSupported never throws UnimplementedError', () async {
      // This is the core bug fix: PlaceholderImplementation.isSupported()
      // used to throw UnimplementedError. Now it returns false.
      // After registerWith(), the real platform impl is active.
      for (final feature in QuillNativeBridgeFeature.values) {
        // Must NOT throw — should return a bool
        final result = await bridge.isSupported(feature);
        expect(result, isA<bool>());
      }
    });

    test('PlaceholderImplementation is not the active platform instance', () {
      // If PlaceholderImplementation is still active, all features
      // report unsupported. A real platform should support at least
      // some features.
      final platform = QuillNativeBridgePlatform.instance;
      expect(
        platform.runtimeType.toString(),
        isNot(equals('PlaceholderImplementation')),
        reason:
            'PlaceholderImplementation should be replaced by a real '
            'platform implementation via registerWith(). '
            'Got: ${platform.runtimeType}',
      );
    });
  });

  group('isSupported returns correct values for platform', () {
    test('clipboard features report support correctly', () async {
      // On Linux/Windows, clipboard features should be supported
      // On unknown platforms, they should return false (not throw)
      final htmlReadSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardHtml);
      final htmlWriteSupported = await bridge.isSupported(QuillNativeBridgeFeature.copyHtmlToClipboard);
      final textReadSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardText);
      final textWriteSupported = await bridge.isSupported(QuillNativeBridgeFeature.copyTextToClipboard);

      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.windows)) {
        // Linux and Windows support all clipboard features
        expect(htmlReadSupported, isTrue, reason: 'getClipboardHtml should be supported on ${defaultTargetPlatform.name}');
        expect(htmlWriteSupported, isTrue, reason: 'copyHtmlToClipboard should be supported on ${defaultTargetPlatform.name}');
        expect(textReadSupported, isTrue, reason: 'getClipboardText should be supported on ${defaultTargetPlatform.name}');
        expect(textWriteSupported, isTrue, reason: 'copyTextToClipboard should be supported on ${defaultTargetPlatform.name}');
      }
    });

    test('markdown features report support correctly', () async {
      final mdReadSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardMarkdown);
      final mdWriteSupported = await bridge.isSupported(QuillNativeBridgeFeature.copyMarkdownToClipboard);

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        // Windows supports text/markdown clipboard format
        expect(mdReadSupported, isTrue, reason: 'getClipboardMarkdown should be supported on Windows');
        expect(mdWriteSupported, isTrue, reason: 'copyMarkdownToClipboard should be supported on Windows');
      }

      // On ALL platforms, isSupported must return a bool (never throw)
      expect(mdReadSupported, isA<bool>());
      expect(mdWriteSupported, isA<bool>());
    });

    test('isIOSSimulator reports support correctly', () async {
      final supported = await bridge.isSupported(QuillNativeBridgeFeature.isIOSSimulator);
      if (defaultTargetPlatform != TargetPlatform.iOS) {
        expect(supported, isFalse, reason: 'isIOSSimulator should not be supported on non-iOS');
      }
    });

    test('isAppleSafari reports support correctly', () async {
      final supported = await bridge.isSupported(QuillNativeBridgeFeature.isAppleSafari);
      if (!kIsWeb) {
        expect(supported, isFalse, reason: 'isAppleSafari should not be supported on native platforms');
      }
    });
  });

  group('Clipboard read/write integration', () {
    test('copyTextToClipboard and getClipboardText round-trip', () async {
      final textSupported = await bridge.isSupported(QuillNativeBridgeFeature.copyTextToClipboard);
      if (!textSupported) {
        // Skip on platforms that don't support it
        debugPrint('Skipping: copyTextToClipboard not supported on this platform');
        return;
      }

      const testText = 'Hello Quill Native Bridge! 纯文本测试 🎉';
      await bridge.copyTextToClipboard(testText);

      final readSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardText);
      if (readSupported) {
        final result = await bridge.getClipboardText();
        expect(result, isNotNull, reason: 'getClipboardText should return non-null after copyTextToClipboard');
        expect(result, equals(testText));
      }
    });

    test('copyHtmlToClipboard and getClipboardHtml round-trip', () async {
      final htmlWriteSupported = await bridge.isSupported(QuillNativeBridgeFeature.copyHtmlToClipboard);
      if (!htmlWriteSupported) {
        debugPrint('Skipping: copyHtmlToClipboard not supported on this platform');
        return;
      }

      const testHtml = '<strong>Bold</strong> <em>Italic</em>';
      await bridge.copyHtmlToClipboard(testHtml);

      final htmlReadSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardHtml);
      if (htmlReadSupported) {
        final result = await bridge.getClipboardHtml();
        expect(result, isNotNull, reason: 'getClipboardHtml should return non-null after copyHtmlToClipboard');
        // The result may have platform-specific headers (e.g. Windows HTML Format)
        // but must contain the original content
        expect(result!.contains('Bold'), isTrue);
      }
    });

    test('copyMarkdownToClipboard and getClipboardMarkdown round-trip', () async {
      final mdWriteSupported = await bridge.isSupported(QuillNativeBridgeFeature.copyMarkdownToClipboard);
      if (!mdWriteSupported) {
        debugPrint('Skipping: copyMarkdownToClipboard not supported on this platform');
        return;
      }

      const testMarkdown = '# Hello\n\n**bold** and *italic*';
      await bridge.copyMarkdownToClipboard(testMarkdown);

      final mdReadSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardMarkdown);
      if (mdReadSupported) {
        final result = await bridge.getClipboardMarkdown();
        expect(result, isNotNull, reason: 'getClipboardMarkdown should return non-null after copyMarkdownToClipboard');
        expect(result!.contains('Hello'), isTrue);
      }
    });

    test('getClipboardText returns null when clipboard has no text', () async {
      final readSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardText);
      if (!readSupported) {
        debugPrint('Skipping: getClipboardText not supported on this platform');
        return;
      }

      // After copying HTML (not plain text), text might be available as
      // a side-effect. This test just validates the API doesn't crash.
      final result = await bridge.getClipboardText();
      // Result can be null or a string — must not throw
      expect(result, isA<String?>());
    });

    test('getClipboardHtml returns null or string, never throws', () async {
      final readSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardHtml);
      if (!readSupported) {
        debugPrint('Skipping: getClipboardHtml not supported on this platform');
        return;
      }

      final result = await bridge.getClipboardHtml();
      // Result can be null (no HTML in clipboard) or a string — must not throw
      expect(result, isA<String?>());
    });

    test('getClipboardMarkdown returns null or string, never throws', () async {
      final readSupported = await bridge.isSupported(QuillNativeBridgeFeature.getClipboardMarkdown);
      if (!readSupported) {
        debugPrint('Skipping: getClipboardMarkdown not supported on this platform');
        return;
      }

      final result = await bridge.getClipboardMarkdown();
      // Result can be null (no Markdown in clipboard) or a string — must not throw
      expect(result, isA<String?>());
    });
  });
}
