//
//  NSAttributedString+YYAdd.swift
//  JianZhiApp-swift
//
//  Created by 老欧 on 2022/4/20.
//

import UIKit
#if canImport(YYImage)
import YYImage
#endif

/**
 Get pre-defined attributes from attributed string.
 All properties defined in UIKit, CoreText and BSText are included.
 */
extension NSAttributedString {
    
    /**
     Returns the attributes at first charactor.
     */
    @objc public var yy_attributes: [NSAttributedString.Key : Any]? {
        get {
            return yy_attributes(at: 0)
        }
    }
    
    /**
     The font of the text. (read-only)
     
     @discussion Default is Helvetica (Neue) 12.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:3.2  UIKit:6.0
     */
    @objc public var yy_font: UIFont? {
        get {
            return yy_font(at: 0)
        }
    }
    
    /**
     A kerning adjustment. (read-only)
     
     @discussion Default is standard kerning. The kerning attribute indicate how many
     points the following character should be shifted from its default offset as
     defined by the current character's font in points; a positive kern indicates a
     shift farther along and a negative kern indicates a shift closer to the current
     character. If this attribute is not present, standard kerning will be used.
     If this attribute is set to 0, no kerning will be done at all.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:3.2  UIKit:6.0
     */
    @objc public var yy_kern: NSNumber? {
        get {
            return yy_kern(at: 0)
        }
    }
    
    /**
     The foreground color. (read-only)
     
     @discussion Default is Black.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:3.2  UIKit:6.0
     */
    @objc public var yy_color: UIColor? {
        get {
            return yy_color(at: 0)
        }
    }
    
    /**
     The background color. (read-only)
     
     @discussion Default is nil (or no background).
     @discussion Get this property returns the first character's attribute.
     @since UIKit:6.0
     */
    @objc public var yy_backgroundColor: UIColor? {
        get {
            return yy_backgroundColor(at: 0)
        }
    }
    
    /**
     The stroke width. (read-only)
     
     @discussion Default value is 0 (no stroke). This attribute, interpreted as
     a percentage of font point size, controls the text drawing mode: positive
     values effect drawing with stroke only; negative values are for stroke and fill.
     A typical value for outlined text is 3.0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:3.2  UIKit:6.0
     */
    @objc public var yy_strokeWidth: NSNumber? {
        get {
            return yy_strokeWidth(at: 0)
        }
    }
    
    /**
     The stroke color. (read-only)
     
     @discussion Default value is nil (same as foreground color).
     @discussion Get this property returns the first character's attribute.
     @since CoreText:3.2  UIKit:6.0
     */
    @objc public var yy_strokeColor: UIColor? {
        get {
            return yy_strokeColor(at: 0)
        }
    }
    
    /**
     The text shadow. (read-only)
     
     @discussion Default value is nil (no shadow).
     @discussion Get this property returns the first character's attribute.
     @since UIKit:6.0
     */
    @objc public var yy_shadow: NSShadow? {
        get {
            return yy_shadow(at: 0)
        }
    }
    
    /**
     The strikethrough style. (read-only)
     
     @discussion Default value is NSUnderlineStyleNone (no strikethrough).
     @discussion Get this property returns the first character's attribute.
     @since UIKit:6.0
     */
    @objc public var yy_strikethroughStyle: NSUnderlineStyle {
        get {
            return yy_strikethroughStyle(at: 0)
        }
    }
    
    /**
     The strikethrough color. (read-only)
     
     @discussion Default value is nil (same as foreground color).
     @discussion Get this property returns the first character's attribute.
     @since UIKit:7.0
     */
    @objc public var yy_strikethroughColor: UIColor? {
        get {
            return yy_strikethroughColor(at: 0)
        }
    }
    
    /**
     The underline style. (read-only)
     
     @discussion Default value is NSUnderlineStyleNone (no underline).
     @discussion Get this property returns the first character's attribute.
     @since CoreText:3.2  UIKit:6.0
     */
    @objc public var yy_underlineStyle: NSUnderlineStyle {
        get {
            return yy_underlineStyle(at: 0)
        }
    }
    
    /**
     The underline color. (read-only)
     
     @discussion Default value is nil (same as foreground color).
     @discussion Get this property returns the first character's attribute.
     @since CoreText:3.2  UIKit:7.0
     */
    @objc public var yy_underlineColor: UIColor? {
        get {
            return yy_underlineColor(at: 0)
        }
    }
    
    /**
     Ligature formation control. (read-only)
     
     @discussion Default is int value 1. The ligature attribute determines what kinds
     of ligatures should be used when displaying the string. A value of 0 indicates
     that only ligatures essential for proper rendering of text should be used,
     1 indicates that standard ligatures should be used, and 2 indicates that all
     available ligatures should be used. Which ligatures are standard depends on the
     script and possibly the font.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:3.2  UIKit:6.0
     */
    @objc public var yy_ligature: NSNumber? {
        get {
            return yy_ligature(at: 0)
        }
    }
    
    /**
     The text effect. (read-only)
     
     @discussion Default is nil (no effect). The only currently supported value
     is NSTextEffectLetterpressStyle.
     @discussion Get this property returns the first character's attribute.
     @since UIKit:7.0
     */
    @objc public var yy_textEffect: String? {
        get {
            return yy_textEffect(at: 0)
        }
    }
    
    /**
     The skew to be applied to glyphs. (read-only)
     
     @discussion Default is 0 (no skew).
     @discussion Get this property returns the first character's attribute.
     @since UIKit:7.0
     */
    @objc public var yy_obliqueness: NSNumber? {
        get {
            return yy_obliqueness(at: 0)
        }
    }
    
    /**
     The log of the expansion factor to be applied to glyphs. (read-only)
     
     @discussion Default is 0 (no expansion).
     @discussion Get this property returns the first character's attribute.
     @since UIKit:7.0
     */
    @objc public var yy_expansion: NSNumber? {
        get {
            return yy_expansion(at: 0)
        }
    }
    
    /**
     The character's offset from the baseline, in points. (read-only)
     
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since UIKit:7.0
     */
    @objc public var yy_baselineOffset: NSNumber? {
        get {
            return yy_baselineOffset(at: 0)
        }
    }
    
    /**
     Glyph orientation control. (read-only)
     
     @discussion Default is NO. A value of NO indicates that horizontal glyph forms
     are to be used, YES indicates that vertical glyph forms are to be used.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:4.3
     */
    @objc public var yy_verticalGlyphForm: Bool {
        get {
            return yy_verticalGlyphForm(at: 0)
        }
    }
    
    /**
     Specifies text language. (read-only)
     
     @discussion Value must be a NSString containing a locale identifier. Default is
     unset. When this attribute is set to a valid identifier, it will be used to select
     localized glyphs (if supported by the font) and locale-specific line breaking rules.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:7.0
     */
    @objc public var yy_language: String? {
        get {
            return yy_language(at: 0)
        }
    }
    
    /**
     Specifies a bidirectional override or embedding. (read-only)
     
     @discussion See alse NSWritingDirection and NSWritingDirectionAttributeName.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:7.0
     */
    @objc public var yy_writingDirection: [Any]? {
        get {
            return yy_writingDirection(at: 0)
        }
    }
    
    /**
     An NSParagraphStyle object which is used to specify things like
     line alignment, tab rulers, writing direction, etc. (read-only)
     
     @discussion Default is nil ([NSParagraphStyle defaultParagraphStyle]).
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_paragraphStyle: NSParagraphStyle? {
        get {
            return yy_paragraphStyle(at: 0)
        }
    }
    
    // MARK: - Get paragraph attribute as property
    
    /**
     The text alignment (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion Natural text alignment is realized as left or right alignment
     depending on the line sweep direction of the first script contained in the paragraph.
     @discussion Default is NSTextAlignmentNatural.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_alignment: NSTextAlignment {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.alignment
        }
    }
    
    /**
     The mode that should be used to break lines (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property contains the line break mode to be used laying out the paragraph's text.
     @discussion Default is NSLineBreakByWordWrapping.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_lineBreakMode: NSLineBreakMode {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.lineBreakMode
        }
    }
    
    /**
     The distance in points between the bottom of one line fragment and the top of the next.
     (A wrapper for NSParagraphStyle) (read-only)
     
     @discussion This value is always nonnegative. This value is included in the line
     fragment heights in the layout manager.
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_lineSpacing: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.lineSpacing
        }
    }
    
    /**
     The space after the end of the paragraph (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property contains the space (measured in points) added at the
     end of the paragraph to separate it from the following paragraph. This value must
     be nonnegative. The space between paragraphs is determined by adding the previous
     paragraph's paragraphSpacing and the current paragraph's paragraphSpacingBefore.
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_paragraphSpacing: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.paragraphSpacing
        }
    }
    
    /**
     The distance between the paragraph's top and the beginning of its text content.
     (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property contains the space (measured in points) between the
     paragraph's top and the beginning of its text content.
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_paragraphSpacingBefore: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.paragraphSpacingBefore
        }
    }
    
    /**
     The indentation of the first line (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property contains the distance (in points) from the leading margin
     of a text container to the beginning of the paragraph's first line. This value
     is always nonnegative.
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_firstLineHeadIndent: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.firstLineHeadIndent
        }
    }
    
    /**
     The indentation of the receiver's lines other than the first. (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property contains the distance (in points) from the leading margin
     of a text container to the beginning of lines other than the first. This value is
     always nonnegative.
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_headIndent: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.headIndent
        }
    }
    
    /**
     The trailing indentation (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion If positive, this value is the distance from the leading margin
     (for example, the left margin in left-to-right text). If 0 or negative, it's the
     distance from the trailing margin.
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_tailIndent: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.tailIndent
        }
    }
    
    /**
     The receiver's minimum height (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property contains the minimum height in points that any line in
     the receiver will occupy, regardless of the font size or size of any attached graphic.
     This value must be nonnegative.
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_minimumLineHeight: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.minimumLineHeight
        }
    }
    
    /**
     The receiver's maximum line height (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property contains the maximum height in points that any line in
     the receiver will occupy, regardless of the font size or size of any attached graphic.
     This value is always nonnegative. Glyphs and graphics exceeding this height will
     overlap neighboring lines; however, a maximum height of 0 implies no line height limit.
     Although this limit applies to the line itself, line spacing adds extra space between adjacent lines.
     @discussion Default is 0 (no limit).
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_maximumLineHeight: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.maximumLineHeight
        }
    }
    
    /**
     The line height multiple (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property contains the line break mode to be used laying out the paragraph's text.
     @discussion Default is 0 (no multiple).
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_lineHeightMultiple: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.lineHeightMultiple
        }
    }
    
    /**
     The base writing direction (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion If you specify NSWritingDirectionNaturalDirection, the receiver resolves
     the writing direction to either NSWritingDirectionLeftToRight or NSWritingDirectionRightToLeft,
     depending on the direction for the user's `language` preference setting.
     @discussion Default is NSWritingDirectionNatural.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:6.0  UIKit:6.0
     */
    @objc public var yy_baseWritingDirection: NSWritingDirection {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.baseWritingDirection
        }
    }
    
    /**
     The paragraph's threshold for hyphenation. (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion Valid values lie between 0 and 1.0 inclusive. Hyphenation is attempted
     when the ratio of the text width (as broken without hyphenation) to the width of the
     line fragment is less than the hyphenation factor. When the paragraph's hyphenation
     factor is 0, the layout manager's hyphenation factor is used instead. When both
     are 0, hyphenation is disabled.
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since UIKit:6.0
     */
    @objc public var yy_hyphenationFactor: Float {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.hyphenationFactor
        }
    }
    
    /**
     The document-wide default tab interval (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion This property represents the default tab interval in points. Tabs after the
     last specified in tabStops are placed at integer multiples of this distance (if positive).
     @discussion Default is 0.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:7.0  UIKit:7.0
     */
    @objc public var yy_defaultTabInterval: CGFloat {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.defaultTabInterval
        }
    }
    
    /**
     An array of NSTextTab objects representing the receiver's tab stops.
     (A wrapper for NSParagraphStyle). (read-only)
     
     @discussion The NSTextTab objects, sorted by location, define the tab stops for
     the paragraph style.
     @discussion Default is 12 TabStops with 28.0 tab interval.
     @discussion Get this property returns the first character's attribute.
     @since CoreText:7.0  UIKit:7.0
     */
    @objc public var yy_tabStops: [NSTextTab]? {
        get {
            let style = yy_paragraphStyle ?? NSParagraphStyle.default
            return style.tabStops
        }
    }
    
    // MARK: - Get BSText attribute as property
    
    /**
     Unarchive string from data.
     @param data  The archived attributed string data.
     @return Returns nil if an error occurs.
     */
    @objc public class func yy_unarchive(from data: Data?) -> NSAttributedString? {
        
        guard let aData = data else {
            return nil
        }
        
        return TextUnarchiver.unarchiveObject(with: aData) as? NSAttributedString
    }
    
    /**
     Archive the string to data.
     @return Returns nil if an error occurs.
     */
    @objc public func yy_archiveToData() -> Data? {
        
        return YYTextArchiver.archivedData(withRootObject: self)
    }
    
    // MARK: - Retrieving character attribute information
    
    ///=============================================================================
    /// @name Retrieving character attribute information
    ///=============================================================================

    /**
     Returns the attributes for the character at a given index.
     
     @discussion Raises an `NSRangeException` if index lies beyond the end of the
     receiver's characters.
     
     @param index  The index for which to return attributes.
     This value must lie within the bounds of the receiver.
     
     @return The attributes for the character at index.
     */
    @objc(yy_attributesAtIndex:)
    public func yy_attributes(at index: Int) -> [NSAttributedString.Key : Any]? {
        
        if index > self.length || self.length == 0 {
            return nil
        }
        var idx = index
        if self.length > 0 && index == self.length {
            idx -= 1
        }
        return self.attributes(at: idx, effectiveRange: nil)
    }
    
    /**
     Returns the value for an attribute with a given name of the character at a given index.
     
     @discussion Raises an `NSRangeException` if index lies beyond the end of the
     receiver's characters.
     
     @param attributeName  The name of an attribute.
     @param index          The index for which to return attributes.
     This value must not exceed the bounds of the receiver.
     
     @return The value for the attribute named `attributeName` of the character at
     index `index`, or nil if there is no such attribute.
     */
    @objc(yy_attribute:atIndex:)
    public func yy_attribute(_ attributeName: NSAttributedString.Key?, at index: Int) -> Any? {
        if attributeName == nil {
            return nil
        }
        if index > length || length == 0 {
            return nil
        }
        var idx = index
        if self.length > 0 && index == self.length {
            idx -= 1
        }
        return self.attribute(attributeName!, at: idx, effectiveRange: nil)
    }
    
    @objc(yy_fontAtIndex:)
    public func yy_font(at index: Int) -> UIFont? {
        /*
         In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
         although Apple does not mention it in documentation.
         
         In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
         but UILabel/UITextView cannot use CTFontRef.
         
         We use UIFont for both CoreText and UIKit.
         */
        let font: UIFont? = yy_attribute(NSAttributedString.Key.font, at: index) as? UIFont
        return font
    }
    
    @objc(yy_kernAtIndex:)
    public func yy_kern(at index: Int) -> NSNumber? {
        return yy_attribute(NSAttributedString.Key.kern, at: index) as? NSNumber
    }
    
    @objc(yy_colorAtIndex:)
    public func yy_color(at index: Int) -> UIColor? {
        var color = yy_attribute(NSAttributedString.Key.foregroundColor, at: index) as? UIColor
        if color == nil {
            let ref = yy_attribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String), at: index)
            if let aRef = ref {
                color = UIColor(cgColor: aRef as! CGColor)
            }
        }
//        if let aColor = color, !(aColor is UIColor) {
//            if CFGetTypeID(color as CFTypeRef) == CGColor.typeID {
//                color = UIColor(cgColor: aColor as! CGColor)
//            } else {
//                color = nil
//            }
//        }
        return color
    }
    
    @objc(yy_backgroundColorAtIndex:)
    public func yy_backgroundColor(at index: Int) -> UIColor? {
        return yy_attribute(NSAttributedString.Key.backgroundColor, at: index) as? UIColor
    }
    
    @objc(yy_strokeWidthAtIndex:)
    public func yy_strokeWidth(at index: Int) -> NSNumber? {
        return yy_attribute(NSAttributedString.Key.strokeWidth, at: index) as? NSNumber
    }
    
    @objc(yy_strokeColorAtIndex:)
    public func yy_strokeColor(at index: Int) -> UIColor? {
        var color = yy_attribute(NSAttributedString.Key.strokeColor, at: index)
        if color == nil {
            let ref = yy_attribute(NSAttributedString.Key(rawValue: kCTStrokeColorAttributeName as String), at: index)
            if let aRef = ref {
                color = UIColor(cgColor: aRef as! CGColor)
            }
        }
        return color as? UIColor
    }
    
    @objc(yy_shadowAtIndex:)
    public func yy_shadow(at index: Int) -> NSShadow? {
        return yy_attribute(NSAttributedString.Key.shadow, at: index) as? NSShadow
    }
    
    @objc(yy_strikethroughStyleAtIndex:)
    public func yy_strikethroughStyle(at index: Int) -> NSUnderlineStyle {
        let style = yy_attribute(NSAttributedString.Key.strikethroughStyle, at: index)
        return NSUnderlineStyle(rawValue: style as! Int)
    }
    
    @objc(yy_strikethroughColorAtIndex:)
    public func yy_strikethroughColor(at index: Int) -> UIColor? {
        return yy_attribute(NSAttributedString.Key.strikethroughColor, at: index) as? UIColor
    }
    
    @objc(yy_underlineStyleAtIndex:)
    public func yy_underlineStyle(at index: Int) -> NSUnderlineStyle {
        let style = yy_attribute(NSAttributedString.Key.underlineStyle, at: index)
        return NSUnderlineStyle(rawValue: style as! Int)
    }
    
    @objc(yy_underlineColorAtIndex:)
    public func yy_underlineColor(at index: Int) -> UIColor? {
        var color: UIColor? = nil
        color = yy_attribute(NSAttributedString.Key.underlineColor, at: index) as? UIColor
        if color == nil {
            let ref = yy_attribute(NSAttributedString.Key(rawValue: kCTUnderlineColorAttributeName as String), at: index)
            if let aRef = ref {
                color = UIColor(cgColor: aRef as! CGColor)
            }
        }
        return color
    }
    
    @objc(yy_ligatureAtIndex:)
    public func yy_ligature(at index: Int) -> NSNumber? {
        return yy_attribute(NSAttributedString.Key.ligature, at: index) as? NSNumber
    }
    
    @objc(yy_textEffectAtIndex:)
    public func yy_textEffect(at index: Int) -> String? {
        return yy_attribute(NSAttributedString.Key.textEffect, at: index) as? String
    }
    
    @objc(yy_obliquenessAtIndex:)
    public func yy_obliqueness(at index: Int) -> NSNumber? {
        return yy_attribute(NSAttributedString.Key.obliqueness, at: index) as? NSNumber
    }
    
    @objc(yy_expansionAtIndex:)
    public func yy_expansion(at index: Int) -> NSNumber? {
        return yy_attribute(NSAttributedString.Key.expansion, at: index) as? NSNumber
    }

    @objc(yy_baselineOffsetAtIndex:)
    public func yy_baselineOffset(at index: Int) -> NSNumber? {
        return yy_attribute(NSAttributedString.Key.baselineOffset, at: index) as? NSNumber
    }
    
    @objc(yy_verticalGlyphFormAtIndex:)
    public func yy_verticalGlyphForm(at index: Int) -> Bool {
        let num = yy_attribute(NSAttributedString.Key.verticalGlyphForm, at: index) as? Int
        return num != 0
    }
    
    @objc(yy_languageAtIndex:)
    public func yy_language(at index: Int) -> String? {
        return yy_attribute(NSAttributedString.Key(rawValue: kCTLanguageAttributeName as String), at: index) as? String
    }
    
    @objc(yy_writingDirectionAtIndex:)
    public func yy_writingDirection(at index: Int) -> [Any]? {
        return yy_attribute(NSAttributedString.Key(rawValue: kCTWritingDirectionAttributeName as String), at: index) as? [Any]
    }
    
    @objc(yy_paragraphStyleAtIndex:)
    public func yy_paragraphStyle(at index: Int) -> NSParagraphStyle? {
        /*
         NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
         
         CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
         but UILabel/UITextView can only use NSParagraphStyle.
         
         We use NSParagraphStyle in both CoreText and UIKit.
         */
        var style = yy_attribute(NSAttributedString.Key.paragraphStyle, at: index) as? NSParagraphStyle
        if let s = style {
            if CFGetTypeID(s) == CTParagraphStyleGetTypeID() {
                style = NSParagraphStyle.yy_styleWith(ctStyle: style as! CTParagraphStyle)
            }
        }
        return style
    }
    
    
    @objc(yy_alignmentAtIndex:)
    public func yy_alignment(at index: Int) -> NSTextAlignment {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.alignment
    }
    
    @objc(yy_lineBreakModeAtIndex:)
    public func yy_lineBreakMode(at index: Int) -> NSLineBreakMode {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.lineBreakMode
    }
    
    @objc(yy_lineSpacingAtIndex:)
    public func yy_lineSpacing(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.lineSpacing
    }
    
    @objc(yy_paragraphSpacingAtIndex:)
    public func yy_paragraphSpacing(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.paragraphSpacing
    }
    
    @objc(yy_paragraphSpacingBeforeAtIndex:)
    public func yy_paragraphSpacingBefore(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.paragraphSpacingBefore
    }
    
    @objc(yy_firstLineHeadIndentAtIndex:)
    public func yy_firstLineHeadIndent(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.firstLineHeadIndent
    }
    
    @objc(yy_headIndentAtIndex:)
    public func yy_headIndent(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.headIndent
    }
    
    @objc(yy_tailIndentAtIndex:)
    public func yy_tailIndent(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.tailIndent
    }
    
    @objc(yy_minimumLineHeightAtIndex:)
    public func yy_minimumLineHeight(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.minimumLineHeight
    }
    
    @objc(yy_maximumLineHeightAtIndex:)
    public func yy_maximumLineHeight(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.maximumLineHeight
    }
    
    @objc(yy_lineHeightMultipleAtIndex:)
    public func yy_lineHeightMultiple(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.lineHeightMultiple
    }
    
    @objc(yy_baseWritingDirectionAtIndex:)
    public func yy_baseWritingDirection(at index: Int) -> NSWritingDirection {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.baseWritingDirection
    }
    
    @objc(yy_hyphenationFactorAtIndex:)
    public func yy_hyphenationFactor(at index: Int) -> Float {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.hyphenationFactor
    }
    
    @objc(yy_defaultTabIntervalAtIndex:)
    public func yy_defaultTabInterval(at index: Int) -> CGFloat {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.defaultTabInterval
    }
    
    @objc(yy_tabStopsAtIndex:)
    public func yy_tabStops(at index: Int) -> [NSTextTab]? {
        
        let style = yy_paragraphStyle(at: index) ?? NSParagraphStyle.default
        return style.tabStops
    }
    
    /**
     The text shadow. (read-only)
     
     @discussion Default value is nil (no shadow).
     @discussion Get this property returns the first character's attribute.
     */
    @objc public var yy_textShadow: YYTextShadow? {
        get {
            return yy_textShadow(at: 0)
        }
    }
    
    @objc(yy_textShadowAtIndex:)
    public func yy_textShadow(at index: Int) -> YYTextShadow? {
        return yy_attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textShadowAttributeName), at: index) as? YYTextShadow
    }
    
    /**
     The text inner shadow. (read-only)
     
     @discussion Default value is nil (no shadow).
     @discussion Get this property returns the first character's attribute.
     */
    @objc public var yy_textInnerShadow: YYTextShadow? {
        get {
            return yy_textInnerShadow(at: 0)
        }
    }
    
    @objc(yy_textInnerShadowAtIndex:)
    public func yy_textInnerShadow(at index: Int) -> YYTextShadow? {
        return yy_attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textInnerShadowAttributeName), at: index) as? YYTextShadow
    }
    
    /**
     The text underline. (read-only)
     
     @discussion Default value is nil (no underline).
     @discussion Get this property returns the first character's attribute.
     */
    @objc public var yy_textUnderline: YYTextDecoration? {
        get {
            return yy_textUnderline(at: 0)
        }
    }
    
    @objc(yy_textUnderlineAtIndex:)
    public func yy_textUnderline(at index: Int) -> YYTextDecoration? {
        return yy_attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textUnderlineAttributeName), at: index) as? YYTextDecoration
    }
    
    /**
     The text strikethrough. (read-only)
     
     @discussion Default value is nil (no strikethrough).
     @discussion Get this property returns the first character's attribute.
     */
    @objc public var yy_textStrikethrough: YYTextDecoration? {
        get {
            return yy_textStrikethrough(at: 0)
        }
    }
    
    @objc(yy_textStrikethroughAtIndex:)
    public func yy_textStrikethrough(at index: Int) -> YYTextDecoration? {
        return yy_attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textStrikethroughAttributeName), at: index) as? YYTextDecoration
    }
    
    /**
     The text border. (read-only)
     
     @discussion Default value is nil (no border).
     @discussion Get this property returns the first character's attribute.
     */
    @objc public var yy_textBorder: YYTextBorder? {
        get {
            return yy_textBorder(at: 0)
        }
    }
    
    @objc(yy_textBorderAtIndex:)
    public func yy_textBorder(at index: Int) -> YYTextBorder? {
        return yy_attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textBorderAttributeName), at: index) as? YYTextBorder
    }
    
    /**
     The text background border. (read-only)
     
     @discussion Default value is nil (no background border).
     @discussion Get this property returns the first character's attribute.
     */
    @objc public var yy_textBackgroundBorder: YYTextBorder? {
        get {
            return yy_textBackgroundBorder(at: 0)
        }
    }
    
    @objc(yy_textBackgroundBorderAtIndex:)
    public func yy_textBackgroundBorder(at index: Int) -> YYTextBorder? {
        return yy_attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textBackedStringAttributeName), at: index) as? YYTextBorder
    }
    
    /**
     The glyph transform. (read-only)
     
     @discussion Default value is CGAffineTransformIdentity (no transform).
     @discussion Get this property returns the first character's attribute.
     */
    @objc public var yy_textGlyphTransform: CGAffineTransform {
        get {
            return yy_textGlyphTransform(at: 0)
        }
    }
    
    @objc(yy_textGlyphTransformAtIndex:)
    public func yy_textGlyphTransform(at index: Int) -> CGAffineTransform {
        let value: NSValue? = yy_attribute(NSAttributedString.Key(rawValue: YYTextAttribute.textGlyphTransformAttributeName), at: index) as? NSValue
        if value == nil {
            return .identity
        }
        return (value?.cgAffineTransformValue)!
    }
    
    
    // MARK: - Query for BSText
    
    /**
     Returns the plain text from a range.
     If there's `YYTextBackedStringAttributeName` attribute, the backed string will
     replace the attributed string range.
     
     @param range A range in receiver.
     @return The plain text.
     */
    @objc(yy_plainTextForRange:)
    public func yy_plainText(for range: NSRange) -> String? {
        if range.location == NSNotFound || range.length == NSNotFound {
            return nil
        }
        var result = ""
        if range.length == 0 {
            return result
        }
        let string = self.string
        enumerateAttribute(NSAttributedString.Key(rawValue: YYTextAttribute.textBackedStringAttributeName), in: range, options: [], using: { value, range, stop in
            let backed = value as? YYTextBackedString
            if backed != nil && backed?.string != nil {
                result += backed?.string ?? ""
            } else {
                result += (string as NSString).substring(with: range)
            }
        })
        return result
    }
    
    /**
     Creates and returns an attachment.
     
     @param content      The attachment (UIImage/UIView/CALayer).
     @param contentMode  The attachment's content mode.
     @param width        The attachment's container width in layout.
     @param ascent       The attachment's container ascent in layout.
     @param descent      The attachment's container descent in layout.
     
     @return An attributed string, or nil if an error occurs.
     */
    @objc(yy_attachmentStringWithContent:contentMode:width:ascent:descent:)
    public class func yy_attachmentString(with content: Any?, contentMode: UIView.ContentMode, width: CGFloat, ascent: CGFloat, descent: CGFloat) -> NSMutableAttributedString {
        
        let atr = NSMutableAttributedString(string: YYTextAttribute.textAttachmentToken)
        let attach = YYTextAttachment()
        attach.content = content
        attach.contentMode = contentMode
        atr.yy_set(textAttachment: attach, range: NSRange(location: 0, length: atr.length))
        let delegate = YYTextRunDelegate()
        delegate.width = width
        delegate.ascent = ascent
        delegate.descent = descent
        let delegateRef = delegate.ctRunDelegate
        atr.yy_set(runDelegate: delegateRef, range: NSRange(location: 0, length: atr.length))
        return atr
    }
    
    /**
     Creates and returns an attachment.
     
     
     Example: ContentMode:bottom Alignment:Top.
     
     The text      The attachment holder
     ↓                ↓
     ─────────┌──────────────────────┐───────
     / \   │                      │ / ___|
     / _ \  │                      │| |
     / ___ \ │                      │| |___     ←── The text line
     /_/   \_\│    ██████████████    │ \____|
     ─────────│    ██████████████    │───────
     │    ██████████████    │
     │    ██████████████ ←───────────────── The attachment content
     │    ██████████████    │
     └──────────────────────┘
     
     @param content        The attachment (UIImage/UIView/CALayer).
     @param contentMode    The attachment's content mode in attachment holder
     @param attachmentSize The attachment holder's size in text layout.
     @param font           The attachment will align to this font.
     @param alignment      The attachment holder's alignment to text line.
     
     @return An attributed string, or nil if an error occurs.
     */
    @objc(yy_attachmentStringWithContent:contentMode:attachmentSize:alignToFont:alignment:)
    public class func yy_attachmentString(with content: Any?, contentMode: UIView.ContentMode, attachmentSize: CGSize, alignTo font: UIFont?, alignment: YYTextVerticalAlignment) -> NSMutableAttributedString? {
        
        let atr = NSMutableAttributedString(string: YYTextAttribute.textAttachmentToken)
        let attach = YYTextAttachment()
        attach.content = content
        attach.contentMode = contentMode
        atr.yy_set(textAttachment: attach, range: NSRange(location: 0, length: atr.length))
        let delegate = YYTextRunDelegate()
        delegate.width = attachmentSize.width
        switch alignment {
        case .top:
            delegate.ascent = font?.ascender ?? 0
            delegate.descent = attachmentSize.height - (font?.ascender ?? 0)
            if delegate.descent < 0 {
                delegate.descent = 0
                delegate.ascent = attachmentSize.height
            }
        case .center:
            let fontHeight: CGFloat = (font?.ascender ?? 0) - (font?.descender ?? 0)
            let yOffset: CGFloat = (font?.ascender ?? 0) - fontHeight * 0.5
            delegate.ascent = attachmentSize.height * 0.5 + yOffset
            delegate.descent = attachmentSize.height - delegate.ascent
            if delegate.descent < 0 {
                delegate.descent = 0
                delegate.ascent = attachmentSize.height
            }
        case .bottom:
            delegate.ascent = attachmentSize.height + (font?.descender ?? 0)
            delegate.descent = -(font?.descender ?? 0)
            if delegate.ascent < 0 {
                delegate.ascent = 0
                delegate.descent = attachmentSize.height
            }
        default:
            delegate.ascent = attachmentSize.height
            delegate.descent = 0
        }
        // Swift 中 CoreFoundation 对象 进行了自动内存管理，不需要手动释放
        let delegateRef = delegate.ctRunDelegate
        atr.yy_set(runDelegate: delegateRef, range: NSRange(location: 0, length: atr.length))
        
        return atr
    }
    
    /**
     Creates and returns an attahment from a fourquare image as if it was an emoji.
     
     @param emojiImage  A fourquare image.
     @param fontSize    The font size.
     
     @return An attributed string, or nil if an error occurs.
     */
    @objc(yy_attachmentStringWithEmojiImage:fontSize:)
    public class func yy_attachmentString(with emojiImage: UIImage?, fontSize: CGFloat) -> NSMutableAttributedString? {
        guard let image = emojiImage, fontSize > 0 else {
            return nil
        }
        var hasAnim = false
        if (image.images?.count ?? 0) > 1 {
            hasAnim = true
        } else {
            #if canImport(YYImage)
            let frameCount = (image as? YYImage)?.animatedImageFrameCount() ?? 0
            if frameCount > 1 {
                hasAnim = true
            }
            #endif
        }
        let ascent = YYTextUtilities.textEmojiGetAscent(with: fontSize)
        let descent = YYTextUtilities.textEmojiGetDescent(with: fontSize)
        let bounding: CGRect = YYTextUtilities.textEmojiGetGlyphBoundingRect(with: fontSize)
        let delegate = YYTextRunDelegate()
        delegate.ascent = ascent
        delegate.descent = descent
        delegate.width = bounding.size.width + 2 * bounding.origin.x
        let attachment = YYTextAttachment()
        attachment.contentMode = UIView.ContentMode.scaleAspectFit
        attachment.contentInsets = UIEdgeInsets(top: ascent - (bounding.size.height + bounding.origin.y), left: bounding.origin.x, bottom: descent + bounding.origin.y, right: bounding.origin.x)

        if hasAnim {
            #if canImport(YYImage)
            let view = YYAnimatedImageView()
            #else
            let view = UIImageView()
            #endif
            
            view.frame = bounding
            view.image = image
            view.contentMode = .scaleAspectFit
            attachment.content = view
        } else {
            attachment.content = image
        }
        let atr = NSMutableAttributedString(string: YYTextAttribute.textAttachmentToken)
        atr.yy_set(textAttachment: attachment, range: NSRange(location: 0, length: atr.length))
        let ctDelegate = delegate.ctRunDelegate
        atr.yy_set(runDelegate: ctDelegate, range: NSRange(location: 0, length: atr.length))
        
        return atr
    }
    
    // MARK: - Utility
    
    /**
     Returns NSMakeRange(0, self.length).
     */
    @objc public var yy_rangeOfAll: NSRange {
        get {
            return NSRange(location: 0, length: length)
        }
    }
    
    /**
     If YES, it share the same attribute in entire text range.
     */
    @objc public func yy_isSharedAttributesInAllRange() -> Bool {
        
        var shared = true
        var firstAttrs: [NSAttributedString.Key : Any]? = nil
        enumerateAttributes(in: yy_rangeOfAll, options: .longestEffectiveRangeNotRequired, using: { attrs, range, stop in
            if range.location == 0 {
                firstAttrs = attrs
            } else {
                if firstAttrs?.count != attrs.count {
                    shared = false
                    stop.pointee = true
                } else if let tmp = firstAttrs {
                    if !(tmp as NSDictionary).isEqual(to: attrs) {
                        shared = false
                        stop.pointee = true
                    }
                }
            }
        })
        return shared
    }
    
    static var failSet: Set<AnyHashable>?
    
    /**
     If YES, it can be drawn with the [drawWithRect:options:context:] method or displayed with UIKit.
     If NO, it should be drawn with CoreText or BSText.
     
     @discussion If the method returns NO, it means that there's at least one attribute
     which is not supported by UIKit (such as CTParagraphStyleRef). If display this string
     in UIKit, it may lose some attribute, or even crash the app.
     */
    @objc public func yy_canDrawWithUIKit() -> Bool {
        
        if (NSAttributedString.failSet == nil) {
            var failSet = Set<AnyHashable>()
            let _ = failSet.insert(kCTGlyphInfoAttributeName)
            let _ = failSet.insert(kCTCharacterShapeAttributeName)
            let _ = failSet.insert(kCTLanguageAttributeName)
            let _ = failSet.insert(kCTRunDelegateAttributeName)
            let _ = failSet.insert(kCTBaselineClassAttributeName)
            let _ = failSet.insert(kCTBaselineInfoAttributeName)
            let _ = failSet.insert(kCTBaselineReferenceInfoAttributeName)
            let _ = failSet.insert(kCTRubyAnnotationAttributeName)
            let _ = failSet.insert(YYTextAttribute.textShadowAttributeName)
            let _ = failSet.insert(YYTextAttribute.textInnerShadowAttributeName)
            let _ = failSet.insert(YYTextAttribute.textUnderlineAttributeName)
            let _ = failSet.insert(YYTextAttribute.textStrikethroughAttributeName)
            let _ = failSet.insert(YYTextAttribute.textBorderAttributeName)
            let _ = failSet.insert(YYTextAttribute.textBackgroundBorderAttributeName)
            let _ = failSet.insert(YYTextAttribute.textBlockBorderAttributeName)
            let _ = failSet.insert(YYTextAttribute.textAttachmentAttributeName)
            let _ = failSet.insert(YYTextAttribute.textHighlightAttributeName)
            let _ = failSet.insert(YYTextAttribute.textGlyphTransformAttributeName)

            NSAttributedString.failSet = failSet
        }

        let failSet = NSAttributedString.failSet!

        var result = true
        enumerateAttributes(in: yy_rangeOfAll, options: .longestEffectiveRangeNotRequired, using: { (attrs, range, stop) in
            if attrs.count == 0 {
                return
            }
            for str: NSAttributedString.Key in attrs.keys {
                if failSet.contains(str.rawValue) {
                    result = false
                    stop.pointee = true
                    return
                }
            }

            if attrs[NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String)] != nil && attrs[NSAttributedString.Key.foregroundColor] == nil {
                result = false
                stop.pointee = true
                return
            }

            if attrs[NSAttributedString.Key(rawValue: kCTStrokeColorAttributeName as String)] != nil && attrs[NSAttributedString.Key.strokeColor] == nil {
                result = false
                stop.pointee = true
                return
            }

            if attrs[NSAttributedString.Key(rawValue: kCTUnderlineColorAttributeName as String)] != nil && attrs[NSAttributedString.Key.underlineColor] == nil {
                result = false
                stop.pointee = true
                return
            }

            let style = attrs[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
            if style != nil && CFGetTypeID(style!) == CTParagraphStyleGetTypeID() {
                result = false
                stop.pointee = true
                return
            }
        })
        return result
    }
    
}

/**
 Set pre-defined attributes to attributed string.
 All properties defined in UIKit, CoreText and BSText are included.
 */
extension NSMutableAttributedString {
    
    // MARK: - Set character attribute
    
    /**
     Sets the attributes to the entire text string.
     
     @discussion The old attributes will be removed.
     
     @param attributes  A dictionary containing the attributes to set, or nil to remove all attributes.
     */
    @objc public func yy_setAttributes(_ attributes: [NSAttributedString.Key : Any]?) {
        self.yy_attributes = attributes     // setter
    }
    
    /**
     Returns the attributes at first charactor.
     */
    @objc public override var yy_attributes: [NSAttributedString.Key : Any]? {
        set {
            setAttributes([:], range: NSRange(location: 0, length: length))
            
            guard let attr = newValue else {
                return
            }
            
            for (_, ele) in attr.enumerated() {
                self.yy_set(attribute: ele.key, value: ele.value)
            }
        }
        get {
            return super.yy_attributes
        }
    }
    
    
    /**
     Sets an attribute with the given name and value to the entire text string.
     
     @param name   A string specifying the attribute name.
     @param value  The attribute value associated with name. Pass `nil` or `NSNull` to
     remove the attribute.
     */
    @objc(yy_setAttribute:value:)
    public func yy_set(attribute name: NSAttributedString.Key?, value: Any?) {
        yy_set(attribute: name, value: value, range: NSRange(location: 0, length: length))
    }
    
    /**
     Sets an attribute with the given name and value to the characters in the specified range.
     
     @param name   A string specifying the attribute name.
     @param value  The attribute value associated with name. Pass `nil` or `NSNull` to
     remove the attribute.
     @param range  The range of characters to which the specified attribute/value pair applies.
     */
    @objc(yy_setAttribute:value:range:)
    public func yy_set(attribute name: NSAttributedString.Key?, value: Any?, range: NSRange) {
        guard let n = name else {
            return
        }
        if let aValue = value {
            addAttribute(n, value: aValue, range: range)
        } else {
            removeAttribute(n, range: range)
        }
    }
    
    /**
     Removes all attributes in the specified range.
     
     @param range  The range of characters.
     */
    @objc(yy_removeAttributesInRange:)
    public func yy_removeAttributes(in range: NSRange) {
        setAttributes(nil, range: range)
    }
    
    // MARK: - Set character attribute as property
    
    @objc public override var yy_font: UIFont? {
        set {
            /*
             In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
             although Apple does not mention it in documentation.
             
             In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
             but UILabel/UITextView cannot use CTFontRef.
             
             We use UIFont for both CoreText and UIKit.
             */
            yy_set(font: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_font
        }
    }
    
    public override var yy_kern: NSNumber? {
        set {
            yy_set(kern: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_kern
        }
    }
    
    @objc public override var yy_color: UIColor? {
        set {
            yy_set(color: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_color
        }
    }
    
    @objc public override var yy_backgroundColor: UIColor? {
        set {
            yy_set(backgroundColor: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_backgroundColor
        }
    }
    
    public override var yy_strokeWidth: NSNumber? {
        set {
            yy_set(strokeWidth: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_strokeWidth
        }
    }
    
    public override var yy_strokeColor: UIColor? {
        set {
            yy_set(strokeColor: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_strokeColor
        }
    }
    
    public override var yy_shadow: NSShadow? {
        get {
            return super.yy_shadow
        }
        set {
            yy_set(shadow: newValue, range: NSRange(location: 0, length: length))
        }
    }
    
    public override var yy_strikethroughStyle: NSUnderlineStyle {
        set {
            yy_set(strikethroughStyle: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_strikethroughStyle
        }
    }
    
    public override var yy_strikethroughColor: UIColor? {
        set {
            yy_set(strikethroughColor: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_strikethroughColor
        }
    }
    
    public override var yy_underlineStyle: NSUnderlineStyle {
        set {
            yy_set(underlineStyle: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_underlineStyle
        }
    }
    
    public override var yy_underlineColor: UIColor? {
        set {
            yy_set(underlineColor: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_underlineColor
        }
    }
    
    public override var yy_ligature: NSNumber? {
        set {
            yy_set(ligature: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_ligature
        }
    }
    
    public override var yy_textEffect: String? {
        set {
            yy_set(textEffect: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_textEffect
        }
    }
    
    public override var yy_obliqueness: NSNumber? {
        set {
            yy_set(obliqueness: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_obliqueness
        }
    }
    
    public override var yy_expansion: NSNumber? {
        get {
            return super.yy_expansion
        }
        set {
            yy_set(expansion: newValue, range: NSRange(location: 0, length: length))
        }
    }
    
    public override var yy_baselineOffset: NSNumber? {
        set {
            yy_set(baselineOffset: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_baselineOffset
        }
    }
    
    public override var yy_verticalGlyphForm: Bool {
        get {
            return super.yy_verticalGlyphForm
        }
        set {
            yy_set(verticalGlyphForm: newValue, range: NSRange(location: 0, length: length))
        }
    }
    
    public override var yy_language: String? {
        get {
            return super.yy_language
        }
        set {
            yy_set(language: newValue, range: NSRange(location: 0, length: length))
        }
    }
    
    public override var yy_writingDirection: [Any]? {
        get {
            return super.yy_writingDirection
        }
        set {
            yy_set(writingDirection: newValue, range: NSRange(location: 0, length: length))
        }
    }
    
    public override var yy_paragraphStyle: NSParagraphStyle? {
        get {
            return super.yy_paragraphStyle
        }
        set {
            /*
             NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
             
             CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
             but UILabel/UITextView can only use NSParagraphStyle.
             
             We use NSParagraphStyle in both CoreText and UIKit.
             */
            yy_set(paragraphStyle: newValue, range: NSRange(location: 0, length: length))
        }
    }
    
    public override var yy_alignment: NSTextAlignment {
        set {
            yy_set(alignment: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_alignment
        }
    }
    
    public override var yy_baseWritingDirection: NSWritingDirection {
        set {
            yy_set(baseWritingDirection: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_baseWritingDirection
        }
    }
    
    public override var yy_lineSpacing: CGFloat {
        set {
            yy_set(lineSpacing: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_lineSpacing
        }
    }
    
    public override var yy_paragraphSpacing: CGFloat {
        set {
            yy_set(paragraphSpacing: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_paragraphSpacing
        }
    }
    
    public override var yy_paragraphSpacingBefore: CGFloat {
        set {
            yy_set(paragraphSpacing: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_paragraphSpacingBefore
        }
    }
    
    public override var yy_firstLineHeadIndent: CGFloat {
        set {
            yy_set(firstLineHeadIndent: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_firstLineHeadIndent
        }
    }
    
    public override var yy_headIndent: CGFloat {
        set {
            yy_set(headIndent: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_headIndent
        }
    }
    
    public override var yy_tailIndent: CGFloat {
        set {
            yy_set(tailIndent: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_tailIndent
        }
    }
    
    public override var yy_lineBreakMode: NSLineBreakMode {
        set {
            yy_set(lineBreakMode: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_lineBreakMode
        }
    }
    
    public override var yy_minimumLineHeight: CGFloat {
        set {
            yy_set(minimumLineHeight: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_minimumLineHeight
        }
    }
    
    public override var yy_maximumLineHeight: CGFloat {
        set {
            yy_set(maximumLineHeight: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_maximumLineHeight
        }
    }
    
    public override var yy_lineHeightMultiple: CGFloat {
        set {
            yy_set(lineHeightMultiple: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_lineHeightMultiple
        }
    }
    
    public override var yy_hyphenationFactor: Float {
        set {
            yy_set(hyphenationFactor: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_hyphenationFactor
        }
    }
    
    public override var yy_defaultTabInterval: CGFloat {
        set {
            yy_set(defaultTabInterval: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_defaultTabInterval
        }
    }
    
    public override var yy_tabStops: [NSTextTab]? {
        set {
            yy_set(tabStops: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_tabStops
        }
    }
    
    public override var yy_textShadow: YYTextShadow? {
        set {
            yy_set(textShadow: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_textShadow
        }
    }
    
    public override var yy_textInnerShadow: YYTextShadow? {
        set {
            yy_set(textInnerShadow: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_textInnerShadow
        }
    }
    
    public override var yy_textUnderline: YYTextDecoration? {
        set {
            yy_set(textUnderline: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_textUnderline
        }
    }
    
    public override var yy_textStrikethrough: YYTextDecoration? {
        set {
            yy_set(textStrikethrough: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_textStrikethrough
        }
    }
    
    public override var yy_textBorder: YYTextBorder? {
        set {
            yy_set(textBorder: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_textBorder
        }
    }
    
    public override var yy_textBackgroundBorder: YYTextBorder? {
        set {
            yy_set(textBackgroundBorder: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_textBackgroundBorder
        }
    }
    
    public override var yy_textGlyphTransform: CGAffineTransform {
        set {
            yy_set(textGlyphTransform: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return super.yy_textGlyphTransform
        }
    }
    
    // MARK: - Range Setter
    
    @objc(yy_setFont:range:)
    public func yy_set(font: UIFont?, range: NSRange) {
        /*
         In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
         although Apple does not mention it in documentation.
         
         In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
         but UILabel/UITextView cannot use CTFontRef.
         
         We use UIFont for both CoreText and UIKit.
         */
        yy_set(attribute: NSAttributedString.Key.font, value: font, range: range)
    }
    
    @objc(yy_setKern:range:)
    public func yy_set(kern: NSNumber?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.kern, value: kern, range: range)
    }
    
    @objc(yy_setColor:range:)
    public func yy_set(color: UIColor?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String), value: color?.cgColor, range: range)
        yy_set(attribute: NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    @objc(yy_setBackgroundColor:range:)
    public func yy_set(backgroundColor: UIColor?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.backgroundColor, value: backgroundColor, range: range)
    }
    
    @objc(yy_setStrokeWidth:range:)
    public func yy_set(strokeWidth: NSNumber?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.strokeWidth, value: strokeWidth, range: range)
    }
    
    @objc(yy_setStrokeColor:range:)
    public func yy_set(strokeColor: UIColor?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTStrokeColorAttributeName as String), value: strokeColor?.cgColor, range: range)
        yy_set(attribute: NSAttributedString.Key.strokeColor, value: strokeColor, range: range)
    }
    
    @objc(yy_setShadow:range:)
    public func yy_set(shadow: NSShadow?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.shadow, value: shadow, range: range)
    }
    
    @objc(yy_setStrikethroughStyle:range:)
    public func yy_set(strikethroughStyle: NSUnderlineStyle, range: NSRange) {
        let style = strikethroughStyle.rawValue == 0 ? nil : strikethroughStyle.rawValue
        yy_set(attribute: NSAttributedString.Key.strikethroughStyle, value: style, range: range)
    }
    
    @objc(yy_setStrikethroughColor:range:)
    public func yy_set(strikethroughColor: UIColor?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.strikethroughColor, value: strikethroughColor, range: range)
    }
    
    @objc(yy_setUnderlineStyle:range:)
    public func yy_set(underlineStyle: NSUnderlineStyle, range: NSRange) {
        let style = underlineStyle.rawValue == 0 ? nil : underlineStyle.rawValue
        yy_set(attribute: NSAttributedString.Key.underlineStyle, value: style, range: range)
    }
    
    @objc(yy_setUnderlineColor:range:)
    public func yy_set(underlineColor: UIColor?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTUnderlineColorAttributeName as String), value: underlineColor?.cgColor, range: range)
        yy_set(attribute: NSAttributedString.Key.underlineColor, value: underlineColor, range: range)
    }
    
    @objc(yy_setLigature:range:)
    public func yy_set(ligature: NSNumber?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.ligature, value: ligature, range: range)
    }
    
    @objc(yy_setTextEffect:range:)
    public func yy_set(textEffect: String?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.textEffect, value: textEffect, range: range)
    }
    
    @objc(yy_setObliqueness:range:)
    public func yy_set(obliqueness: NSNumber?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.obliqueness, value: obliqueness, range: range)
    }
    
    @objc(yy_setExpansion:range:)
    public func yy_set(expansion: NSNumber?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.expansion, value: expansion, range: range)
    }
    
    @objc(yy_setBaselineOffset:range:)
    public func yy_set(baselineOffset: NSNumber?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.baselineOffset, value: baselineOffset, range: range)
    }
    
    @objc(yy_setVerticalGlyphForm:range:)
    public func yy_set(verticalGlyphForm: Bool, range: NSRange) {
        let v = verticalGlyphForm ? true : nil
        yy_set(attribute: NSAttributedString.Key.verticalGlyphForm, value: v, range: range)
    }
    
    @objc(yy_setLanguage:range:)
    public func yy_set(language: String?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTLanguageAttributeName as String), value: language, range: range)
    }
    
    @objc(yy_setWritingDirection:range:)
    public func yy_set(writingDirection: [Any]?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTWritingDirectionAttributeName as String), value: writingDirection, range: range)
    }
    
    @objc(yy_setParagraphStyle:range:)
    public func yy_set(paragraphStyle: NSParagraphStyle?, range: NSRange) {
        /*
         NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
         
         CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
         but UILabel/UITextView can only use NSParagraphStyle.
         
         We use NSParagraphStyle in both CoreText and UIKit.
         */
        yy_set(attribute: NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
    }
    
    @objc(yy_setAlignment:range:)
    public func yy_set(alignment: NSTextAlignment, range: NSRange) {
        
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.alignment == alignment {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.alignment == alignment {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.alignment = alignment
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setBaseWritingDirection:range:)
    public func yy_set(baseWritingDirection: NSWritingDirection, range: NSRange) {
        
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.baseWritingDirection == baseWritingDirection {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.baseWritingDirection == baseWritingDirection {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.baseWritingDirection = baseWritingDirection
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setLineSpacing:range:)
    public func yy_set(lineSpacing: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.lineSpacing == lineSpacing {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.lineSpacing == lineSpacing {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.lineSpacing = lineSpacing
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setParagraphSpacing:range:)
    public func yy_set(paragraphSpacing: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.paragraphSpacing == paragraphSpacing {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.paragraphSpacing == paragraphSpacing {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.paragraphSpacing = paragraphSpacing
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setParagraphSpacingBefore:range:)
    public func yy_set(paragraphSpacingBefore: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.paragraphSpacingBefore == paragraphSpacingBefore {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.paragraphSpacingBefore == paragraphSpacingBefore {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.paragraphSpacingBefore = paragraphSpacingBefore
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setFirstLineHeadIndent:range:)
    public func yy_set(firstLineHeadIndent: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.firstLineHeadIndent == firstLineHeadIndent {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.firstLineHeadIndent == firstLineHeadIndent {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.firstLineHeadIndent = firstLineHeadIndent
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setHeadIndent:range:)
    public func yy_set(headIndent: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.headIndent == headIndent {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.headIndent == headIndent {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.headIndent = headIndent
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setTailIndent:range:)
    public func yy_set(tailIndent: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.tailIndent == tailIndent {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.tailIndent == tailIndent {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.tailIndent = tailIndent
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setLineBreakMode:range:)
    public func yy_set(lineBreakMode: NSLineBreakMode, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.lineBreakMode == lineBreakMode {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.lineBreakMode == lineBreakMode {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.lineBreakMode = lineBreakMode
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setMinimumLineHeight:range:)
    public func yy_set(minimumLineHeight: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.minimumLineHeight == minimumLineHeight {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.minimumLineHeight == minimumLineHeight {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.minimumLineHeight = minimumLineHeight
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setMaximumLineHeight:range:)
    public func yy_set(maximumLineHeight: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.maximumLineHeight == maximumLineHeight {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.maximumLineHeight == maximumLineHeight {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.maximumLineHeight = maximumLineHeight
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setLineHeightMultiple:range:)
    public func yy_set(lineHeightMultiple: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.lineHeightMultiple == lineHeightMultiple {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.lineHeightMultiple == lineHeightMultiple {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.lineHeightMultiple = lineHeightMultiple
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setHyphenationFactor:range:)
    public func yy_set(hyphenationFactor: Float, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.hyphenationFactor == hyphenationFactor {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.hyphenationFactor == hyphenationFactor {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.hyphenationFactor = hyphenationFactor
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setDefaultTabInterval:range:)
    public func yy_set(defaultTabInterval: CGFloat, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.defaultTabInterval == defaultTabInterval {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.defaultTabInterval == defaultTabInterval {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.defaultTabInterval = defaultTabInterval
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setTabStops:range:)
    public func yy_set(tabStops: [NSTextTab]?, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { valuein, subRange, stop in
            var style: NSMutableParagraphStyle? = nil
            if var value = valuein as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                    value = NSParagraphStyle.yy_styleWith(ctStyle: value as! CTParagraphStyle)
                }
                if value.tabStops == tabStops {
                    return
                }
                if (value is NSMutableParagraphStyle) {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.tabStops == tabStops {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            if let aStops = tabStops {
                style?.tabStops = aStops
            }
            self.yy_set(paragraphStyle: style, range: subRange)
        })
    }
    
    @objc(yy_setSuperscript:range:)
    public func yy_set(superscript: NSNumber?, range: NSRange) {
        var s = superscript
        if (s == 0) {
            s = nil
        }
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTSuperscriptAttributeName as String), value: s, range: range)
    }
    
    @objc(yy_setGlyphInfo:range:)
    public func yy_set(glyphInfo: CTGlyphInfo?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTGlyphInfoAttributeName as String), value: glyphInfo, range: range)
    }
    
    @objc(yy_setCharacterShape:range:)
    public func yy_set(characterShape: NSNumber?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTCharacterShapeAttributeName as String), value: characterShape, range: range)
    }
    
    @objc(yy_setRunDelegate:range:)
    public func yy_set(runDelegate: CTRunDelegate?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTRunDelegateAttributeName as String), value: runDelegate, range: range)
    }
    
    @objc(yy_setBaselineClass:range:)
    public func yy_set(baselineClass: CFString?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTBaselineClassAttributeName as String), value: baselineClass, range: range)
    }
    
    @objc(yy_setBaselineInfo:range:)
    public func yy_set(baselineInfo: CFDictionary?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTBaselineInfoAttributeName as String), value: baselineInfo, range: range)
    }
    
    @objc(yy_setBaselineReferenceInfo:range:)
    public func yy_set(referenceInfo: CFDictionary?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTBaselineReferenceInfoAttributeName as String), value: referenceInfo, range: range)
    }
    
    @objc(yy_setRubyAnnotation:range:)
    public func yy_set(rubyAnnotation ruby: CTRubyAnnotation?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: kCTRubyAnnotationAttributeName as String), value: ruby, range: range)
    }
    
    @objc(yy_setAttachment:range:)
    public func yy_set(attachment: YYTextAttachment?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.attachment, value: attachment, range: range)
    }
    
    @objc(yy_setLink:range:)
    public func yy_set(link: Any?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key.link, value: link, range: range)
    }
    
    @objc(yy_setYYTextBackedString:range:)
    public func yy_set(textBackedString: YYTextBackedString?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textBackedStringAttributeName), value: textBackedString, range: range)
    }
    
    @objc(yy_setYYTextBinding:range:)
    public func yy_set(textBinding: YYTextBinding?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textBindingAttributeName), value: textBinding, range: range)
    }
    
    @objc(yy_setYYTextShadow:range:)
    public func yy_set(textShadow: YYTextShadow?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textShadowAttributeName), value: textShadow, range: range)
    }
    
    @objc(yy_setTextInnerShadow:range:)
    public func yy_set(textInnerShadow: YYTextShadow?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textInnerShadowAttributeName), value: textInnerShadow, range: range)
    }
    
    @objc(yy_setTextUnderline:range:)
    public func yy_set(textUnderline: YYTextDecoration?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textUnderlineAttributeName), value: textUnderline, range: range)
    }
    
    @objc(yy_setTextStrikethrough:range:)
    public func yy_set(textStrikethrough: YYTextDecoration?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textStrikethroughAttributeName), value: textStrikethrough, range: range)
    }
    
    @objc(yy_setYYTextBorder:range:)
    public func yy_set(textBorder: YYTextBorder?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textBorderAttributeName), value: textBorder, range: range)
    }
    
    @objc(yy_setTextBackgroundBorder:range:)
    public func yy_set(textBackgroundBorder: YYTextBorder?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textBackgroundBorderAttributeName), value: textBackgroundBorder, range: range)
    }
    
    @objc(yy_setYYTextAttachment:range:)
    public func yy_set(textAttachment: YYTextAttachment?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textAttachmentAttributeName), value: textAttachment, range: range)
    }
    
    @objc(yy_setYYTextHighlight:range:)
    public func yy_set(textHighlight: YYTextHighlight?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textHighlightAttributeName), value: textHighlight, range: range)
    }
    
    @objc(yy_setTextBlockBorder:range:)
    public func yy_set(textBlockBorder: YYTextBorder?, range: NSRange) {
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textBlockBorderAttributeName), value: textBlockBorder, range: range)
    }
    
    @objc(yy_setYYTextRubyAnnotation:range:)
    public func yy_set(textRubyAnnotation ruby: YYTextRubyAnnotation?, range: NSRange) {
        let rubyRef = ruby?.ctRubyAnnotation()
        yy_set(rubyAnnotation: rubyRef, range: range)
    }
    
    @objc(yy_setTextGlyphTransform:range:)
    public func yy_set(textGlyphTransform: CGAffineTransform, range: NSRange) {
        let value = textGlyphTransform.isIdentity ? nil : NSValue(cgAffineTransform: textGlyphTransform)
        yy_set(attribute: NSAttributedString.Key(rawValue: YYTextAttribute.textGlyphTransformAttributeName), value: value, range: range)
    }
    
    // Convenience methods for text highlight
    
    /**
     Convenience method to set text highlight
     
     @param range           text range
     @param color           text color (pass nil to ignore)
     @param backgroundColor text background color when highlight
     @param userInfo        user information dictionary (pass nil to ignore)
     @param action          tap action when user tap the highlight (pass nil to ignore)
     @param longPressAction long press action when user long press the highlight (pass nil to ignore)
     */
    @objc(yy_setYYTextHighlightRange:color:backgroundColor:userInfo:tapAction:longPress:)
    public func yy_set(textHighlightRange range: NSRange, color: UIColor?, backgroundColor: UIColor?, userInfo: [AnyHashable : Any]?, tapAction action: TextAction?, longPress longPressAction: TextAction?) {
        
        let highlight = YYTextHighlight.highlight(with: backgroundColor)
        highlight.userInfo = userInfo as NSDictionary?
        highlight.tapAction = action
        highlight.longPressAction = longPressAction
        if color != nil {
            yy_set(color: color, range: range)
        }
        yy_set(textHighlight: highlight, range: range)
    }
    
    /**
     Convenience method to set text highlight
     
     @param range           text range
     @param color           text color (pass nil to ignore)
     @param backgroundColor text background color when highlight
     @param action          tap action when user tap the highlight (pass nil to ignore)
     */
    @objc(yy_setYYTextHighlightRange:color:backgroundColor:tapAction:)
    public func yy_set(textHighlightRange range: NSRange, color: UIColor?, backgroundColor: UIColor?, tapAction action: TextAction?) {
        yy_set(textHighlightRange: range, color: color, backgroundColor: backgroundColor, userInfo: nil, tapAction: action, longPress: nil)
    }
    
    /**
     Convenience method to set text highlight
     
     @param range           text range
     @param color           text color (pass nil to ignore)
     @param backgroundColor text background color when highlight
     @param userInfo        tap action when user tap the highlight (pass nil to ignore)
     */
    @objc(yy_setYYTextHighlightRange:color:backgroundColor:userInfo:)
    public func yy_set(textHighlightRange range: NSRange, color: UIColor?, backgroundColor: UIColor?, userInfo: [AnyHashable : Any]?) {
        yy_set(textHighlightRange: range, color: color, backgroundColor: backgroundColor, userInfo: userInfo, tapAction: nil, longPress: nil)
    }
    
    // MARK: - Utilities
    
    /**
     Inserts into the receiver the characters of a given string at a given location.
     The new string inherit the attributes of the first replaced character from location.
     
     @param string  The string to insert into the receiver, must not be nil.
     @param location The location at which string is inserted. The location must not
     exceed the bounds of the receiver.
     @throw Raises an NSRangeException if the location out of bounds.
     */
    @objc(yy_insertString:atIndex:)
    public func yy_insert(string: String?, at location: Int) {
        guard let s = string else {
            return
        }
        replaceCharacters(in: NSRange(location: location, length: 0), with: s)
        yy_removeDiscontinuousAttributes(in: NSRange(location: location, length: s.count))
    }
    
    /**
     Adds to the end of the receiver the characters of a given string.
     The new string inherit the attributes of the receiver's tail.
     
     @param string  The string to append to the receiver, must not be nil.
     */
    @objc(yy_appendString:)
    public func yy_append(string: String?) {
        guard let _ = string else {
            return
        }
        let length = self.length
        replaceCharacters(in: NSRange(location: length, length: 0), with: string!)
        yy_removeDiscontinuousAttributes(in: NSRange(location: length, length: string!.count))
    }
    
    static var clearColorToJoinedEmojiRegex: NSRegularExpression?
    
    /**
     Set foreground color with [UIColor clearColor] in joined-emoji range.
     Emoji drawing will not be affected by the foreground color.
     
     @discussion In iOS 8.3, Apple releases some new diversified emojis.
     There's some single emoji which can be assembled to a new 'joined-emoji'.
     The joiner is unicode character 'ZERO WIDTH JOINER' (U+200D).
     For example: 👨👩👧👧 -> 👨‍👩‍👧‍👧.
     
     When there are more than 5 'joined-emoji' in a same CTLine, CoreText may render some
     extra glyphs above the emoji. It's a bug in CoreText, try this method to avoid.
     This bug is fixed in iOS 9.
     */
    @objc public func yy_setClearColorToJoinedEmoji() {
        let str = string
        if str.length < 8 {
            return
        }
        // Most string do not contains the joined-emoji, test the joiner first.
        var containsJoiner = false
        let nsStr = str as NSString
        
        for i in 0..<nsStr.length {
            let char: UniChar = nsStr.character(at: i)
            if char == 0x200d {
                // 'ZERO WIDTH JOINER' (U+200D)
                containsJoiner = true
                break
            }
        }
        if !containsJoiner {
            return
        }
        
        if (NSMutableAttributedString.clearColorToJoinedEmojiRegex == nil) {
            let regex = try? NSRegularExpression(pattern: "((👨‍👩‍👧‍👦|👨‍👩‍👦‍👦|👨‍👩‍👧‍👧|👩‍👩‍👧‍👦|👩‍👩‍👦‍👦|👩‍👩‍👧‍👧|👨‍👨‍👧‍👦|👨‍👨‍👦‍👦|👨‍👨‍👧‍👧)+|(👨‍👩‍👧|👩‍👩‍👦|👩‍👩‍👧|👨‍👨‍👦|👨‍👨‍👧))", options: [])
            NSMutableAttributedString.clearColorToJoinedEmojiRegex = regex
        }
        let regex = NSMutableAttributedString.clearColorToJoinedEmojiRegex
        
        let clear = UIColor.clear
        regex?.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            self.yy_set(color: clear, range: (result?.range)!)
        })
    }
    
    static var allDiscontinuousAttributeKeys: [NSAttributedString.Key]?
    
    /**
     Returns all discontinuous attribute keys, such as RunDelegate/Attachment/Ruby.
     
     @discussion These attributes can only set to a specified range of text, and
     should not extend to other range when editing text.
     */
    @objc public class func yy_allDiscontinuousAttributeKeys() -> [NSAttributedString.Key] {
        
        if allDiscontinuousAttributeKeys == nil {
            
            var keys = [NSAttributedString.Key]()
            
            keys.append(NSAttributedString.Key(kCTSuperscriptAttributeName as String))
            keys.append(NSAttributedString.Key(kCTRunDelegateAttributeName as String))
            keys.append(NSAttributedString.Key(YYTextAttribute.textBackedStringAttributeName))
            keys.append(NSAttributedString.Key(YYTextAttribute.textBindingAttributeName))
            keys.append(NSAttributedString.Key(YYTextAttribute.textAttachmentAttributeName))
            keys.append(NSAttributedString.Key(kCTRubyAnnotationAttributeName as String))
            keys.append(NSAttributedString.Key.attachment)
            
            allDiscontinuousAttributeKeys = keys
        }
        
        let keys = allDiscontinuousAttributeKeys!
        
        return keys
    }
    
    /**
     Removes all discontinuous attributes in a specified range.
     See `allDiscontinuousAttributeKeys`.
     
     @param range A text range.
     */
    @objc(yy_removeDiscontinuousAttributesInRange:)
    public func yy_removeDiscontinuousAttributes(in range: NSRange) {
        
        for key in NSMutableAttributedString.yy_allDiscontinuousAttributeKeys() {
            removeAttribute(key, range: range)
        }
    }
}
