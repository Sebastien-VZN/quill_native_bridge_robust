/// Re-export of [HtmlToDelta] from the `flutter_quill_delta_from_html` package.
///
/// This converter transforms raw HTML clipboard content into a Quill [Delta].
/// The conversion is handled entirely by `flutter_quill_delta_from_html` v1.5.3,
/// which depends only on `dart_quill_delta` and `html` — no dependency on
/// `flutter_quill` itself.
///
/// Usage:
/// ```dart
/// import 'package:quill_native_bridge/quill_native_bridge.dart';
///
/// final delta = HtmlToDelta().convert(htmlString);
/// ```
library;

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart';

export 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
