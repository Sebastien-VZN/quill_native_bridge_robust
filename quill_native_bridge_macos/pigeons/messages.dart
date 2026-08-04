import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'macos/quill_native_bridge_macos/Sources/quill_native_bridge_macos/Messages.g.swift',
    dartPackageName: 'quill_native_bridge_macos',
  ),
)
@HostApi()
abstract class QuillNativeBridgeApi {
  // HTML
  String? getClipboardHtml();
  void copyHtmlToClipboard(String html);

  // Text
  String? getClipboardText();
  void copyTextToClipboard(String text);
}
