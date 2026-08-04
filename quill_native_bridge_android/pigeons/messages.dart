import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/src/main/kotlin/dev/flutterquill/quill_native_bridge/generated/GeneratedMessages.kt',
    kotlinOptions: KotlinOptions(package: 'dev.flutterquill.quill_native_bridge.generated'),
    dartPackageName: 'quill_native_bridge_android',
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

  // Markdown
  String? getClipboardMarkdown();
  void copyMarkdownToClipboard(String markdown);
}
