# quill_native_bridge_robust — Traduction française du README

Fork durci et prêt pour la production de `quill_native_bridge` pour l'écosystème `flutter_quill`. Ce plugin fournit une interface fédérée robuste pour les opérations de presse-papiers textuelles sur toutes les principales plateformes.

## CHANGEMENT CRITIQUE : Suppression du support des médias

Il s'agit d'un **fork durci**. Le `quill_native_bridge` original incluait des fonctionnalités étendues de presse-papiers pour les médias/images (`getClipboardImage`, `saveImageToGallery`, `getClipboardFiles`, etc.). Sur la base d'une expérience approfondie en déploiement réel, **l'ensemble du sous-système média a été supprimé.**

### Pourquoi ce fork existe

L'implémentation originale des médias était fondamentalement défectueuse, mal testée et introduisait une instabilité significative. Nous avons pris la décision stratégique de supprimer ces fonctionnalités pour garantir la fiabilité des workflows d'édition de texte.

**Raisons de la suppression :**

1. **Fondamentalement défectueux** : Les opérations de presse-papiers pour les images étaient peu fiables sur toutes les plateformes.
   - Android : `ClipboardManager` avait un comportement incohérent avec les types MIME des images.
   - iOS : La gestion de `UIPasteboard` provoquait des fuites mémoire et des corruptions d'encodage.
   - Windows : Les opérations d'images basées sur FFI étaient fragiles et sujettes aux plantages.
2. **Mal testé** : Le plugin original manquait de couverture de tests adéquate pour les opérations sur les images. Les tests d'intégration pour les allers-retours d'images échouaient régulièrement en CI/CD.
3. **Risques de sécurité** : La méthode `getClipboardFiles` exposait des chemins de fichiers bruts depuis le presse-papiers système sans assainissement approprié, créant une vulnérabilité potentielle.
4. **Dépassement de périmètre** : Un pont de presse-papiers doit gérer le transfert de données, pas servir de gestionnaire de galerie ou de processeur d'images. Ces responsabilités relèvent de packages dédiés et spécialisés.
5. **Charge de maintenance** : Les fonctionnalités média nécessitaient un code complexe et spécifique à chaque plateforme (Kotlin, Swift, FFI, JS) qui se brisait fréquemment avec les mises à jour des OS. Leur suppression a considérablement réduit la surface d'attaque et les coûts de maintenance.

> **Remarque** : Si vous avez besoin de fonctionnalités de presse-papiers pour les images, nous recommandons d'utiliser des plugins dédiés comme `flutter_image_picker` ou `pasteboard` en complément de ce package. Ce plugin se concentre **exclusivement** sur le texte, le HTML et le Markdown.

## Fonctionnalités

- Texte brut (`text/plain`)
- HTML (`text/html`)
- Markdown (`text/markdown`) — ajouté sur les plateformes supportées
- Convertisseurs Delta — outils intégrés pour convertir directement le HTML/Markdown en Deltas Quill

## 8 fonctionnalités de l'API

| Fonctionnalité | Description |
|---|---|
| `isIOSSimulator` | Détecte si l'app tourne sur le simulateur iOS |
| `getClipboardHtml` | Lit le HTML du presse-papiers système |
| `copyHtmlToClipboard` | Copie du HTML dans le presse-papiers |
| `getClipboardText` | Lit le texte brut du presse-papiers |
| `copyTextToClipboard` | Copie du texte brut dans le presse-papiers |
| `getClipboardMarkdown` | Lit le Markdown du presse-papiers |
| `copyMarkdownToClipboard` | Copie du Markdown dans le presse-papiers |
| `isAppleSafari` | Détecte si le navigateur est Safari (Web uniquement) |

## Support des plateformes

| Plateforme | HTML | Texte | Markdown | Implémentation |
|---|:---:|:---:|:---:|---|
| Android | ✅ | ✅ | ✅ | Pigeon + Kotlin |
| iOS | ✅ | ✅ | ⚠️ | Pigeon + Swift |
| macOS | ✅ | ✅ | ⚠️ | Pigeon + Swift |
| Windows | ✅ | ✅ | ✅ | FFI Win32 |
| Linux | ✅ | ✅ | ✅ | xclip |
| Web | ✅ | ✅ | ⚠️ | Clipboard API |

Légende :
- ✅ : Supporté et fonctionnel
- ⚠️ : `isSupported()` retourne `true`, mais l'implémentation réelle des méthodes `getClipboardMarkdown`/`copyMarkdownToClipboard` est manquante côté plateforme — **l'appel direct déclenche `UnimplementedError`**. Voir la section Problèmes connus.

> **Note Web** : Sur Firefox, `isClipboardApiSupported` retourne `false`, ce qui fait que `isSupported()` retourne `false` pour HTML et Markdown. Les méthodes lancent `UnsupportedError` avec un message invitant à utiliser les Clipboard Events en fallback.

## Convertisseurs clipboard → Delta

Le bridge inclut deux convertisseurs découplés qui transforment les données brutes du presse-papiers en format Quill Delta :

- **HtmlToDelta** — ré-exporté depuis `flutter_quill_delta_from_html` v1.5.3. Zéro dépendance à `flutter_quill`.
- **MarkdownToDelta** — porté et découplé. Utilise des Maps brutes (`{"bold": true}`) au lieu de `FormatAttribute`.
  - Supporte le GitHub Flavored Markdown (strikethrough via `~~text~~`).
  - Médias supprimés : pas d'image, vidéo, règle horizontale, ni tableau.

```dart
import 'package:quill_native_bridge/quill_native_bridge.dart';

final htmlDelta = HtmlToDelta().convert(htmlString);
final mdDelta = MarkdownToDelta().convert(markdownString);
```

## Enum QuillNativeBridgeFeature

Les 8 fonctionnalités supportées :

```dart
enum QuillNativeBridgeFeature {
  isIOSSimulator,
  getClipboardHtml,
  copyHtmlToClipboard,
  getClipboardText,
  copyTextToClipboard,
  getClipboardMarkdown,
  copyMarkdownToClipboard,
  isAppleSafari,
}
```

## Corrections de bugs critiques

1. **PlaceholderImplementation crash** — toutes les méthodes renvoient des valeurs sûres (`false`/`null`/no-op) au lieu de `throw UnimplementedError`. Empêche les crashes quand `registerWith()` n'est pas encore appelé.
2. **Classe Android manquante** — `QuillNativeBridgeAndroid extends QuillNativeBridgePlatform` créée. Sans elle, le plugin ne s'enregistrait jamais sur Android.
3. **Stabilité `isSupported()`** — les méthodes Markdown étaient déclarées supportées mais non implémentées, causant des crashes `UnimplementedError`. Corrigé sur Android, Linux et Windows. **⚠️ iOS, macOS et Web déclarent toujours Markdown comme supporté dans `isSupported()` sans override des méthodes — bug ouvert.**
4. **Parité Linux** — ajout des overrides Markdown manquants sur Linux (xclip).
5. **Nettoyage Pigeon** — suppression de `dartTestOut` et `dartHostTestHandler` obsolètes (Pigeon v27+).
6. **Découverte des tests** — renommage des fichiers de test avec le suffixe `_test.dart`.

## Problèmes connus

- **Initialisation FFI impatiente sous Windows** — le constructeur charge `user32.dll` et `kernel32.dll` de manière eager dans `QuillNativeBridgeWindows()`. En cas d'échec, `registerWith()` échoue silencieusement et `PlaceholderImplementation` reste actif. Nécessite un pattern lazy-init.
- **Markdown sur iOS, macOS et Web** — `isSupported(QuillNativeBridgeFeature.getClipboardMarkdown)` retourne `true`, mais `getClipboardMarkdown()` et `copyMarkdownToClipboard()` ne sont pas override dans l'implémentation Dart de ces plateformes. L'appel direct lève `UnimplementedError`. Utiliser `isSupported()` comme garde-fou n'est **pas** suffisant — il faut également catcher ou éviter ces appels sur ces plateformes jusqu'à ce que les implémentations natives soient ajoutées.

## Structure du projet

Plugin Flutter fédéré standard avec 8 packages (7 + exemple) :

1. `quill_native_bridge` — package app-facing (API + convertisseurs)
2. `quill_native_bridge_platform_interface` — interface abstraite + PlaceholderImplementation
3. `quill_native_bridge_android` — Android (Pigeon + Kotlin)
4. `quill_native_bridge_ios` — iOS (Pigeon + Swift)
5. `quill_native_bridge_macos` — macOS (Pigeon + Swift)
6. `quill_native_bridge_windows` — Windows (FFI Win32)
7. `quill_native_bridge_linux` — Linux (xclip)
8. `quill_native_bridge_web` — Web (Clipboard API)

+ `quill_native_bridge/example` — application de démo