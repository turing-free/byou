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
        textView.textColor = NSColor.black
        textView.backgroundColor = NSColor.white
        textView.textContainer?.containerSize = NSSize(width: 390, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = .width

        scrollView.documentView = textView

        self.view = scrollView
        self.view.frame = NSRect(x: 0, y: 0, width: 390, height: 400)
    }

    func setContent(_ content: String) {
        _ = self.view

        if let scrollView = self.view as? NSScrollView {
            let scrollViewWidth = scrollView.bounds.width
            self.textView.frame = NSRect(x: 0, y: 0, width: scrollViewWidth, height: scrollView.bounds.height)
            print("ScrollView width: \(scrollViewWidth), setting TextView frame to: \(self.textView.frame)")
        }

        print("PopoverViewController.setContent called, content length: \(content.count)")
        self.textView.string = content
        print("TextView string after set: \(self.textView.string.prefix(50))")
        print("TextView frame after setting content: \(self.textView.frame)")

        self.textView.needsDisplay = true
        self.view.needsDisplay = true
    }

    func clearContent() {
        _ = self.view
        self.textView.string = ""
    }
}
