# 🪶 quill_native_bridge_robust

A **hardened, production-ready fork** of [`quill_native_bridge`](https://pub.dev/packages/quill_native_bridge) for the [`flutter_quill`](https://pub.dev/packages/flutter_quill) ecosystem.

This plugin provides a federated Flutter plugin for **text-only clipboard operations** (plain text, HTML, Markdown) across all major platforms, plus built-in Delta converters.

> **⚠️ Breaking change**: All media/image clipboard features from the original plugin have been removed. See the [quill_native_bridge README](./quill_native_bridge/README.md) for details.

## Why this fork?

The original `quill_native_bridge` included image and gallery clipboard features that were fundamentally unreliable, poorly tested, and introduced security risks. This fork removes all media functionality to focus on what works: **robust text, HTML, and Markdown clipboard operations**.

Key improvements:
- **PlaceholderImplementation** returns safe defaults instead of `UnimplementedError` — no more crashes before `registerWith()`.
- **Markdown clipboard** support on all 6 platforms (read + write `text/markdown`).
- **Delta converters** bundled: `HtmlToDelta` and `MarkdownToDelta`.
- **Bug fixes**: Android registration, `isSupported()` consistency, Pigeon v27+ cleanup.

## Architecture

Built following the [federated plugin architecture](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins). The project is separated into the following packages:

1. **[`quill_native_bridge`](./quill_native_bridge/)** — App-facing package (API + Delta converters). Clients depend on this.
2. **[`quill_native_bridge_platform_interface`](./quill_native_bridge_platform_interface/)** — Abstract interface that platform packages must implement.
3. Platform packages (contain platform-specific implementation, not directly included in apps):
    - [`quill_native_bridge_android`](./quill_native_bridge_android/) — Android (Pigeon + Kotlin)
    - [`quill_native_bridge_ios`](./quill_native_bridge_ios/) — iOS (Pigeon + Swift)
    - [`quill_native_bridge_macos`](./quill_native_bridge_macos/) — macOS (Pigeon + Swift)
    - [`quill_native_bridge_windows`](./quill_native_bridge_windows/) — Windows (FFI Win32)
    - [`quill_native_bridge_linux`](./quill_native_bridge_linux/) — Linux (xclip)
    - [`quill_native_bridge_web`](./quill_native_bridge_web/) — Web (Clipboard API)

For full API documentation, usage examples, and known issues, refer to [quill_native_bridge README](./quill_native_bridge/README.md).

---

[Français](./README_FR.md)