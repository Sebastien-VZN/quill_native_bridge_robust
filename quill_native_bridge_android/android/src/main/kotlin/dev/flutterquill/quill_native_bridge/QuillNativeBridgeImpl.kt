package dev.flutterquill.quill_native_bridge

import android.content.Context
import dev.flutterquill.quill_native_bridge.clipboard.ClipboardRichTextHandler
import dev.flutterquill.quill_native_bridge.generated.QuillNativeBridgeApi

class QuillNativeBridgeImpl(
    private val context: Context,
) : QuillNativeBridgeApi {
    override fun getClipboardHtml(): String? = ClipboardRichTextHandler.getClipboardHtml(context)

    override fun copyHtmlToClipboard(html: String) = ClipboardRichTextHandler.copyHtmlToClipboard(context, html)

    override fun getClipboardText(): String? = ClipboardRichTextHandler.getClipboardText(context)

    override fun copyTextToClipboard(text: String) = ClipboardRichTextHandler.copyTextToClipboard(context, text)

    override fun getClipboardMarkdown(): String? = ClipboardRichTextHandler.getClipboardMarkdown(context)

    override fun copyMarkdownToClipboard(markdown: String) = ClipboardRichTextHandler.copyMarkdownToClipboard(context, markdown)
}