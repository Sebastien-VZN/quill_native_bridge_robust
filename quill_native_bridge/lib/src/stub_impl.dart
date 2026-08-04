import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

class QuillNativeBridgeStub extends QuillNativeBridgePlatform {
  static void registerWith() {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeStub();
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async => false;

  @override
  Future<String?> getClipboardHtml() async {
    return null;
  }

  @override
  Future<String?> getClipboardText() async {
    return null;
  }

  @override
  Future<String?> getClipboardMarkdown() async {
    return null;
  }
}
