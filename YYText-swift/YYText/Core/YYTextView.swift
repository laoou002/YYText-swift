//
//  YYTextView.swift
//  JianZhiApp-swift
//
//  Created by 老欧 on 2022/4/20.
//

import UIKit
#if canImport(YYImage)
import YYImage
#endif

/**
 The YYTextViewDelegate protocol defines a set of optional methods you can use
 to receive editing-related messages for YYTextView objects.
 
 @discussion The API and behavior is similar to UIYYTextViewDelegate,
 see UIYYTextViewDelegate's documentation for more information.
 */
@objc public protocol YYTextViewDelegate: UIScrollViewDelegate {
    
    @objc optional func textViewShouldBeginEditing(_ textView: YYTextView) -> Bool
    @objc optional func textViewShouldEndEditing(_ textView: YYTextView) -> Bool
    @objc optional func textViewDidBeginEditing(_ textView: YYTextView)
    @objc optional func textViewDidEndEditing(_ textView: YYTextView)
    @objc optional func textView(_ textView: YYTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    @objc optional func textViewDidChange(_ textView: YYTextView)
    @objc optional func textViewDidChangeSelection(_ textView: YYTextView)
    @objc optional func textViewWordCountChange(_ textView: YYTextView, count: Int)
    @objc optional func textView(_ textView: YYTextView, shouldTap highlight: YYTextHighlight, in characterRange: NSRange) -> Bool
    @objc optional func textView(_ textView: YYTextView, didTap highlight: YYTextHighlight, in characterRange: NSRange, rect: CGRect)
    @objc optional func textView(_ textView: YYTextView, shouldLongPress highlight: YYTextHighlight, in characterRange: NSRange) -> Bool
    @objc optional func textView(_ textView: YYTextView, didLongPress highlight: YYTextHighlight, in characterRange: NSRange, rect: CGRect)
}

fileprivate let kDefaultUndoLevelMax: Int = 20

fileprivate let kAutoScrollMinimumDuration = 0.1
fileprivate let kLongPressMinimumDuration = 0.5
fileprivate let kLongPressAllowableMovement: Float = 10.0

fileprivate let kMagnifierRangedTrackFix: CGFloat = -6
fileprivate let kMagnifierRangedPopoverOffset: CGFloat = 4
fileprivate let kMagnifierRangedCaptureOffset: CGFloat = -6

fileprivate let kHighlightFadeDuration: TimeInterval = 0.15

fileprivate let kDefaultInset = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
fileprivate let kDefaultVerticalInset = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)

public enum TextGrabberDirection : UInt {
    case none = 0
    case start = 1
    case end = 2
}

public enum TextMoveDirection : UInt {
    case none = 0
    case left = 1
    case top = 2
    case right = 3
    case bottom = 4
}

/// An object that captures the state of the text view. Used for undo and redo.
fileprivate class YYTextViewUndoObject: NSObject {
    
    var text: NSAttributedString?
    var selectedRange: NSRange?
    
    override init() {
        super.init()
    }
    
    convenience init(text: NSAttributedString?, range: NSRange) {
        self.init()
        self.text = text ?? NSAttributedString()
        self.selectedRange = range
    }
}


/**
 The YYTextView class implements the behavior for a scrollable, multiline text region.
 
 @discussion The API and behavior is similar to UITextView, but provides more features:
 
 * It extends the CoreText attributes to support more text effects.
 * It allows to add UIImage, UIView and CALayer as text attachments.
 * It allows to add 'highlight' link to some range of text to allow user interact with.
 * It allows to add exclusion paths to control text container's shape.
 * It supports vertical form layout to display and edit CJK text.
 * It allows user to copy/paste image and attributed text from/to text view.
 * It allows to set an attributed text as placeholder.
 
 See NSAttributedStringExtension.swift for more convenience methods to set the attributes.
 See YYTextAttribute.swift and YYTextLayout.swift for more information.
 */
open class YYTextView: UIScrollView, UITextInput, UITextInputTraits, UIScrollViewDelegate, UIAlertViewDelegate, YYTextDebugTarget, YYTextKeyboardObserver, NSSecureCoding {
    
    public lazy var tokenizer: UITextInputTokenizer = UITextInputStringTokenizer(textInput: self)
        
    public var markedTextRange: UITextRange?
    
    @objc public static let textViewTextDidBeginEditingNotification = "TextViewTextDidBeginEditing"
    @objc public static let textViewTextDidChangeNotification = "TextViewTextDidChange"
    @objc public static let textViewTextDidEndEditingNotification = "TextViewTextDidEndEditing"
    
    // MARK: - Accessing the Delegate
    ///*****************************************************************************
    /// @name Accessing the Delegate
    ///*****************************************************************************
    @objc open weak override var delegate: UIScrollViewDelegate? {
        set {
            _outerDelegate = newValue as? YYTextViewDelegate
        }
        get {
            return _outerDelegate
        }
    }
    
    // MARK: - Configuring the Text Attributes
    ///*****************************************************************************
    /// @name Configuring the Text Attributes
    ///*****************************************************************************
    
    private var _text = ""
    /**
     The text displayed by the text view.
     Set a new value to this property also replaces the text in `attributedText`.
     Get the value returns the plain text in `attributedText`.
     */
    @objc public var text: String {
        set {
            if _text == newValue {
                return
            }
            _setText(newValue)
            
            state.selectedWithoutEdit = false
            state.deleteConfirm = false
            _endTouchTracking()
            _hideMenu()
            _resetUndoAndRedoStack()
            replace(YYTextRange(range: NSRange(location: 0, length: _innerText.length)), withText: _text)
        }
        get {
            return _text
        }
    }
    
    private lazy var _font: UIFont? = YYTextView._defaultFont
    /**
     The font of the text. Default is 12-point system font.
     Set a new value to this property also causes the new font to be applied to the entire `attributedText`.
     Get the value returns the font at the head of `attributedText`.
     */
    @objc public var font: UIFont? {
        set {
            if _font == newValue {
                return
            }
            _setFont(newValue)
            
            state.typingAttributesOnce = false
            _typingAttributesHolder.yy_font = newValue
            _innerText.yy_font = newValue
            _resetUndoAndRedoStack()
            _commitUpdate()
        }
        get {
            return _font
        }
    }
    
    private var _textColor: UIColor? = UIColor.black
    /**
     The color of the text. Default is black.
     Set a new value to this property also causes the new color to be applied to the entire `attributedText`.
     Get the value returns the color at the head of `attributedText`.
     */
    @objc public var textColor: UIColor? {
        set {
            if _textColor == newValue {
                return
            }
            _setTextColor(newValue)
            
            state.typingAttributesOnce = false
            _typingAttributesHolder.yy_color = newValue
            _innerText.yy_color = newValue
            _resetUndoAndRedoStack()
            _commitUpdate()
        }
        get {
            return _textColor
        }
    }
    
    private var _textAlignment = NSTextAlignment.natural
    /**
     The technique to use for aligning the text. Default is NSTextAlignmentNatural.
     Set a new value to this property also causes the new alignment to be applied to the entire `attributedText`.
     Get the value returns the alignment at the head of `attributedText`.
     */
    @objc public var textAlignment: NSTextAlignment {
        set {
            if _textAlignment == newValue {
                return
            }
            _setTextAlignment(newValue)
            
            _typingAttributesHolder.yy_alignment = newValue
            _innerText.yy_alignment = newValue
            _resetUndoAndRedoStack()
            _commitUpdate()
        }
        get {
            return _textAlignment
        }
    }
    
    private var _textVerticalAlignment = YYTextVerticalAlignment.top
    /**
     The text vertical aligmnent in container. Default is YYTextVerticalAlignmentTop.
     */
    @objc public var textVerticalAlignment: YYTextVerticalAlignment {
        set {
            if _textVerticalAlignment == newValue {
                return
            }
            willChangeValue(forKey: "textVerticalAlignment")
            _textVerticalAlignment = newValue
            didChangeValue(forKey: "textVerticalAlignment")
            _containerView.textVerticalAlignment = newValue
            _commitUpdate()
        }
        get {
            return _textVerticalAlignment
        }
    }
    
    private var _dataDetectorTypes = UIDataDetectorTypes.init(rawValue: 0)
    /**
     The types of data converted to clickable URLs in the text view. Default is UIDataDetectorTypeNone.
     The tap or long press action should be handled by delegate.
     */
    @objc public var dataDetectorTypes: UIDataDetectorTypes {
        set {
            if _dataDetectorTypes == newValue {
                return
            }
            _setDataDetectorTypes(newValue)
            let type = YYTextUtilities.textCheckingType(from: newValue)
            _dataDetector = type.rawValue != 0 ? try? NSDataDetector(types: type.rawValue) : nil
            _resetUndoAndRedoStack()
            _commitUpdate()
        }
        get {
            return _dataDetectorTypes
        }
    }
    
    private var _linkTextAttributes: [NSAttributedString.Key : Any]?
    /**
     The attributes to apply to links at normal state. Default is light blue color.
     When a range of text is detected by the `dataDetectorTypes`, this value would be
     used to modify the original attributes in the range.
     */
    @objc public var linkTextAttributes: [NSAttributedString.Key : Any]? {
        set {
            let dic1 = _linkTextAttributes as NSDictionary?, dic2 = newValue as NSDictionary?
            if dic1 == dic2 || dic1?.isEqual(dic2) ?? false {
                return
            }
            _setLinkTextAttributes(newValue)
            if _dataDetector != nil {
                _commitUpdate()
            }
        }
        get {
            return _linkTextAttributes
        }
    }
    
    private var _highlightTextAttributes: [NSAttributedString.Key : Any]?
    /**
     The attributes to apply to links at highlight state. Default is a gray border.
     When a range of text is detected by the `dataDetectorTypes` and the range was touched by user,
     this value would be used to modify the original attributes in the range.
     */
    @objc public var highlightTextAttributes: [NSAttributedString.Key : Any]? {
        set {
            let dic1 = _highlightTextAttributes as NSDictionary?, dic2 = newValue as NSDictionary?
            if dic1 == dic2 || dic1?.isEqual(dic2) ?? false {
                return
            }
            _sethighlightTextAttributes(newValue)
            if _dataDetector != nil {
                _commitUpdate()
            }
        }
        get {
            return _highlightTextAttributes
        }
    }
    
    private var _typingAttributes: [NSAttributedString.Key : Any]?
    /**
     The attributes to apply to new text being entered by the user.
     When the text view's selection changes, this value is reset automatically.
     */
    @objc public var typingAttributes: [NSAttributedString.Key : Any]? {
        set {
            _setTypingAttributes(newValue)
            state.typingAttributesOnce = true
            for (key, obj) in newValue ?? [:] {
                self._typingAttributesHolder.yy_set(attribute: key, value: obj)
            }
            _commitUpdate()
        }
        get {
            return _typingAttributes
        }
    }
    
    
    private var _attributedText = NSAttributedString()
    /**
     The styled text displayed by the text view.
     Set a new value to this property also replaces the value of the `text`, `font`, `textColor`,
     `textAlignment` and other properties in text view.
     
     @discussion It only support the attributes declared in CoreText and YYTextAttribute.
     See `NSAttributedStringExtension.swift` for more convenience methods to set the attributes.
     */
    @objc public var attributedText: NSAttributedString? {
        get {
            return _attributedText
        }
        set {
            if _attributedText == newValue {
                return
            }
            _setAttributedText(newValue)
            state.typingAttributesOnce = false
            
            let text = _attributedText as? NSMutableAttributedString
            if text?.length ?? 0 == 0 {
                replace(YYTextRange(range: NSRange(location: 0, length: _innerText.length)), withText: "")
                return
            }
            if let should = _outerDelegate?.textView?(self, shouldChangeTextIn: NSRange(location: 0, length: _innerText.length), replacementText: text?.string ?? "") {
                if !should {
                    return
                }
            }
            
            state.selectedWithoutEdit = false
            state.deleteConfirm = false
            _endTouchTracking()
            _hideMenu()
            
            _inputDelegate?.selectionWillChange(self)
            _inputDelegate?.textWillChange(self)
            _innerText = text!
            _parseText()
            _selectedTextRange = YYTextRange(range: NSRange(location: 0, length: _innerText.length))
            _inputDelegate?.textDidChange(self)
            _inputDelegate?.selectionDidChange(self)
            
            _setAttributedText(text)
            if _innerText.length > 0 {
                _typingAttributesHolder.yy_attributes = _innerText.yy_attributes(at: _innerText.length - 1)
            }
            
            _updateOuterProperties()
            _updateLayout()
            _updateSelectionView()
            
            if isFirstResponder {
                _scrollRangeToVisible(_selectedTextRange)
            }
            
            _outerDelegate?.textViewDidChange?(self)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YYTextView.textViewTextDidChangeNotification), object: self)
            
            if !state.insideUndoBlock {
                _resetUndoAndRedoStack()
            }
            checkWordCount()
        }
    }
    
    private var _textParser: YYTextParser?
    /**
     When `text` or `attributedText` is changed, the parser will be called to modify the text.
     It can be used to add code highlighting or emoticon replacement to text view.
     The default value is nil.
     
     See `YYTextParser` protocol for more information.
     */
    @objc public var textParser: YYTextParser? {
        set {
            if _textParser === newValue || _textParser?.isEqual(newValue) ?? false {
                return
            }
            _setYYTextParser(newValue)
            if textParser != nil && text != "" {
                replace(YYTextRange(range: NSRange(location: 0, length: text.length)), withText: text)
            }
            _resetUndoAndRedoStack()
            _commitUpdate()
        }
        get {
            return _textParser
        }
    }
    
    private var _maxWordCount: Int = 0
    /**
     最大字数
     */
    @objc public var maxWordCount: Int = 0 {
        didSet {
            checkWordCount()
        }
    }
    
    /**
     The current text layout in text view (readonly).
     It can be used to query the text layout information.
     */
    @objc public private(set) var textLayout: YYTextLayout? {
        set {
            
        }
        get {
            _updateIfNeeded()
            return _innerLayout
        }
    }
    
    
    // MARK: - Configuring the Placeholder
    ///*****************************************************************************
    /// @name Configuring the Placeholder
    ///*****************************************************************************
    
    private var _placeholderText: String?
    /**
     The placeholder text displayed by the text view (when the text view is empty).
     Set a new value to this property also replaces the text in `placeholderAttributedText`.
     Get the value returns the plain text in `placeholderAttributedText`.
     */
    @objc public var placeholderText: String? {
        set {
            if _placeholderAttributedText?.length ?? 0 > 0 {
                
                (_placeholderAttributedText as? NSMutableAttributedString)?.replaceCharacters(in: NSRange(location: 0, length: _placeholderAttributedText!.length), with: newValue ?? "")
                
                (_placeholderAttributedText as? NSMutableAttributedString)?.yy_font = placeholderFont
                (_placeholderAttributedText as? NSMutableAttributedString)?.yy_color = placeholderTextColor
            } else {
                if (newValue?.length ?? 0) > 0 {
                    let atr = NSMutableAttributedString(string: newValue!)
                    if _placeholderFont == nil {
                        _placeholderFont = _font ?? YYTextView._defaultFont
                    }
                    if _placeholderTextColor == nil {
                        _placeholderTextColor = YYTextView._defaultPlaceholderColor
                    }
                    atr.yy_font = _placeholderFont
                    atr.yy_color = _placeholderTextColor
                    _placeholderAttributedText = atr
                }
            }
            _placeholderText = _placeholderAttributedText?.yy_plainText(for: NSRange(location: 0, length: _placeholderAttributedText!.length))
            _commitPlaceholderUpdate()
        }
        get {
            return _placeholderText
        }
    }
    
    private var _placeholderFont: UIFont?
    /**
     The font of the placeholder text. Default is same as `font` property.
     Set a new value to this property also causes the new font to be applied to the entire `placeholderAttributedText`.
     Get the value returns the font at the head of `placeholderAttributedText`.
     */
    @objc public var placeholderFont: UIFont? {
        set {
            _placeholderFont = newValue
            (_placeholderAttributedText as? NSMutableAttributedString)?.yy_font = _placeholderFont
            _commitPlaceholderUpdate()
        }
        get {
            return _placeholderFont
        }
    }
    
    private var _placeholderTextColor: UIColor?
    /**
     The color of the placeholder text. Default is gray.
     Set a new value to this property also causes the new color to be applied to the entire `placeholderAttributedText`.
     Get the value returns the color at the head of `placeholderAttributedText`.
     */
    @objc public var placeholderTextColor: UIColor? {
        set {
            _placeholderTextColor = newValue
            (_placeholderAttributedText as? NSMutableAttributedString)?.yy_color = _placeholderTextColor
            _commitPlaceholderUpdate()
        }
        get {
            return _placeholderTextColor
        }
    }
    
    private var _placeholderAttributedText: NSAttributedString?
    /**
     The styled placeholder text displayed by the text view (when the text view is empty).
     Set a new value to this property also replaces the value of the `placeholderText`,
     `placeholderFont`, `placeholderTextColor`.
     
     @discussion It only support the attributes declared in CoreText and YYTextAttribute.
     See `NSAttributedStringExtension.swift` for more convenience methods to set the attributes.
     */
    @objc public var placeholderAttributedText: NSAttributedString? {
        set {
            _placeholderAttributedText = newValue
            _placeholderText = placeholderAttributedText?.yy_plainText(for: NSRange(location: 0, length: _placeholderAttributedText!.length))
            _placeholderFont = _placeholderAttributedText?.yy_font
            _placeholderTextColor = _placeholderAttributedText?.yy_color
            _commitPlaceholderUpdate()
        }
        get {
            return _placeholderAttributedText
        }
    }
    
    
    // MARK: - Configuring the Text Container
    ///*****************************************************************************
    /// @name Configuring the Text Container
    ///*****************************************************************************
    
    private var _textContainerInset = kDefaultInset
    /**
     The inset of the text container's layout area within the text view's content area.
     */
    @objc public var textContainerInset: UIEdgeInsets {
        get {
            return _textContainerInset
        }
        set {
            if _textContainerInset == newValue {
                return
            }
            _setYYTextContainerInset(newValue)
            _innerContainer.insets = newValue
            _commitUpdate()
        }
    }
    
    private var _exclusionPaths: [UIBezierPath]?
    /**
     An array of UIBezierPath objects representing the exclusion paths inside the
     receiver's bounding rectangle. Default value is nil.
     */
    @objc public var exclusionPaths: [UIBezierPath]? {
        get {
            return _exclusionPaths
        }
        set {
            if _exclusionPaths == newValue {
                return
            }
            _setExclusionPaths(newValue)
            _innerContainer.exclusionPaths = newValue
            
            if _innerContainer.isVerticalForm {
                let trans = CGAffineTransform(translationX: _innerContainer.size.width - bounds.size.width, y: 0)
                (_innerContainer.exclusionPaths as NSArray?)?.enumerateObjects({ path, idx, stop in
                    (path as! UIBezierPath).apply(trans)
                })
            }
            _commitUpdate()
        }
    }
    
    private var _verticalForm = false
    /**
     Whether the receiver's layout orientation is vertical form. Default is NO.
     It may used to edit/display CJK text.
     */
    @objc public var isVerticalForm: Bool {
        get {
            return _verticalForm
        }
        set {
            if _verticalForm == newValue {
                return
            }
            _setVerticalForm(newValue)
            _innerContainer.isVerticalForm = newValue
            _selectionView.verticalForm = newValue
            
            _updateInnerContainerSize()
            
            if isVerticalForm {
                if _innerContainer.insets == kDefaultInset {
                    _innerContainer.insets = kDefaultVerticalInset
                    _setYYTextContainerInset(kDefaultVerticalInset)
                }
            } else {
                if _innerContainer.insets == kDefaultVerticalInset {
                    _innerContainer.insets = kDefaultInset
                    _setYYTextContainerInset(kDefaultInset)
                }
            }
            
            _innerContainer.exclusionPaths = exclusionPaths
            if newValue {
                let trans = CGAffineTransform(translationX: _innerContainer.size.width - bounds.size.width, y: 0)
                for path in _innerContainer.exclusionPaths ?? [] {
                    path.apply(trans)
                }
            }
            
            _keyboardChanged()
            _commitUpdate()
        }
    }
    
    private var _linePositionModifier: YYTextLinePositionModifier?
    /**
     The text line position modifier used to modify the lines' position in layout.
     See `YYTextLinePositionModifier` protocol for more information.
     */
    @objc public weak var linePositionModifier: YYTextLinePositionModifier? {
        set {
            if _linePositionModifier === newValue || _linePositionModifier?.isEqual(newValue) ?? false {
                return
            }
            _setLinePositionModifier(newValue)
            _innerContainer.linePositionModifier = newValue
            _commitUpdate()
        }
        get {
            return _linePositionModifier
        }
    }
    
    /**
     The debug option to display CoreText layout result.
     The default value is [YYTextDebugOption sharedDebugOption].
     */
    @objc public var debugOption: YYTextDebugOption? { // = YYTextDebugOption.shared {
        set {
            _containerView.debugOption = newValue
        }
        get {
            return _containerView.debugOption
        }
    }
    
    
    // MARK: - Working with the Selection and Menu
    ///*****************************************************************************
    /// @name Working with the Selection and Menu
    ///*****************************************************************************
    
    /**
     Scrolls the receiver until the text in the specified range is visible.
     */
    @objc public func scrollRangeToVisible(_ range: NSRange) {
        var textRange = YYTextRange(range: range)
        textRange = _correctedTextRange(textRange)!
        _scrollRangeToVisible(textRange)
    }
    
    private var _selectedRange = NSRange(location: 0, length: 0)
    /**
     The current selection range of the receiver.
     */
    @objc public var selectedRange: NSRange {
        get {
            return _selectedRange
        }
        set {
            if NSEqualRanges(_selectedRange, newValue) {
                return
            }
            if (_markedTextRange != nil) {
                return
            }
            state.typingAttributesOnce = false
            
            var range = YYTextRange(range: newValue)
            range = _correctedTextRange(range)!
            _endTouchTracking()
            _selectedTextRange = range
            _updateSelectionView()
            
            _setSelectedRange(range.asRange)
            
            if !state.insideUndoBlock {
                _resetUndoAndRedoStack()
            }
        }
    }
    
    /**
     A Boolean value indicating whether inserting text replaces the previous contents.
     The default value is NO.
     */
    @objc public var clearsOnInsertion = false {
        didSet {
            if clearsOnInsertion == oldValue {
                return
            }
            if clearsOnInsertion {
                if isFirstResponder {
                    selectedRange = NSRange(location: 0, length: _attributedText.length)
                } else {
                    state.clearsOnInsertionOnce = true
                }
            }
        }
    }
    
    /**
     A Boolean value indicating whether the receiver is isSelectable. Default is YES.
     When the value of this property is NO, user cannot select content or edit text.
     */
    @objc public var isSelectable = true {
        didSet {
            if isSelectable == oldValue {
                return
            }
            if !isSelectable {
                if isFirstResponder {
                    resignFirstResponder()
                } else {
                    state.selectedWithoutEdit = false
                    _endTouchTracking()
                    _hideMenu()
                    _updateSelectionView()
                }
            }
        }
    }
    
    /**
     A Boolean value indicating whether the receiver is isHighlightable. Default is YES.
     When the value of this property is NO, user cannot interact with the highlight range of text.
     */
    @objc public var isHighlightable = true {
        didSet {
            if isHighlightable == oldValue {
                return
            }
            _commitUpdate()
        }
    }
    
    /**
     A Boolean value indicating whether the receiver is isEditable. Default is YES.
     When the value of this property is NO, user cannot edit text.
     */
    @objc public var isEditable = true {
        didSet {
            if isEditable == oldValue {
                return
            }
            if !isEditable {
                resignFirstResponder()
            }
        }
    }
    
    
    /**
     A Boolean value indicating whether the receiver can paste image from pasteboard. Default is NO.
     When the value of this property is YES, user can paste image from pasteboard via "paste" menu.
     */
    @objc public var allowsPasteImage = false
    
    /**
     A Boolean value indicating whether the receiver can paste attributed text from pasteboard. Default is NO.
     When the value of this property is YES, user can paste attributed text from pasteboard via "paste" menu.
     */
    @objc public var allowsPasteAttributedString = false
    
    /**
     A Boolean value indicating whether the receiver can copy attributed text to pasteboard. Default is YES.
     When the value of this property is YES, user can copy attributed text (with attachment image)
     from text view to pasteboard via "copy" menu.
     */
    @objc public var allowsCopyAttributedString = true
    
    // MARK: - Manage the undo and redo
    ///*****************************************************************************
    /// @name Manage the undo and redo
    ///*****************************************************************************
    
    /**
     A Boolean value indicating whether the receiver can undo and redo typing with
     shake gesture. The default value is YES.
     */
    @objc public var allowsUndoAndRedo = true
    
    /**
     The maximum undo/redo level. The default value is 20.
     */
    @objc public var maximumUndoLevel: Int = kDefaultUndoLevelMax
    
    
    // MARK: - Replacing the System Input Views
    ///*****************************************************************************
    /// @name Replacing the System Input Views
    ///*****************************************************************************
    
    private var _inputView: UIView?
    /**
     The custom input view to display when the text view becomes the first responder.
     It can be used to replace system keyboard.
     
     @discussion If set the value while first responder, it will not take effect until
     'reloadInputViews' is called.
     */
    open override var inputView: UIView? {      // kind of UIView
        set {
            _inputView = newValue
        }
        get {
            return _inputView
        }
    }
    
    private var _inputAccessoryView: UIView?
    /**
     The custom accessory view to display when the text view becomes the first responder.
     It can be used to add a toolbar at the top of keyboard.
     
     @discussion If set the value while first responder, it will not take effect until
     'reloadInputViews' is called.
     */
    open override var inputAccessoryView: UIView? {      // kind of UIView
        set {
            _inputAccessoryView = newValue
        }
        get {
            return _inputAccessoryView
        }
    }
    /**
     If you use an custom accessory view without "inputAccessoryView" property,
     you may set the accessory view's height. It may used by auto scroll calculation.
     */
    @objc public var extraAccessoryViewHeight: CGFloat = 0
    
    
    fileprivate lazy var _selectedTextRange = YYTextRange.default() /// nonnull
    fileprivate var _markedTextRange: YYTextRange?
    
    fileprivate weak var _outerDelegate: YYTextViewDelegate?
    
    fileprivate var _placeHolderView = UIImageView()
    
    fileprivate lazy var _innerText = NSMutableAttributedString() ///< nonnull, inner attributed text
    fileprivate var _delectedText: NSMutableAttributedString? ///< detected text for display
    fileprivate lazy var _innerContainer = YYTextContainer() ///< nonnull, inner text container
    fileprivate var _innerLayout: YYTextLayout? ///< inner text layout, the text in this layout is longer than `_innerText` by appending '\n'
    
    fileprivate lazy var _containerView = YYTextContainerView() ///< nonnull
    fileprivate lazy var _selectionView = YYTextSelectionView() ///< nonnull
    fileprivate lazy var _magnifierCaret = YYTextMagnifier() ///< nonnull
    fileprivate lazy var _magnifierRanged = YYTextMagnifier() ///< nonnull
    
    fileprivate lazy var _typingAttributesHolder = NSMutableAttributedString(string: " ") ///< nonnull, typing attributes
    fileprivate var _dataDetector: NSDataDetector?
    fileprivate var _magnifierRangedOffset: CGFloat = 0
    
    fileprivate lazy var _highlightRange = NSRange(location: 0, length: 0) ///< current highlight range
    fileprivate var _highlight: YYTextHighlight? ///< highlight attribute in `_highlightRange`
    fileprivate var _highlightLayout: YYTextLayout? ///< when _state.showingHighlight=YES, this layout should be displayed
    fileprivate var _trackingRange: YYTextRange? ///< the range in _innerLayout, may out of _innerText.
    
    fileprivate var _insetModifiedByKeyboard = false ///< text is covered by keyboard, and the contentInset is modified
    fileprivate var _originalContentInset = UIEdgeInsets.zero ///< the original contentInset before modified
    fileprivate var _originalScrollIndicatorInsets = UIEdgeInsets.zero ///< the original scrollIndicatorInsets before modified
    
    fileprivate var _longPressTimer: Timer?
    fileprivate var _autoScrollTimer: Timer?
    fileprivate var _autoScrollOffset: CGFloat = 0 ///< current auto scroll offset which shoud add to scroll view
    fileprivate var _autoScrollAcceleration: Int = 0 ///< an acceleration coefficient for auto scroll
    fileprivate var _selectionDotFixTimer: Timer? ///< fix the selection dot in window if the view is moved by parents
    fileprivate var _previousOriginInWindow = CGPoint.zero
    
    fileprivate var _touchBeganPoint = CGPoint.zero
    fileprivate var _trackingPoint = CGPoint.zero
    fileprivate var _touchBeganTime: TimeInterval = 0
    fileprivate var _trackingTime: TimeInterval = 0
    fileprivate lazy var _undoStack: [YYTextViewUndoObject] = []
    fileprivate lazy var _redoStack: [YYTextViewUndoObject] = []
    fileprivate var _lastTypeRange: NSRange?
    
    private lazy var state = YYState()
    
    private struct YYState {
        ///< TextGrabberDirection, current tracking grabber
        var trackingGrabber = TextGrabberDirection.none
        ///< track the caret
        var trackingCaret = false
        ///< track pre-select
        var trackingPreSelect = false
        ///< is in touch phase
        var trackingTouch = false
        ///< don't forward event to next responder
        var swallowTouch = false
        ///< TextMoveDirection, move direction after touch began
        var touchMoved = TextMoveDirection.none
        ///< show selected range but not first responder
        var selectedWithoutEdit = false
        ///< delete a binding text range
        var deleteConfirm = false
        ///< ignore become first responder temporary
        var ignoreFirstResponder = false
        ///< ignore begin tracking touch temporary
        var ignoreTouchBegan = false
        
        var showingMagnifierCaret = false
        var showingMagnifierRanged = false
        var showingMenu = false
        var showingHighlight = false
        
        ///< apply the typing attributes once
        var typingAttributesOnce = false
        ///< select all once when become first responder
        var clearsOnInsertionOnce = false
        ///< auto scroll did tick scroll at this timer period
        var autoScrollTicked = false
        ///< the selection grabber dot has displayed at least once
        var firstShowDot = false
        ///< the layout or selection view is 'dirty' and need update
        var needUpdate = false
        ///< the placeholder need update it's contents
        var placeholderNeedUpdate = false
        
        var insideUndoBlock = false
        var firstResponderBeforeUndoAlert = false
    }
    
    
    // UITextInputTraits
    public var autocapitalizationType = UITextAutocapitalizationType.sentences
    public var autocorrectionType = UITextAutocorrectionType.default
    public var spellCheckingType = UITextSpellCheckingType.default
    public var keyboardType = UIKeyboardType.default
    public var keyboardAppearance = UIKeyboardAppearance.default
    public var returnKeyType = UIReturnKeyType.default
    public var enablesReturnKeyAutomatically = false
    public var isSecureTextEntry = false
    
    
    // MARK: - Private
    
    /// Update layout and selection before runloop sleep/end.
    func _commitUpdate() {
        #if !TARGET_INTERFACE_BUILDER
        state.needUpdate = true
        YYTextTransaction(target: self, selector: #selector(self._updateIfNeeded)).commit()
        #else
        _update()
        #endif
    }
    
    /// Update layout and selection view if needed.
    @objc func _updateIfNeeded() {
        if state.needUpdate {
            _update()
        }
    }
    
    /// Update layout and selection view immediately.
    func _update() {
        state.needUpdate = false
        _updateLayout()
        _updateSelectionView()
    }
    
    /// Update layout immediately.
    func _updateLayout() {
        let text = _innerText.mutableCopy() as! NSMutableAttributedString
        _placeHolderView.isHidden = (text.length > 0)
        if _detectText(text) {
            _delectedText = text
        } else {
            _delectedText = nil
        }
        text.replaceCharacters(in: NSRange(location: text.length, length: 0), with: "\r") // add for nextline caret
        text.yy_removeDiscontinuousAttributes(in: NSRange(location: _innerText.length, length: 1))
        text.removeAttribute(NSAttributedString.Key(rawValue: YYTextAttribute.textBorderAttributeName), range: NSRange(location: _innerText.length, length: 1))
        text.removeAttribute(NSAttributedString.Key(rawValue: YYTextAttribute.textBackgroundBorderAttributeName), range: NSRange(location: _innerText.length, length: 1))
        if _innerText.length == 0 {
            text.yy_setAttributes(_typingAttributesHolder.yy_attributes) // add for empty text caret
        }
        if _selectedTextRange.end.offset == _innerText.length {
            for (key, value) in _typingAttributesHolder.yy_attributes ?? [:] {
                text.yy_set(attribute: key, value: value, range: NSRange(location: _innerText.length, length: 1))
            }
        }
        willChangeValue(forKey: "textLayout")
        _innerLayout = YYTextLayout(container: _innerContainer, text: text)
        didChangeValue(forKey: "textLayout")
        var size: CGSize = _innerLayout?.textBoundingSize ?? .zero
        let visibleSize: CGSize = _getVisibleSize()
        if _innerContainer.isVerticalForm {
            size.height = visibleSize.height
            if size.width < visibleSize.width {
                size.width = visibleSize.width
            }
        } else {
            size.width = visibleSize.width
        }
        
        _containerView.set(layout: _innerLayout, with: 0)
        _containerView.frame = CGRect()
        _containerView.frame.size = size
        state.showingHighlight = false
        self.contentSize = size
    }
    
    /// Update selection view immediately.
    /// This method should be called after "layout update" finished.
    func _updateSelectionView() {
        _selectionView.frame = _containerView.frame
        _selectionView.caretBlinks = false
        _selectionView.caretVisible = false
        _selectionView.selectionRects = nil
        YYTextEffectWindow.shared?.hide(selectionDot: _selectionView)
        if _innerLayout == nil {
            return
        }
        
        var allRects = [YYTextSelectionRect]()
        var containsDot = false
        
        var selectedRange = _selectedTextRange
        if state.trackingTouch && _trackingRange != nil {
            selectedRange = _trackingRange!
        }
        
        if _markedTextRange != nil {
            var rects = _innerLayout?.selectionRectsWithoutStartAndEnd(for: _markedTextRange!)
            if let aRects = rects {
                allRects.append(contentsOf: aRects)
            }
            if selectedRange.asRange.length > 0 {
                rects = _innerLayout?.selectionRectsWithOnlyStartAndEnd(for: selectedRange)
                if let aRects = rects {
                    allRects.append(contentsOf: aRects)
                    containsDot = aRects.count > 0
                }
            } else {
                let rect = _innerLayout!.caretRect(for: selectedRange.end)
                _selectionView.caretRect = _convertRect(fromLayout: rect)
                _selectionView.caretVisible = true
                _selectionView.caretBlinks = true
            }
        } else {
            if selectedRange.asRange.length == 0 {
                // only caret
                if isFirstResponder || state.trackingPreSelect {
                    let rect: CGRect = _innerLayout!.caretRect(for: selectedRange.end)
                    _selectionView.caretRect = _convertRect(fromLayout: rect)
                    _selectionView.caretVisible = true
                    if !state.trackingCaret && !state.trackingPreSelect {
                        _selectionView.caretBlinks = true
                    }
                }
            } else {
                // range selected
                if (isFirstResponder && !state.deleteConfirm) || (!isFirstResponder && state.selectedWithoutEdit) {
                    let rects = _innerLayout!.selectionRects(for: selectedRange)
                    allRects.append(contentsOf: rects)
                    containsDot = rects.count > 0
                } else if (!isFirstResponder && state.trackingPreSelect) || (isFirstResponder && state.deleteConfirm) {
                    let rects = _innerLayout!.selectionRectsWithoutStartAndEnd(for: selectedRange)
                    allRects.append(contentsOf: rects)
                }
            }
        }
        (allRects as NSArray).enumerateObjects({ rect, idx, stop in
            (rect as! YYTextSelectionRect).rect = self._convertRect(fromLayout: (rect as! YYTextSelectionRect).rect)
        })
        _selectionView.selectionRects = allRects
        if !state.firstShowDot && containsDot {
            state.firstShowDot = true
            /*
             The dot position may be wrong at the first time displayed.
             I can't find the reason. Here's a workaround.
             */
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                YYTextEffectWindow.shared?.show(selectionDot: self._selectionView)
            })
        }
        YYTextEffectWindow.shared?.show(selectionDot: _selectionView)
        
        if containsDot {
            _startSelectionDotFixTimer()
        } else {
            _endSelectionDotFixTimer()
        }
    }
    
    /// Update inner contains's size.
    func _updateInnerContainerSize() {
        var size: CGSize = _getVisibleSize()
        if _innerContainer.isVerticalForm {
            size.width = CGFloat.greatestFiniteMagnitude
        } else {
            size.height = CGFloat.greatestFiniteMagnitude
        }
        _innerContainer.size = size
    }
    
    /// Update placeholder before runloop sleep/end.
    func _commitPlaceholderUpdate() {
        #if !TARGET_INTERFACE_BUILDER
        state.placeholderNeedUpdate = true
        YYTextTransaction(target: self, selector: #selector(self._updatePlaceholderIfNeeded)).commit()
        #else
        _updatePlaceholder()
        #endif
    }
    
    /// Update placeholder if needed.
    @objc func _updatePlaceholderIfNeeded() {
        if state.placeholderNeedUpdate {
            state.placeholderNeedUpdate = false
            _updatePlaceholder()
        }
    }
    
    /// Update placeholder immediately.
    func _updatePlaceholder() {
        var frame = CGRect.zero
        _placeHolderView.image = nil
        _placeHolderView.frame = frame
        if (placeholderAttributedText?.length ?? 0) > 0 {
            let container = _innerContainer.copy() as! YYTextContainer
            container.size = bounds.size
            container.truncationType = YYTextTruncationType.end
            container.truncationToken = nil
            let layout = YYTextLayout(container: container, text: placeholderAttributedText)!
            let size: CGSize = layout.textBoundingSize
            let needDraw: Bool = size.width > 1 && size.height > 1
            if needDraw {
                UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0)
                let context = UIGraphicsGetCurrentContext()
                layout.draw(in: context, size: size, debug: debugOption)
                let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                _placeHolderView.image = image
                frame.size = image?.size ?? CGSize.zero
                if container.isVerticalForm {
                    frame.origin.x = bounds.size.width - (image?.size.width ?? 0)
                } else {
                    frame.origin = CGPoint.zero
                }
                _placeHolderView.frame = frame
            }
        }
    }
    
    /// Update the `_selectedTextRange` to a single position by `_trackingPoint`.
    func _updateTextRangeByTrackingCaret() {
        if !state.trackingTouch {
            return
        }
        
        let trackingPoint = _convertPoint(toLayout: _trackingPoint)
        
        if var newPos = _innerLayout?.closestPosition(to: trackingPoint) {
            newPos = _correctedTextPosition(newPos)!
            if _markedTextRange != nil {
                if newPos.compare(_markedTextRange!.start) == .orderedAscending {
                    newPos = _markedTextRange!.start
                } else if newPos.compare(_markedTextRange!.end) == .orderedDescending {
                    newPos = _markedTextRange!.end
                }
            }
            _trackingRange = YYTextRange.range(with: NSRange(location: newPos.offset, length: 0), affinity: newPos.affinity)
        }
    }
    
    /// Update the `_selectedTextRange` to a new range by `_trackingPoint` and `_state.trackingGrabber`.
    func _updateTextRangeByTrackingGrabber() {
        if !state.trackingTouch || state.trackingGrabber == .none {
            return
        }
        
        let isStart = (state.trackingGrabber == .start)
        var magPoint = _trackingPoint
        magPoint.y += kMagnifierRangedTrackFix
        magPoint = _convertPoint(toLayout: magPoint)
        var position: YYTextPosition? = _innerLayout?.position(for: magPoint, oldPosition: (isStart ? _selectedTextRange.start : _selectedTextRange.end), otherPosition: (isStart ? _selectedTextRange.end : _selectedTextRange.start))
        if position != nil {
            position = _correctedTextPosition(position)
            if (position?.offset ?? 0) > _innerText.length {
                position = YYTextPosition.position(with: _innerText.length)
            }
            _trackingRange = YYTextRange.range(with: (isStart ? position! : _selectedTextRange.start), end: (isStart ? _selectedTextRange.end : position!))
        }
    }
    
    /// Update the `_selectedTextRange` to a new range/position by `_trackingPoint`.
    func _updateTextRangeByTrackingPreSelect() {
        if !state.trackingTouch {
            return
        }
        _trackingRange = _getClosestTokenRange(at: _trackingPoint)
    }
    
    /// Show or update `_magnifierCaret` based on `_trackingPoint`, and hide `_magnifierRange`.
    func _showMagnifierCaret() {
        if YYTextUtilities.isAppExtension {
            return
        }
        
        if state.showingMagnifierRanged {
            state.showingMagnifierRanged = false
            YYTextEffectWindow.shared?.hide(_magnifierRanged)
        }
        
        _magnifierCaret.hostPopoverCenter = _trackingPoint
        _magnifierCaret.hostCaptureCenter = _trackingPoint
        if !state.showingMagnifierCaret {
            state.showingMagnifierCaret = true
            YYTextEffectWindow.shared?.show(_magnifierCaret)
        } else {
            YYTextEffectWindow.shared?.move(_magnifierCaret)
        }
    }
    
    /// Show or update `_magnifierRanged` based on `_trackingPoint`, and hide `_magnifierCaret`.
    private func _showMagnifierRanged() {
        if YYTextUtilities.isAppExtension {
            return
        }
        
        if isVerticalForm {
            // hack for vertical form...
            _showMagnifierCaret()
            return
        }
        
        if state.showingMagnifierCaret {
            state.showingMagnifierCaret = false
            YYTextEffectWindow.shared?.hide(_magnifierCaret)
        }
        
        var magPoint = _trackingPoint
        if isVerticalForm {
            magPoint.x += kMagnifierRangedTrackFix
        } else {
            magPoint.y += kMagnifierRangedTrackFix
        }
        
        var selectedRange = _selectedTextRange
        if state.trackingTouch && _trackingRange != nil {
            selectedRange = _trackingRange!
        }
        
        var position: YYTextPosition?
        if _markedTextRange != nil {
            position = selectedRange.end
        } else {
            position = _innerLayout?.position(for: _convertPoint(toLayout: magPoint), oldPosition: (state.trackingGrabber == .start ? selectedRange.start : selectedRange.end), otherPosition: (state.trackingGrabber == .start ? selectedRange.end : selectedRange.start))
        }
        
        let lineIndex = _innerLayout?.lineIndex(for: position) ?? 0
        if lineIndex < _innerLayout?.lines.count ?? 0 {
            let line = _innerLayout!.lines[lineIndex]
            let lineRect: CGRect = _convertRect(fromLayout: line.bounds)
            if isVerticalForm {
                magPoint.x = YYTextUtilities.textClamp(x: magPoint.x, low: lineRect.minX, high: lineRect.maxX)
            } else {
                
                magPoint.y = YYTextUtilities.textClamp(x: magPoint.y, low: lineRect.minY, high: lineRect.maxY)
            }
            var linePoint: CGPoint = _innerLayout!.linePosition(for: position)
            linePoint = _convertPoint(fromLayout: linePoint)
            
            var popoverPoint: CGPoint = linePoint
            if isVerticalForm {
                popoverPoint.x = linePoint.x + _magnifierRangedOffset
            } else {
                popoverPoint.y = linePoint.y + _magnifierRangedOffset
            }
            
            var capturePoint: CGPoint = .zero
            if isVerticalForm {
                capturePoint.x = linePoint.x + kMagnifierRangedCaptureOffset
                capturePoint.y = linePoint.y
            } else {
                capturePoint.x = linePoint.x
                capturePoint.y = linePoint.y + kMagnifierRangedCaptureOffset
            }
            
            _magnifierRanged.hostPopoverCenter = popoverPoint
            _magnifierRanged.hostCaptureCenter = capturePoint
            if !state.showingMagnifierRanged {
                state.showingMagnifierRanged = true
                YYTextEffectWindow.shared?.show(_magnifierRanged)
            } else {
                YYTextEffectWindow.shared?.move(_magnifierRanged)
            }
        }
    }
    
    /// Update the showing magnifier.
    private func _updateMagnifier() {
        if YYTextUtilities.isAppExtension {
            return
        }
        
        if state.showingMagnifierCaret {
            YYTextEffectWindow.shared?.move(_magnifierCaret)
        }
        if state.showingMagnifierRanged {
            YYTextEffectWindow.shared?.move(_magnifierRanged)
        }
    }
    
    /// Hide the `_magnifierCaret` and `_magnifierRanged`.
    private func _hideMagnifier() {
        if YYTextUtilities.isAppExtension {
            return
        }
        
        if state.showingMagnifierCaret || state.showingMagnifierRanged {
            // disable touch began temporary to ignore caret animation overlap
            state.ignoreTouchBegan = true
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [weak self] in
                if let strongSelf = self {
                    strongSelf.state.ignoreTouchBegan = false
                }
            })
        }
        
        if state.showingMagnifierCaret {
            state.showingMagnifierCaret = false
            YYTextEffectWindow.shared?.hide(_magnifierCaret)
        }
        if state.showingMagnifierRanged {
            state.showingMagnifierRanged = false
            YYTextEffectWindow.shared?.hide(_magnifierRanged)
        }
    }
    
    /// Show and update the UIMenuController.
    private func _showMenu() {
        var rect: CGRect
        if _selectionView.caretVisible {
            rect = _selectionView.caretView.frame
        } else if let rects = _selectionView.selectionRects, rects.count > 0 {
            var sRect = rects.first!
            rect = sRect.rect
            for i in 1..<rects.count {
                sRect = rects[i]
                rect = rect.union(sRect.rect)
            }
            
            let inter: CGRect = rect.intersection(bounds)
            if !inter.isNull && inter.size.height > 1 {
                rect = inter //clip to bounds
            } else {
                if rect.minY < bounds.minY {
                    rect.size.height = 1
                    rect.origin.y = bounds.minY
                } else {
                    rect.size.height = 1
                    rect.origin.y = bounds.maxY
                }
            }
            
            let mgr = YYTextKeyboardManager.default
            if mgr.keyboardVisible {
                let kbRect = mgr.convert(mgr.keyboardFrame, to: self)
                let kbInter: CGRect = rect.intersection(kbRect)
                if !kbInter.isNull && kbInter.size.height > 1 && kbInter.size.width > 1 {
                    // self is covered by keyboard
                    if kbInter.minY > rect.minY {
                        // keyboard at bottom
                        rect.size.height -= kbInter.size.height
                    } else if kbInter.maxY < rect.maxY {
                        // keyboard at top
                        rect.origin.y += kbInter.size.height
                        rect.size.height -= kbInter.size.height
                    }
                }
            }
        } else {
            rect = _selectionView.bounds
        }
        
        if !isFirstResponder {
            if !_containerView.isFirstResponder {
                _containerView.becomeFirstResponder()
            }
        }
        
        if isFirstResponder || _containerView.isFirstResponder {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [weak self] in
                if let strongSelf = self {
                    let menu = UIMenuController.shared
                    menu.showMenu(from: strongSelf._selectionView, rect: rect)
                    menu.update()
                    if !strongSelf.state.showingMenu || !menu.isMenuVisible {
                        strongSelf.state.showingMenu = true
                        menu.showMenu(from: strongSelf._selectionView, rect: rect)
                    }
                }
            })
        }
    }
    
    /// Hide the UIMenuController.
    private func _hideMenu() {
        if state.showingMenu {
            state.showingMenu = false
            let menu = UIMenuController.shared
            menu.hideMenu()
        }
        if _containerView.isFirstResponder {
            state.ignoreFirstResponder = true
            _containerView.resignFirstResponder() // it will call [self becomeFirstResponder], ignore it temporary.
            state.ignoreFirstResponder = false
        }
    }
    
    /// Show highlight layout based on `_highlight` and `_highlightRange`
    /// If the `_highlightLayout` is nil, try to create.
    private func _showHighlight(animated: Bool) {
        let fadeDuration: TimeInterval = animated ? kHighlightFadeDuration : 0
        if _highlight == nil {
            return
        }
        if _highlightLayout == nil {
            let hiText = (_delectedText ?? _innerText)
            let newAttrs = _highlight!.attributes
            for (key, value) in newAttrs {
                hiText.yy_set(attribute: key, value: value, range: _highlightRange)
            }
            
            _highlightLayout = YYTextLayout(container: _innerContainer, text: hiText)
            if _highlightLayout == nil {
                _highlight = nil
            }
        }
        
        if (_highlightLayout != nil) && !state.showingHighlight {
            state.showingHighlight = true
            _containerView.set(layout: _highlightLayout, with: fadeDuration)
        }
    }
    
    /// Show `_innerLayout` instead of `_highlightLayout`.
    /// It does not destory the `_highlightLayout`.
    private func _hideHighlight(animated: Bool) {
        let fadeDuration: TimeInterval = animated ? kHighlightFadeDuration : 0
        if state.showingHighlight {
            state.showingHighlight = false
            _containerView.set(layout: _innerLayout, with: fadeDuration)
        }
    }
    
    /// Show `_innerLayout` and destory the `_highlight` and `_highlightLayout`.
    private func _removeHighlight(animated: Bool) {
        _hideHighlight(animated: animated)
        _highlight = nil
        _highlightLayout = nil
    }
    
    /// Scroll current selected range to visible.
    @objc private func _scrollSelectedRangeToVisible() {
        _scrollRangeToVisible(_selectedTextRange)
    }
    
    /// Scroll range to visible, take account into keyboard and insets.
    private func _scrollRangeToVisible(_ range: YYTextRange?) {
        if range == nil {
            return
        }
        var rect: CGRect = _innerLayout!.rect(for: range)
        if rect.isNull {
            return
        }
        rect = _convertRect(fromLayout: rect)
        rect = _containerView.convert(rect, to: self)
        
        if rect.size.width < 1 {
            rect.size.width = 1
        }
        if rect.size.height < 1 {
            rect.size.height = 1
        }
        let extend: CGFloat = 3
        
        var insetModified = false
        let mgr = YYTextKeyboardManager.default
        
        if mgr.keyboardVisible && (window != nil) && (superview != nil) && isFirstResponder && !isVerticalForm {
            var bounds: CGRect = self.bounds
            bounds.origin = CGPoint.zero
            var kbRect = mgr.convert(mgr.keyboardFrame, to: self)
            kbRect.origin.y -= extraAccessoryViewHeight
            kbRect.size.height += extraAccessoryViewHeight
            
            kbRect.origin.x -= contentOffset.x
            kbRect.origin.y -= contentOffset.y
            let inter: CGRect = bounds.intersection(kbRect)
            if !inter.isNull && inter.size.height > 1 && inter.size.width > extend {
                // self is covered by keyboard
                if inter.minY > bounds.minY {
                    // keyboard below self.top
                    
                    var originalContentInset = self.contentInset
                    var originalScrollIndicatorInsets = self.scrollIndicatorInsets
                    if _insetModifiedByKeyboard {
                        originalContentInset = self._originalContentInset
                        originalScrollIndicatorInsets = self._originalScrollIndicatorInsets
                    }
                    
                    if originalContentInset.bottom < inter.size.height + extend {
                        insetModified = true
                        if !_insetModifiedByKeyboard {
                            _insetModifiedByKeyboard = true
                            originalContentInset = contentInset
                            originalScrollIndicatorInsets = scrollIndicatorInsets
                        }
                        var newInset: UIEdgeInsets = originalContentInset
                        var newIndicatorInsets: UIEdgeInsets = originalScrollIndicatorInsets
                        newInset.bottom = inter.size.height + extend
                        newIndicatorInsets.bottom = newInset.bottom
                        
                        let curve = UIView.AnimationOptions(rawValue: 7 << 16)
                        
                        UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, curve], animations: {
                            super.contentInset = newInset
                            super.scrollIndicatorInsets = newIndicatorInsets
                            self.scrollRectToVisible(rect.insetBy(dx: -extend, dy: -extend), animated: false)
                        })
                    }
                    
                }
            }
        }
        
        if !insetModified {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut], animations: {
                self._restoreInsets(animated: false)
                self.scrollRectToVisible(rect.insetBy(dx: -extend, dy: -extend), animated: false)
            })
        }
    }
    
    /// Restore contents insets if modified by keyboard.
    private func _restoreInsets(animated: Bool) {
        if _insetModifiedByKeyboard {
            _insetModifiedByKeyboard = false
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut], animations: {
                    super.contentInset = self._originalContentInset
                    super.scrollIndicatorInsets = self._originalScrollIndicatorInsets
                })
            } else {
                super.contentInset = _originalContentInset
                super.scrollIndicatorInsets = _originalScrollIndicatorInsets
            }
        }
    }
    
    /// Keyboard frame changed, scroll the caret to visible range, or modify the content insets.
    private func _keyboardChanged() {
        if !isFirstResponder {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            if YYTextKeyboardManager.default.keyboardVisible {
                self._scrollRangeToVisible(self._selectedTextRange)
            } else {
                self._restoreInsets(animated: true)
            }
            self._updateMagnifier()
            if self.state.showingMenu {
                self._showMenu()
            }
        })
    }
    
    /// Start long press timer, used for 'highlight' range text action.
    private func _startLongPressTimer() {
        _longPressTimer?.invalidate()
        _longPressTimer = Timer.yy_scheduledTimer(with: kLongPressMinimumDuration, target: self, selector: #selector(self._trackDidLongPress), userInfo: nil, repeats: false)
        RunLoop.current.add(_longPressTimer!, forMode: .common)
    }
    
    /// Invalidate the long press timer.
    private func _endLongPressTimer() {
        _longPressTimer?.invalidate()
        _longPressTimer = nil
    }
    
    /// Long press detected.
    @objc
    private func _trackDidLongPress() {
        _endLongPressTimer()
        
        var dealLongPressAction = false
        if state.showingHighlight {
            _hideMenu()
            
            if let action = _highlight?.longPressAction {
                dealLongPressAction = true
                var rect: CGRect = _innerLayout!.rect(for: YYTextRange(range: _highlightRange))
                rect = _convertRect(fromLayout: rect)
                action(self, _innerText, _highlightRange, rect)
                _endTouchTracking()
            } else {
                var shouldHighlight = true
                if let d = _outerDelegate {
                    if let s = d.textView?(self, shouldLongPress: _highlight!, in: _highlightRange) {
                        shouldHighlight = s
                    }
                    if shouldHighlight {
                        dealLongPressAction = true
                        var rect: CGRect = _innerLayout!.rect(for: YYTextRange(range: _highlightRange))
                        rect = _convertRect(fromLayout: rect)
                        d.textView?(self, didLongPress: _highlight!, in: _highlightRange, rect: rect)
                        _endTouchTracking()
                    }
                }
            }
        }
        
        if !dealLongPressAction {
            _removeHighlight(animated: false)
            if state.trackingTouch {
                if (state.trackingGrabber != .none) {
                    panGestureRecognizer.isEnabled = false
                    _hideMenu()
                    _showMagnifierRanged()
                } else if isFirstResponder {
                    panGestureRecognizer.isEnabled = false
                    _selectionView.caretBlinks = false
                    state.trackingCaret = true
                    let trackingPoint: CGPoint = _convertPoint(toLayout: _trackingPoint)
                    var newPos = _innerLayout?.closestPosition(to: trackingPoint)
                    newPos = _correctedTextPosition(newPos)
                    if newPos != nil {
                        if let m = _markedTextRange {
                            if newPos?.compare(m.start) != .orderedDescending {
                                newPos = m.start
                            } else if newPos?.compare(m.end) != .orderedAscending {
                                newPos = m.end
                            }
                        }
                        _trackingRange = YYTextRange(range: NSRange(location: newPos?.offset ?? 0, length: 0), affinity: newPos!.affinity)
                        _updateSelectionView()
                    }
                    _hideMenu()
                    
                    if _markedTextRange != nil {
                        _showMagnifierRanged()
                    } else {
                        _showMagnifierCaret()
                    }
                } else if isSelectable {
                    panGestureRecognizer.isEnabled = false
                    state.trackingPreSelect = true
                    state.selectedWithoutEdit = false
                    _updateTextRangeByTrackingPreSelect()
                    _updateSelectionView()
                    _showMagnifierCaret()
                }
            }
        }
    }
    
    /// Start auto scroll timer, used for auto scroll tick.
    private func _startAutoScrollTimer() {
        if _autoScrollTimer == nil {
            _autoScrollTimer = Timer.yy_scheduledTimer(with: kAutoScrollMinimumDuration, target: self, selector: #selector(self._trackDidTickAutoScroll), userInfo: nil, repeats: true)
            RunLoop.current.add(_autoScrollTimer!, forMode: .common)
        }
    }
    
    /// Invalidate the auto scroll, and restore the text view state.
    private func _endAutoScrollTimer() {
        if state.autoScrollTicked {
            flashScrollIndicators()
        }
        _autoScrollTimer?.invalidate()
        _autoScrollTimer = nil
        _autoScrollOffset = 0
        _autoScrollAcceleration = 0
        state.autoScrollTicked = false
        
        if _magnifierCaret.captureDisabled {
            _magnifierCaret.captureDisabled = false
            if state.showingMagnifierCaret {
                _showMagnifierCaret()
            }
        }
        if _magnifierRanged.captureDisabled {
            _magnifierRanged.captureDisabled = false
            if state.showingMagnifierRanged {
                _showMagnifierRanged()
            }
        }
    }
    
    /// Auto scroll ticked by timer.
    @objc
    private func _trackDidTickAutoScroll() {
        if _autoScrollOffset != 0 {
            _magnifierCaret.captureDisabled = true
            _magnifierRanged.captureDisabled = true
            
            var offset: CGPoint = contentOffset
            if isVerticalForm {
                offset.x += _autoScrollOffset
                
                if _autoScrollAcceleration > 0 {
                    offset.x += (_autoScrollOffset > 0 ? 1 : -1) * CGFloat(_autoScrollAcceleration) * CGFloat(_autoScrollAcceleration) * CGFloat(0.5)
                }
                _autoScrollAcceleration += 1
                offset.x = CGFloat(round(Double(offset.x)))
                if _autoScrollOffset < 0 {
                    if offset.x < -contentInset.left {
                        offset.x = -contentInset.left
                    }
                } else {
                    let maxOffsetX: CGFloat = contentSize.width - bounds.size.width + contentInset.right
                    if offset.x > maxOffsetX {
                        offset.x = maxOffsetX
                    }
                }
                if offset.x < -contentInset.left {
                    offset.x = -contentInset.left
                }
            } else {
                offset.y += _autoScrollOffset
                if _autoScrollAcceleration > 0 {
                    offset.y += (_autoScrollOffset > 0 ? 1 : -1) * CGFloat(_autoScrollAcceleration) * CGFloat(_autoScrollAcceleration) * CGFloat(0.5)
                }
                _autoScrollAcceleration += 1
                offset.y = CGFloat(round(Double(offset.y)))
                if _autoScrollOffset < 0 {
                    if offset.y < -contentInset.top {
                        offset.y = -contentInset.top
                    }
                } else {
                    let maxOffsetY: CGFloat = contentSize.height - bounds.size.height + contentInset.bottom
                    if offset.y > maxOffsetY {
                        offset.y = maxOffsetY
                    }
                }
                if offset.y < -contentInset.top {
                    offset.y = -contentInset.top
                }
            }
            
            var shouldScroll: Bool
            if isVerticalForm {
                shouldScroll = abs(Float(offset.x - contentOffset.x)) > 0.5
            } else {
                shouldScroll = abs(Float(offset.y - contentOffset.y)) > 0.5
            }
            
            if shouldScroll {
                state.autoScrollTicked = true
                _trackingPoint.x += offset.x - contentOffset.x
                _trackingPoint.y += offset.y - contentOffset.y
                UIView.animate(withDuration: kAutoScrollMinimumDuration, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear], animations: {
                    self.contentOffset = offset
                }) { finished in
                    if self.state.trackingTouch {
                        if (self.state.trackingGrabber != .none) {
                            self._showMagnifierRanged()
                            self._updateTextRangeByTrackingGrabber()
                        } else if self.state.trackingPreSelect {
                            self._showMagnifierCaret()
                            self._updateTextRangeByTrackingPreSelect()
                        } else if self.state.trackingCaret {
                            if self._markedTextRange != nil {
                                self._showMagnifierRanged()
                            } else {
                                self._showMagnifierCaret()
                            }
                            self._updateTextRangeByTrackingCaret()
                        }
                        self._updateSelectionView()
                    }
                }
            } else {
                _endAutoScrollTimer()
            }
        } else {
            _endAutoScrollTimer()
        }
    }
    
    /// End current touch tracking (if is tracking now), and update the state.
    private func _endTouchTracking() {
        if !state.trackingTouch {
            return
        }
        
        state.trackingTouch = false
        state.trackingGrabber = .none
        state.trackingCaret = false
        state.trackingPreSelect = false
        state.touchMoved = .none
        state.deleteConfirm = false
        state.clearsOnInsertionOnce = false
        _trackingRange = nil
        _selectionView.caretBlinks = true
        
        _removeHighlight(animated: true)
        _hideMagnifier()
        _endLongPressTimer()
        _endAutoScrollTimer()
        _updateSelectionView()
        
        panGestureRecognizer.isEnabled = isScrollEnabled
    }
    
    /// Start a timer to fix the selection dot.
    private func _startSelectionDotFixTimer() {
        _selectionDotFixTimer?.invalidate()
        _longPressTimer = Timer.yy_scheduledTimer(with: 1 / 15.0, target: self, selector: #selector(self._fixSelectionDot), userInfo: nil, repeats: false)
        RunLoop.current.add(_longPressTimer!, forMode: .common)
    }
    
    /// End the timer.
    private func _endSelectionDotFixTimer() {
        _selectionDotFixTimer?.invalidate()
        _selectionDotFixTimer = nil
    }
    
    /// If it shows selection grabber and this view was moved by super view,
    /// update the selection dot in window.
    @objc
    private func _fixSelectionDot() {
        if YYTextUtilities.isAppExtension {
            return
        }
        let origin = yy_convertPoint(CGPoint.zero, toViewOrWindow: YYTextEffectWindow.shared)
        if !origin.equalTo(_previousOriginInWindow) {
            _previousOriginInWindow = origin
            YYTextEffectWindow.shared?.hide(selectionDot: _selectionView)
            YYTextEffectWindow.shared?.show(selectionDot: _selectionView)
        }
    }
    
    /// Try to get the character range/position with word granularity from the tokenizer.
    private func _getClosestTokenRange(at position: YYTextPosition?) -> YYTextRange? {
        
        guard let position = _correctedTextPosition(position) else {
            return nil
        }
//        var range: YYTextRange? = nil
//        if true  {       // tokenizer
            var range = tokenizer.rangeEnclosingPosition(position, with: .word, inDirection: UITextDirection(rawValue: UITextStorageDirection.forward.rawValue)) as? YYTextRange
            if range?.asRange.length == 0 {
                range = tokenizer.rangeEnclosingPosition(position, with: .word, inDirection: UITextDirection(rawValue: UITextStorageDirection.backward.rawValue)) as? YYTextRange
            }
//        }
        
        if range == nil || range?.asRange.length == 0 {
            range = _innerLayout?.textRange(byExtending: position, in: UITextLayoutDirection.right, offset: 1)
            range = _correctedTextRange(range)
            if range?.asRange.length == 0 {
                range = _innerLayout?.textRange(byExtending: position, in: UITextLayoutDirection.left, offset: 1)
                range = _correctedTextRange(range)
            }
        } else {
            let extStart: YYTextRange? = _innerLayout?.textRange(byExtending: range?.start)
            let extEnd: YYTextRange? = _innerLayout?.textRange(byExtending: range?.end)
            if let es = extStart, let ee = extEnd {
                let arr = ([es.start, es.end, ee.start, ee.end] as NSArray).sortedArray(using: #selector(es.start.compare(_:)))
                range = YYTextRange(start: arr.first as! YYTextPosition, end: arr.last as! YYTextPosition)
            }
        }
        
        range = _correctedTextRange(range)
        if range?.asRange.length == 0 {
            range = YYTextRange(range: NSRange(location: 0, length: _innerText.length))
        }
        
        return _correctedTextRange(range)
    }
    
    /// Try to get the character range/position with word granularity from the tokenizer.
    private func _getClosestTokenRange(at point: CGPoint) -> YYTextRange? {
        var point = point
        point = _convertPoint(toLayout: point)
        var touchRange: YYTextRange? = _innerLayout?.closestTextRange(at: point)
        touchRange = _correctedTextRange(touchRange)
        
        if true {  // tokenizer
            let encEnd = tokenizer.rangeEnclosingPosition(touchRange!.end, with: .word, inDirection: UITextDirection(rawValue: UITextStorageDirection.backward.rawValue)) as? YYTextRange
            let encStart = tokenizer.rangeEnclosingPosition(touchRange!.start, with: .word, inDirection: UITextDirection(rawValue: UITextStorageDirection.forward.rawValue)) as? YYTextRange
            if let es = encStart, let ee = encEnd {
                let arr = ([es.start, es.end, ee.start, ee.end] as NSArray).sortedArray(using: #selector(es.start.compare(_:)))
                touchRange = YYTextRange(start: arr.first as! YYTextPosition, end: arr.last as! YYTextPosition)
            }
        }
        
        if touchRange != nil {
            let extStart: YYTextRange? = _innerLayout?.textRange(byExtending: touchRange!.start)
            let extEnd: YYTextRange? = _innerLayout?.textRange(byExtending: touchRange!.end)
            if let es = extStart, let ee = extEnd {
                let arr = ([es.start, es.end, ee.start, ee.end] as NSArray).sortedArray(using: #selector(es.start.compare(_:)))
                touchRange = YYTextRange(start: arr.first as! YYTextPosition, end: arr.last as! YYTextPosition)
            }
        }
        
        if touchRange == nil {
            touchRange = YYTextRange()
        }
        
        if _innerText.length > 0, let r = touchRange?.asRange, r.length == 0 {
            touchRange = YYTextRange(range: NSRange(location: 0, length: _innerText.length))
        }
        
        return touchRange
    }
    
    /// Try to get the highlight property. If exist, the range will be returnd by the range pointer.
    /// If the delegate ignore the highlight, returns nil.
    private func _getHighlight(at point: CGPoint, range: NSRangePointer?) -> YYTextHighlight? {
        var point = point
        if !isHighlightable || _innerLayout?.containsHighlight == nil {
            return nil
        }
        point = _convertPoint(toLayout: point)
        var textRange: YYTextRange? = _innerLayout?.textRange(at: point)
        textRange = _correctedTextRange(textRange)
        if textRange == nil {
            return nil
        }
        var startIndex = textRange?.start.offset ?? 0
        if startIndex == _innerText.length {
            if startIndex == 0 {
                return nil
            } else {
                startIndex = startIndex - 1
            }
        }
        let highlightRange = NSRangePointer.allocate(capacity: 1)
        defer {
            highlightRange.deallocate()
        }
        let text = _delectedText ?? _innerText
        guard let highlight = text.attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textHighlightAttributeName), at: startIndex, longestEffectiveRange: highlightRange, in: NSRange(location: 0, length: _innerText.length)) as? YYTextHighlight else {
            return nil
        }
        
        var shouldTap = true
        var shouldLongPress = true
        if highlight.tapAction == nil && highlight.longPressAction == nil {
            if let d = _outerDelegate {
                if let t = d.textView?(self, shouldTap: highlight, in: highlightRange.pointee) {
                    shouldTap = t
                }
                if let l = d.textView?(self, shouldLongPress: highlight, in: highlightRange.pointee) {
                    shouldLongPress = l
                }
            }
        }
        if !shouldTap && !shouldLongPress {
            return nil
        }
        
        range?.pointee = highlightRange.pointee
        
        return highlight
    }
    
    /// Return the ranged magnifier popover offset from the baseline, base on `_trackingPoint`.
    func _getMagnifierRangedOffset() -> CGFloat {
        var magPoint: CGPoint = _trackingPoint
        magPoint = _convertPoint(toLayout: magPoint)
        if isVerticalForm {
            magPoint.x += kMagnifierRangedTrackFix
        } else {
            magPoint.y += kMagnifierRangedTrackFix
        }
        let position = _innerLayout?.closestPosition(to: magPoint)
        let lineIndex = _innerLayout?.lineIndex(for: position) ?? 0
        if lineIndex < (_innerLayout?.lines.count ?? 0) {
            let line = _innerLayout!.lines[lineIndex]
            if isVerticalForm {
                magPoint.x = YYTextUtilities.textClamp(x: magPoint.x, low: line.left, high: line.right)
                return magPoint.x - line.position.x + kMagnifierRangedPopoverOffset
            } else {
                
                magPoint.y = YYTextUtilities.textClamp(x: magPoint.y, low: line.top, high: line.bottom)
                return magPoint.y - line.position.y + kMagnifierRangedPopoverOffset
            }
        } else {
            return 0
        }
    }
    
    /// Return a TextMoveDirection from `_touchBeganPoint` to `_trackingPoint`.
    private func _getMoveDirection() -> TextMoveDirection {
        let moveH = _trackingPoint.x - _touchBeganPoint.x
        let moveV = _trackingPoint.y - _touchBeganPoint.y
        if abs(Float(moveH)) > abs(Float(moveV)) {
            if abs(Float(moveH)) > kLongPressAllowableMovement {
                return moveH > 0 ? TextMoveDirection.right : TextMoveDirection.left
            }
        } else {
            if abs(Float(moveV)) > kLongPressAllowableMovement {
                return moveV > 0 ? TextMoveDirection.bottom : TextMoveDirection.top
            }
        }
        return .none
    }
    
    /// Get the auto scroll offset in one tick time.
    private func _getAutoscrollOffset() -> CGFloat {
        if !state.trackingTouch {
            return 0
        }
        
        var bounds: CGRect = self.bounds
        bounds.origin = CGPoint.zero
        let mgr = YYTextKeyboardManager.default
        if mgr.keyboardVisible && (window != nil) && (superview != nil) && isFirstResponder && !isVerticalForm {
            var kbRect = mgr.convert(mgr.keyboardFrame, to: self)
            kbRect.origin.y -= extraAccessoryViewHeight
            kbRect.size.height += extraAccessoryViewHeight
            
            kbRect.origin.x -= contentOffset.x
            kbRect.origin.y -= contentOffset.y
            let inter: CGRect = bounds.intersection(kbRect)
            if !inter.isNull && inter.size.height > 1 && inter.size.width > 1 {
                if inter.minY > bounds.minY {
                    bounds.size.height -= inter.size.height
                }
            }
        }
        
        var point = _trackingPoint
        point.x -= contentOffset.x
        point.y -= contentOffset.y
        
        let maxOfs: CGFloat = 32 // a good value ~
        var ofs: CGFloat = 0
        if isVerticalForm {
            if point.x < contentInset.left {
                ofs = (point.x - contentInset.left - 5) * 0.5
                if ofs < -maxOfs {
                    ofs = -maxOfs
                }
            } else if point.x > bounds.size.width {
                ofs = ((point.x - bounds.size.width) + 5) * 0.5
                if ofs > maxOfs {
                    ofs = maxOfs
                }
            }
        } else {
            if point.y < contentInset.top {
                ofs = (point.y - contentInset.top - 5) * 0.5
                if ofs < -maxOfs {
                    ofs = -maxOfs
                }
            } else if point.y > bounds.size.height {
                ofs = ((point.y - bounds.size.height) + 5) * 0.5
                if ofs > maxOfs {
                    ofs = maxOfs
                }
            }
        }
        return ofs
    }
    
    /// Visible size based on bounds and insets
    private func _getVisibleSize() -> CGSize {
        var visibleSize: CGSize = bounds.size
        visibleSize.width -= contentInset.left - contentInset.right
        visibleSize.height -= contentInset.top - contentInset.bottom
        if visibleSize.width < 0 {
            visibleSize.width = 0
        }
        if visibleSize.height < 0 {
            visibleSize.height = 0
        }
        return visibleSize
    }
    
    /// Returns whether the text view can paste data from pastboard.
    private func _isPasteboardContainsValidValue() -> Bool {
        let pasteboard = UIPasteboard.general
        if (pasteboard.string?.length ?? 0) > 0 {
            return true
        }
        if (pasteboard.yy_AttributedString?.length ?? 0) > 0 {
            if allowsPasteAttributedString {
                return true
            }
        }
        if pasteboard.image != nil || (pasteboard.yy_ImageData?.count ?? 0) > 0 {
            if allowsPasteImage {
                return true
            }
        }
        return false
    }
    
    /// Save current selected attributed text to pasteboard.
    private func _copySelectedTextToPasteboard() {
        if allowsCopyAttributedString {
            let text: NSAttributedString = _innerText.attributedSubstring(from: _selectedTextRange.asRange)
            if text.length > 0 {
                UIPasteboard.general.yy_AttributedString = text
            }
        } else {
            let string = _innerText.yy_plainText(for: _selectedTextRange.asRange)
            if (string?.length ?? 0) > 0 {
                UIPasteboard.general.string = string
            }
        }
    }
    
    /// Update the text view state when pasteboard changed.
    @objc
    private func _pasteboardChanged() {
        if state.showingMenu {
            let menu = UIMenuController.shared
            menu.update()
        }
    }
    
    /// Whether the position is valid (not out of bounds).
    private func _isYYTextPositionValid(_ position: YYTextPosition?) -> Bool {
        guard let position = position else {
            return false
        }
        if position.offset < 0 {
            return false
        }
        if position.offset > _innerText.length {
            return false
        }
        if position.offset == 0 && position.affinity == YYTextAffinity.backward {
            return false
        }
        if position.offset == _innerText.length && position.affinity == YYTextAffinity.backward {
            return false
        }
        return true
    }
    
    /// Whether the range is valid (not out of bounds).
    private func _isTextRangeValid(_ range: YYTextRange?) -> Bool {
        if !_isYYTextPositionValid(range?.start) {
            return false
        }
        if !_isYYTextPositionValid(range?.end) {
            return false
        }
        return true
    }
    
    /// Correct the position if it out of bounds.
    private func _correctedTextPosition(_ position: YYTextPosition?) -> YYTextPosition? {
        guard let position = position else {
            return nil
        }
        if _isYYTextPositionValid(position) {
            return position
        }
        if position.offset < 0 {
            return YYTextPosition.position(with: 0)
        }
        if position.offset > _innerText.length {
            return YYTextPosition.position(with: _innerText.length)
        }
        if position.offset == 0 && position.affinity == YYTextAffinity.backward {
            return YYTextPosition.position(with: position.offset)
        }
        if position.offset == _innerText.length && position.affinity == YYTextAffinity.backward {
            return YYTextPosition.position(with: position.offset)
        }
        return position
    }
    
    /// Correct the range if it out of bounds.
    private func _correctedTextRange(_ range: YYTextRange?) -> YYTextRange? {
        guard let range = range else {
            return nil
        }
        if _isTextRangeValid(range) {
            return range
        }
        guard let start = _correctedTextPosition(range.start) else {
            return nil
        }
        guard let end = _correctedTextPosition(range.end) else {
            return nil
        }
        return YYTextRange(start: start, end: end)
    }
    
    /// Convert the point from this view to text layout.
    private func _convertPoint(toLayout point: CGPoint) -> CGPoint {
        var point = point
        let boundingSize: CGSize = _innerLayout!.textBoundingSize
        if _innerLayout?.container.isVerticalForm ?? false {
            var w = _innerLayout!.textBoundingSize.width
            if w < bounds.size.width {
                w = bounds.size.width
            }
            point.x += _innerLayout!.container.size.width - w
            if boundingSize.width < bounds.size.width {
                if textVerticalAlignment == YYTextVerticalAlignment.center {
                    point.x += (bounds.size.width - boundingSize.width) * 0.5
                } else if textVerticalAlignment == YYTextVerticalAlignment.bottom {
                    point.x += bounds.size.width - boundingSize.width
                }
            }
            return point
        } else {
            if boundingSize.height < bounds.size.height {
                if textVerticalAlignment == YYTextVerticalAlignment.center {
                    point.y -= (bounds.size.height - boundingSize.height) * 0.5
                } else if textVerticalAlignment == YYTextVerticalAlignment.bottom {
                    point.y -= bounds.size.height - boundingSize.height
                }
            }
            return point
        }
    }
    
    /// Convert the point from text layout to this view.
    private func _convertPoint(fromLayout point: CGPoint) -> CGPoint {
        var point = point
        let boundingSize: CGSize = _innerLayout?.textBoundingSize ?? .zero
        if _innerLayout?.container.isVerticalForm ?? false {
            var w = _innerLayout!.textBoundingSize.width
            if w < bounds.size.width {
                w = bounds.size.width
            }
            point.x -= _innerLayout!.container.size.width - w
            if boundingSize.width < bounds.size.width {
                if textVerticalAlignment == YYTextVerticalAlignment.center {
                    point.x -= (bounds.size.width - boundingSize.width) * 0.5
                } else if textVerticalAlignment == YYTextVerticalAlignment.bottom {
                    point.x -= bounds.size.width - boundingSize.width
                }
            }
            return point
        } else {
            if boundingSize.height < bounds.size.height {
                if textVerticalAlignment == YYTextVerticalAlignment.center {
                    point.y += (bounds.size.height - boundingSize.height) * 0.5
                } else if textVerticalAlignment == YYTextVerticalAlignment.bottom {
                    point.y += bounds.size.height - boundingSize.height
                }
            }
            return point
        }
    }
    
    /// Convert the rect from this view to text layout.
    private func _convertRect(toLayout rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin = _convertPoint(toLayout: rect.origin)
        return rect
    }
    
    /// Convert the rect from text layout to this view.
    private func _convertRect(fromLayout rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin = _convertPoint(fromLayout: rect.origin)
        return rect
    }
    
    /// Replace the range with the text, and change the `_selectTextRange`.
    /// The caller should make sure the `range` and `text` are valid before call this method.
    private func _replace(_ range: YYTextRange, withText text: String, notifyToDelegate notify: Bool) {
        if notify {
            _inputDelegate?.textWillChange(self)
        }
        let newRange = NSRange(location: range.asRange.location, length: text.length)
        _innerText.replaceCharacters(in: range.asRange, with: text)
        _innerText.yy_removeDiscontinuousAttributes(in: newRange)

        if notify {
            _inputDelegate?.textDidChange(self)
        }
        
        if NSEqualRanges(range.asRange, _selectedTextRange.asRange) {
            if notify {
                _inputDelegate?.selectionWillChange(self)
            }
            var newRange = NSRange(location: 0, length: 0)
            // fixbug 修复连续输入 Emoji 时出现的乱码的问题，原因：NSString 中 Emoji 表情的 length 等于2，而 Swift 中 Emoji 的 Count 等于1，_innerText 继承于 NSString，所以此处用 (text as NSString).length
            // now use text.utf16.count replace (text as NSString).length
            newRange.location = _selectedTextRange.start.offset + text.length
            _selectedTextRange = YYTextRange(range: newRange)
            if notify {
                _inputDelegate?.selectionDidChange(self)
            }
        } else {
            if range.asRange.length != text.length {
                if notify {
                    _inputDelegate?.selectionWillChange(self)
                }
                let unionRange: NSRange = NSIntersectionRange(_selectedTextRange.asRange, range.asRange)
                if unionRange.length == 0 {
                    // no intersection
                    if range.end.offset <= _selectedTextRange.start.offset {
                        let ofs = text.length - range.asRange.length
                        var newRange = _selectedTextRange.asRange
                        newRange.location += ofs
                        _selectedTextRange = YYTextRange(range: newRange)
                    }
                } else if unionRange.length == _selectedTextRange.asRange.length {
                    // target range contains selected range
                    _selectedTextRange = YYTextRange(range: NSRange(location: range.start.offset + text.length, length: 0))
                } else if range.start.offset >= _selectedTextRange.start.offset && range.end.offset <= _selectedTextRange.end.offset {
                    // target range inside selected range
                    let ofs = text.length - range.asRange.length
                    var newRange: NSRange = _selectedTextRange.asRange
                    newRange.length += ofs
                    _selectedTextRange = YYTextRange(range: newRange)
                } else {
                    // interleaving
                    if range.start.offset < _selectedTextRange.start.offset {
                        var newRange: NSRange = _selectedTextRange.asRange
                        newRange.location = range.start.offset + text.length
                        newRange.length -= unionRange.length
                        _selectedTextRange = YYTextRange(range: newRange)
                    } else {
                        var newRange: NSRange = _selectedTextRange.asRange
                        newRange.length -= unionRange.length
                        _selectedTextRange = YYTextRange(range: newRange)
                    }
                }
                _selectedTextRange = _correctedTextRange(_selectedTextRange)!
                if notify {
                    _inputDelegate?.selectionDidChange(self)
                }
            }
        }
    }
    
    /// Save current typing attributes to the attributes holder.
    private func _updateAttributesHolder() {
        if _innerText.length > 0 {
            let index: Int = _selectedTextRange.end.offset == 0 ? 0 : _selectedTextRange.end.offset - 1
            let attributes = _innerText.yy_attributes(at: index) ?? [:]
            
            _typingAttributesHolder.yy_attributes = attributes
            _typingAttributesHolder.yy_removeDiscontinuousAttributes(in: NSRange(location: 0, length: _typingAttributesHolder.length))
            _typingAttributesHolder.removeAttribute(NSAttributedString.Key(rawValue: YYTextAttribute.textBorderAttributeName), range: NSRange(location: 0, length: _typingAttributesHolder.length))
            _typingAttributesHolder.removeAttribute(NSAttributedString.Key(rawValue: YYTextAttribute.textBackgroundBorderAttributeName), range: NSRange(location: 0, length: _typingAttributesHolder.length))
        }
    }
    
    /// Update outer properties from current inner data.
    private func _updateOuterProperties() {
        _updateAttributesHolder()
        var style: NSParagraphStyle? = _innerText.yy_paragraphStyle
        if style == nil {
            style = _typingAttributesHolder.yy_paragraphStyle
        }
        if style == nil {
            style = NSParagraphStyle.default
        }
        
        var font: UIFont? = _innerText.yy_font
        if font == nil {
            font = _typingAttributesHolder.yy_font
        }
        if font == nil {
            font = YYTextView._defaultFont
        }
        
        var color: UIColor? = _innerText.yy_color
        if color == nil {
            color = _typingAttributesHolder.yy_color
        }
        if color == nil {
            color = UIColor.black
        }
        
        _setText(_innerText.yy_plainText(for: NSRange(location: 0, length: _innerText.length)))
        _setFont(font)
        _setTextColor(color)
        _setTextAlignment(style!.alignment)
        _setSelectedRange(_selectedTextRange.asRange)
        _setTypingAttributes(_typingAttributesHolder.yy_attributes)
        _setAttributedText(_innerText)
    }
    
    /// Parse text with `textParser` and update the _selectedTextRange.
    /// @return Whether changed (text or selection)
    @discardableResult
    private func _parseText() -> Bool {
        if (textParser != nil) {
            let oldTextRange = _selectedTextRange
            var newRange = _selectedTextRange.asRange
            
            _inputDelegate?.textWillChange(self)
            let textChanged = textParser!.parseText(_innerText, selectedRange: &newRange)
            _inputDelegate?.textDidChange(self)
            
            var newTextRange = YYTextRange(range: newRange)
            newTextRange = _correctedTextRange(newTextRange)!
            
            if !(oldTextRange == newTextRange) {
                _inputDelegate?.selectionWillChange(self)
                _selectedTextRange = newTextRange
                _inputDelegate?.selectionDidChange(self)
            }
            return textChanged
        }
        return false
    }
    
    /// Returns whether the text should be detected by the data detector.
    private func _shouldDetectText() -> Bool {
        if _dataDetector == nil {
            return false
        }
        if !isHighlightable {
            return false
        }
        if _linkTextAttributes?.count ?? 0 == 0 && _highlightTextAttributes?.count ?? 0 == 0 {
            return false
        }
        if isFirstResponder || _containerView.isFirstResponder {
            return false
        }
        return true
    }
    
    /// Detect the data in text and add highlight to the data range.
    /// @return Whether detected.
    private func _detectText(_ text: NSMutableAttributedString?) -> Bool {
        
        guard let text = text, text.length > 0 else {
            return false
        }
        if !_shouldDetectText() {
            return false
        }
        
        var detected = false
        _dataDetector?.enumerateMatches(in: text.string, options: [], range: NSRange(location: 0, length: text.length), using: { result, flags, stop in
            switch result!.resultType {
            case .date, .address, .link, .phoneNumber:
                detected = true
                if self.highlightTextAttributes?.count ?? 0 > 0 {
                    let highlight = YYTextHighlight(attributes: self.highlightTextAttributes)
                    text.yy_set(textHighlight: highlight, range: result!.range)
                }
                if self.linkTextAttributes?.count ?? 0 > 0 {
                    for (key, obj) in self.linkTextAttributes! {
                        text.yy_set(attribute: key, value: obj, range: result!.range)
                    }
                }
            default:
                break
            }
        })
        return detected
    }
    
    /// Returns the `root` view controller (returns nil if not found).
    private func _getRootViewController() -> UIViewController? {
        var ctrl: UIViewController? = nil
        let app: UIApplication? = YYTextUtilities.sharedApplication
        if ctrl == nil {
            ctrl = YYLabel.keyWindow?.rootViewController
        }
        if ctrl == nil {
            ctrl = app?.windows.first?.rootViewController
        }
        if ctrl == nil {
            ctrl = yy_viewController
        }
        if ctrl == nil {
            return nil
        }
        
        while ctrl?.view.window == nil && ctrl?.presentedViewController != nil {
            ctrl = ctrl?.presentedViewController
        }
        if ctrl?.view.window == nil {
            return nil
        }
        return ctrl
    }
    
    /// Clear the undo and redo stack, and capture current state to undo stack.
    private func _resetUndoAndRedoStack() {
        _undoStack.removeAll()
        _redoStack.removeAll()
        let object = YYTextViewUndoObject(text: _innerText.copy() as? NSAttributedString, range: _selectedTextRange.asRange)
        _lastTypeRange = _selectedTextRange.asRange
        
        _undoStack.append(object)
    }
    
    /// Clear the redo stack.
    private func _resetRedoStack() {
        _redoStack.removeAll()
    }
    
    /// Capture current state to undo stack.
    private func _saveToUndoStack() {
        if !allowsUndoAndRedo {
            return
        }
        let lastObject = _undoStack.last
        if let text = attributedText {
            if lastObject?.text!.isEqual(to: text) ?? false {
                return
            }
        }
        
        let object = YYTextViewUndoObject(text: (_innerText.copy() as! NSAttributedString), range: _selectedTextRange.asRange)
        _lastTypeRange = _selectedTextRange.asRange
        _undoStack.append(object)
        while _undoStack.count > maximumUndoLevel {
            _undoStack.remove(at: 0)
        }
    }
    
    /// Capture current state to redo stack.
    private func _saveToRedoStack() {
        if !allowsUndoAndRedo {
            return
        }
        let lastObject = _redoStack.last
        if let text = attributedText {
            if lastObject?.text?.isEqual(to: text) ?? false {
                return
            }
        }
        
        let object = YYTextViewUndoObject(text: (_innerText.copy() as! NSAttributedString), range: _selectedTextRange.asRange)
        _redoStack.append(object)
        while _redoStack.count > maximumUndoLevel {
            _redoStack.remove(at: 0)
        }
    }
    
    private func _canUndo() -> Bool {
        if _undoStack.count == 0 {
            return false
        }
        let object = _undoStack.last
        if object?.text?.isEqual(to: _innerText) ?? false {
            return false
        }
        return true
    }
    
    private func _canRedo() -> Bool {
        if _redoStack.count == 0 {
            return false
        }
        let object = _undoStack.last
        if object?.text?.isEqual(to: _innerText) ?? false {
            return false
        }
        return true
    }
    
    private func _undo() {
        if !_canUndo() {
            return
        }
        _saveToRedoStack()
        let object = _undoStack.last
        _undoStack.removeLast()
        
        state.insideUndoBlock = true
        _attributedText = (object?.text)!
        _selectedRange = (object?.selectedRange)!
        state.insideUndoBlock = false
    }
    
    private func _redo() {
        if !_canRedo() {
            return
        }
        _saveToUndoStack()
        let object = _redoStack.last
        _redoStack.removeLast()
        
        state.insideUndoBlock = true
        _attributedText = (object?.text)! // ?? NSAttributedString()
        _selectedRange = (object?.selectedRange)!
        state.insideUndoBlock = false
    }
    
    private func _restoreFirstResponderAfterUndoAlert() {
        if state.firstResponderBeforeUndoAlert {
            perform(#selector(self.becomeFirstResponder), with: nil, afterDelay: 0)
        }
    }
    
    /// Show undo alert if it can undo or redo.
    private func _showUndoRedoAlert() {
        #if TARGET_OS_IOS
        state.firstResponderBeforeUndoAlert = isFirstResponder
        weak var _self = self
        let strings = _localizedUndoStrings()
        let canUndo = _canUndo()
        let canRedo = _canRedo()
        
        let ctrl: UIViewController? = _getRootViewController()
        
        if canUndo && canRedo {
            
            let alert = UIAlertController(title: strings[4] as? String, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: strings[3] as? String, style: .default, handler: { action in
                _self._undo()
                _self._restoreFirstResponderAfterUndoAlert()
            }))
            alert.addAction(UIAlertAction(title: strings[2] as? String, style: .default, handler: { action in
                _self._redo()
                _self._restoreFirstResponderAfterUndoAlert()
            }))
            alert.addAction(UIAlertAction(title: strings[0] as? String, style: .cancel, handler: { action in
                _self._restoreFirstResponderAfterUndoAlert()
            }))
            ctrl?.present(alert, animated: true)
        } else if canUndo {
            
            let alert = UIAlertController(title: strings[4] as? String, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: strings[3] as? String, style: .default, handler: { action in
                _self._undo()
                _self._restoreFirstResponderAfterUndoAlert()
            }))
            alert.addAction(UIAlertAction(title: strings[0] as? String, style: .cancel, handler: { action in
                _self._restoreFirstResponderAfterUndoAlert()
            }))
            ctrl?.present(alert, animated: true)
        } else if canRedo {
            var alert = UIAlertController(title: strings[2], message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: strings[1], style: .default, handler: { action in
                self._redo()
                self._restoreFirstResponderAfterUndoAlert()
            }))
            alert.addAction(UIAlertAction(title: strings[0], style: .cancel, handler: { action in
                self._restoreFirstResponderAfterUndoAlert()
            }))
            ctrl.present(alert, animated: true)
        }
        #endif
    }
    
    static let localizedUndoStringsDic =
        ["ar": ["إلغاء", "إعادة", "إعادة الكتابة", "تراجع", "تراجع عن الكتابة"], "ca": ["Cancel·lar", "Refer", "Refer l’escriptura", "Desfer", "Desfer l’escriptura"], "cs": ["Zrušit", "Opakovat akci", "Opakovat akci Psát", "Odvolat akci", "Odvolat akci Psát"], "da": ["Annuller", "Gentag", "Gentag Indtastning", "Fortryd", "Fortryd Indtastning"], "de": ["Abbrechen", "Wiederholen", "Eingabe wiederholen", "Widerrufen", "Eingabe widerrufen"], "el": ["Ακύρωση", "Επανάληψη", "Επανάληψη πληκτρολόγησης", "Αναίρεση", "Αναίρεση πληκτρολόγησης"], "en": ["Cancel", "Redo", "Redo Typing", "Undo", "Undo Typing"], "es": ["Cancelar", "Rehacer", "Rehacer escritura", "Deshacer", "Deshacer escritura"], "es_MX": ["Cancelar", "Rehacer", "Rehacer escritura", "Deshacer", "Deshacer escritura"], "fi": ["Kumoa", "Tee sittenkin", "Kirjoita sittenkin", "Peru", "Peru kirjoitus"], "fr": ["Annuler", "Rétablir", "Rétablir la saisie", "Annuler", "Annuler la saisie"], "he": ["ביטול", "חזור על הפעולה האחרונה", "חזור על הקלדה", "בטל", "בטל הקלדה"], "hr": ["Odustani", "Ponovi", "Ponovno upiši", "Poništi", "Poništi upisivanje"], "hu": ["Mégsem", "Ismétlés", "Gépelés ismétlése", "Visszavonás", "Gépelés visszavonása"], "id": ["Batalkan", "Ulang", "Ulang Pengetikan", "Kembalikan", "Batalkan Pengetikan"], "it": ["Annulla", "Ripristina originale", "Ripristina Inserimento", "Annulla", "Annulla Inserimento"], "ja": ["キャンセル", "やり直す", "やり直す - 入力", "取り消す", "取り消す - 入力"], "ko": ["취소", "실행 복귀", "입력 복귀", "실행 취소", "입력 실행 취소"], "ms": ["Batal", "Buat semula", "Ulang Penaipan", "Buat asal", "Buat asal Penaipan"], "nb": ["Avbryt", "Utfør likevel", "Utfør skriving likevel", "Angre", "Angre skriving"], "nl": ["Annuleer", "Opnieuw", "Opnieuw typen", "Herstel", "Herstel typen"], "pl": ["Anuluj", "Przywróć", "Przywróć Wpisz", "Cofnij", "Cofnij Wpisz"], "pt": ["Cancelar", "Refazer", "Refazer Digitação", "Desfazer", "Desfazer Digitação"], "pt_PT": ["Cancelar", "Refazer", "Refazer digitar", "Desfazer", "Desfazer digitar"], "ro": ["Renunță", "Refă", "Refă tastare", "Anulează", "Anulează tastare"], "ru": ["Отменить", "Повторить", "Повторить набор на клавиатуре", "Отменить", "Отменить набор на клавиатуре"], "sk": ["Zrušiť", "Obnoviť", "Obnoviť písanie", "Odvolať", "Odvolať písanie"], "sv": ["Avbryt", "Gör om", "Gör om skriven text", "Ångra", "Ångra skriven text"], "th": ["ยกเลิก", "ทำกลับมาใหม่", "ป้อนกลับมาใหม่", "เลิกทำ", "เลิกป้อน"], "tr": ["Vazgeç", "Yinele", "Yazmayı Yinele", "Geri Al", "Yazmayı Geri Al"], "uk": ["Скасувати", "Повторити", "Повторити введення", "Відмінити", "Відмінити введення"], "vi": ["Hủy", "Làm lại", "Làm lại thao tác Nhập", "Hoàn tác", "Hoàn tác thao tác Nhập"], "zh": ["取消", "重做", "重做键入", "撤销", "撤销键入"], "zh_CN": ["取消", "重做", "重做键入", "撤销", "撤销键入"], "zh_HK": ["取消", "重做", "重做輸入", "還原", "還原輸入"], "zh_TW": ["取消", "重做", "重做輸入", "還原", "還原輸入"]]
    
    static let localizedUndoStrings: [String] = {
        var strings: [String] = []
        
        var preferred = Bundle.main.preferredLocalizations.first ?? ""
        if preferred == "" {
            preferred = "English"
        }
        var canonical = NSLocale.canonicalLocaleIdentifier(from: preferred)
        if canonical == "" {
            canonical = "en"
        }
        strings = localizedUndoStringsDic[canonical] ?? []
        if strings.count == 0 && ((canonical as NSString).range(of: "_").location != NSNotFound) {
            
            if let prefix = canonical.components(separatedBy: "_").first, prefix != "" {
                strings = localizedUndoStringsDic[prefix] ?? []
            }
        }
        if strings.count == 0 {
            strings = localizedUndoStringsDic["en"] ?? []
        }
        
        return strings
    }()
    
    private func _localizedUndoStrings() -> [String] {
        return YYTextView.localizedUndoStrings
    }
    
    /// Returns the default font for text view (same as CoreText).
    private static let _defaultFont = UIFont.systemFont(ofSize: 12)
    
    /// Returns the default tint color for text view (used for caret and select range background).
    private static let _defaultTintColor = UIColor(red: 69 / 255.0, green: 111 / 255.0, blue: 238 / 255.0, alpha: 1)
    
    /// Returns the default placeholder color for text view (same as UITextField).
    private static let _defaultPlaceholderColor = UIColor(red: 0, green: 0, blue: 25 / 255.0, alpha: 44 / 255.0)
    
    // MARK: - 检测字数
    private func checkWordCount(_ length:Int = 0) {
        var mode:UITextInputMode?
        if UITextInputMode.activeInputModes.count > 0 {
            mode = UITextInputMode.activeInputModes[0]
        }
        
        let lang = mode?.primaryLanguage
        if lang == "zh-Hans" {
            if (markedTextRange as? YYTextRange) != nil {
                return
            }
        }
                
        if (maxWordCount != 0 && text.count > maxWordCount) {
            text = text.subString(to: maxWordCount)
        }
        
        _outerDelegate?.textViewWordCountChange?(self, count:text.count)
    }
    
    // MARK: - Private Setter
    private func _setText(_ text: String?) {
        if _text == text {
            return
        }
        willChangeValue(forKey: "text")
        _text = text ?? ""
        didChangeValue(forKey: "text")
        accessibilityLabel = _text
    }
    
    private func _setFont(_ font: UIFont?) {
        if _font == font {
            return
        }
        willChangeValue(forKey: "font")
        _font = font ?? YYTextView._defaultFont
        didChangeValue(forKey: "font")
    }
    
    private func _setTextColor(_ textColor: UIColor?) {
        if _textColor === textColor {
            return
        }
        if _textColor != nil && textColor != nil {
            if CFGetTypeID(_textColor!.cgColor) == CFGetTypeID(textColor!.cgColor) && CFGetTypeID(_textColor!.cgColor) == CGColor.typeID {
                if _textColor == textColor {
                    return
                }
            }
        }
        willChangeValue(forKey: "textColor")
        _textColor = textColor
        didChangeValue(forKey: "textColor")
    }
    
    private func _setTextAlignment(_ textAlignment: NSTextAlignment) {
        if _textAlignment == textAlignment {
            return
        }
        willChangeValue(forKey: "textAlignment")
        _textAlignment = textAlignment
        didChangeValue(forKey: "textAlignment")
    }
    
    private func _setDataDetectorTypes(_ dataDetectorTypes: UIDataDetectorTypes) {
        if _dataDetectorTypes == dataDetectorTypes {
            return
        }
        willChangeValue(forKey: "dataDetectorTypes")
        _dataDetectorTypes = dataDetectorTypes
        didChangeValue(forKey: "dataDetectorTypes")
    }
    
    private func _setLinkTextAttributes(_ linkTextAttributes: [NSAttributedString.Key : Any]?) {
        let dic1 = _linkTextAttributes as NSDictionary?, dic2 = linkTextAttributes as NSDictionary?
        if dic1 == dic2 || dic1?.isEqual(dic2) ?? false {
            return
        }
        willChangeValue(forKey: "linkTextAttributes")
        _linkTextAttributes = linkTextAttributes
        didChangeValue(forKey: "linkTextAttributes")
    }
    
    private func _sethighlightTextAttributes(_ highlightTextAttributes: [NSAttributedString.Key : Any]?) {
        let dic1 = _highlightTextAttributes as NSDictionary?, dic2 = highlightTextAttributes as NSDictionary?
        if dic1 == dic2 || dic1?.isEqual(dic2) ?? false {
            return
        }
        willChangeValue(forKey: "highlightTextAttributes")
        _highlightTextAttributes = highlightTextAttributes
        didChangeValue(forKey: "highlightTextAttributes")
    }
    
    private func _setYYTextParser(_ textParser: YYTextParser?) {
        if _textParser === textParser || _textParser?.isEqual(textParser) ?? false {
            return
        }
        willChangeValue(forKey: "textParser")
        _textParser = textParser
        didChangeValue(forKey: "textParser")
    }
    
    private func _setAttributedText(_ attributedText: NSAttributedString?) {
        if _attributedText == attributedText {
            return
        }
        willChangeValue(forKey: "attributedText")
        _attributedText = attributedText ?? NSMutableAttributedString()
        didChangeValue(forKey: "attributedText")
    }
    
    private func _setYYTextContainerInset(_ textContainerInset: UIEdgeInsets) {
        if _textContainerInset == textContainerInset {
            return
        }
        willChangeValue(forKey: "textContainerInset")
        _textContainerInset = textContainerInset
        didChangeValue(forKey: "textContainerInset")
    }
    
    private func _setExclusionPaths(_ exclusionPaths: [UIBezierPath]?) {
        if _exclusionPaths == exclusionPaths {
            return
        }
        willChangeValue(forKey: "exclusionPaths")
        _exclusionPaths = exclusionPaths
        didChangeValue(forKey: "exclusionPaths")
    }
    
    private func _setVerticalForm(_ verticalForm: Bool) {
        if _verticalForm == verticalForm {
            return
        }
        willChangeValue(forKey: "isVerticalForm")
        _verticalForm = verticalForm
        didChangeValue(forKey: "isVerticalForm")
    }
    
    private func _setLinePositionModifier(_ linePositionModifier: YYTextLinePositionModifier?) {
        if _linePositionModifier === linePositionModifier {
            return
        }
        willChangeValue(forKey: "linePositionModifier")
        _linePositionModifier = linePositionModifier
        didChangeValue(forKey: "linePositionModifier")
    }
    
    private func _setSelectedRange(_ selectedRange: NSRange) {
        if NSEqualRanges(_selectedRange, selectedRange) {
            return
        }
        willChangeValue(forKey: "selectedRange")
        _selectedRange = selectedRange
        didChangeValue(forKey: "selectedRange")
        
        _outerDelegate?.textViewDidChangeSelection?(self)
    }
    
    private func _setTypingAttributes(_ typingAttributes: [NSAttributedString.Key : Any]?) {
        let dic1 = _typingAttributes as NSDictionary?, dic2 = typingAttributes as NSDictionary?
        if dic1 == dic2 || dic1?.isEqual(dic2) ?? false {
            return
        }
        willChangeValue(forKey: "typingAttributes")
        _typingAttributes = typingAttributes
        didChangeValue(forKey: "typingAttributes")
    }
    
    // MARK: - Private Init
    private func _initTextView() {
        delaysContentTouches = false
        canCancelContentTouches = true
        clipsToBounds = true
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        super.delegate = self
        
        _innerContainer.insets = kDefaultInset
        
        let name = NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String)
        let c = YYTextView._defaultTintColor.cgColor
        _linkTextAttributes = [NSAttributedString.Key.foregroundColor: YYTextView._defaultTintColor, name: c]
        
        
        let highlight = YYTextHighlight()
        let border = YYTextBorder()
        border.insets = UIEdgeInsets(top: -2, left: -2, bottom: -2, right: -2)
        border.fillColor = UIColor(white: 0.1, alpha: 0.2)
        border.cornerRadius = 3
        highlight.border = border
        _highlightTextAttributes = highlight.attributes
        
        _placeHolderView.isUserInteractionEnabled = false
        _placeHolderView.isHidden = true
        
        _containerView = YYTextContainerView()
        _containerView.hostView = self
        
        _selectionView = YYTextSelectionView()
        _selectionView.isUserInteractionEnabled = false
        _selectionView.hostView = self
        _selectionView.color = YYTextView._defaultTintColor
        
        _magnifierCaret = YYTextMagnifier.magnifier(with: YYTextMagnifierType.caret)!
        _magnifierCaret.hostView = _containerView
        _magnifierRanged = YYTextMagnifier.magnifier(with: YYTextMagnifierType.ranged)!
        _magnifierRanged.hostView = _containerView
        
        addSubview(_placeHolderView)
        addSubview(_containerView)
        addSubview(_selectionView)
        
        self.debugOption = YYTextDebugOption.shared
        YYTextDebugOption.add(self)
        
        _updateInnerContainerSize()
        _update()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self._pasteboardChanged), name: UIPasteboard.changedNotification, object: nil)
        YYTextKeyboardManager.default.add(observer: self)
        
        isAccessibilityElement = true
    }
    
    // MARK: - Public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tokenizer = UITextInputStringTokenizer(textInput: self)
        _initTextView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIPasteboard.changedNotification, object: nil)
        YYTextKeyboardManager.default.remove(observer: self)
        
        YYTextEffectWindow.shared?.hide(selectionDot: _selectionView)
        YYTextEffectWindow.shared?.hide(_magnifierCaret)
        YYTextEffectWindow.shared?.hide(_magnifierRanged)
        
        YYTextDebugOption.remove(self)
        
        _longPressTimer?.invalidate()
        _autoScrollTimer?.invalidate()
        _selectionDotFixTimer?.invalidate()
    }
    
    // MARK: - Override For Protect
    
    open override var isMultipleTouchEnabled: Bool {
        get {
            return super.isMultipleTouchEnabled
        }
        set {
            super.isMultipleTouchEnabled = false // must not enabled
        }
    }
    
    open override var contentInset: UIEdgeInsets {
        get {
            return super.contentInset
        }
        set {
            let oldInsets = self.contentInset
            if _insetModifiedByKeyboard {
                _originalContentInset = newValue
            } else {
                super.contentInset = newValue
                if oldInsets != newValue { // changed
                    _updateInnerContainerSize()
                    _commitUpdate()
                    _commitPlaceholderUpdate()
                }
            }
        }
    }
    
    open override var scrollIndicatorInsets: UIEdgeInsets {
        get {
            return super.verticalScrollIndicatorInsets
        }
        set {
            if _insetModifiedByKeyboard {
                _originalScrollIndicatorInsets = newValue
            } else {
                super.scrollIndicatorInsets = newValue
            }
        }
    }
    
    open override var frame: CGRect {
        set {
            let oldSize: CGSize = bounds.size
            super.frame = newValue
            let newSize: CGSize = bounds.size
            let changed: Bool = _innerContainer.isVerticalForm ? (oldSize.height != newSize.height) : (oldSize.width != newSize.width)
            if changed {
                _updateInnerContainerSize()
                _commitUpdate()
            }
            if !oldSize.equalTo(newSize) {
                _commitPlaceholderUpdate()
            }
        }
        get {
            return super.frame
        }
    }
    
    open override var bounds: CGRect {
        set {
            let oldSize: CGSize = self.bounds.size
            super.bounds = newValue
            let newSize: CGSize = self.bounds.size
            let changed: Bool = _innerContainer.isVerticalForm ? (oldSize.height != newSize.height) : (oldSize.width != newSize.width)
            if changed {
                _updateInnerContainerSize()
                _commitUpdate()
            }
            if !oldSize.equalTo(newSize) {
                _commitPlaceholderUpdate()
            }
        }
        get {
            return super.bounds
        }
    }
    
    open override func tintColorDidChange() {
        if responds(to: #selector(setter: self.tintColor)) {
            let color: UIColor? = tintColor
            var attrs = _highlightTextAttributes
            var linkAttrs = _linkTextAttributes ?? [NSAttributedString.Key : Any]()
            
            if color == nil {
                attrs?.removeValue(forKey: .foregroundColor)
                attrs?.removeValue(forKey: NSAttributedString.Key(kCTForegroundColorAttributeName as String))
                linkAttrs[.foregroundColor] = YYTextView._defaultTintColor
                linkAttrs[NSAttributedString.Key(kCTForegroundColorAttributeName as String)] = YYTextView._defaultTintColor.cgColor
            } else {
                attrs?[.foregroundColor] = color
                attrs?[NSAttributedString.Key(kCTForegroundColorAttributeName as String)] = color?.cgColor
                linkAttrs[.foregroundColor] = color
                linkAttrs[NSAttributedString.Key(kCTForegroundColorAttributeName as String)] = color?.cgColor
            }
            highlightTextAttributes = attrs
            _selectionView.color = color != nil ? color : YYTextView._defaultTintColor
            linkTextAttributes = linkAttrs
            _commitUpdate()
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        if !isVerticalForm && size.width <= 0 {
            size.width = YYTextContainer.textContainerMaxSize.width
        }
        if isVerticalForm && size.height <= 0 {
            size.height = YYTextContainer.textContainerMaxSize.height
        }
        
        if (!isVerticalForm && size.width == bounds.size.width) || (isVerticalForm && size.height == bounds.size.height) {
            _updateIfNeeded()
            if !isVerticalForm {
                if _containerView.bounds.size.height <= size.height {
                    return _containerView.bounds.size
                }
            } else {
                if _containerView.bounds.size.width <= size.width {
                    return _containerView.bounds.size
                }
            }
        }
        
        if !isVerticalForm {
            size.height = YYTextContainer.textContainerMaxSize.height
        } else {
            size.width = YYTextContainer.textContainerMaxSize.width
        }
        
        let container: YYTextContainer? = _innerContainer.copy() as? YYTextContainer
        container?.size = size
        
        let layout = YYTextLayout(container: container, text: _innerText)
        return layout?.textBoundingSize ?? .zero
    }
    
    // MARK: - Override UIResponder
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        _updateIfNeeded()
        let touch = touches.first!
        let point = touch.location(in: _containerView)
        
        _trackingTime = touch.timestamp
        _touchBeganTime = _trackingTime
        _trackingPoint = point
        _touchBeganPoint = _trackingPoint
        _trackingRange = _selectedTextRange
        
        state.trackingGrabber = .none
        state.trackingCaret = false
        state.trackingPreSelect = false
        state.trackingTouch = true
        state.swallowTouch = true
        state.touchMoved = .none
        
        if !isFirstResponder && !state.selectedWithoutEdit && isHighlightable {
            _highlight = _getHighlight(at: point, range: &_highlightRange)
            _highlightLayout = nil
        }
        
        if (!isSelectable && _highlight == nil) || state.ignoreTouchBegan {
            state.swallowTouch = false
            state.trackingTouch = false
        }
        
        if state.trackingTouch {
            _startLongPressTimer()
            if _highlight != nil {
                _showHighlight(animated: false)
            } else {
                if _selectionView.isGrabberContains(point) {
                    // track grabber
                    panGestureRecognizer.isEnabled = false // disable scroll view
                    _hideMenu()
                    state.trackingGrabber = _selectionView.isStartGrabberContains(point) ? .start : .end
                    _magnifierRangedOffset = _getMagnifierRangedOffset()
                } else {
                    if _selectedTextRange.asRange.length == 0 && isFirstResponder {
                        if _selectionView.isCaretContains(point) {
                            // track caret
                            state.trackingCaret = true
                            panGestureRecognizer.isEnabled = false // disable scroll view
                        }
                    }
                }
            }
            _updateSelectionView()
        }
        
        if !state.swallowTouch {
            super.touchesBegan(touches, with: event)
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        _updateIfNeeded()
        let touch = touches.first!
        let point = touch.location(in: _containerView)
        
        _trackingTime = touch.timestamp
        _trackingPoint = point
        
        if state.touchMoved == .none {
            state.touchMoved = _getMoveDirection()
            if state.touchMoved != .none {
                _endLongPressTimer()
            }
        }
        state.clearsOnInsertionOnce = false
        
        if state.trackingTouch {
            var showMagnifierCaret = false
            var showMagnifierRanged = false
            
            if _highlight != nil {
                
                let highlight = _getHighlight(at: _trackingPoint, range: nil)
                if highlight == _highlight {
                    _showHighlight(animated: true)
                } else {
                    _hideHighlight(animated: true)
                }
            } else {
                _trackingRange = _selectedTextRange
                if state.trackingGrabber != .none {
                    panGestureRecognizer.isEnabled = false
                    _hideMenu()
                    _updateTextRangeByTrackingGrabber()
                    showMagnifierRanged = true
                } else if state.trackingPreSelect {
                    _updateTextRangeByTrackingPreSelect()
                    showMagnifierCaret = true
                } else if state.trackingCaret || (_markedTextRange != nil) || isFirstResponder {
                    if state.trackingCaret || state.touchMoved != .none {
                        state.trackingCaret = true
                        _hideMenu()
                        if isVerticalForm {
                            if state.touchMoved == .top || state.touchMoved == .bottom {
                                panGestureRecognizer.isEnabled = false
                            }
                        } else {
                            if state.touchMoved == .left || state.touchMoved == .right {
                                panGestureRecognizer.isEnabled = false
                            }
                        }
                        _updateTextRangeByTrackingCaret()
                        if _markedTextRange != nil {
                            showMagnifierRanged = true
                        } else {
                            showMagnifierCaret = true
                        }
                    }
                }
            }
            _updateSelectionView()
            if showMagnifierCaret {
                _showMagnifierCaret()
            }
            if showMagnifierRanged {
                _showMagnifierRanged()
            }
        }
        
        let autoScrollOffset: CGFloat = _getAutoscrollOffset()
        if autoScrollOffset != _autoScrollOffset {
            if abs(Float(autoScrollOffset)) < abs(Float(_autoScrollOffset)) {
//                _autoScrollAcceleration *= 0.5
                _autoScrollAcceleration /= 2
            }
            _autoScrollOffset = autoScrollOffset
            if _autoScrollOffset != 0 && state.touchMoved != .none {
                _startAutoScrollTimer()
            }
        }
        
        if !state.swallowTouch {
            super.touchesMoved(touches, with: event)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        _updateIfNeeded()
        
        let touch = touches.first!
        let point = touch.location(in: _containerView)
        
        _trackingTime = touch.timestamp
        _trackingPoint = point
        
        if state.touchMoved == .none {
            state.touchMoved = _getMoveDirection()
        }
        if state.trackingTouch {
            _hideMagnifier()
            
            if _highlight != nil {
                if state.showingHighlight {
                    if _highlight!.tapAction != nil {
                        var rect: CGRect = _innerLayout!.rect(for: YYTextRange(range: _highlightRange))
                        rect = _convertRect(fromLayout: rect)
                        _highlight!.tapAction!(self, _innerText, _highlightRange, rect)
                    } else {
                        var shouldTap = true
                        if let t = _outerDelegate?.textView?(self, shouldTap: _highlight!, in: _highlightRange) {
                            shouldTap = t
                        }
                        if shouldTap {
                            var rect = _innerLayout!.rect(for: YYTextRange(range: _highlightRange))
                            rect = _convertRect(fromLayout: rect)
                            _outerDelegate?.textView?(self, didTap: _highlight!, in: _highlightRange, rect: rect)
                        }
                    }
                    _removeHighlight(animated: true)
                }
            } else {
                if state.trackingCaret {
                    if state.touchMoved != .none {
                        _updateTextRangeByTrackingCaret()
                        _showMenu()
                    } else {
                        if state.showingMenu {
                            _hideMenu()
                        } else {
                            _showMenu()
                        }
                    }
                } else if state.trackingGrabber != .none {
                    _updateTextRangeByTrackingGrabber()
                    _showMenu()
                } else if state.trackingPreSelect {
                    _updateTextRangeByTrackingPreSelect()
                    if _trackingRange!.asRange.length > 0 {
                        state.selectedWithoutEdit = true
                        _showMenu()
                    } else {
                        perform(#selector(self.becomeFirstResponder), with: nil, afterDelay: 0)
                    }
                } else if state.deleteConfirm || (markedTextRange != nil) {
                    _updateTextRangeByTrackingCaret()
                    _hideMenu()
                } else {
                    if state.touchMoved == .none {
                        if state.selectedWithoutEdit {
                            state.selectedWithoutEdit = false
                            _hideMenu()
                        } else {
                            if isFirstResponder {
                                let oldRange = _trackingRange
                                _updateTextRangeByTrackingCaret()
                                if oldRange == _trackingRange {
                                    if state.showingMenu {
                                        _hideMenu()
                                    } else {
                                        _showMenu()
                                    }
                                } else {
                                    _hideMenu()
                                }
                            } else {
                                _hideMenu()
                                if state.clearsOnInsertionOnce {
                                    state.clearsOnInsertionOnce = false
                                    _selectedTextRange = YYTextRange(range: NSRange(location: 0, length: _innerText.length))
                                    _setSelectedRange(_selectedTextRange.asRange)
                                } else {
                                    _updateTextRangeByTrackingCaret()
                                }
                                perform(#selector(self.becomeFirstResponder), with: nil, afterDelay: 0)
                            }
                        }
                    }
                }
            }
            if _trackingRange != nil && (!(_trackingRange == _selectedTextRange) || state.trackingPreSelect) {
                if !(_trackingRange == _selectedTextRange) {
                    _inputDelegate?.selectionWillChange(self)
                    _selectedTextRange = _trackingRange!
                    _inputDelegate?.selectionDidChange(self)
                    _updateAttributesHolder()
                    _updateOuterProperties()
                }
                if state.trackingGrabber == .none && !state.trackingPreSelect {
                    _scrollRangeToVisible(_selectedTextRange)
                }
            }
            
            _endTouchTracking()
        }
        if !state.swallowTouch {
            super.touchesEnded(touches, with: event)
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        _endTouchTracking()
        _hideMenu()
        
        if !state.swallowTouch {
            super.touchesCancelled(touches, with: event)
        }
    }
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if motion == .motionShake && allowsUndoAndRedo {
            if !YYTextUtilities.isAppExtension {
                _showUndoRedoAlert()
            }
        } else {
            super.motionEnded(motion, with: event)
        }
    }
    
    override open var canBecomeFirstResponder: Bool {
        if !isSelectable {
            return false
        }
        if !isEditable {
            return false
        }
        if state.ignoreFirstResponder {
            return false
        }
        if let should = _outerDelegate?.textViewShouldBeginEditing?(self) {
            if !should {
                return false
            }
        }
        return true
    }
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        let isFirstResponder: Bool = self.isFirstResponder
        if isFirstResponder {
            return true
        }
        let shouldDetectData = _shouldDetectText()
        let become: Bool = super.becomeFirstResponder()
        if !isFirstResponder && become {
            _endTouchTracking()
            _hideMenu()
            
            state.selectedWithoutEdit = false
            if shouldDetectData != _shouldDetectText() {
                _update()
            }
            _updateIfNeeded()
            _updateSelectionView()
            perform(#selector(self._scrollSelectedRangeToVisible), with: nil, afterDelay: 0)
            
            _outerDelegate?.textViewDidBeginEditing?(self)
                
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YYTextView.textViewTextDidBeginEditingNotification), object: self)
        }
        return become
    }
    
    open override var canResignFirstResponder: Bool {
        if !isFirstResponder {
            return true
        }
        if let should = _outerDelegate?.textViewShouldEndEditing?(self) {
            return !should
        }
        return true
    }
    
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        let isFirstResponder: Bool = self.isFirstResponder
        if !isFirstResponder {
            return true
        }
        let resign: Bool = super.resignFirstResponder()
        if resign {
            if (markedTextRange != nil) {
                markedTextRange = nil
                _parseText()
                _setText(_innerText.yy_plainText(for: NSRange(location: 0, length: _innerText.length)))
            }
            state.selectedWithoutEdit = false
            if _shouldDetectText() {
                _update()
            }
            _endTouchTracking()
            _hideMenu()
            _updateIfNeeded()
            _updateSelectionView()
            _restoreInsets(animated: true)
            
            _outerDelegate?.textViewDidEndEditing?(self)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YYTextView.textViewTextDidEndEditingNotification), object: self)
        }
        return resign
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        /*
         ------------------------------------------------------
         Default menu actions list:
         cut:                                   Cut
         copy:                                  Copy
         select:                                Select
         selectAll:                             Select All
         paste:                                 Paste
         delete:                                Delete
         _promptForReplace:                     Replace...
         _transliterateChinese:                 简⇄繁
         _showTextStyleOptions:                 𝐁𝐼𝐔
         _define:                               Define
         _addShortcut:                          Add...
         _accessibilitySpeak:                   Speak
         _accessibilitySpeakLanguageSelection:  Speak...
         _accessibilityPauseSpeaking:           Pause Speak
         makeTextWritingDirectionRightToLeft:   ⇋
         makeTextWritingDirectionLeftToRight:   ⇌
         
         ------------------------------------------------------
         Default attribute modifier list:
         toggleBoldface:
         toggleItalics:
         toggleUnderline:
         increaseSize:
         decreaseSize:
         */
        
        if _selectedTextRange.asRange.length == 0 {
            if action == #selector(self.select(_:)) || action == #selector(self.selectAll(_:)) {
                return _innerText.length > 0
            }
            if action == #selector(self.paste(_:)) {
                return _isPasteboardContainsValidValue()
            }
        } else {
            if action == #selector(self.cut(_:)) {
                return isFirstResponder && isEditable
            }
            if action == #selector(self.copy(_:)) {
                return true
            }
            if action == #selector(self.selectAll(_:)) {
                return _selectedTextRange.asRange.length < _innerText.length
            }
            if action == #selector(self.paste(_:)) {
                return isFirstResponder && isEditable && _isPasteboardContainsValidValue()
            }
            let selString = NSStringFromSelector(action)
            if selString.hasSuffix("define:") && selString.hasPrefix("_") {
                return _getRootViewController() != nil
            }
        }
        return false
    }
    
    override open func reloadInputViews() {
        super.reloadInputViews()
        if (markedTextRange != nil) {
            unmarkText()
        }
    }
    
    // MARK: - Override NSObject(UIResponderStandardEditActions)
    
    override open func cut(_ sender: Any?) {
        _endTouchTracking()
        if _selectedTextRange.asRange.length == 0 {
            return
        }
        
        _copySelectedTextToPasteboard()
        _saveToUndoStack()
        _resetRedoStack()
        replace(_selectedTextRange, withText: "")
    }
    
    override open func copy(_ sender: Any?) {
        _endTouchTracking()
        _copySelectedTextToPasteboard()
    }
    
    override open func paste(_ sender: Any?) {
        _endTouchTracking()
        let p = UIPasteboard.general
        var atr: NSAttributedString? = nil
        
        if allowsPasteAttributedString {
            atr = p.yy_AttributedString
            if atr?.length ?? 0 == 0 {
                atr = nil
            }
        }
        if atr == nil && allowsPasteImage {
            var img: UIImage? = nil
            
            #if canImport(YYImage)
            let scale: CGFloat = UIScreen.main.scale
            if let d = p.yy_GIFData {
                img = YYImage(data: d, scale: scale)
            }
            if img == nil, let d = p.yy_PNGData {
                img = YYImage(data: d, scale: scale)
            }
            if img == nil, let d = p.yy_WEBPData {
                img = YYImage(data: d, scale: scale)
            }
            #endif
            
            if img == nil {
                img = p.image
            }
            if img == nil && (p.yy_ImageData != nil) {
                img = UIImage(data: p.yy_ImageData!, scale: YYTextUtilities.textScreenScale)
            }
            if let tmpimg = img, tmpimg.size.width > 1, tmpimg.size.height > 1 {
                var content: Any = tmpimg
                
                #if canImport(YYImage)
                if tmpimg.conforms(to: YYAnimatedImage.self) {
                    let frameCount = (tmpimg as! YYAnimatedImage).animatedImageFrameCount()
                    if frameCount > 1 {
                        let imgView = YYAnimatedImageView()
                        imgView.image = img
                        imgView.frame = CGRect(x: 0, y: 0, width: tmpimg.size.width, height: tmpimg.size.height)
                        content = imgView
                    }
                }
                #endif
                
                if (content is UIImage) && tmpimg.images?.count ?? 0 > 1 {
                    let imgView = UIImageView()
                    imgView.image = img
                    imgView.frame = CGRect(x: 0, y: 0, width: tmpimg.size.width, height: tmpimg.size.height)
                    content = imgView
                }
                
                let attText = NSAttributedString.yy_attachmentString(with: content, contentMode: UIView.ContentMode.scaleToFill, width: tmpimg.size.width, ascent: tmpimg.size.height, descent: 0)
                
                if let attrs = _typingAttributesHolder.yy_attributes {
                    attText.addAttributes(attrs, range: NSRange(location: 0, length: attText.length))
                }
                atr = attText
            }
        }
        if let atr = atr {
            let endPosition: Int = _selectedTextRange.start.offset + atr.length
            let text = _innerText.mutableCopy() as! NSMutableAttributedString
            text.replaceCharacters(in: _selectedTextRange.asRange, with: atr)
            attributedText = text
            let pos = _correctedTextPosition(YYTextPosition(offset: endPosition))
            let range = _innerLayout?.textRange(byExtending: pos)
            if let range = _correctedTextRange(range) {
                selectedRange = NSRange(location: range.end.offset, length: 0)
            }
        } else {
            let string = p.string
            if let s = string, s != "" {
                _saveToUndoStack()
                _resetRedoStack()
                replace(_selectedTextRange, withText: s)
            }
        }
    }
    
    override open func select(_ sender: Any?) {
        _endTouchTracking()
        
        if _selectedTextRange.asRange.length > 0 || _innerText.length == 0 {
            return
        }
        
        if let newRange = _getClosestTokenRange(at: _selectedTextRange.start), newRange.asRange.length > 0 {
            _inputDelegate?.selectionWillChange(self)
            _selectedTextRange = newRange
            _inputDelegate?.selectionDidChange(self)
        }
        
        _updateIfNeeded()
        _updateOuterProperties()
        _updateSelectionView()
        _hideMenu()
        _showMenu()
    }
    
    override open func selectAll(_ sender: Any?) {
        _trackingRange = nil
        _inputDelegate?.selectionWillChange(self)
        _selectedTextRange = YYTextRange(range: NSRange(location: 0, length: _innerText.length))
        _inputDelegate?.selectionDidChange(self)
        
        _updateIfNeeded()
        _updateOuterProperties()
        _updateSelectionView()
        _hideMenu()
        _showMenu()
    }
    
    func _define(_ sender: Any?) {
        _hideMenu()
        
        guard let string = _innerText.yy_plainText(for: _selectedTextRange.asRange), string != "" else {
            return
        }
        let resign: Bool = resignFirstResponder()
        if !resign {
            return
        }
        
        let ref = UIReferenceLibraryViewController(term: string)
        ref.view.backgroundColor = UIColor.white
        _getRootViewController()?.present(ref, animated: true) {
        }
    }
    
    // MARK: - Overrice NSObject(NSKeyValueObservingCustomization)
    
    static let automaticallyNotifiesObserversKeys: Set<AnyHashable>? = {
        var keys = Set<AnyHashable>(["text", "font", "textColor", "textAlignment", "dataDetectorTypes", "linkTextAttributes", "highlightTextAttributes", "textParser", "attributedText", "textVerticalAlignment", "textContainerInset", "exclusionPaths", "isVerticalForm", "linePositionModifier", "selectedRange", "typingAttributes"])
        return keys
    }()
    
    override open class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        // `dispatch_once()` call was converted to a static variable initializer
        if automaticallyNotifiesObserversKeys?.contains(key) != nil {
            return false
        }
        return super.automaticallyNotifiesObservers(forKey: key)
    }
    
    // MARK: - @protocol NSCoding
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _initTextView()
        attributedText = aDecoder.decodeObject(forKey: "attributedText") as? NSAttributedString
        if let decode = (aDecoder.decodeObject(forKey: "selectedRange") as? NSValue)?.rangeValue {
            selectedRange = decode
        }
        textVerticalAlignment = YYTextVerticalAlignment(rawValue: aDecoder.decodeInteger(forKey: "textVerticalAlignment"))!
        dataDetectorTypes = UIDataDetectorTypes(rawValue: UInt(aDecoder.decodeInteger(forKey: "dataDetectorTypes")))
        textContainerInset = aDecoder.decodeUIEdgeInsets(forKey: "textContainerInset")
        if let decode = aDecoder.decodeObject(forKey: "exclusionPaths") as? [UIBezierPath] {
            exclusionPaths = decode
        }
        isVerticalForm = aDecoder.decodeBool(forKey: "isVerticalForm")
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(attributedText, forKey: "attributedText")
        aCoder.encode(NSValue(range: selectedRange), forKey: "selectedRange")
        aCoder.encode(textVerticalAlignment, forKey: "textVerticalAlignment")
        aCoder.encode(dataDetectorTypes.rawValue, forKey: "dataDetectorTypes")
        aCoder.encode(textContainerInset, forKey: "textContainerInset")
        aCoder.encode(exclusionPaths, forKey: "exclusionPaths")
        aCoder.encode(isVerticalForm, forKey: "isVerticalForm")
    }
    
    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: - @protocol UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        YYTextEffectWindow.shared?.hide(selectionDot: _selectionView)
        
        _outerDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        _outerDelegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        _outerDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        _outerDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            YYTextEffectWindow.shared?.show(selectionDot: _selectionView)
        }
        
        _outerDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        _outerDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        YYTextEffectWindow.shared?.show(selectionDot: _selectionView)
        
        _outerDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        _outerDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return _outerDelegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
        _outerDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        _outerDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        return _outerDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
        _outerDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    // MARK: - @protocol YYTextKeyboardObserver
    
    public func keyboardChanged(with transition: YYTextKeyboardTransition) {
        _keyboardChanged()
    }
    
    // MARK: - @protocol UIALertViewDelegate
    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        let title = alertView.buttonTitle(at: buttonIndex)
        if (title?.length ?? 0) == 0 {
            return
        }
        let strings = _localizedUndoStrings()
        if (title == strings[1]) || (title == strings[2]) {
            _redo()
        } else if (title == strings[3]) || (title == strings[4]) {
            _undo()
        }
        _restoreFirstResponderAfterUndoAlert()
    }
    
    // MARK: - @protocol UIKeyInput
    
    public var hasText: Bool {
        return _innerText.length > 0
    }
    
    public func insertText(_ text: String) {
        if text == "" {
            return
        }
        if !NSEqualRanges(_lastTypeRange ?? NSMakeRange(0, 0), _selectedTextRange.asRange) {
            _saveToUndoStack()
            _resetRedoStack()
        }
        replace(_selectedTextRange, withText: text)
    }
    
    public func deleteBackward() {
        _updateIfNeeded()
        var range: NSRange = _selectedTextRange.asRange
        if range.location == 0 && range.length == 0 {
            return
        }
        state.typingAttributesOnce = false
        
        // test if there's 'YYTextBinding' before the caret
        if !state.deleteConfirm && range.length == 0 && range.location > 0 {
            var effectiveRange = NSRange(location: 0, length: 0)
            let binding = _innerText.attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textBindingAttributeName), at: range.location - 1, longestEffectiveRange: &effectiveRange, in: NSRange(location: 0, length: _innerText.length)) as? YYTextBinding
            if binding != nil && binding?.deleteConfirm != nil {
                state.deleteConfirm = true
                _inputDelegate?.selectionWillChange(self)
                _selectedTextRange = YYTextRange(range: effectiveRange)
                _selectedTextRange = _correctedTextRange(_selectedTextRange)!
                _inputDelegate?.selectionDidChange(self)
                
                _updateOuterProperties()
                _updateSelectionView()
                return
            }
        }
        
        state.deleteConfirm = false
        if range.length == 0 {
            let extendRange = _innerLayout?.textRange(byExtending: _selectedTextRange.end, in: UITextLayoutDirection.left, offset: 1)
            if _isTextRangeValid(extendRange) {
                range = extendRange!.asRange
            }
        }
        if !NSEqualRanges(_lastTypeRange!, _selectedTextRange.asRange) {
            _saveToUndoStack()
            _resetRedoStack()
        }
        replace(YYTextRange(range: range), withText: "")
    }
    
    // MARK: - @protocol UITextInput
    
    private weak var _inputDelegate: UITextInputDelegate?
    weak public var inputDelegate: UITextInputDelegate? {
        set {
            _inputDelegate = newValue
        }
        get {
            return _inputDelegate
        }
    }
    
    public var selectedTextRange: UITextRange? {
        get {
            return _selectedTextRange
        }
        set {
            guard var n = newValue as? YYTextRange else {
                return
            }
            n = _correctedTextRange(n)!
            if _selectedTextRange == n {
                return
            }
            _updateIfNeeded()
            _endTouchTracking()
            _hideMenu()
            state.deleteConfirm = false
            state.typingAttributesOnce = false
            
            _inputDelegate?.selectionWillChange(self)
            _selectedTextRange = n
            _lastTypeRange = _selectedTextRange.asRange
            _inputDelegate?.selectionDidChange(self)
            
            _updateOuterProperties()
            _updateSelectionView()
            
            if isFirstResponder {
                _scrollRangeToVisible(self._selectedTextRange)
            }
        }
    }
    
    public var markedTextStyle: [NSAttributedString.Key : Any]?
    
    /*
     Replace current markedText with the new markedText
     @param markedText     New marked text.
     @param selectedRange  The range from the '_markedTextRange'
     */
    public func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        let markedText = markedText ?? ""
        _updateIfNeeded()
        _endTouchTracking()
        _hideMenu()
        
        if let d = _outerDelegate {
            let r = (markedTextRange as? YYTextRange)
            let range = (r != nil) ? r!.asRange : NSRange(location: _selectedTextRange.end.offset, length: 0)
            
            if let should = d.textView?(self, shouldChangeTextIn: range, replacementText: markedText), should == false {
                return
            }
        }
        
        if !NSEqualRanges(_lastTypeRange!, _selectedTextRange.asRange) {
            _saveToUndoStack()
            _resetRedoStack()
        }
        
        var needApplyHolderAttribute = false
        if _innerText.length > 0 && (markedTextRange != nil) {
            _updateAttributesHolder()
        } else {
            needApplyHolderAttribute = true
        }
        
        if _selectedTextRange.asRange.length > 0 {
            replace(_selectedTextRange, withText: "")
        }
        
        _inputDelegate?.textWillChange(self)
        _inputDelegate?.selectionWillChange(self)
        
        if markedTextRange == nil {
            markedTextRange = YYTextRange(range: NSRange(location: _selectedTextRange.end.offset, length: markedText.length))
            let subRange = NSRange(location: _selectedTextRange.end.offset, length: 0)
            _innerText.replaceCharacters(in: subRange, with: markedText)
            _selectedTextRange = YYTextRange(range: NSRange(location: _selectedTextRange.start.offset + selectedRange.location, length: selectedRange.length))
        } else {
            markedTextRange = _correctedTextRange((markedTextRange as? YYTextRange))!
            if let subRange = (markedTextRange as? YYTextRange)?.asRange {
                _innerText.replaceCharacters(in: subRange, with: markedText)
            }
            
            if let offset = (markedTextRange as? YYTextRange)?.start.offset {
                markedTextRange = YYTextRange(range: NSRange(location: offset, length: markedText.length))
                _selectedTextRange = YYTextRange(range: NSRange(location: offset + selectedRange.location, length: selectedRange.length))
            }
        }

        _selectedTextRange = _correctedTextRange(_selectedTextRange)!
        markedTextRange = _correctedTextRange((markedTextRange as? YYTextRange))
        if (markedTextRange as? YYTextRange)?.asRange.length == 0 {
            markedTextRange = nil
        } else {
            if let asRange = (markedTextRange as? YYTextRange)?.asRange {
                if needApplyHolderAttribute {
                    _innerText.setAttributes(_typingAttributesHolder.yy_attributes, range: asRange)
                }
                _innerText.yy_removeDiscontinuousAttributes(in: asRange)
            }
        }
        
        _inputDelegate?.selectionDidChange(self)
        _inputDelegate?.textDidChange(self)
        
        _updateOuterProperties()
        _updateLayout()
        _updateSelectionView()
        _scrollRangeToVisible(_selectedTextRange)
        
        _outerDelegate?.textViewDidChange?(self)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YYTextView.textViewTextDidChangeNotification), object: self)
        
        _lastTypeRange = _selectedTextRange.asRange
        
        checkWordCount(selectedRange.location)
    }
    
    public func unmarkText() {
        markedTextRange = nil
        _endTouchTracking()
        _hideMenu()
        if _parseText() {
            state.needUpdate = true
        }
        
        _updateIfNeeded()
        _updateOuterProperties()
        _updateSelectionView()
        _scrollRangeToVisible(_selectedTextRange)
        
        checkWordCount()
    }
    
    public func replace(_ range: UITextRange, withText text: String) {
        
        var range = range as! YYTextRange
        let text = text
        
        if range.asRange.length == 0 && text == "" {
            return
        }
        range = _correctedTextRange(range)!
        
        if let d = _outerDelegate {
            if let should = d.textView?(self, shouldChangeTextIn: range.asRange, replacementText: text), should == false {
                return
            }
        }
        
        var useInnerAttributes = false
        if _innerText.length > 0 {
            if range.start.offset == 0 && range.end.offset == _innerText.length {
                if text == "" {
                    var attrs = _innerText.yy_attributes(at: 0)
                    for k in NSMutableAttributedString.yy_allDiscontinuousAttributeKeys() {
                        attrs?.removeValue(forKey: k)
                    }
                    _typingAttributesHolder.yy_attributes = attrs
                }
            }
        } else {
            // no text
            useInnerAttributes = true
        }
        var applyTypingAttributes = false
        if state.typingAttributesOnce {
            state.typingAttributesOnce = false
            if !useInnerAttributes {
                if range.asRange.length == 0 && text != "" {
                    applyTypingAttributes = true
                }
            }
        }
        
        state.selectedWithoutEdit = false
        state.deleteConfirm = false
        _endTouchTracking()
        _hideMenu()
        
        _replace(range, withText: text, notifyToDelegate: true)
        if useInnerAttributes {
            _innerText.yy_setAttributes(_typingAttributesHolder.yy_attributes)
        } else if applyTypingAttributes {
            let newRange = NSRange(location: range.asRange.location, length: text.length)
            for (key, obj) in _typingAttributesHolder.yy_attributes ?? [:] {
                self._innerText.yy_set(attribute: key, value: obj, range: newRange)
            }
        }
        _parseText()
        _updateOuterProperties()
        _update()
        
        if isFirstResponder {
            _scrollRangeToVisible(_selectedTextRange)
        }
        
        _outerDelegate?.textViewDidChange?(self)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YYTextView.textViewTextDidChangeNotification), object: self)
        
        _lastTypeRange = _selectedTextRange.asRange
        checkWordCount()
    }
    
    public func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
        
        guard var range = range as? YYTextRange else {
            return
        }
        range = _correctedTextRange(range)!
        _innerText.yy_set(baseWritingDirection: NSWritingDirection(rawValue: writingDirection.rawValue)!, range: range.asRange)
        _commitUpdate()
    }
    
    public func text(in range: UITextRange) -> String? {
        guard var range = range as? YYTextRange else {
            return ""
        }
        guard let r = _correctedTextRange(range) else {
            return ""
        }
        range = r
        let tmpstr = _innerText.attributedSubstring(from: range.asRange)
        return tmpstr.string
    }
    
    public func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
        
        guard var position = position as? YYTextPosition else {
            return .natural
        }
        _updateIfNeeded()
        
        guard let p = _correctedTextPosition(position) else {
            return .natural
        }
        position = p
        
        if _innerText.length == 0 {
            return .natural
        }
        var idx = position.offset
        if idx == _innerText.length {
            idx -= 1
        }
        
        let attrs = _innerText.yy_attributes(at: idx)
        let paraStyle = (attrs![NSAttributedString.Key.paragraphStyle]) as! CTParagraphStyle?
        if paraStyle != nil {
            let baseWritingDirection = UnsafeMutablePointer<CTWritingDirection>.allocate(capacity: 1)
            defer {
                baseWritingDirection.deallocate()
            }
            if CTParagraphStyleGetValueForSpecifier(paraStyle!, CTParagraphStyleSpecifier.baseWritingDirection, MemoryLayout<CTWritingDirection>.size, baseWritingDirection) {
                return (NSWritingDirection(rawValue: Int(baseWritingDirection.pointee.rawValue)))!
            }
        }
        
        return .natural
    }
    
    public var beginningOfDocument: UITextPosition {
        return YYTextPosition(offset: 0)
    }
    
    public var endOfDocument: UITextPosition {
        return YYTextPosition(offset: _innerText.length)
    }
    
    public func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        if offset == 0 {
            return position
        }
        
        let location = (position as! YYTextPosition).offset
        var newLocation: Int = location + offset
        if newLocation < 0 || newLocation > _innerText.length {
            return nil
        }
        
        if newLocation != 0 && newLocation != _innerText.length {
            // fix emoji
            _updateIfNeeded()
            let extendRange: YYTextRange? = _innerLayout?.textRange(byExtending: YYTextPosition(offset: newLocation))
            if extendRange?.asRange.length ?? 0 > 0 {
                if offset < 0 {
                    newLocation = extendRange?.start.offset ?? 0
                } else {
                    newLocation = extendRange?.end.offset ?? 0
                }
            }
        }
        
        let p = YYTextPosition(offset: newLocation)
        return _correctedTextPosition(p)
    }
    
    public func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        _updateIfNeeded()
        let range: YYTextRange? = _innerLayout?.textRange(byExtending: position as? YYTextPosition, in: direction, offset: offset)
        
        var forward: Bool
        if _innerContainer.isVerticalForm {
            forward = direction == .left || direction == .down
        } else {
            forward = direction == .down || direction == .right
        }
        if !forward && offset < 0 {
            forward = !forward
        }
        
        var newPosition: YYTextPosition? = forward ? range?.end : range?.start
        if (newPosition?.offset)! > _innerText.length {
            newPosition = YYTextPosition(offset: _innerText.length, affinity: YYTextAffinity.backward)
        }
        
        return _correctedTextPosition(newPosition)
    }
    
    public func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        guard let p = fromPosition as? YYTextPosition else {
            return nil
        }
        return YYTextRange(start: p, end: toPosition as! YYTextPosition)
    }
    
    public func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        return (position as? YYTextPosition)?.compare(other as? YYTextPosition) ?? .orderedAscending
    }
    
    public func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        return (toPosition as! YYTextPosition).offset - (from as! YYTextPosition).offset
    }
    
    public func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        let nsRange: NSRange? = (range as? YYTextRange)?.asRange
        if direction == .left || direction == .up {
            return YYTextPosition(offset: (nsRange?.location)!)
        } else {
            return YYTextPosition(offset: (nsRange?.location ?? 0) + (nsRange?.length ?? 0), affinity: YYTextAffinity.backward)
        }
    }
    
    public func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        _updateIfNeeded()
        let range: YYTextRange? = _innerLayout?.textRange(byExtending: (position as! YYTextPosition), in: direction, offset: 1)
        return _correctedTextRange(range)
    }
    
    public func closestPosition(to point: CGPoint) -> UITextPosition? {
        var point = point
        _updateIfNeeded()
        point = _convertPoint(toLayout: point)
        let position = _innerLayout?.closestPosition(to: point)
        return _correctedTextPosition(position)
    }
    
    public func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        
        guard var range = range as? YYTextRange else {
            return nil
        }
        
        guard var pos = closestPosition(to: point) as? YYTextPosition else {
            return nil
        }
        
        range = _correctedTextRange(range)!
        if pos.compare(range.start) == .orderedAscending {
            pos = range.start
        } else if pos.compare(range.end) == .orderedDescending {
            pos = range.end
        }
        return pos
    }
    
    public func characterRange(at point: CGPoint) -> UITextRange? {
        var point = point
        _updateIfNeeded()
        point = _convertPoint(toLayout: point)
        let r = _innerLayout?.closestTextRange(at: point)
        return _correctedTextRange(r)
    }
    
    public func firstRect(for range: UITextRange) -> CGRect {
        _updateIfNeeded()
        var rect: CGRect = _innerLayout!.firstRect(for: range as! YYTextRange)
        if rect.isNull {
            rect = CGRect.zero
        }
        return _convertRect(fromLayout: rect)
    }
    
    public func caretRect(for position: UITextPosition) -> CGRect {
        _updateIfNeeded()
        var caretRect: CGRect = _innerLayout!.caretRect(for: position as! YYTextPosition)
        if !caretRect.isNull {
            caretRect = _convertRect(fromLayout: caretRect)
            caretRect = caretRect.standardized
            if isVerticalForm {
                if caretRect.size.height == 0 {
                    caretRect.size.height = 2
                    caretRect.origin.y -= 2 * 0.5
                }
                if caretRect.origin.y < 0 {
                    caretRect.origin.y = 0
                } else if caretRect.origin.y + caretRect.size.height > bounds.size.height {
                    caretRect.origin.y = bounds.size.height - caretRect.size.height
                }
            } else {
                if caretRect.size.width == 0 {
                    caretRect.size.width = 2
                    caretRect.origin.x -= 2 * 0.5
                }
                if caretRect.origin.x < 0 {
                    caretRect.origin.x = 0
                } else if caretRect.origin.x + caretRect.size.width > bounds.size.width {
                    caretRect.origin.x = bounds.size.width - caretRect.size.width
                }
            }
            return YYTextUtilities.textCGRect(pixelRound: caretRect)
        }
        return CGRect.zero
    }
    
    public func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        _updateIfNeeded()
        guard let r = range as? YYTextRange else {
            return []
        }
        let rects = _innerLayout?.selectionRects(for: r)
        
        for rect in rects ?? [] {
            rect.rect = self._convertRect(fromLayout: rect.rect)
        }
        return rects ?? []
    }
    
    // MARK: - @protocol UITextInput optional
    
    public var selectionAffinity: UITextStorageDirection {
        get {
            if _selectedTextRange.end.affinity == YYTextAffinity.forward {
                return .forward
            } else {
                return .backward
            }
        }
        set(selectionAffinity) {
            _selectedTextRange = YYTextRange(range: _selectedTextRange.asRange, affinity: selectionAffinity == .forward ? YYTextAffinity.forward : YYTextAffinity.backward)
            _updateSelectionView()
        }
    }
    
    public func textStyling(at position: UITextPosition, in direction: UITextStorageDirection) -> [NSAttributedString.Key : Any]? {
        guard let position = position as? YYTextPosition else {
            return nil
        }
        if _innerText.length == 0 {
            return _typingAttributesHolder.yy_attributes
        }
        var attrs: [NSAttributedString.Key : Any]? = nil
        if 0 <= position.offset && position.offset <= _innerText.length {
            var ofs = position.offset
            if position.offset == _innerText.length || direction == .backward {
                ofs = ofs - 1
            }
            attrs = _innerText.attributes(at: ofs, effectiveRange: nil)
        }
        return attrs
    }
    
    public func position(within range: UITextRange, atCharacterOffset offset: Int) -> UITextPosition? {
        guard let range = range as? YYTextRange else {
            return nil
        }
        if offset < range.start.offset || offset > range.end.offset {
            return nil
        }
        if offset == range.start.offset {
            return range.start
        } else if offset == range.end.offset {
            return range.end
        } else {
            return YYTextPosition(offset: offset)
        }
    }
    
    public func characterOffset(of position: UITextPosition, within range: UITextRange) -> Int {
        guard let position = position as? YYTextPosition else {
            return NSNotFound
        }
        return position.offset
    }
}
