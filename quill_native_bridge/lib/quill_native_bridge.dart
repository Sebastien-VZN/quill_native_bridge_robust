/// An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill)
/// package to access platform-specific APIs.
library;

import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

export 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart'
    show QuillNativeBridgeFeature;

export 'src/converters/html_to_delta.dart';
export 'src/converters/markdown_to_delta.dart';
export 'src/stub_impl.dart' show QuillNativeBridgeStub;

/// An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill)
/// package to access platform-specific APIs.
///
/// Use [QuillNativeBridge.isSupported] to check whether a feature is supported.
class QuillNativeBridge {
  /// The platform interface that drives this plugin.
  static QuillNativeBridgePlatform get _platform =>
      QuillNativeBridgePlatform.instance;

  /// Checks if the specified [feature] is supported in the current implementation.
  ///
  /// Will verify if the platform supports this feature, the platform
  /// implementation of the plugin, and the current running OS version.
  ///
  /// For example if [feature] is:
  ///
  /// - Supported on **Android API 21** (as an example) and the
  /// current Android API is `19` then will return `false`.
  ///
  /// - Supported on the web if Clipboard API (as another example)
  /// available in the current browser, and the current browser doesn't support it,
  /// will return `false` too. For this specific example, you will need
  /// to fallback to **Clipboard events** on **Firefox** or browsers that doesn't
  /// support **Clipboard API**.
  ///
  /// - Supported by the platform itself but the plugin currently implements it,
  /// then return `false`.
  ///
  /// Always review the doc comment of a method before use for special notes.
  ///
  /// See also: [QuillNativeBridgeFeature]
  Future<bool> isSupported(QuillNativeBridgeFeature feature) =>
      _platform.isSupported(feature);

  /// Checks if the app runs on [iOS Simulator](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device).
  ///
  /// Should be called only on an iOS app.
  Future<bool> isIOSSimulator() => _platform.isIOSSimulator();

  /// Returns a HTML from the system clipboard. The HTML can be platform-dependent.
  ///
  /// **Important for web**: If [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)
  /// is not supported on the web browser, should fallback to [Clipboard Events](https://developer.mozilla.org/en-US/docs/Web/API/ClipboardEvent)
  /// such as the [paste_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/paste_event).
  ///
  /// Returns `null` if the HTML content is not available or if the user has not granted
  /// permission for pasting on iOS.
  Future<String?> getClipboardHtml() => _platform.getClipboardHtml();

  /// Copies an HTML to the system clipboard to be pasted on other apps.
  ///
  /// **Important for web**: Should fallback to [Clipboard Events](https://developer.mozilla.org/en-US/docs/Web/API/ClipboardEvent)
  /// if [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API) is unsupported,
  /// not available or restricted (the case for Firefox and Safari). See [copy_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/copy_event).
  Future<void> copyHtmlToClipboard(String html) =>
      _platform.copyHtmlToClipboard(html);

  /// Returns plain text from the system clipboard.
  ///
  /// Returns `null` if the text content is not available.
  Future<String?> getClipboardText() => _platform.getClipboardText();

  /// Copies plain text to the system clipboard.
  Future<void> copyTextToClipboard(String text) =>
      _platform.copyTextToClipboard(text);

  /// Returns Markdown from the system clipboard.
  ///
  /// On Windows, this reads the `text/markdown` clipboard format.
  /// Returns `null` if Markdown content is not available.
  Future<String?> getClipboardMarkdown() => _platform.getClipboardMarkdown();

  /// Copies Markdown text to the system clipboard in the `text/markdown` format.
  Future<void> copyMarkdownToClipboard(String markdown) =>
      _platform.copyMarkdownToClipboard(markdown);

  /// Returns whether the current browser is Safari on the web.
  bool isAppleSafari() => _platform.isAppleSafari();
}
