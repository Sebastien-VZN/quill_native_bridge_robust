// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'dart:convert' show utf8;
import 'dart:io' hide exitCode; // Avoids name conflict with local "exitCode" variable

import 'package:quill_native_bridge_linux/src/binary_runner.dart';
import 'package:quill_native_bridge_linux/src/constants.dart';
import 'package:quill_native_bridge_linux/src/mime_types_constants.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

/// A Linux implementation of the [QuillNativeBridgePlatform].
class QuillNativeBridgeLinux extends QuillNativeBridgePlatform {
  static void registerWith() {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeLinux();
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

  // Improve error handling

  // The xclipFile should always be removed in finally block, extractBinaryFromAsset()
  //  should be part of the try-catch

  // Support wayland https://github.com/bugaevc/wl-clipboard.
  //  Need to abstract implementation of xclip first.

  // Might want to improve the description of _hasClipboardItemOfType()

  /// Check if the system clipboard has [mimeType] to paste using [xclip](https://github.com/astrand/xclip).
  ///
  /// `xclip` doesn't throw an error when retrieving a clipboard item
  /// while specifying type using `-t text/html`.
  ///
  /// Without this check, will return the last copied
  /// item even if the last item is an image (as bytes).
  ///
  /// This only check the type in the clipboard selection.
  Future<bool> _hasClipboardItemOfType({required String mimeType, required String xclipFilePath}) async {
    return (await Process.run(xclipFilePath, ['-selection', 'clipboard', '-t', 'TARGETS', '-o'])).stdout.toString().contains(mimeType);
  }

  @override
  Future<String?> getClipboardHtml() async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);
    try {
      // Write a test case where copying an image and then retrieving HTML
      //  should not throw an exception or unexpected behavior. Not required
      //  since some of the tests will fail if this issue happen.

      // Should check if the expected type is avalaible before
      //  avaliable before getting it using: xclip -o -t TARGETS
      final hasHtmlInClipboard = await _hasClipboardItemOfType(mimeType: kHtmlMimeType, xclipFilePath: xclipFile.path);
      if (!hasHtmlInClipboard) {
        return null;
      }
      final result = await Process.run(xclipFile.path, ['-selection', 'clipboard', '-o', '-t', kHtmlMimeType]);
      if (result.exitCode == 0) {
        return (result.stdout as String?)?.trim();
      }
      final processErrorOutput = result.stderr.toString().trim();
      if (processErrorOutput.startsWith('Error: target $kHtmlMimeType not available')) {
        return null;
      }
      assert(false, 'Error retrieving the HTML to clipboard. Exit code: ${result.exitCode}\nError output: $processErrorOutput');
    } finally {
      await xclipFile.delete();
    }
    return null;
  }

  @override
  Future<void> copyHtmlToClipboard(String html) async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);

    try {
      final process = await Process.start(xclipFile.path, ['-selection', 'clipboard', '-t', kHtmlMimeType]);
      process.stdin.writeln(html);
      await process.stdin.close();
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final processErrorOutput = await process.stderr.transform(utf8.decoder).join();
        assert(false, 'Error copying the HTML to clipboard. Exit code: $exitCode\nError output: $processErrorOutput');
      }
    } finally {
      await xclipFile.delete();
    }
  }

  @override
  Future<String?> getClipboardText() async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);
    try {
      final result = await Process.run(xclipFile.path, ['-selection', 'clipboard', '-o']);
      if (result.exitCode == 0) {
        return (result.stdout as String?)?.trim();
      }
      return null;
    } finally {
      await xclipFile.delete();
    }
  }

  @override
  Future<void> copyTextToClipboard(String text) async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);
    try {
      final process = await Process.start(xclipFile.path, ['-selection', 'clipboard']);
      process.stdin.writeln(text);
      await process.stdin.close();
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final processErrorOutput = await process.stderr.transform(utf8.decoder).join();
        assert(false, 'Error copying text to clipboard. Exit code: $exitCode\nError output: $processErrorOutput');
      }
    } finally {
      await xclipFile.delete();
    }
  }

  @override
  Future<String?> getClipboardMarkdown() async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);
    try {
      final hasMarkdownInClipboard = await _hasClipboardItemOfType(mimeType: kMarkdownMimeType, xclipFilePath: xclipFile.path);
      if (!hasMarkdownInClipboard) {
        return null;
      }
      final result = await Process.run(xclipFile.path, ['-selection', 'clipboard', '-o', '-t', kMarkdownMimeType]);
      if (result.exitCode == 0) {
        return (result.stdout as String?)?.trim();
      }
      final processErrorOutput = result.stderr.toString().trim();
      if (processErrorOutput.startsWith('Error: target $kMarkdownMimeType not available')) {
        return null;
      }
      assert(false, 'Error retrieving the Markdown from clipboard. Exit code: ${result.exitCode}\nError output: $processErrorOutput');
    } finally {
      await xclipFile.delete();
    }
    return null;
  }

  @override
  Future<void> copyMarkdownToClipboard(String markdown) async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);
    try {
      final process = await Process.start(xclipFile.path, ['-selection', 'clipboard', '-t', kMarkdownMimeType]);
      process.stdin.writeln(markdown);
      await process.stdin.close();
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final processErrorOutput = await process.stderr.transform(utf8.decoder).join();
        assert(false, 'Error copying Markdown to clipboard. Exit code: $exitCode\nError output: $processErrorOutput');
      }
    } finally {
      await xclipFile.delete();
    }
  }
}
