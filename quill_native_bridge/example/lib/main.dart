import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';

/// Creates a global instance of [QuillNativeBridge], allowing it to be overridden in tests.
@visibleForTesting
QuillNativeBridge quillNativeBridge = QuillNativeBridge();

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Quill Native Bridge')),
        body: const SingleChildScrollView(child: Center(child: Buttons())),
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        ElevatedButton.icon(
          onPressed: () => _onButtonPressed(QuillNativeBridgeFeature.isIOSSimulator, context: context),
          label: const Text('Is iOS Simulator'),
          icon: const Icon(Icons.apple),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonPressed(QuillNativeBridgeFeature.getClipboardHtml, context: context),
          label: const Text('Get HTML from Clipboard'),
          icon: const Icon(Icons.html),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonPressed(QuillNativeBridgeFeature.copyHtmlToClipboard, context: context),
          label: const Text('Copy HTML to Clipboard'),
          icon: const Icon(Icons.copy),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonPressed(QuillNativeBridgeFeature.getClipboardText, context: context),
          label: const Text('Get Text from Clipboard'),
          icon: const Icon(Icons.text_fields),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonPressed(QuillNativeBridgeFeature.copyTextToClipboard, context: context),
          label: const Text('Copy Text to Clipboard'),
          icon: const Icon(Icons.content_copy),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonPressed(QuillNativeBridgeFeature.getClipboardMarkdown, context: context),
          label: const Text('Get Markdown from Clipboard'),
          icon: const Icon(Icons.data_object),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonPressed(QuillNativeBridgeFeature.copyMarkdownToClipboard, context: context),
          label: const Text('Copy Markdown to Clipboard'),
          icon: const Icon(Icons.edit_note),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonPressed(QuillNativeBridgeFeature.isAppleSafari, context: context),
          label: const Text('Is Safari'),
          icon: const Icon(Icons.apple),
        ),
      ],
    );
  }
}

Future<void> _onButtonPressed(QuillNativeBridgeFeature feature, {required BuildContext context}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  try {
    final isFeatureUnsupported = !(await quillNativeBridge.isSupported(feature));
    switch (feature) {
      case QuillNativeBridgeFeature.isIOSSimulator:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            kIsWeb ? "Can't check if the device is an iOS simulator on the web." : 'Available only on iOS to determine if the device is a simulator.',
          );
          return;
        }
        final result = await quillNativeBridge.isIOSSimulator();
        scaffoldMessenger.showText(result ? "You're running the app on iOS simulator." : "You're running the app on a real iOS device.");
      case QuillNativeBridgeFeature.getClipboardHtml:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            kIsWeb
                ? 'Retrieving HTML from the clipboard is currently not supported on the web.'
                : 'Retrieving HTML from the clipboard is currently not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        final result = await quillNativeBridge.getClipboardHtml();
        if (result == null) {
          scaffoldMessenger.showText('The HTML is not available on the clipboard.');
          return;
        }
        scaffoldMessenger.showText('HTML from the clipboard: $result');
        debugPrint('HTML from the clipboard: $result');
      case QuillNativeBridgeFeature.copyHtmlToClipboard:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            kIsWeb
                ? 'Copying HTML to the clipboard is not supported on the web.'
                : 'Copying HTML to the clipboard is not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        const html = '<strong>Bold text</strong> <em>Italic text</em> <u>Underlined</u>';
        await quillNativeBridge.copyHtmlToClipboard(html);
        scaffoldMessenger.showText('HTML copied to the clipboard.');
      case QuillNativeBridgeFeature.getClipboardText:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            kIsWeb
                ? 'Retrieving text from the clipboard is currently not supported on the web.'
                : 'Retrieving text from the clipboard is currently not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        final result = await quillNativeBridge.getClipboardText();
        if (result == null) {
          scaffoldMessenger.showText('The text is not available on the clipboard.');
          return;
        }
        scaffoldMessenger.showText('Text from the clipboard: $result');
        debugPrint('Text from the clipboard: $result');
      case QuillNativeBridgeFeature.copyTextToClipboard:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            kIsWeb
                ? 'Copying text to the clipboard is not supported on the web.'
                : 'Copying text to the clipboard is not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        const text = 'Hello from Quill Native Bridge!';
        await quillNativeBridge.copyTextToClipboard(text);
        scaffoldMessenger.showText('Text copied to the clipboard.');
      case QuillNativeBridgeFeature.getClipboardMarkdown:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            kIsWeb
                ? 'Retrieving Markdown from the clipboard is currently not supported on the web.'
                : 'Retrieving Markdown from the clipboard is currently not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        final result = await quillNativeBridge.getClipboardMarkdown();
        if (result == null) {
          scaffoldMessenger.showText('The Markdown is not available on the clipboard.');
          return;
        }
        scaffoldMessenger.showText('Markdown from the clipboard: $result');
        debugPrint('Markdown from the clipboard: $result');
      case QuillNativeBridgeFeature.copyMarkdownToClipboard:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            kIsWeb
                ? 'Copying Markdown to the clipboard is not supported on the web.'
                : 'Copying Markdown to the clipboard is not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        const markdown = '# Hello\n\nThis is **bold** and *italic* text.';
        await quillNativeBridge.copyMarkdownToClipboard(markdown);
        scaffoldMessenger.showText('Markdown copied to the clipboard.');
      case QuillNativeBridgeFeature.isAppleSafari:
        if (!kIsWeb) {
          scaffoldMessenger.showText('Checking whether the browser is Safari is only supported on the web.');
          return;
        }
        if (quillNativeBridge.isAppleSafari()) {
          scaffoldMessenger.showText("You're running this app on Safari browser");
        } else {
          scaffoldMessenger.showText("You're not running this app on Safari browser");
        }
    }
  } on PlatformException catch (e) {
    scaffoldMessenger.showText('Platform error: ${e.message ?? e.code}');
    debugPrint('PlatformException calling $feature: $e');
  } on Exception catch (e) {
    scaffoldMessenger.showText('Error: $e');
    debugPrint('Error calling $feature: $e');
  }
}

extension ScaffoldMessengerX on ScaffoldMessengerState {
  void showText(String text, {SnackBarAction? action}) {
    clearSnackBars();
    showSnackBar(SnackBar(content: Text(text), action: action));
  }
}
