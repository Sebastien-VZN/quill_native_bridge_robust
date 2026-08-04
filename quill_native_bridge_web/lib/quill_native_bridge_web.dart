// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';
import 'package:quill_native_bridge_web/src/clipboard_api_support_unsafe.dart';
import 'package:quill_native_bridge_web/src/mime_types_constants.dart';
import 'package:web/web.dart';

/// A web implementation of the [QuillNativeBridgePlatform].
class QuillNativeBridgeWeb extends QuillNativeBridgePlatform {
  static void registerWith(Registrar registrar) {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeWeb();
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async {
    switch (feature) {
      case QuillNativeBridgeFeature.isIOSSimulator:
        return false;
      case QuillNativeBridgeFeature.getClipboardHtml:
      case QuillNativeBridgeFeature.copyHtmlToClipboard:
        return isClipboardApiSupported;
      case QuillNativeBridgeFeature.getClipboardText:
      case QuillNativeBridgeFeature.copyTextToClipboard:
        return true;
      case QuillNativeBridgeFeature.getClipboardMarkdown:
      case QuillNativeBridgeFeature.copyMarkdownToClipboard:
        return isClipboardApiSupported;
      case QuillNativeBridgeFeature.isAppleSafari:
        return true;
    }
  }

  @override
  Future<String?> getClipboardHtml() async {
    if (isClipbaordApiUnsupported) {
      throw UnsupportedError(
        'Could not retrieve HTML from the clipboard.\n'
        'The Clipboard API is not supported on ${window.navigator.userAgent}.\n'
        'Should fallback to Clipboard events.',
      );
    }
    final clipboardItems =
        (await window.navigator.clipboard.read().toDart).toDart;
    for (final item in clipboardItems) {
      if (item.types.toDart.contains(kHtmlMimeType.toJS)) {
        final html = await item.getType(kHtmlMimeType).toDart;
        return (await html.text().toDart).toDart;
      }
    }
    return null;
  }

  @override
  Future<void> copyHtmlToClipboard(String html) async {
    if (isClipbaordApiUnsupported) {
      throw UnsupportedError(
        'Could not copy HTML to the clipboard.\n'
        'The Clipboard API is not supported on ${window.navigator.userAgent}.\n'
        'Should fallback to Clipboard events.',
      );
    }
    final blob = Blob([html.toJS].toJS, BlobPropertyBag(type: kHtmlMimeType));
    final clipboardItem = ClipboardItem(
      {kHtmlMimeType.toJS: blob}.jsify()! as JSObject,
    );
    await window.navigator.clipboard.write([clipboardItem].toJS).toDart;
  }

  @override
  Future<String?> getClipboardText() async {
    final jsText = await window.navigator.clipboard.readText().toDart;
    final text = jsText.toDart;
    return text.isEmpty ? null : text;
  }

  @override
  Future<void> copyTextToClipboard(String text) async {
    await window.navigator.clipboard.writeText(text).toDart;
  }

  @override
  Future<String?> getClipboardMarkdown() async {
    if (isClipbaordApiUnsupported) {
      throw UnsupportedError(
        'Could not retrieve Markdown from the clipboard.\n'
        'The Clipboard API is not supported on ${window.navigator.userAgent}.\n'
        'Should fallback to Clipboard events.',
      );
    }
    final clipboardItems =
        (await window.navigator.clipboard.read().toDart).toDart;
    for (final item in clipboardItems) {
      if (item.types.toDart.contains(kMarkdownMimeType.toJS)) {
        final markdown = await item.getType(kMarkdownMimeType).toDart;
        return (await markdown.text().toDart).toDart;
      }
    }
    return null;
  }

  @override
  Future<void> copyMarkdownToClipboard(String markdown) async {
    if (isClipbaordApiUnsupported) {
      throw UnsupportedError(
        'Could not copy Markdown to the clipboard.\n'
        'The Clipboard API is not supported on ${window.navigator.userAgent}.\n'
        'Should fallback to Clipboard events.',
      );
    }
    final blob = Blob(
      [markdown.toJS].toJS,
      BlobPropertyBag(type: kMarkdownMimeType),
    );
    final clipboardItem = ClipboardItem(
      {kMarkdownMimeType.toJS: blob}.jsify()! as JSObject,
    );
    await window.navigator.clipboard.write([clipboardItem].toJS).toDart;
  }

  // https://github.com/flutter/packages/blob/main/packages/cross_file/lib/src/web_helpers/web_helpers.dart#L35-L37
  @override
  bool isAppleSafari() => window.navigator.vendor == 'Apple Computer, Inc.';
}
