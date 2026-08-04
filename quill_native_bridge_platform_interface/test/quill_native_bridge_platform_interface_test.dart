import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';
import 'package:quill_native_bridge_platform_interface/src/placeholder_implementation.dart';

class MockQuillNativeBridgePlatform
    with MockPlatformInterfaceMixin
    implements QuillNativeBridgePlatform {
  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async => false;

  @override
  Future<bool> isIOSSimulator() async => false;

  @override
  Future<String?> getClipboardHtml() async => '<center>Invalid HTML</center>';

  String? primaryHTMLClipboard;

  @override
  Future<void> copyHtmlToClipboard(String html) async {
    primaryHTMLClipboard = html;
  }

  String? primaryTextClipboard;

  @override
  Future<String?> getClipboardText() async => 'plain text';

  @override
  Future<void> copyTextToClipboard(String text) async {
    primaryTextClipboard = text;
  }

  String? primaryMarkdownClipboard;

  @override
  Future<String?> getClipboardMarkdown() async => '# Hello';

  @override
  Future<void> copyMarkdownToClipboard(String markdown) async {
    primaryMarkdownClipboard = markdown;
  }

  @override
  bool isAppleSafari() => isSafari;

  bool isSafari = false;
}

void main() {
  final initialPlatform = QuillNativeBridgePlatform.instance;

  test('$PlaceholderImplementation is the default instance', () {
    expect(initialPlatform, isInstanceOf<PlaceholderImplementation>());
  });

  group('$PlaceholderImplementation returns safe defaults (never throws)', () {
    final placeholder = PlaceholderImplementation();

    test('isSupported returns false for all features', () async {
      for (final feature in QuillNativeBridgeFeature.values) {
        final result = await placeholder.isSupported(feature);
        expect(
          result,
          isFalse,
          reason:
              '$feature should not be supported by PlaceholderImplementation',
        );
      }
    });

    test('isIOSSimulator returns false', () async {
      expect(await placeholder.isIOSSimulator(), isFalse);
    });

    test('getClipboardHtml returns null', () async {
      expect(await placeholder.getClipboardHtml(), isNull);
    });

    test('copyHtmlToClipboard is a no-op', () async {
      // Must not throw
      await placeholder.copyHtmlToClipboard('<p>test</p>');
    });

    test('getClipboardText returns null', () async {
      expect(await placeholder.getClipboardText(), isNull);
    });

    test('copyTextToClipboard is a no-op', () async {
      // Must not throw
      await placeholder.copyTextToClipboard('test');
    });

    test('getClipboardMarkdown returns null', () async {
      expect(await placeholder.getClipboardMarkdown(), isNull);
    });

    test('copyMarkdownToClipboard is a no-op', () async {
      // Must not throw
      await placeholder.copyMarkdownToClipboard('# test');
    });

    test('isAppleSafari returns false', () {
      expect(placeholder.isAppleSafari(), isFalse);
    });
  });

  final fakePlatform = MockQuillNativeBridgePlatform();
  QuillNativeBridgePlatform.instance = fakePlatform;

  test('isIOSSimulator', () async {
    expect(await QuillNativeBridgePlatform.instance.isIOSSimulator(), false);
  });

  test('getClipboardHtml()', () async {
    expect(
      await QuillNativeBridgePlatform.instance.getClipboardHtml(),
      '<center>Invalid HTML</center>',
    );
  });

  test('copyHtmlToClipboard()', () async {
    const html = '<pre>HTML</pre>';
    expect(fakePlatform.primaryHTMLClipboard, null);
    await QuillNativeBridgePlatform.instance.copyHtmlToClipboard(html);
    expect(fakePlatform.primaryHTMLClipboard, html);
  });

  test('getClipboardText()', () async {
    expect(
      await QuillNativeBridgePlatform.instance.getClipboardText(),
      'plain text',
    );
  });

  test('copyTextToClipboard()', () async {
    const text = 'hello';
    expect(fakePlatform.primaryTextClipboard, null);
    await QuillNativeBridgePlatform.instance.copyTextToClipboard(text);
    expect(fakePlatform.primaryTextClipboard, text);
  });

  test('getClipboardMarkdown()', () async {
    expect(
      await QuillNativeBridgePlatform.instance.getClipboardMarkdown(),
      '# Hello',
    );
  });

  test('copyMarkdownToClipboard()', () async {
    const markdown = '# Hello\n\nThis is **bold** text.';
    expect(fakePlatform.primaryMarkdownClipboard, null);
    await QuillNativeBridgePlatform.instance.copyMarkdownToClipboard(markdown);
    expect(fakePlatform.primaryMarkdownClipboard, markdown);
  });

  test('isAppleSafari', () async {
    fakePlatform.isSafari = true;
    expect(fakePlatform.isAppleSafari(), true);

    fakePlatform.isSafari = false;
    expect(fakePlatform.isAppleSafari(), false);
  });
}
