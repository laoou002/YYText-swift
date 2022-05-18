//
//  YYTextMagnifier.swift
//  JianZhiApp-swift
//
//  Created by 老欧 on 2022/4/20.
//

import UIKit

/// Magnifier type
@objc public enum YYTextMagnifierType : Int {
    ///< Circular magnifier
    case caret
    ///< Round rectangle magnifier
    case ranged
}

/**
 A magnifier view which can be displayed in `YYTextEffectWindow`.
 
 @discussion Use `magnifierWithType:` to create instance.
 Typically, you should not use this class directly.
 */
@objc public class YYTextMagnifier: UIView {
    
    /*/< Type of magnifier */
    @objc public private(set) var type = YYTextMagnifierType.caret
    /*/< The 'best' size for magnifier view. */
    @objc public private(set) var fitSize = CGSize.zero
    /*/< The 'best' snapshot image size for magnifier. */
    @objc public private(set) var snapshotSize = CGSize.zero
    /*/< The image in magnifier (readwrite). */
    @objc public var snapshot: UIImage?
    /*/< The coordinate based view. */
    @objc public weak var hostView: UIView?
    /*/< The snapshot capture center in `hostView`. */
    @objc public var hostCaptureCenter = CGPoint.zero
    /*/< The popover center in `hostView`. */
    @objc public var hostPopoverCenter = CGPoint.zero
    /*/< The host view is vertical form. */
    @objc public var hostVerticalForm = false
    /*/< A hint for `YYTextEffectWindow` to disable capture. */
    @objc public var captureDisabled = false
    ///< Show fade animation when the snapshot image changed.
    @objc public var captureFadeAnimation = false
    
    
    /// Create a mangifier with the specified type. @param type The magnifier type.
    @objc(magnifierWithType:)
    public class func magnifier(with type: YYTextMagnifierType) -> YYTextMagnifier? {
        switch type {
        case .caret:
            return YYTextMagnifierCaret()
        case .ranged:
            return YYTextMagnifierRanged()
        default:
            break
        }
        return nil
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate let kCaptureDisableFadeTime = 0.1

fileprivate class YYTextMagnifierCaret: YYTextMagnifier {
    
    var contentView: UIImageView
    var coverView: UIImageView
    
    static let kMultiple: CGFloat = 1.2
    static let kDiameter: CGFloat = 113
    static let kPadding: CGFloat = 7
    static let kSize = CGSize(width: kDiameter + kPadding * 2, height: kDiameter + kPadding * 2)

    override init(frame: CGRect) {
        contentView = UIImageView()
        coverView = UIImageView()
        super.init(frame: frame)
        
        contentView.frame = CGRect(x: CGFloat(YYTextMagnifierCaret.kPadding), y: CGFloat(YYTextMagnifierCaret.kPadding), width: CGFloat(YYTextMagnifierCaret.kDiameter), height: CGFloat(YYTextMagnifierCaret.kDiameter))
        contentView.layer.cornerRadius = CGFloat(YYTextMagnifierCaret.kDiameter / 2)
        contentView.clipsToBounds = true
        addSubview(contentView)
        coverView.frame = CGRect()
        coverView.frame.origin = CGPoint.zero
        coverView.frame.size = YYTextMagnifierCaret.kSize
        coverView.image = YYTextMagnifierCaret.coverImage()
        addSubview(coverView)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        frame = CGRect.zero
        frame.size = sizeThatFits(CGSize.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var type: YYTextMagnifierType {
        return .caret
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return YYTextMagnifierCaret.kSize
    }
    
    func setSnapshot(_ snapshot: UIImage?) {
        if captureFadeAnimation {
            contentView.layer.removeAnimation(forKey: "contents")
            let animation = CABasicAnimation()
            animation.duration = kCaptureDisableFadeTime
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            contentView.layer.add(animation, forKey: "contents")
        }
        contentView.image = snapshot
    }
    
    func snapshot() -> UIImage? {
        return contentView.image
    }
    
    func snapshotSize() -> CGSize {
        let length = floor(YYTextMagnifierCaret.kDiameter / 1.2)
        return CGSize(width: length, height: length)
    }
    
    func fitSize() -> CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    static var image: UIImage?
    class func coverImage() -> UIImage? {
        if let i = image {
            return i
        }
        let size: CGSize = kSize
        var rect = CGRect()
        rect.size = size
        rect.origin = CGPoint.zero
        rect = rect.insetBy(dx: kPadding, dy: kPadding)
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0)
        let context = UIGraphicsGetCurrentContext()!
        
        let boxPath = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        let fillPath = CGPath(ellipseIn: rect, transform: nil)
        let strokePath = CGPath(ellipseIn: YYTextUtilities.textCGRect(pixelHalf: rect), transform: nil)
        // inner shadow
        context.saveGState()
        do {
            let blurRadius: CGFloat = 25
            let offset = CGSize(width: 0, height: 15)
            let shadowColor = UIColor(white: 0, alpha: 0.16).cgColor
            let opaqueShadowColor = shadowColor.copy(alpha: 1)
            context.addPath(fillPath)
            context.clip()
            context.setAlpha(shadowColor.alpha)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            do {
                context.setShadow(offset: offset, blur: blurRadius, color: opaqueShadowColor)
                context.setBlendMode(CGBlendMode.sourceOut)
                context.setFillColor(opaqueShadowColor!)
                context.addPath(fillPath)
                context.fillPath()
            }
            context.endTransparencyLayer()
        }
        context.restoreGState()
        
        // outer shadow
        context.saveGState()
        do {
            context.addPath(boxPath)
            context.addPath(fillPath)
            context.clip(using: .evenOdd)
            let shadowColor = UIColor(white: 0, alpha: 0.32).cgColor
            context.setShadow(offset: CGSize(width: 0, height: 1.5), blur: 3, color: shadowColor)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            do {
                context.addPath(fillPath)
                UIColor(white: 0.7, alpha: 1).setFill()
                context.fillPath()
            }
            context.endTransparencyLayer()
        }
        context.restoreGState()
        // stroke
        context.saveGState()
        do {
            context.addPath(strokePath)
            UIColor(white: 0.6, alpha: 1).setStroke()
            context.setLineWidth(YYTextUtilities.textCGFloat(fromPixel: 1))
            context.strokePath()
        }
        context.restoreGState()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

fileprivate class YYTextMagnifierRanged: YYTextMagnifier {
    
    var contentView: UIImageView = UIImageView()
    var coverView: UIImageView = UIImageView()
    
    static let kMultiple: CGFloat = 1.2
    static let kSize = CGSize(width: 141, height: 60)
    static let kPadding = YYTextUtilities.textCGFloat(pixelHalf: 6)
    static let kRadius: CGFloat = 6
    static let kHeight: CGFloat = 32
    static let kArrow: CGFloat = 14
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.frame = CGRect(x: YYTextMagnifierRanged.kPadding, y: YYTextMagnifierRanged.kPadding, width: YYTextMagnifierRanged.kSize.width - 2 * YYTextMagnifierRanged.kPadding, height: CGFloat(YYTextMagnifierRanged.kHeight))
        contentView.layer.cornerRadius = CGFloat(YYTextMagnifierRanged.kRadius)
        contentView.clipsToBounds = true
        coverView.frame = CGRect()
        coverView.frame.origin = CGPoint.zero
        coverView.frame.size = YYTextMagnifierRanged.kSize
        coverView.image = YYTextMagnifierRanged.coverImage()
        addSubview(contentView)
        addSubview(coverView)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.2)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        frame = CGRect()
        frame.size = sizeThatFits(CGSize.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var type: YYTextMagnifierType {
        return .ranged
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return YYTextMagnifierRanged.kSize
    }
    
    func setSnapshot(_ snapshot: UIImage?) {
        if captureFadeAnimation {
            contentView.layer.removeAnimation(forKey: "contents")
            let animation = CABasicAnimation()
            animation.duration = kCaptureDisableFadeTime
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            contentView.layer.add(animation, forKey: "contents")
        }
        contentView.image = snapshot
    }
    
    func snapshot() -> UIImage? {
        return contentView.image
    }
    
    func snapshotSize() -> CGSize {
        var size = CGSize.zero
        size.width = floor((YYTextMagnifierRanged.kSize.width - 2 * YYTextMagnifierRanged.kPadding) / YYTextMagnifierRanged.kMultiple)
        size.height = floor(YYTextMagnifierRanged.kHeight / YYTextMagnifierRanged.kMultiple)
        return size
    }
    
    func fitSize() -> CGSize {
        return sizeThatFits(CGSize.zero)
    }

    static var image: UIImage?
    class func coverImage() -> UIImage? {
        if let i = image {
            return i
        }
        let size: CGSize = kSize
        var rect = CGRect()
        rect.size = size
        rect.origin = CGPoint.zero
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0)
        let context = UIGraphicsGetCurrentContext()!
        let boxPath = CGPath(rect: rect, transform: nil)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: kPadding + kRadius, y: kPadding), transform: .identity)
        path.addLine(to: CGPoint(x: size.width - kPadding - kRadius, y: kPadding), transform: .identity)
        path.addQuadCurve(to: CGPoint(x: size.width - kPadding, y: kPadding + kRadius), control: CGPoint(x: size.width - kPadding, y: kPadding), transform: .identity)
        path.addLine(to: CGPoint(x: size.width - kPadding, y: kHeight), transform: .identity)
        path.addCurve(to: CGPoint(x: size.width - kPadding - kRadius, y: kPadding + kHeight), control1: CGPoint(x: size.width - kPadding, y: kPadding + kHeight), control2: CGPoint(x: size.width - kPadding - kRadius, y: kPadding + kHeight), transform: .identity)
        path.addLine(to: CGPoint(x: size.width / 2 + kArrow, y: kPadding + kHeight), transform: .identity)
        path.addLine(to: CGPoint(x: size.width / 2, y: kPadding + kHeight + kArrow), transform: .identity)
        path.addLine(to: CGPoint(x: size.width / 2 - kArrow, y: kPadding + kHeight), transform: .identity)
        path.addLine(to: CGPoint(x: kPadding + kRadius, y: kPadding + kHeight), transform: .identity)
        path.addQuadCurve(to: CGPoint(x: kPadding, y: kHeight), control: CGPoint(x: kPadding, y: kPadding + kHeight), transform: .identity)
        path.addLine(to: CGPoint(x: kPadding, y: kPadding + kRadius), transform: .identity)
        path.addQuadCurve(to: CGPoint(x: kPadding + kRadius, y: kPadding), control: CGPoint(x: kPadding, y: kPadding), transform: .identity)
        path.closeSubpath()
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: size.width / 2 - kArrow, y: YYTextUtilities.textCGFloat(pixelFloor: kPadding) + kHeight), transform: .identity)
        arrowPath.addLine(to: CGPoint(x: size.width / 2 + kArrow, y: YYTextUtilities.textCGFloat(pixelFloor: kPadding) + kHeight), transform: .identity)
        arrowPath.addLine(to: CGPoint(x: size.width / 2, y: kPadding + kHeight + kArrow), transform: .identity)
        arrowPath.closeSubpath()
        // inner shadow
        context.saveGState()
        do {
            let blurRadius: CGFloat = 25
            let offset = CGSize(width: 0, height: 15)
            let shadowColor = UIColor(white: 0, alpha: 0.16).cgColor
            let opaqueShadowColor = shadowColor.copy(alpha: 1.0)
            context.addPath(path)
            context.clip()
            context.setAlpha(shadowColor.alpha)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            do {
                context.setShadow(offset: offset, blur: blurRadius, color: opaqueShadowColor)
                context.setBlendMode(CGBlendMode.sourceOut)
                context.setFillColor(opaqueShadowColor!)
                context.addPath(path)
                context.fillPath()
            }
            context.endTransparencyLayer()
        }
        context.restoreGState()
        // outer shadow
        context.saveGState()
        do {
            context.addPath(boxPath)
            context.addPath(path)
            context.clip(using: .evenOdd)
            let shadowColor = UIColor(white: 0, alpha: 0.32).cgColor
            context.setShadow(offset: CGSize(width: 0, height: 1.5), blur: 3, color: shadowColor)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            do {
                context.addPath(path)
                UIColor(white: 0.7, alpha: 1.000).setFill()
                context.fillPath()
            }
            context.endTransparencyLayer()
        }
        context.restoreGState()
        
        // arrow
        context.saveGState()
        do {
            context.addPath(arrowPath)
            UIColor(white: 1, alpha: 0.95).set()
            context.fillPath()
        }
        context.restoreGState()
        // stroke
        context.saveGState()
        do {
            context.addPath(path)
            UIColor(white: 0.6, alpha: 1).setStroke()
            context.setLineWidth(YYTextUtilities.textCGFloat(fromPixel: 1))
            context.strokePath()
        }
        context.restoreGState()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
