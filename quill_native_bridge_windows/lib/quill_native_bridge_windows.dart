// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import "dart:ffi";
import "package:ffi/ffi.dart";
import "package:flutter/foundation.dart";
import "package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart";
import "package:quill_native_bridge_windows/src/html_cleaner.dart";
import "package:quill_native_bridge_windows/src/html_formatter.dart";

/// A Windows implementation of the [QuillNativeBridgePlatform].
///
/// Uses direct FFI bindings to Win32 APIs — no dependency on the `win32`
/// package's Win32Result wrappers. Error handling follows the native
/// Win32 convention: check the return value first, then [GetLastError]()
/// only when needed.
class QuillNativeBridgeWindows extends QuillNativeBridgePlatform {
  /// Lazy-initialised FFI bindings. Loaded on first use rather than in the
  /// constructor so that a failure to load a DLL does not crash the plugin
  /// registration — the placeholder stays active and `isSupported()` returns
  /// false for every feature, which is the safe default.
  static void registerWith() {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeWindows();
  }

  bool _initialized = false;
  bool _initFailed = false;

  // ── DLL handles ──────────────────────────────────────────────────────

  late final DynamicLibrary _user32;
  late final DynamicLibrary _kernel32;

  /// Ensures FFI bindings are loaded. Returns `true` on success, `false` if
  /// the DLLs could not be opened or a symbol lookup failed (e.g. running on
  /// a non-Windows platform). Once the initialisation has failed it is not
  /// retried — every public method will keep returning the safe default
  /// (`false`/`null`/no-op) instead of re-running the failing lookup on each
  /// call.
  bool _ensureInitialized() {
    if (_initialized) return true;
    if (_initFailed) return false;
    try {
      _user32 = DynamicLibrary.open("user32.dll");
      _kernel32 = DynamicLibrary.open("kernel32.dll");
      _bindUser32Functions();
      _bindKernel32Functions();
      _initialized = true;
      return true;
    } catch (e) {
      debugPrint("Error _ensureInitialized $e");
      _initFailed = true;
      return false;
    }
  }

  // ── User32 bindings ─────────────────────────────────────────────────

  late final int Function(Pointer) _openClipboard;
  late final int Function() _closeClipboard;
  late final int Function() _emptyClipboard;
  late final int Function(int) _isClipboardFormatAvailable;
  late final Pointer Function(int) _getClipboardData;
  late final Pointer Function(int, Pointer) _setClipboardData;
  late final int Function(Pointer<Utf16>) _registerClipboardFormatW;

  void _bindUser32Functions() {
    _openClipboard = _user32.lookupFunction<Int32 Function(Pointer), int Function(Pointer)>("OpenClipboard");

    _closeClipboard = _user32.lookupFunction<Int32 Function(), int Function()>("CloseClipboard");

    _emptyClipboard = _user32.lookupFunction<Int32 Function(), int Function()>("EmptyClipboard");

    _isClipboardFormatAvailable = _user32.lookupFunction<Int32 Function(Uint32), int Function(int)>("IsClipboardFormatAvailable");

    _getClipboardData = _user32.lookupFunction<Pointer Function(Uint32), Pointer Function(int)>("GetClipboardData");

    _setClipboardData = _user32.lookupFunction<Pointer Function(Uint32, Pointer), Pointer Function(int, Pointer)>("SetClipboardData");

    _registerClipboardFormatW = _user32.lookupFunction<Uint32 Function(Pointer<Utf16>), int Function(Pointer<Utf16>)>("RegisterClipboardFormatW");
  }

  // ── Kernel32 bindings ────────────────────────────────────────────────

  late final Pointer Function(int, int) _globalAlloc;
  late final Pointer Function(Pointer) _globalFree;
  late final Pointer Function(Pointer) _globalLock;
  late final int Function(Pointer) _globalUnlock;
  late final int Function() _getLastError;

  void _bindKernel32Functions() {
    _globalAlloc = _kernel32.lookupFunction<Pointer Function(Uint32, IntPtr), Pointer Function(int, int)>("GlobalAlloc");

    _globalFree = _kernel32.lookupFunction<Pointer Function(Pointer), Pointer Function(Pointer)>("GlobalFree");

    _globalLock = _kernel32.lookupFunction<Pointer Function(Pointer), Pointer Function(Pointer)>("GlobalLock");

    _globalUnlock = _kernel32.lookupFunction<Int32 Function(Pointer), int Function(Pointer)>("GlobalUnlock");

    // GetLastError is exported by kernel32.dll, NOT user32.dll. Looking it
    // up in user32 fails with ERROR_PROC_NOT_FOUND (127), which silently
    // broke _ensureInitialized() and disabled every clipboard feature on
    // Windows.
    _getLastError = _kernel32.lookupFunction<Uint32 Function(), int Function()>("GetLastError");
  }

  // ── Win32 constants ──────────────────────────────────────────────────

  static const int _false = 0;
  static const int _gmemMoveable = 0x0002;
  static final Pointer _nullPointer = Pointer.fromAddress(0);

  // ── HTML clipboard format registration ───────────────────────────────

  /// Nom du format clipboard HTML tel que défini par Microsoft.
  /// Voir https://learn.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format
  static const String _htmlFormatName = "HTML Format";

  int? _cfHtml;

  /// Enregistre le format clipboard "HTML Format" une seule fois et le met en cache.
  /// Réessaie si la précédente tentative a échoué (le cache null est réévaluable).
  /// Retourne `null` si l'enregistrement échoue.
  int? _registerHtmlClipboardFormat() {
    final existing = _cfHtml;
    if (existing != null) return existing;

    final formatNamePtr = _htmlFormatName.toNativeUtf16(allocator: calloc);
    try {
      final formatId = _registerClipboardFormatW(formatNamePtr);
      if (formatId == 0) return null;
      _cfHtml = formatId;
      return formatId;
    } finally {
      calloc.free(formatNamePtr);
    }
  }

  // ── Platform interface ───────────────────────────────────────────────

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async {
    if (!_ensureInitialized()) return false;
    return {
      QuillNativeBridgeFeature.getClipboardHtml,
      QuillNativeBridgeFeature.copyHtmlToClipboard,
      QuillNativeBridgeFeature.getClipboardText,
      QuillNativeBridgeFeature.copyTextToClipboard,
      QuillNativeBridgeFeature.getClipboardMarkdown,
      QuillNativeBridgeFeature.copyMarkdownToClipboard,
    }.contains(feature);
  }

  // ── Clipboard HTML read ───────────────────────────────────────────────

  /// Lit le contenu HTML du presse-papiers Windows.
  ///
  /// Utilise l'API clipboard Win32 directement. Le format HTML est enregistré
  /// une seule fois et mis en cache pour la durée de vie du processus.
  ///
  /// Voir [Windows GetClipboardData() docs](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclipboarddata)
  @override
  Future<String?> getClipboardHtml() async {
    if (!_ensureInitialized()) return null;
    if (_openClipboard(_nullPointer) == _false) {
      assert(false, "Échec d'ouverture du clipboard. Erreur: ${_getLastError()}");
      return null;
    }

    try {
      final htmlFormatId = _registerHtmlClipboardFormat();
      if (htmlFormatId == null) {
        assert(false, "Échec d'enregistrement du format clipboard HTML.");
        return null;
      }

      if (_isClipboardFormatAvailable(htmlFormatId) == _false) {
        return null;
      }

      final clipboardDataHandle = _getClipboardData(htmlFormatId);
      if (clipboardDataHandle == _nullPointer) {
        assert(false, "Échec de lecture du clipboard. Erreur: ${_getLastError()}");
        return null;
      }

      final lockedPointer = _globalLock(clipboardDataHandle);
      if (lockedPointer == _nullPointer) {
        assert(false, "Échec de verrouillage mémoire globale. Erreur: ${_getLastError()}");
        return null;
      }

      try {
        final windowsHtmlWithMetadata = lockedPointer.cast<Utf8>().toDartString();
        return stripWindowsHtmlDescriptionHeaders(windowsHtmlWithMetadata);
      } finally {
        _globalUnlock(clipboardDataHandle);
      }
    } finally {
      _closeClipboard();
    }
  }

  // ── Clipboard HTML write ─────────────────────────────────────────────

  /// Copie du contenu HTML dans le presse-papiers Windows.
  ///
  /// Construit les en-têtes du format clipboard HTML Windows et écrit
  /// le contenu combiné dans le clipboard.
  ///
  /// Voir [Windows SetClipboardData() docs](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclipboarddata)
  @override
  Future<void> copyHtmlToClipboard(String html) async {
    if (!_ensureInitialized()) return;
    if (_openClipboard(_nullPointer) == _false) {
      assert(false, "Échec d'ouverture du clipboard. Erreur: ${_getLastError()}");
      return;
    }

    final windowsClipboardHtml = constructWindowsHtmlDescriptionHeaders(html);
    final htmlPointer = windowsClipboardHtml.toNativeUtf8(allocator: calloc);

    try {
      if (_emptyClipboard() == _false) {
        assert(false, "Échec de vidage du clipboard. Erreur: ${_getLastError()}");
        return;
      }

      final htmlFormatId = _registerHtmlClipboardFormat();
      if (htmlFormatId == null) {
        assert(false, "Échec d'enregistrement du format HTML. Erreur: ${_getLastError()}");
        return;
      }

      final htmlSize = (htmlPointer.length + 1) * sizeOf<Uint8>();
      final clipboardMemoryHandle = _globalAlloc(_gmemMoveable, htmlSize);

      if (clipboardMemoryHandle == _nullPointer) {
        assert(false, "Échec d'allocation mémoire pour le clipboard. Erreur: ${_getLastError()}");
        return;
      }

      final lockedPointer = _globalLock(clipboardMemoryHandle);
      if (lockedPointer == _nullPointer) {
        _globalFree(clipboardMemoryHandle);
        assert(false, "Échec de verrouillage mémoire globale. Erreur: ${_getLastError()}");
        return;
      }

      final sourcePointer = htmlPointer.cast<Uint8>();
      final targetPointer = lockedPointer.cast<Uint8>();

      // Copie octet par octet du contenu HTML
      for (var i = 0; i < htmlPointer.length; i++) {
        targetPointer[i] = (sourcePointer + i).value;
      }

      // Terminateur nul
      (targetPointer + htmlPointer.length).value = 0;

      _globalUnlock(clipboardMemoryHandle);

      final result = _setClipboardData(htmlFormatId, clipboardMemoryHandle);
      if (result == _nullPointer) {
        // Échec de SetClipboardData — on doit libérer la mémoire nous-mêmes
        _globalFree(clipboardMemoryHandle);
        assert(false, "Échec d'écriture dans le clipboard. Erreur: ${_getLastError()}");
      }
      // Si SetClipboardData a réussi, Windows possède la mémoire — NE PAS libérer
    } finally {
      _closeClipboard();
      calloc.free(htmlPointer);
    }
  }

  // ── Clipboard text read ──────────────────────────────────────────────

  static const int _cfUnicodeText = 13;

  /// Lit le texte brut du presse-papiers Windows.
  @override
  Future<String?> getClipboardText() async {
    if (!_ensureInitialized()) return null;
    if (_openClipboard(_nullPointer) == _false) {
      return null;
    }
    try {
      if (_isClipboardFormatAvailable(_cfUnicodeText) == _false) {
        return null;
      }
      final clipboardDataHandle = _getClipboardData(_cfUnicodeText);
      if (clipboardDataHandle == _nullPointer) {
        return null;
      }
      final lockedPointer = _globalLock(clipboardDataHandle);
      if (lockedPointer == _nullPointer) {
        return null;
      }
      try {
        return lockedPointer.cast<Utf16>().toDartString();
      } finally {
        _globalUnlock(clipboardDataHandle);
      }
    } finally {
      _closeClipboard();
    }
  }

  // ── Clipboard text write ─────────────────────────────────────────────

  /// Copie du texte brut dans le presse-papiers Windows.
  @override
  Future<void> copyTextToClipboard(String text) async {
    if (!_ensureInitialized()) return;
    if (_openClipboard(_nullPointer) == _false) {
      return;
    }
    final textPointer = text.toNativeUtf16(allocator: calloc);
    try {
      if (_emptyClipboard() == _false) {
        return;
      }
      final textSize = (textPointer.length + 1) * 2;
      final clipboardMemoryHandle = _globalAlloc(_gmemMoveable, textSize);
      if (clipboardMemoryHandle == _nullPointer) {
        return;
      }
      final lockedPointer = _globalLock(clipboardMemoryHandle);
      if (lockedPointer == _nullPointer) {
        _globalFree(clipboardMemoryHandle);
        return;
      }
      final sourcePointer = textPointer.cast<Uint8>();
      final targetPointer = lockedPointer.cast<Uint8>();
      for (var i = 0; i < textSize; i++) {
        targetPointer[i] = (sourcePointer + i).value;
      }
      _globalUnlock(clipboardMemoryHandle);
      final result = _setClipboardData(_cfUnicodeText, clipboardMemoryHandle);
      if (result == _nullPointer) {
        _globalFree(clipboardMemoryHandle);
      }
    } finally {
      _closeClipboard();
      calloc.free(textPointer);
    }
  }

  // ── Clipboard Markdown format registration ───────────────────────────

  /// Nom du format clipboard Markdown tel qu'enregistré par VS Code, Obsidian, etc.
  static const String _markdownFormatName = "text/markdown";

  int? _cfMarkdown;

  /// Enregistre le format clipboard "text/markdown" une seule fois et le met en cache.
  /// Réessaie si la précédente tentative a échoué (le cache null est réévaluable).
  /// Retourne `null` si l'enregistrement échoue.
  int? _registerMarkdownClipboardFormat() {
    final existing = _cfMarkdown;
    if (existing != null) return existing;

    final formatNamePtr = _markdownFormatName.toNativeUtf16(allocator: calloc);
    try {
      final formatId = _registerClipboardFormatW(formatNamePtr);
      if (formatId == 0) return null;
      _cfMarkdown = formatId;
      return formatId;
    } finally {
      calloc.free(formatNamePtr);
    }
  }

  // ── Clipboard Markdown read ──────────────────────────────────────────

  /// Lit le contenu Markdown du presse-papiers Windows.
  ///
  /// Utilise le format clipboard "text/markdown" (même format que VS Code, Obsidian).
  /// Le contenu est stocké en UTF-8 sans en-têtes — texte brut uniquement.
  @override
  Future<String?> getClipboardMarkdown() async {
    if (!_ensureInitialized()) return null;
    if (_openClipboard(_nullPointer) == _false) {
      assert(false, "Échec d'ouverture du clipboard. Erreur: ${_getLastError()}");
      return null;
    }

    try {
      final markdownFormatId = _registerMarkdownClipboardFormat();
      if (markdownFormatId == null) {
        assert(false, "Échec d'enregistrement du format clipboard Markdown.");
        return null;
      }

      if (_isClipboardFormatAvailable(markdownFormatId) == _false) {
        return null;
      }

      final clipboardDataHandle = _getClipboardData(markdownFormatId);
      if (clipboardDataHandle == _nullPointer) {
        assert(false, "Échec de lecture du clipboard Markdown. Erreur: ${_getLastError()}");
        return null;
      }

      final lockedPointer = _globalLock(clipboardDataHandle);
      if (lockedPointer == _nullPointer) {
        assert(false, "Échec de verrouillage mémoire globale. Erreur: ${_getLastError()}");
        return null;
      }

      try {
        // Le format text/markdown est stocké en UTF-8 (comme le format HTML)
        return lockedPointer.cast<Utf8>().toDartString();
      } finally {
        _globalUnlock(clipboardDataHandle);
      }
    } finally {
      _closeClipboard();
    }
  }

  // ── Clipboard Markdown write ─────────────────────────────────────────

  /// Copie du contenu Markdown dans le presse-papiers Windows.
  ///
  /// Écrit le Markdown dans le format "text/markdown" (UTF-8, sans en-têtes).
  /// Contrairement au HTML, pas de construction d'en-têtes — texte brut uniquement.
  @override
  Future<void> copyMarkdownToClipboard(String markdown) async {
    if (!_ensureInitialized()) return;
    if (_openClipboard(_nullPointer) == _false) {
      assert(false, "Échec d'ouverture du clipboard. Erreur: ${_getLastError()}");
      return;
    }

    final markdownPointer = markdown.toNativeUtf8(allocator: calloc);

    try {
      if (_emptyClipboard() == _false) {
        assert(false, "Échec de vidage du clipboard. Erreur: ${_getLastError()}");
        return;
      }

      final markdownFormatId = _registerMarkdownClipboardFormat();
      if (markdownFormatId == null) {
        assert(false, "Échec d'enregistrement du format Markdown. Erreur: ${_getLastError()}");
        return;
      }

      final markdownSize = (markdownPointer.length + 1) * sizeOf<Uint8>();
      final clipboardMemoryHandle = _globalAlloc(_gmemMoveable, markdownSize);

      if (clipboardMemoryHandle == _nullPointer) {
        assert(false, "Échec d'allocation mémoire pour le clipboard. Erreur: ${_getLastError()}");
        return;
      }

      final lockedPointer = _globalLock(clipboardMemoryHandle);
      if (lockedPointer == _nullPointer) {
        _globalFree(clipboardMemoryHandle);
        assert(false, "Échec de verrouillage mémoire globale. Erreur: ${_getLastError()}");
        return;
      }

      final sourcePointer = markdownPointer.cast<Uint8>();
      final targetPointer = lockedPointer.cast<Uint8>();

      // Copie octet par octet du contenu Markdown
      for (var i = 0; i < markdownPointer.length; i++) {
        targetPointer[i] = (sourcePointer + i).value;
      }

      // Terminateur nul
      (targetPointer + markdownPointer.length).value = 0;

      _globalUnlock(clipboardMemoryHandle);

      final result = _setClipboardData(markdownFormatId, clipboardMemoryHandle);
      if (result == _nullPointer) {
        // Échec de SetClipboardData — on doit libérer la mémoire nous-mêmes
        _globalFree(clipboardMemoryHandle);
        assert(false, "Échec d'écriture Markdown dans le clipboard. Erreur: ${_getLastError()}");
      }
      // Si SetClipboardData a réussi, Windows possède la mémoire — NE PAS libérer
    } finally {
      _closeClipboard();
      calloc.free(markdownPointer);
    }
  }
}
