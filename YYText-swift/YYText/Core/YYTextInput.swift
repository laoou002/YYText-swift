//
//  YYTextInput.swift
//  JianZhiApp-swift
//
//  Created by 老欧 on 2022/4/20.
//

import UIKit

/**
 Text position affinity. For example, the offset appears after the last
 character on a line is backward affinity, before the first character on
 the following line is forward affinity.
 */
@objc public enum YYTextAffinity : Int {
    ///< offset appears before the character
    case forward = 0
    ///< offset appears after the character
    case backward = 1
}

/**
 A YYTextPosition object represents a position in a text container; in other words,
 it is an index into the backing string in a text-displaying view.
 
 YYTextPosition has the same API as Apple's implementation in UITextView/UITextField,
 so you can alse use it to interact with UITextView/UITextField.
 */
public class YYTextPosition: UITextPosition, NSCopying {
    
    @objc public private(set) var offset: Int = 0
    @objc public private(set) var affinity: YYTextAffinity = .forward
    
    @objc override init() {
        super.init()
    }
    
    @objc(positionWithOffset:)
    public class func position(with offset: Int) -> YYTextPosition {
        return YYTextPosition.position(with: offset, affinity: YYTextAffinity.forward)
    }
    
    public convenience init(offset: Int) {
        self.init()
        self.offset = offset
    }
    
    @objc(positionWithOffset:affinity:)
    public class func position(with offset: Int, affinity: YYTextAffinity) -> YYTextPosition {
        let e = YYTextPosition()
        e.offset = offset
        e.affinity = affinity
        return e
    }
    
    public convenience init(offset: Int, affinity: YYTextAffinity) {
        self.init()
        self.offset = offset
        self.affinity = affinity
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return YYTextPosition.position(with: self.offset, affinity: self.affinity)
    }
    
    public override var description: String {
        return "<\(type(of: self)): \(String(format: "%p", self))> (\(offset)\(affinity == YYTextAffinity.forward ? "F" : "B"))"
    }
    
    public func hash() -> Int {
        return offset * 2 + (affinity == YYTextAffinity.forward ? 1 : 0)
    }
    
    public func isEqual(_ object: YYTextPosition?) -> Bool {
        guard let o = object else {
            return false
        }
        return offset == o.offset && affinity == o.affinity
    }
    
    @objc public func compare(_ otherPosition: YYTextPosition?) -> ComparisonResult {
        if otherPosition == nil {
            return .orderedAscending
        }
        if offset < otherPosition?.offset ?? 0 {
            return .orderedAscending
        }
        if offset > otherPosition?.offset ?? 0 {
            return .orderedDescending
        }
        if affinity == YYTextAffinity.backward && otherPosition?.affinity == YYTextAffinity.forward {
            return .orderedAscending
        }
        if affinity == YYTextAffinity.forward && otherPosition?.affinity == YYTextAffinity.backward {
            return .orderedDescending
        }
        return .orderedSame
    }
}

/**
 A YYTextRange object represents a range of characters in a text container; in other words,
 it identifies a starting index and an ending index in string backing a text-displaying view.
 
 YYTextRange has the same API as Apple's implementation in UITextView/UITextField,
 so you can alse use it to interact with UITextView/UITextField.
 */
public class YYTextRange: UITextRange, NSCopying {
    
    private var _start = YYTextPosition(offset: 0)
    @objc override public var start: YYTextPosition {
        set {
            _start = newValue
        }
        get {
            return _start
        }
    }
    
    private var _end = YYTextPosition(offset: 0)
    override public var end: YYTextPosition {
        set {
            _end = newValue
        }
        get {
            return _end
        }
    }
    
    override public var isEmpty: Bool {
        get {
            return _start.offset == _end.offset
        }
    }
    
    public func markedPosition(innerLength:Int, offset:Int = 0) -> YYTextPosition? {
        let position = start;
        let location = position.offset
        let newLocation: Int = location + offset
        if newLocation < 0 || newLocation > innerLength {
            return nil
        }
        return position
    }
    
    @objc(rangeWithRange:)
    public class func range(with range: NSRange) -> YYTextRange {
        return YYTextRange.range(with: range, affinity: .forward)
    }
    
    @objc(rangeWithRange:affinity:)
    public class func range(with range: NSRange, affinity: YYTextAffinity) -> YYTextRange {
        let start = YYTextPosition.position(with: range.location, affinity: affinity)
        let end = YYTextPosition.position(with: range.location + range.length, affinity: affinity)
        return YYTextRange.range(with: start, end: end)
    }
    
    @objc(rangeWithStart:end:)
    public class func range(with start: YYTextPosition, end: YYTextPosition) -> YYTextRange {
        
        let range = YYTextRange()
        if start.compare(end) == .orderedDescending {
            range._start = end
            range._end = start
        } else {
            range._start = start
            range._end = end
        }
        return range
    }
    
    override init() {
        super.init()
    }
    
    public convenience init(range: NSRange) {
        self.init(range: range, affinity: .forward)
    }
    
    public convenience init(range: NSRange, affinity: YYTextAffinity) {
        let start = YYTextPosition.position(with: range.location, affinity: affinity)
        let end = YYTextPosition.position(with: range.location + range.length, affinity: affinity)
        self.init(start: start, end: end)
    }
    
    public convenience init(start: YYTextPosition, end: YYTextPosition) {
        self.init()
        if start.compare(end) == .orderedDescending {
            self._start = end
            self._end = start
        } else {
            self._start = start
            self._end = end
        }
    }
    
    @objc public var asRange: NSRange {
        return NSRange(location: _start.offset, length: _end.offset - _start.offset)
    }
    
    @objc(defaultRange)
    public class func `default`() -> YYTextRange {
        return YYTextRange.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let e = YYTextRange.range(with: self.start, end: self.end)
        return e
    }
    
    public override var description: String {
        return "<\(type(of: self)): \(String(format: "%p", self))> (\(_start.offset), \(end.offset - start.offset))\(end.affinity == YYTextAffinity.forward ? "F" : "B")"
    }
    
    func hash() -> Int {
        return (MemoryLayout<Int>.size == 8 ? Int(CFSwapInt64(UInt64(start.hash()))) : Int(CFSwapInt32(UInt32(start.hash()))) + end.hash())
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let o = object as! YYTextRange? else {
            return false
        }
        return start.isEqual(o.start) && end.isEqual(o.end)
    }
}


/**
 A YYTextSelectionRect object encapsulates information about a selected range of
 text in a text-displaying view.
 
 YYTextSelectionRect has the same API as Apple's implementation in UITextView/UITextField,
 so you can alse use it to interact with UITextView/UITextField.
 */
public class YYTextSelectionRect: UITextSelectionRect, NSCopying {
    
    private var _rect = CGRect.zero
    @objc override public var rect: CGRect {
        set {
            _rect = newValue
        }
        get {
            return _rect
        }
    }
    
    private var _writingDirection: NSWritingDirection = .natural
    @objc override public var writingDirection: NSWritingDirection {
        set {
            _writingDirection = newValue
        }
        get {
            return _writingDirection
        }
    }
    
    private var _containsStart = false
    @objc override public var containsStart: Bool {
        set {
            _containsStart = newValue
        }
        get {
            return _containsStart
        }
    }
    
    private var _containsEnd = false
    @objc override public var containsEnd: Bool {
        set {
            _containsEnd = newValue
        }
        get {
            return _containsEnd
        }
    }
    
    private var _isVertical = false
    @objc override public var isVertical: Bool {
        set {
            _isVertical = newValue
        }
        get {
            return _isVertical
        }
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = YYTextSelectionRect()
        one.rect = self.rect
        one.writingDirection = self.writingDirection
        one.containsStart = self.containsStart
        one.containsEnd = self.containsEnd
        one.isVertical = self.isVertical
        return one
    }
}
