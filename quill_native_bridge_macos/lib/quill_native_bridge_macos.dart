// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'package:quill_native_bridge_macos/src/messages.g.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

/// An implementation of [QuillNativeBridgePlatform] for macOS.
class QuillNativeBridgeMacOS extends QuillNativeBridgePlatform {
  final QuillNativeBridgeApi _hostApi = QuillNativeBridgeApi();

  /// Registers this class as the default instance of [QuillNativeBridgePlatform].
  static void registerWith() {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeMacOS();
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async => {
    QuillNativeBridgeFeature.getClipboardHtml,
    QuillNativeBridgeFeature.copyHtmlToClipboard,
    QuillNativeBridgeFeature.getClipboardText,
    QuillNativeBridgeFeature.copyTextToClipboard,
    QuillNativeBridgeFeature.getClipboardMarkdown,
    QuillNativeBridgeFeature.copyMarkdownToClipboard,
  }.contains(feature);

  @override
  Future<bool> isIOSSimulator() => throw UnsupportedError('isIOSSimulator() is only supported on iOS.');

  @override
  Future<String?> getClipboardHtml() => _hostApi.getClipboardHtml();

  @override
  Future<void> copyHtmlToClipboard(String html) => _hostApi.copyHtmlToClipboard(html);

  @override
  Future<String?> getClipboardText() => _hostApi.getClipboardText();

  @override
  Future<void> copyTextToClipboard(String text) => _hostApi.copyTextToClipboard(text);

  @override
  bool isAppleSafari() => false;
}
