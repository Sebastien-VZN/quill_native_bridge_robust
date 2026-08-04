import "package:dart_quill_delta/dart_quill_delta.dart";
import "package:markdown/markdown.dart" as md;

/// Converts Markdown text to a Quill [Delta].
///
/// This is a decoupled port of the Markdown-to-Delta converter. It uses plain
/// `Map<String, dynamic>` for attributes instead of `FormatAttribute`, and has
/// **no dependency on `flutter_quill`**.
///
/// Media embeds (image, video, horizontal rule, table) are **not** supported —
/// this converter handles text formatting only.
///
/// Uses [md.ExtensionSet.gitHubFlavored] by default to enable strikethrough
/// (`~~text~~`) and other GFM features.
///
/// Usage:
/// ```dart
/// final delta = MarkdownToDelta().convert('**bold** and _italic_');
/// ```
class MarkdownToDelta implements md.NodeVisitor {
  MarkdownToDelta({md.ExtensionSet? markdownDocument})
    : _markdownDocument = markdownDocument ?? md.ExtensionSet.gitHubFlavored;

  final md.ExtensionSet _markdownDocument;

  late Delta _delta;
  late List<Map<String, dynamic>> _attributesStack;

  /// Tracks whether the current list context is ordered.
  /// Pushed/popped when entering/exiting <ul> or <ol>.
  late List<bool> _isOrderedListStack;

  /// Converts [markdown] string to a Quill [Delta].
  Delta convert(String markdown) {
    _delta = Delta();
    _attributesStack = [];
    _isOrderedListStack = [];

    final document = md.Document(extensionSet: _markdownDocument);
    final nodes = document.parse(markdown);

    for (final node in nodes) {
      node.accept(this);
    }

    return _delta;
  }

  // ---------------------------------------------------------------
  // NodeVisitor implementation
  // ---------------------------------------------------------------

  @override
  bool visitElementBefore(md.Element element) {
    final tag = element.tag;

    switch (tag) {
      case "strong":
        _pushAttribute({"bold": true});
      case "em":
        _pushAttribute({"italic": true});
      case "del":
        _pushAttribute({"strike": true});
      case "code":
        _pushAttribute({"code": true});
      case "a":
        final href = element.attributes["href"];
        if (href != null) {
          _pushAttribute({"link": href});
        }
      case "blockquote":
        _pushAttribute({"blockquote": true});
      case "h1":
        _pushAttribute({"header": 1});
      case "h2":
        _pushAttribute({"header": 2});
      case "h3":
        _pushAttribute({"header": 3});
      case "pre":
        _pushAttribute({"code-block": true});
      case "ul":
        _isOrderedListStack.add(false);
      case "ol":
        _isOrderedListStack.add(true);
      case "li":
        final isOrdered =
            _isOrderedListStack.isNotEmpty && _isOrderedListStack.last;
        _pushAttribute({"list": isOrdered ? "ordered" : "bullet"});
      case "p":
        break;
      case "br":
        _delta.insert("\n", _currentAttributes());
      case "hr":
        // Horizontal rule — not supported (media)
        break;
      default:
        break;
    }

    return true;
  }

  @override
  void visitElementAfter(md.Element element) {
    final tag = element.tag;

    switch (tag) {
      case "strong":
        _popAttribute();
      case "em":
        _popAttribute();
      case "del":
        _popAttribute();
      case "code":
        _popAttribute();
      case "a":
        _popAttribute();
      case "blockquote":
        _delta.insert("\n", _currentAttributes());
        _popAttribute();
      case "h1":
        _delta.insert("\n", _currentAttributes());
        _popAttribute();
      case "h2":
        _delta.insert("\n", _currentAttributes());
        _popAttribute();
      case "h3":
        _delta.insert("\n", _currentAttributes());
        _popAttribute();
      case "pre":
        _delta.insert("\n", _currentAttributes());
        _popAttribute();
      case "li":
        _delta.insert("\n", _currentAttributes());
        _popAttribute();
      case "ul":
        if (_isOrderedListStack.isNotEmpty) {
          _isOrderedListStack.removeLast();
        }
      case "ol":
        if (_isOrderedListStack.isNotEmpty) {
          _isOrderedListStack.removeLast();
        }
      case "p":
        _delta.insert("\n", _currentAttributes());
    }
  }

  @override
  void visitText(md.Text text) {
    final content = text.text;
    if (content.isEmpty) return;

    _delta.insert(content, _currentAttributes());
  }

  // ---------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------

  Map<String, dynamic>? _currentAttributes() {
    if (_attributesStack.isEmpty) return null;
    final merged = <String, dynamic>{};
    _attributesStack.forEach(merged.addAll);
    return merged;
  }

  void _pushAttribute(Map<String, dynamic> attr) {
    _attributesStack.add(attr);
  }

  void _popAttribute() {
    _attributesStack.removeLast();
  }
}
