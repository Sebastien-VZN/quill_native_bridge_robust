/// Barrel export for Markdown-to-Delta conversion.
///
/// Exposes [MarkdownToDelta] which converts raw Markdown clipboard content
/// into a Quill [Delta]. This is a decoupled port — it uses plain
/// `Map<String, dynamic>` for attributes instead of `FormatAttribute`,
/// and has **no dependency on `flutter_quill`**.
///
/// Usage:
/// ```dart
/// import 'package:quill_native_bridge/quill_native_bridge.dart';
///
/// final delta = MarkdownToDelta().convert(markdownString);
/// ```
library;

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';

export 'markdown/markdown_to_delta.dart';
