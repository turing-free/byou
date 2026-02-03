import Cocoa
import AppKit

class PopoverViewController: NSViewController {

    private var textView: NSTextView!

    override func loadView() {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder

        textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isFieldEditor = false
        textView.font = NSFont.systemFont(ofSize: 13)
        textView.textColor = NSColor.labelColor
        textView.backgroundColor = NSColor.clear
        textView.textContainer?.containerSize = NSSize(width: 400, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false

        scrollView.documentView = textView

        self.view = scrollView
        self.view.frame = NSRect(x: 0, y: 0, width: 400, height: 300)
    }

    func setContent(_ content: String) {
        DispatchQueue.main.async {
            self.textView.string = content
        }
    }

    func clearContent() {
        DispatchQueue.main.async {
            self.textView.string = ""
        }
    }
}
