import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/quill_native_bridge_ios/Sources/quill_native_bridge_ios/Messages.g.swift',
    dartPackageName: 'quill_native_bridge_ios',
  ),
)
@HostApi()
abstract class QuillNativeBridgeApi {
  // HTML
  @async
  String? getClipboardHtml();
  void copyHtmlToClipboard(String html);

  // Text
  String? getClipboardText();
  void copyTextToClipboard(String text);

  // Markdown
  @async
  String? getClipboardMarkdown();
  void copyMarkdownToClipboard(String markdown);
}
