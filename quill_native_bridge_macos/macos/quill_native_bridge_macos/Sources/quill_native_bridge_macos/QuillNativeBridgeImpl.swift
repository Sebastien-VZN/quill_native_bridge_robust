import FlutterMacOS
import Foundation

class QuillNativeBridgeImpl: QuillNativeBridgeApi {
  func getClipboardHtml() throws -> String? {
    guard let htmlData = NSPasteboard.general.data(forType: .html) else {
      return nil
    }
    let html = String(data: htmlData, encoding: .utf8)
    return html
  }

  func copyHtmlToClipboard(html: String) throws {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(html, forType: .html)
  }

  func getClipboardText() throws -> String? {
    return NSPasteboard.general.string(forType: .string)
  }

  func copyTextToClipboard(text: String) throws {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
  }

  private static let mdType = NSPasteboard.PasteboardType(
    "net.daringfireball.markdown")

  func getClipboardMarkdown() throws -> String? {
    return NSPasteboard.general.string(forType: Self.mdType)
  }

  func copyMarkdownToClipboard(markdown: String) throws {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(markdown, forType: Self.mdType)
  }
}
