// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'package:is_ios_simulator/is_ios_simulator.dart';
import 'package:quill_native_bridge_ios/src/messages.g.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

/// An implementation of [QuillNativeBridgePlatform] for iOS.
class QuillNativeBridgeIos extends QuillNativeBridgePlatform {
  final QuillNativeBridgeApi _hostApi = QuillNativeBridgeApi();

  /// Registers this class as the default instance of [QuillNativeBridgePlatform].
  static void registerWith() {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeIos();
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async => {
    QuillNativeBridgeFeature.isIOSSimulator,
    QuillNativeBridgeFeature.getClipboardHtml,
    QuillNativeBridgeFeature.copyHtmlToClipboard,
    QuillNativeBridgeFeature.getClipboardText,
    QuillNativeBridgeFeature.copyTextToClipboard,
    QuillNativeBridgeFeature.getClipboardMarkdown,
    QuillNativeBridgeFeature.copyMarkdownToClipboard,
  }.contains(feature);

  @override
  Future<bool> isIOSSimulator() => isIosSimulator();

  @override
  Future<String?> getClipboardHtml() => _hostApi.getClipboardHtml();

  @override
  Future<void> copyHtmlToClipboard(String html) => _hostApi.copyHtmlToClipboard(html);

  @override
  Future<String?> getClipboardText() => _hostApi.getClipboardText();

  @override
  Future<void> copyTextToClipboard(String text) => _hostApi.copyTextToClipboard(text);
}
