import "package:dart_quill_delta/dart_quill_delta.dart";
import "package:flutter_test/flutter_test.dart";
import "package:quill_native_bridge/quill_native_bridge.dart";

void main() {
  late MarkdownToDelta converter;

  setUp(() {
    converter = MarkdownToDelta();
  });

  Delta convert(String markdown) => converter.convert(markdown);

  List<Operation> insertOps(Delta delta) => delta.toList().where((op) => op.isInsert).toList();

  test("converts bold text", () {
    final delta = convert("**bold text**");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["bold"] == true), isTrue);
  });

  test("converts italic text", () {
    final delta = convert("_italic text_");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["italic"] == true), isTrue);
  });

  test("converts strikethrough text", () {
    final delta = convert("~~strikethrough~~");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["strike"] == true), isTrue);
  });

  test("converts inline code", () {
    final delta = convert("`inline code`");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["code"] == true), isTrue);
  });

  test("converts heading 1", () {
    final delta = convert("# Heading 1");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["header"] == 1), isTrue);
  });

  test("converts heading 2", () {
    final delta = convert("## Heading 2");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["header"] == 2), isTrue);
  });

  test("converts heading 3", () {
    final delta = convert("### Heading 3");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["header"] == 3), isTrue);
  });

  test("converts unordered list", () {
    final delta = convert("- item 1\n- item 2");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["list"] == "bullet"), isTrue);
  });

  test("converts ordered list", () {
    final delta = convert("1. item 1\n2. item 2");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["list"] == "ordered"), isTrue);
  });

  test("converts blockquote", () {
    final delta = convert("> quoted text");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["blockquote"] == true), isTrue);
  });

  test("converts link", () {
    final delta = convert("[example](https://example.com)");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.data is String && op.attributes?["link"] == "https://example.com"), isTrue);
  });

  test("converts code block", () {
    final delta = convert("```\ncode block\n```");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["code-block"] == true), isTrue);
  });

  test("handles empty input", () {
    final delta = convert("");
    expect(delta.toList().isEmpty || delta.toList().every((op) => (op.data as String?)?.isEmpty == true), isTrue);
  });

  test("converts plain text without formatting", () {
    final delta = convert("plain text");
    final ops = insertOps(delta);
    expect(ops.length, greaterThanOrEqualTo(1));
    // Markdown wraps plain text in <p>, so the delta ends with \n
    expect((ops.first.data! as String).startsWith("plain text"), isTrue);
  });

  test("converts mixed bold and italic", () {
    final delta = convert("***bold italic***");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["bold"] == true), isTrue);
    expect(ops.any((op) => op.attributes?["italic"] == true), isTrue);
  });

  test("converts nested lists", () {
    final delta = convert("- item 1\n  - nested item");
    final ops = insertOps(delta);
    expect(ops.any((op) => op.attributes?["list"] == "bullet"), isTrue);
  });
}
