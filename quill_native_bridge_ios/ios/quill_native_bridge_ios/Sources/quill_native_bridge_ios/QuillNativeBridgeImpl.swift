import Flutter
import Foundation

class QuillNativeBridgeImpl: QuillNativeBridgeApi {
  // TODO: Should not hardcode public.html and instead use UTType.html.identifier

  func getClipboardHtml(completion: @escaping (Result<String?, any Error>) -> Void) {
    loadClipboardData(typeIdentifier: "public.html") { data in
      completion(.success(data.flatMap { String(data: $0, encoding: .utf8) }))
    }
  }

  func copyHtmlToClipboard(html: String) throws {
    UIPasteboard.general.setValue(html, forPasteboardType: "public.html")
  }

  func getClipboardText(completion: @escaping (Result<String?, any Error>) -> Void) {
    let text = UIPasteboard.general.string
    completion(.success(text))
  }

  func copyTextToClipboard(text: String) throws {
    UIPasteboard.general.string = text
  }

  private func loadClipboardData(
    typeIdentifier: String, completion: @escaping (Data?) -> Void
  ) {
    guard
      let provider = UIPasteboard.general.itemProviders.first(where: {
        $0.hasItemConformingToTypeIdentifier(typeIdentifier)
      })
    else {
      completion(nil)
      return
    }
    provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, _ in
      // Intentionally ignores load errors. Consumers distinguish only whether
      // a representation was obtained.
      completion(data)
    }
  }
}