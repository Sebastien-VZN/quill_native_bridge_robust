// Supprime les en-têtes de description du format clipboard HTML Windows.
//
// Le format clipboard HTML de Windows inclut des métadonnées avant le contenu HTML :
// Version, StartHTML, EndHTML, StartFragment, EndFragment, etc.
// Ces en-têtes ne sont pas du HTML valide et doivent être retirés pour le parsing.
//
// Voir [HTML Clipboard Format](https://learn.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format)

/// Noms des clés d'en-tête du format clipboard HTML Windows.
const _kWindowsDescriptionHeaders = {
  "Version",
  "StartHTML",
  "EndHTML",
  "StartFragment",
  "EndFragment",
  "StartSelection",
  "EndSelection",
};

/// Supprime les en-têtes de description Windows du HTML du clipboard.
///
/// Les en-têtes comme `Version:0.9`, `StartHTML:0000000105`, etc. précèdent
/// le contenu HTML réel et doivent être retirés pour un parsing correct.
///
/// Exemple d'entrée :
/// ```html
/// Version:0.9
/// StartHTML:0000000105
/// EndHTML:0000000634
/// StartFragment:0000000141
/// EndFragment:0000000598
/// <html>
/// <body>
/// <!--StartFragment--><div>Example HTML</div><!--EndFragment-->
/// </body>
/// </html>
/// ```
///
/// Retourne le HTML nettoyé sans les en-têtes de description.
String stripWindowsHtmlDescriptionHeaders(String html) {
  final lines = html.split("\n");
  final cleanedLines = <String>[];

  for (final line in lines) {
    // Arrêt dès qu'on atteint le contenu HTML réel
    if (line.toLowerCase().startsWith("<html>")) {
      cleanedLines.add(line);
      // Ajouter les lignes restantes telles quelles
      final remainingIndex = lines.indexOf(line) + 1;
      if (remainingIndex < lines.length) {
        cleanedLines.addAll(lines.sublist(remainingIndex));
      }
      break;
    }

    final isWindowsHeader = _kWindowsDescriptionHeaders.any(
      (metadataKey) => line.startsWith("$metadataKey:"),
    );
    if (!isWindowsHeader) {
      cleanedLines.add(line);
    }
  }

  return cleanedLines.join("\n");
}
