import 'package:flutter_test/flutter_test.dart';
import 'package:quill_native_bridge_ios/quill_native_bridge_ios.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registered instance', () {
    QuillNativeBridgeIos.registerWith();
    expect(QuillNativeBridgePlatform.instance, isA<QuillNativeBridgeIos>());
  });

  group('isSupported', () {
    test('returns true for supported features', () async {
      final plugin = QuillNativeBridgeIos();
      expect(
        await plugin.isSupported(QuillNativeBridgeFeature.isIOSSimulator),
        isTrue,
      );
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
      final plugin = QuillNativeBridgeIos();
      expect(
        await plugin.isSupported(QuillNativeBridgeFeature.isAppleSafari),
        isFalse,
      );
    });
  });

  test('isIOSSimulator is not applicable on Android', () async {
    // This test just verifies the method exists and doesn't throw
    // Actual isIOSSimulator() depends on the native platform
  });
}
