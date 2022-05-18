//
//  String+YYAdd.swift
//  JianZhiApp-swift
//
//  Created by 老欧 on 2022/4/20.
//

import Foundation

extension String {
    
    /// Remove the blank characters at both ends of the string
    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    // String's count is equal to String's character.count
    /// compatibility API for NSString
    public var length: Int {
        return self.utf16.count
    }
    
    public func indexOf(_ target: Character) -> Int? {
        #if swift(>=5.0)
        return self.firstIndex(of: target)?.utf16Offset(in: self)
        #else
        return self.firstIndex(of: target)?.encodedOffset
        #endif
    }
    
    public func subString(to: Int) -> String {
        #if swift(>=5.0)
        let endIndex = String.Index(utf16Offset: to, in: self)
        #else
        let endIndex = String.Index.init(encodedOffset: to)
        #endif
        let subStr = self[self.startIndex..<endIndex]
        return String(subStr)
    }
    
    public func subString(from: Int) -> String {
        #if swift(>=5.0)
        let startIndex = String.Index(utf16Offset: from, in: self)
        #else
        let startIndex = String.Index.init(encodedOffset: from)
        #endif
        let subStr = self[startIndex..<self.endIndex]
        return String(subStr)
    }
    
    public func subString(range: Range<String.Index>) -> String {
        return String(self[range.lowerBound..<range.upperBound])
    }
    
    public func subString(start: Int, end: Int) -> String {
        #if swift(>=5.0)
        let startIndex = String.Index(utf16Offset: start, in: self)
        let endIndex = String.Index(utf16Offset: end, in: self)
        #else
        let startIndex = String.Index.init(encodedOffset: start)
        let endIndex = String.Index.init(encodedOffset: end)
        #endif
        return String(self[startIndex..<endIndex])
    }
    
    public func subString(withNSRange range: NSRange) -> String {
        
        return subString(start: range.location, end: range.location + range.length)
    }
    
    /// NSRange 转化为 Range
    public func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        
        return from ..< to
    }
    
    /// 提取出字符串中所有的URL链接
    public func urls() -> [String]? {
        var urls = [String]()
        let pattern = "http(s)?://[+:#@&*^A-Za-z0-9_.?%$=/-]+"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let allMatches = regex.matches(in: self, options: .reportCompletion, range: NSRange(location: 0, length: self.utf16.count))
            allMatches.forEach { result in
                let str = self.subString(withNSRange: result.range)
                urls.append(str)
            }
        }
        return urls
    }
}
