import Cocoa
import AppKit

class PopoverViewController: NSViewController {

    private var originalTextView: NSTextView!
    private var translatedTextView: NSTextView!
    private var originalScrollView: NSScrollView!
    private var translatedScrollView: NSScrollView!
    private var originalContainer: NSView!
    private var translatedContainer: NSView!

    override func loadView() {
        let mainView = NSView(frame: NSRect(x: 0, y: 0, width: 390, height: 400))
        mainView.wantsLayer = true
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        originalContainer = NSView()
        originalContainer.wantsLayer = true
        originalContainer.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        originalContainer.translatesAutoresizingMaskIntoConstraints = false
        
        translatedContainer = NSView()
        translatedContainer.wantsLayer = true
        translatedContainer.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
        translatedContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let originalLabel = NSTextField()
        originalLabel.stringValue = "原文"
        originalLabel.isEditable = false
        originalLabel.isBordered = false
        originalLabel.backgroundColor = .clear
        originalLabel.font = NSFont.systemFont(ofSize: 11)
        originalLabel.textColor = NSColor.secondaryLabelColor
        originalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let translatedLabel = NSTextField()
        translatedLabel.stringValue = "译文"
        translatedLabel.isEditable = false
        translatedLabel.isBordered = false
        translatedLabel.backgroundColor = .clear
        translatedLabel.font = NSFont.systemFont(ofSize: 11)
        translatedLabel.textColor = NSColor.secondaryLabelColor
        translatedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        originalScrollView = NSScrollView()
        originalScrollView.hasVerticalScroller = true
        originalScrollView.hasHorizontalScroller = false
        originalScrollView.autohidesScrollers = true
        originalScrollView.borderType = .noBorder
        originalScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        originalTextView = NSTextView()
        originalTextView.isEditable = false
        originalTextView.isSelectable = true
        originalTextView.isFieldEditor = false
        originalTextView.font = NSFont.systemFont(ofSize: 12)
        originalTextView.textColor = NSColor.labelColor
        originalTextView.backgroundColor = NSColor.clear
        originalTextView.textContainer?.containerSize = NSSize(width: 390, height: CGFloat.greatestFiniteMagnitude)
        originalTextView.textContainer?.widthTracksTextView = true
        originalTextView.textContainer?.heightTracksTextView = false
        originalTextView.isVerticallyResizable = true
        originalTextView.isHorizontallyResizable = false
        originalTextView.autoresizingMask = .width
        
        originalScrollView.documentView = originalTextView
        
        translatedScrollView = NSScrollView()
        translatedScrollView.hasVerticalScroller = true
        translatedScrollView.hasHorizontalScroller = false
        translatedScrollView.autohidesScrollers = true
        translatedScrollView.borderType = .noBorder
        translatedScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        translatedTextView = NSTextView()
        translatedTextView.isEditable = false
        translatedTextView.isSelectable = true
        translatedTextView.isFieldEditor = false
        translatedTextView.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        translatedTextView.textColor = NSColor.labelColor
        translatedTextView.backgroundColor = NSColor.clear
        translatedTextView.textContainer?.containerSize = NSSize(width: 390, height: CGFloat.greatestFiniteMagnitude)
        translatedTextView.textContainer?.widthTracksTextView = true
        translatedTextView.textContainer?.heightTracksTextView = false
        translatedTextView.isVerticallyResizable = true
        translatedTextView.isHorizontallyResizable = false
        translatedTextView.autoresizingMask = .width
        
        translatedScrollView.documentView = translatedTextView
        
        originalContainer.addSubview(originalLabel)
        originalContainer.addSubview(originalScrollView)
        translatedContainer.addSubview(translatedLabel)
        translatedContainer.addSubview(translatedScrollView)
        
        mainView.addSubview(originalContainer)
        mainView.addSubview(translatedContainer)
        
        self.view = mainView
        
        NSLayoutConstraint.activate([
            originalContainer.topAnchor.constraint(equalTo: mainView.topAnchor),
            originalContainer.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            originalContainer.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            originalContainer.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.35),
            
            translatedContainer.topAnchor.constraint(equalTo: originalContainer.bottomAnchor),
            translatedContainer.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            translatedContainer.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            translatedContainer.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            
            originalLabel.topAnchor.constraint(equalTo: originalContainer.topAnchor, constant: 10),
            originalLabel.leadingAnchor.constraint(equalTo: originalContainer.leadingAnchor, constant: 20),
            originalLabel.trailingAnchor.constraint(equalTo: originalContainer.trailingAnchor, constant: -20),
            originalLabel.heightAnchor.constraint(equalToConstant: 20),
            
            originalScrollView.topAnchor.constraint(equalTo: originalLabel.bottomAnchor, constant: 5),
            originalScrollView.leadingAnchor.constraint(equalTo: originalContainer.leadingAnchor, constant: 20),
            originalScrollView.trailingAnchor.constraint(equalTo: originalContainer.trailingAnchor, constant: -20),
            originalScrollView.bottomAnchor.constraint(equalTo: originalContainer.bottomAnchor, constant: -10),
            
            translatedLabel.topAnchor.constraint(equalTo: translatedContainer.topAnchor, constant: 10),
            translatedLabel.leadingAnchor.constraint(equalTo: translatedContainer.leadingAnchor, constant: 20),
            translatedLabel.trailingAnchor.constraint(equalTo: translatedContainer.trailingAnchor, constant: -20),
            translatedLabel.heightAnchor.constraint(equalToConstant: 20),
            
            translatedScrollView.topAnchor.constraint(equalTo: translatedLabel.bottomAnchor, constant: 5),
            translatedScrollView.leadingAnchor.constraint(equalTo: translatedContainer.leadingAnchor, constant: 20),
            translatedScrollView.trailingAnchor.constraint(equalTo: translatedContainer.trailingAnchor, constant: -20),
            translatedScrollView.bottomAnchor.constraint(equalTo: translatedContainer.bottomAnchor, constant: -10)
        ])
    }
    
    func setOriginalText(_ text: String) {
        originalTextView.string = text
    }
    
    func setTranslatedText(_ text: String) {
        translatedTextView.string = text
    }

    func setContent(_ content: String) {
        _ = self.view
        
        let components = content.components(separatedBy: "\n\n---\n\n")
        if components.count >= 2 {
            setOriginalText(components[0])
            setTranslatedText(components[1])
        } else {
            setOriginalText(content)
            setTranslatedText("")
        }
    }

    func clearContent() {
        _ = self.view
        originalTextView.string = ""
        translatedTextView.string = ""
    }
}