import 'package:flutter_test/flutter_test.dart';
import 'package:quill_native_bridge_macos/quill_native_bridge_macos.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registered instance', () {
    QuillNativeBridgeMacOS.registerWith();
    expect(QuillNativeBridgePlatform.instance, isA<QuillNativeBridgeMacOS>());
  });

  test('isIOSSimulator is not applicable on macOS', () async {
    final plugin = QuillNativeBridgeMacOS();
    expect(() async => plugin.isIOSSimulator(), throwsUnsupportedError);
  });

  group('isSupported', () {
    test('returns true for supported features', () async {
      final plugin = QuillNativeBridgeMacOS();
      expect(
        await plugin.isSupported(QuillNativeBridgeFeature.getClipboardHtml),
        isTrue,
      );
      expect(
        await plugin.isSupported(QuillNativeBridgeFeature.copyHtmlToClipboard),
        isTrue,
      );
      expect(
        await plugin.isSupported(QuillNativeBridgeFeature.getClipboardText),
        isTrue,
      );
      expect(
        await plugin.isSupported(QuillNativeBridgeFeature.copyTextToClipboard),
        isTrue,
      );
    });

    test('returns false for unsupported features', () async {
      final plugin = QuillNativeBridgeMacOS();
      expect(
        await plugin.isSupported(QuillNativeBridgeFeature.isIOSSimulator),
        isFalse,
      );
      expect(
        await plugin.isSupported(QuillNativeBridgeFeature.isAppleSafari),
        isFalse,
      );
    });
  });

  test('isAppleSafari returns false', () {
    final plugin = QuillNativeBridgeMacOS();
    expect(plugin.isAppleSafari(), isFalse);
  });
}
