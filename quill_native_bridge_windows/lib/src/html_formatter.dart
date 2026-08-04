// Construit les en-têtes de description du format clipboard HTML Windows.
//
// Le presse-papiers Windows exige des en-têtes avec les offsets en bytes UTF-8
// pour que les applications puissent localiser le fragment HTML dans le contenu.
//
// Voir [HTML Clipboard Format](https://learn.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format)

const _kStartBodyTag = "<body>";
const _kEndBodyTag = "</body>";
const _kStartHtmlTag = "<html>";
const _kEndHtmlTag = "</html>";

const _kStartFragmentComment = "<!--StartFragment-->";
const _kEndFragmentComment = "<!--EndFragment-->";

/// Construit les en-têtes de description Windows pour le HTML du clipboard.
///
/// Windows exige que le HTML soit accompagné de métadonnées décrivant les offsets
/// en bytes UTF-8 des différentes sections (StartHTML, EndHTML, StartFragment,
/// EndFragment).
///
/// Les offsets sont calculés en **bytes UTF-8** et non en caractères, conformément
/// à la spécification Microsoft.
///
/// [html] Le contenu HTML à placer dans le clipboard.
///
/// Retourne le HTML complet avec les en-têtes de description Windows.
String constructWindowsHtmlDescriptionHeaders(String html) {
  final htmlBodyContent = _extractBodyContent(html);

  // Version 1.0 supportée sur Windows 10 20H2 et versions ultérieures.
  // StartSelection et EndSelection sont optionnels et non inclus.
  // Voir https://learn.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format#description-headers-and-offsets
  const version = "1.0";

  // Template avec des valeurs d'offset invalides temporaires (même longueur que les finales)
  // pour calculer les positions correctes après insertion.
  // Important : les placeholders "0001"-"0004" doivent avoir la même longueur que
  // les valeurs finales (4 chiffres) pour que les offsets restent valides.
  final invalidHeaderHtmlTemplate =
      "Version:$version\n"
      "StartHTML:0001\n"
      "EndHTML:0002\n"
      "StartFragment:0003\n"
      "EndFragment:0004\n"
      "<html>$_kStartFragmentComment<body>$htmlBodyContent</body>$_kEndFragmentComment</html>\n";

  // Calcul des offsets en bytes UTF-8 (pas en caractères !)
  final templateBytes = invalidHeaderHtmlTemplate.codeUnits;

  final startHtmlPos =
      _indexOfBytes(templateBytes, _kStartHtmlTag.codeUnits) +
      _kStartHtmlTag.length;
  final endHtmlPos = _indexOfBytes(templateBytes, _kEndHtmlTag.codeUnits);
  final startFragment =
      _indexOfBytes(templateBytes, _kStartFragmentComment.codeUnits) +
      _kStartFragmentComment.length;
  final endFragment = _indexOfBytes(
    templateBytes,
    _kEndFragmentComment.codeUnits,
  );

  final result = invalidHeaderHtmlTemplate
      .replaceFirst("0001", _formatPosition(startHtmlPos))
      .replaceFirst("0002", _formatPosition(endHtmlPos))
      .replaceFirst("0003", _formatPosition(startFragment))
      .replaceFirst("0004", _formatPosition(endFragment));

  return result;
}

/// Formate un offset en string sur 4 chiffres avec zéros en tête.
///
/// La spécification Windows exige des offsets sur au moins 4 chiffres.
/// La valeur -1 est utilisée pour signaler un offset absent.
String _formatPosition(int position) {
  if (position == -1) return position.toString();
  return position.toString().padLeft(4, "0");
}

/// Trouve l'index en bytes UTF-8 de [needle] dans [haystack].
///
/// Les offsets du format clipboard HTML Windows sont en bytes, pas en caractères.
/// Pour du contenu ASCII pur, les offsets en caractères et en bytes coïncident,
/// mais pour du contenu Unicode (caractères multi-octets), seuls les offsets en
/// bytes sont corrects.
int _indexOfBytes(List<int> haystack, List<int> needle) {
  if (needle.isEmpty) return 0;
  if (needle.length > haystack.length) return -1;

  for (var i = 0; i <= haystack.length - needle.length; i++) {
    var found = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        found = false;
        break;
      }
    }
    if (found) return i;
  }
  return -1;
}

/// Extrait le contenu entre les balises `<body>` et `</body>` du HTML.
///
/// Si les balises `<body>` et `</body>` sont présentes, retourne le contenu
/// entre les deux. Sinon, retourne le HTML complet sans les espaces de début/fin.
///
/// La recherche est insensible à la casse mais les offsets sont calculés
/// sur le HTML original pour préserver la casse du contenu.
String _extractBodyContent(String html) {
  final lowerHtml = html.toLowerCase();
  final startBodyIndex = lowerHtml.indexOf(_kStartBodyTag);
  final endBodyIndex = lowerHtml.indexOf(_kEndBodyTag);

  if (startBodyIndex != -1 &&
      endBodyIndex != -1 &&
      endBodyIndex > startBodyIndex) {
    // Les offsets sont calculés sur lowerHtml (insensible à la casse) mais
    // on extrait le contenu du HTML original pour préserver la casse réelle.
    final bodyContentStartIndex = startBodyIndex + _kStartBodyTag.length;
    return html.substring(bodyContentStartIndex, endBodyIndex).trim();
  }

  return html.trim();
}
