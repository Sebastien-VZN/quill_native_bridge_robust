# 🪶 Quill Native Bridge Robust

A hardened, production-ready fork of [`quill_native_bridge`](https://pub.dev/packages/quill_native_bridge) for the [`flutter_quill`](https://pub.dev/packages/flutter_quill) ecosystem.

This plugin provides a federated interface for **text-only clipboard operations** (plain text, HTML, Markdown) across all major platforms, plus built-in Delta converters.

> **Upstream divergence**: This fork has **removed all media/image clipboard features** that were present in the original `quill_native_bridge`. See [Breaking Change](#-breaking-change-media-removed) for rationale.

For the plugin architecture, refer to the [README of the repo](../README.md).

## ⚠️ Breaking Change: Media Removed

The original plugin included `copyImageToClipboard`, `getClipboardImage`, `getClipboardGif`, `getClipboardFiles`, `openGalleryApp`, `saveImageToGallery`, and `saveImage`. **All of these have been removed.**

**Why:**

1. **Fundamentally unreliable** — image clipboard operations were inconsistent across platforms (Android MIME handling, iOS memory leaks, Windows FFI crashes).
2. **Poorly tested** — integration tests for image round-trips failed regularly in CI.
3. **Security risk** — `getClipboardFiles` exposed raw filesystem paths without sanitisation.
4. **Scope creep** — a clipboard bridge should handle data transfer, not gallery management or image processing. Use dedicated packages for those.
5. **Maintenance burden** — platform-specific media code (Kotlin, Swift, FFI, JS) broke frequently with OS updates.

If you need image/media clipboard support, use dedicated packages like `image_picker` or `pasteboard` alongside this plugin.

## ✨ Features

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **isIOSSimulator** | ✅ | ⚪ | ⚪ | ⚪ | ⚪ | ⚪ |
| **getClipboardHtml** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **copyHtmlToClipboard** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **getClipboardText** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **copyTextToClipboard** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **getClipboardMarkdown** | ⚠️ | ✅ | ⚠️ | ✅ | ✅ | ⚠️ |
| **copyMarkdownToClipboard** | ⚠️ | ✅ | ⚠️ | ✅ | ✅ | ⚠️ |
| **isAppleSafari** | ⚪ | ⚪ | ⚪ | ⚪ | ⚪ | ✅ |

Legend:
- ✅ — Supported and functional.
- ⚠️ — `isSupported()` returns `true`, but the platform implementation does not override the method. Calling it will throw `UnimplementedError`. See [Known Issues](#-known-issues).
- ⚪ — Not applicable on this platform.
- **Web/Firefox**: `isSupported()` returns `false` for HTML and Markdown when the Clipboard API is unavailable. Methods throw `UnsupportedError` with a fallback message.

## 📜 Usage

```dart
import 'package:quill_native_bridge/quill_native_bridge.dart';

final bridge = QuillNativeBridge();

// Check feature support before calling
if (await bridge.isSupported(QuillNativeBridgeFeature.getClipboardHtml)) {
  final html = await bridge.getClipboardHtml();
}
```

**Check if the iOS app is running on a simulator:**

```dart
import 'package:flutter/foundation.dart';

final isIOSApp = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
if (isIOSApp && await QuillNativeBridge().isIOSSimulator()) {
  // Running on iOS simulator
}
```

**Retrieve HTML from the system clipboard:**

```dart
final String? html = await QuillNativeBridge().getClipboardHtml();
// Returns null if permission denied (iOS) or HTML not available
```

**Copy HTML to the system clipboard:**

```dart
const exampleHtml = '<b>Bold text</b>';
await QuillNativeBridge().copyHtmlToClipboard(exampleHtml);
```

**Retrieve plain text from the clipboard:**

```dart
final String? text = await QuillNativeBridge().getClipboardText();
```

**Copy plain text to the clipboard:**

```dart
await QuillNativeBridge().copyTextToClipboard('Hello');
```

**Retrieve Markdown from the clipboard:**

```dart
final String? markdown = await QuillNativeBridge().getClipboardMarkdown();
// ⚠️ Not yet implemented on iOS, macOS, Web — check isSupported() first
```

**Copy Markdown to the clipboard:**

```dart
await QuillNativeBridge().copyMarkdownToClipboard('**bold** text');
// ⚠️ Not yet implemented on iOS, macOS, Web — check isSupported() first
```

**Check if the current browser is Safari:**

```dart
final bool isSafari = QuillNativeBridge().isAppleSafari();
// Returns false on non-web platforms
```

## 🔄 Delta Converters

The bridge includes two decoupled converters that transform raw clipboard data into Quill Delta format:

### HtmlToDelta

Re-exported from [`flutter_quill_delta_from_html`](https://pub.dev/packages/flutter_quill_delta_from_html) v1.5.3. No dependency on `flutter_quill`.

```dart
import 'package:quill_native_bridge/quill_native_bridge.dart';

final delta = HtmlToDelta().convert('<b>Bold text</b>');
```

### MarkdownToDelta

A decoupled port using plain `Map<String, dynamic>` attributes (no `FormatAttribute` dependency).

- Supports GitHub Flavored Markdown (strikethrough via `~~text~~`).
- **Media removed**: no image, video, horizontal rule, or table support.

```dart
import 'package:quill_native_bridge/quill_native_bridge.dart';

final delta = MarkdownToDelta().convert('**bold** and _italic_');
```

## 🔧 Bug Fixes

1. **PlaceholderImplementation crash** — All methods return safe defaults (`false`/`null`/no-op) instead of `throw UnimplementedError`. Prevents crashes when `registerWith()` hasn't been called yet.
2. **Missing Android class** — `QuillNativeBridgeAndroid extends QuillNativeBridgePlatform` was added. Without it, the plugin never registered on Android.
3. **`isSupported()` stability** — Markdown methods were declared as supported but threw `UnimplementedError`. Fixed on Android, Linux, and Windows. **iOS, macOS, and Web still declare Markdown as supported without providing overrides — open bug.**
4. **Linux parity** — Added missing Markdown method overrides on Linux (xclip).
5. **Pigeon cleanup** — Removed obsolete `dartTestOut` and `dartHostTestHandler` (Pigeon v27+).
6. **Test discovery** — Renamed test files with the `_test.dart` suffix.

## ⚠️ Known Issues

- **Windows eager FFI init** — The `QuillNativeBridgeWindows` constructor eagerly loads `user32.dll` and `kernel32.dll` via `DynamicLibrary.open()`. If loading fails, `registerWith()` silently fails and `PlaceholderImplementation` remains active. A lazy-init pattern is needed.
- **Markdown on iOS, macOS, Web** — `isSupported(QuillNativeBridgeFeature.getClipboardMarkdown)` returns `true` on these platforms, but `getClipboardMarkdown()` and `copyMarkdownToClipboard()` are **not overridden** in their Dart implementations. Calling these methods directly will throw `UnimplementedError`. Always guard with `isSupported()` **and** catch `UnimplementedError` on these platforms until native implementations are added.

## 🔗 What Was Removed

The following APIs from the original `quill_native_bridge` have been **removed entirely**:

| Removed API | Reason |
|---|---|
| `copyImageToClipboard` | Unreliable across platforms |
| `getClipboardImage` | Memory leaks, encoding corruption |
| `getClipboardGif` | Narrow use case, untested |
| `getClipboardFiles` | Security: exposed raw filesystem paths |
| `openGalleryApp` | Scope creep — not a clipboard operation |
| `saveImageToGallery` | Scope creep — use `image_picker` or similar |
| `saveImage` | Scope creep — use platform save dialogs directly |

All Android/iOS/macOS setup instructions related to gallery permissions, `FileProvider`, `NSPhotoLibraryAddUsageDescription`, `NSPhotoLibraryUsageDescription`, and `com.apple.security.files.user-selected.read-write` for image operations are **no longer needed** and have been removed from this README.