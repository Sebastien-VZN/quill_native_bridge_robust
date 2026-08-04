import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

/// A default implementation that returns safe defaults instead of throwing.
///
/// Used before a platform implementation registers itself via [registerWith()].
/// This prevents crashes when [isSupported] or other methods are called
/// before the platform is ready.
class PlaceholderImplementation extends QuillNativeBridgePlatform {
  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async => false;

  @override
  Future<bool> isIOSSimulator() async => false;

  @override
  Future<String?> getClipboardHtml() async => null;

  @override
  Future<void> copyHtmlToClipboard(String html) async {}

  @override
  Future<String?> getClipboardText() async => null;

  @override
  Future<void> copyTextToClipboard(String text) async {}

  @override
  Future<String?> getClipboardMarkdown() async => null;

  @override
  Future<void> copyMarkdownToClipboard(String markdown) async {}

  @override
  bool isAppleSafari() => false;
}
