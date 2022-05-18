//
//  YYTextEffectWindow.swift
//  JianZhiApp-swift
//
//  Created by 老欧 on 2022/4/20.
//

import UIKit

/**
 A window to display magnifier and extra contents for text view.
 
 @discussion Use `sharedWindow` to get the instance, don't create your own instance.
 Typically, you should not use this class directly.
 */
@objc public class YYTextEffectWindow: UIWindow {
    
    static var sharedWindowOne: YYTextEffectWindow? = nil
    
    /// Returns the shared instance (returns nil in App Extension).
    @objc(sharedWindow)
    public class var shared: YYTextEffectWindow? {
    
        if sharedWindowOne == nil {
            // iOS 9 compatible
            let mode = RunLoop.current.currentMode
            if mode?.rawValue.count == 27 && mode?.rawValue.hasPrefix("UI") ?? false && mode?.rawValue.hasSuffix("InitializationRunLoopMode") ?? false {
                return nil
            }
        }
        
        if let _ = sharedWindowOne {
            return sharedWindowOne
        }
        
        if !YYTextUtilities.isAppExtension {
            let one = self.init()
            one.rootViewController = UIViewController()
            var rect = CGRect.zero
            rect.size = YYTextUtilities.textScreenSize
            one.frame = rect
            one.isUserInteractionEnabled = false
            one.windowLevel = UIWindow.Level(UIWindow.Level.statusBar.rawValue + 1)
            one.isHidden = false
            // for iOS9:
            one.isOpaque = false
            one.backgroundColor = UIColor.clear
            one.layer.backgroundColor = UIColor.clear.cgColor
            
            sharedWindowOne = one
        }
        
        return sharedWindowOne
    }
    
    /// Show the magnifier in this window with a 'popup' animation. @param magnifier A magnifier.
    @objc(showMagnifier:)
    public func show(_ magnifier: YYTextMagnifier?) {
        guard let mag = magnifier else {
            return
        }
        if mag.superview != self {
            addSubview(mag)
        }
        _updateWindowLevel()
        let rotation = _update(magnifier: mag)
        let center: CGPoint = yy_convertPoint(mag.hostPopoverCenter, fromViewOrWindow: mag.hostView)
        var trans = CGAffineTransform(rotationAngle: rotation)
        trans = trans.scaledBy(x: 0.3, y: 0.3)
        mag.transform = trans
        mag.center = center
        if mag.type == YYTextMagnifierType.ranged {
            mag.alpha = 0
        }
        let time: TimeInterval = mag.type == YYTextMagnifierType.caret ? 0.08 : 0.1
        UIView.animate(withDuration: time, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            if mag.type == YYTextMagnifierType.caret {
                var newCenter = CGPoint(x: 0, y: -mag.fitSize.height / 2)
                newCenter = newCenter.applying(CGAffineTransform(rotationAngle: rotation))
                newCenter.x += center.x
                newCenter.y += center.y
                mag.center = self._corrected(center: newCenter, for: mag, rotation: rotation)
            } else {
                mag.center = self._corrected(center: center, for: mag, rotation: rotation)
            }
            mag.transform = CGAffineTransform(rotationAngle: rotation)
            mag.alpha = 1
        }) { finished in
        }
    }
    
    /// Update the magnifier content and position. @param magnifier A magnifier.
    @objc(moveMagnifier:)
    public func move(_ magnifier: YYTextMagnifier?) {
        guard let mag = magnifier else {
            return
        }
        _updateWindowLevel()
        let rotation = _update(magnifier: mag)
        let center: CGPoint = yy_convertPoint(mag.hostPopoverCenter, fromViewOrWindow: mag.hostView)
        if mag.type == YYTextMagnifierType.caret {
            var newCenter = CGPoint(x: 0, y: -mag.fitSize.height / 2)
            newCenter = newCenter.applying(CGAffineTransform(rotationAngle: rotation))
            newCenter.x += center.x
            newCenter.y += center.y
            mag.center = _corrected(center: newCenter, for: mag, rotation: rotation)
        } else {
            mag.center = _corrected(center: center, for: mag, rotation: rotation)
        }
        mag.transform = CGAffineTransform(rotationAngle: rotation)
    }
    
    /// Remove the magnifier from this window with a 'shrink' animation. @param magnifier A magnifier.
    @objc(hideMagnifier:)
    public func hide(_ magnifier: YYTextMagnifier?) {
        guard let mag = magnifier else {
            return
        }
        if mag.superview != self {
            return
        }
        let rotation = _update(magnifier: mag)
        let center: CGPoint = yy_convertPoint(mag.hostPopoverCenter, fromViewOrWindow: mag.hostView)
        let time: TimeInterval = mag.type == YYTextMagnifierType.caret ? 0.20 : 0.15
        UIView.animate(withDuration: time, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            var trans = CGAffineTransform(rotationAngle: rotation)
            trans = trans.scaledBy(x: 0.01, y: 0.01)
            mag.transform = trans
            if mag.type == YYTextMagnifierType.caret {
                var newCenter = CGPoint(x: 0, y: -mag.fitSize.height / 2)
                newCenter = newCenter.applying(CGAffineTransform(rotationAngle: rotation))
                newCenter.x += center.x
                newCenter.y += center.y
                mag.center = self._corrected(center: newCenter, for: mag, rotation: rotation)
            } else {
                mag.center = self._corrected(center: center, for: mag, rotation: rotation)
                mag.alpha = 0
            }
        }) { finished in
            if finished {
                mag.removeFromSuperview()
                mag.transform = CGAffineTransform.identity
                mag.alpha = 1
            }
        }
    }
    
    /// Show the selection dot in this window if the dot is clipped by the selection view.
    /// @param selectionDot A selection view.
    @objc(showSelectionDot:)
    public func show(selectionDot: YYTextSelectionView?) {
        guard let selection = selectionDot else {
            return
        }
        _updateWindowLevel()
        let aMirror = selection.startGrabber.dot.mirror
        insertSubview(aMirror, at: 0)
        
        let eMirror = selection.endGrabber.dot.mirror
        insertSubview(eMirror, at: 0)
        
        _update(dot: selection.startGrabber.dot, selection: selection)
        _update(dot: selection.endGrabber.dot, selection: selection)
    }
    
    /// Remove the selection dot from this window.
    /// @param selectionDot A selection view.
    @objc(hideSelectionDot:)
    public func hide(selectionDot: YYTextSelectionView?) {
        guard let selection = selectionDot else {
            return
        }
        selection.startGrabber.dot.mirror.removeFromSuperview()
        selection.endGrabber.dot.mirror.removeFromSuperview()
    }
    
    // stop self from becoming the KeyWindow
    override public func becomeKey() {
        YYTextUtilities.sharedApplication?.delegate?.window??.makeKey()
    }
    
    override public var rootViewController: UIViewController? {
        set {
            super.rootViewController = newValue
        }
        get {
            guard let ws = YYTextUtilities.sharedApplication?.windows else {
                return nil
            }
            if #available(iOS 13, *) {
                return super.rootViewController
            }
            for window in ws {
                if self == window {
                    continue
                }
                if window.isHidden {
                    continue
                }
                
                if let topViewController = window.rootViewController {
                    return topViewController
                }
            }
            
            return super.rootViewController
        }
    }
    
    // Bring self to front
    func _updateWindowLevel() {
        
        guard let app = YYTextUtilities.sharedApplication else {
            return
        }
        var top = app.windows.last
        let key = YYLabel.keyWindow
        if let aLevel = key?.windowLevel, let aLevel1 = top?.windowLevel {
            if key != nil && aLevel > aLevel1 {
                top = key
            }
        }
        if top == self {
            return
        }
        windowLevel = UIWindow.Level((top?.windowLevel.rawValue ?? 0) + 1)
    }
    
    func _keyboardDirection() -> YYTextDirection {
        var keyboardFrame: CGRect = YYTextKeyboardManager.default.keyboardFrame
        keyboardFrame = YYTextKeyboardManager.default.convert(keyboardFrame, to: self)
        if keyboardFrame.isNull || keyboardFrame.isEmpty {
            return YYTextDirection.none
        }
        if keyboardFrame.minY == 0 && keyboardFrame.minX == 0 && keyboardFrame.maxX == frame.width {
            return YYTextDirection.top
        }
        if keyboardFrame.maxX == frame.width && keyboardFrame.minY == 0 && keyboardFrame.maxY == frame.height {
            return YYTextDirection.right
        }
        if keyboardFrame.maxY == frame.height && keyboardFrame.minX == 0 && keyboardFrame.maxX == frame.width {
            return YYTextDirection.bottom
        }
        if keyboardFrame.minX == 0 && keyboardFrame.minY == 0 && keyboardFrame.maxY == frame.height {
            return YYTextDirection.left
        }
        return YYTextDirection.none
    }
    
    func _corrected(captureCenter center: CGPoint) -> CGPoint {
        var center = center
        var keyboardFrame: CGRect = YYTextKeyboardManager.default.keyboardFrame
        keyboardFrame = YYTextKeyboardManager.default.convert(keyboardFrame, to: self)
        if !keyboardFrame.isNull && !keyboardFrame.isEmpty {
            let direction: YYTextDirection = _keyboardDirection()
            switch direction {
            case YYTextDirection.top:
                if center.y < keyboardFrame.maxY {
                    center.y = keyboardFrame.maxY
                }
            case YYTextDirection.right:
                if center.x > keyboardFrame.minX {
                    center.x = keyboardFrame.minX
                }
            case YYTextDirection.bottom:
                if center.y > keyboardFrame.minY {
                    center.y = keyboardFrame.minY
                }
            case YYTextDirection.left:
                if center.x < keyboardFrame.maxX {
                    center.x = keyboardFrame.maxX
                }
            default:
                break
            }
        }
        return center
    }
    
    func _corrected(center: CGPoint, for mag: YYTextMagnifier, rotation: CGFloat) -> CGPoint {
        var center = center
        var degree = YYTextUtilities.textDegrees(from: rotation)
        degree /= 45.0
        if degree < 0 {
            degree += CGFloat(Int(-degree / 8.0 + 1) * 8)
        }
        if degree > 8 {
            degree -= CGFloat(Int(degree / 8.0) * 8)
        }
        let caretExt: CGFloat = 10
        if degree <= 1 || degree >= 7 {
            //top
            if mag.type == YYTextMagnifierType.caret {
                if center.y < caretExt {
                    center.y = caretExt
                }
            } else if mag.type == YYTextMagnifierType.ranged {
                if center.y < mag.bounds.size.height {
                    center.y = mag.bounds.size.height
                }
            }
        } else if 1 < degree && degree < 3 {
            // right
            if mag.type == YYTextMagnifierType.caret {
                if center.x > bounds.size.width - caretExt {
                    center.x = bounds.size.width - caretExt
                }
            } else if mag.type == YYTextMagnifierType.ranged {
                if center.x > bounds.size.width - mag.bounds.size.height {
                    center.x = bounds.size.width - mag.bounds.size.height
                }
            }
        } else if 3 <= degree && degree <= 5 {
            // bottom
            if mag.type == YYTextMagnifierType.caret {
                if center.y > bounds.size.height - caretExt {
                    center.y = bounds.size.height - caretExt
                }
            } else if mag.type == YYTextMagnifierType.ranged {
                if center.y > mag.bounds.size.height {
                    center.y = mag.bounds.size.height
                }
            }
        } else if 5 < degree && degree < 7 {
            // left
            if mag.type == YYTextMagnifierType.caret {
                if center.x < caretExt {
                    center.x = caretExt
                }
            } else if mag.type == YYTextMagnifierType.ranged {
                if center.x < mag.bounds.size.height {
                    center.x = mag.bounds.size.height
                }
            }
        }
        
        var keyboardFrame: CGRect = YYTextKeyboardManager.default.keyboardFrame
        keyboardFrame = YYTextKeyboardManager.default.convert(keyboardFrame, to: self)
        if !keyboardFrame.isNull && !keyboardFrame.isEmpty {
            let direction: YYTextDirection = _keyboardDirection()
            switch direction {
            case YYTextDirection.top:
                if mag.type == YYTextMagnifierType.caret {
                    if center.y - mag.bounds.size.height / 2 < keyboardFrame.maxY {
                        center.y = keyboardFrame.maxY + mag.bounds.size.height / 2
                    }
                } else if mag.type == YYTextMagnifierType.ranged {
                    if center.y < keyboardFrame.maxY {
                        center.y = keyboardFrame.maxY
                    }
                }
            case YYTextDirection.right:
                if mag.type == YYTextMagnifierType.caret {
                    if center.x + mag.bounds.size.height / 2 > keyboardFrame.minX {
                        center.x = keyboardFrame.minX - mag.bounds.size.width / 2
                    }
                } else if mag.type == YYTextMagnifierType.ranged {
                    if center.x > keyboardFrame.minX {
                        center.x = keyboardFrame.minX
                    }
                }
            case YYTextDirection.bottom:
                if mag.type == YYTextMagnifierType.caret {
                    if center.y + mag.bounds.size.height / 2 > keyboardFrame.minY {
                        center.y = keyboardFrame.minY - mag.bounds.size.height / 2
                    }
                } else if mag.type == YYTextMagnifierType.ranged {
                    if center.y > keyboardFrame.minY {
                        center.y = keyboardFrame.minY
                    }
                }
            case YYTextDirection.left:
                if mag.type == YYTextMagnifierType.caret {
                    if center.x - mag.bounds.size.height / 2 < keyboardFrame.maxX {
                        center.x = keyboardFrame.maxX + mag.bounds.size.width / 2
                    }
                } else if mag.type == YYTextMagnifierType.ranged {
                    if center.x < keyboardFrame.maxX {
                        center.x = keyboardFrame.maxX
                    }
                }
            default:
                break
            }
        }
        
        return center;
    }
    
    private static var placeholderRect = CGRect.zero
    private static var placeholder: UIImage = {
        
        placeholderRect.origin = CGPoint.zero
        UIGraphicsBeginImageContextWithOptions(placeholderRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        UIColor(white: 1, alpha: 0.8).set()
        context?.fill(placeholderRect)
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return img
    }()
    
    /**
     Capture screen snapshot and set it to magnifier.
     @return Magnifier rotation radius.
     */
    private func _update(magnifier mag: YYTextMagnifier) -> CGFloat {
        
        guard let app = YYTextUtilities.sharedApplication else {
            return 0
        }
        let hostView: UIView? = mag.hostView
        let hostWindow = (hostView is UIWindow) ? (hostView as? UIWindow) : hostView?.window
        if hostView == nil || hostWindow == nil {
            return 0
        }
        var captureCenter: CGPoint = yy_convertPoint(mag.hostCaptureCenter, fromViewOrWindow: hostView)
        captureCenter = _corrected(captureCenter: captureCenter)
        var captureRect = CGRect()
        captureRect.size = mag.snapshotSize
        captureRect.origin.x = captureCenter.x - captureRect.size.width / 2
        captureRect.origin.y = captureCenter.y - captureRect.size.height / 2
        let trans: CGAffineTransform = YYTextUtilities.textCGAffineTransformGet(from: hostView, to: self)
        let rotation: CGFloat = YYTextUtilities.textCGAffineTransformGetRotation((trans))
        if mag.captureDisabled {
            if mag.snapshot == nil || mag.snapshot!.size.width > 1 {
                
                YYTextEffectWindow.placeholderRect = mag.bounds
                
                mag.captureFadeAnimation = true
                mag.snapshot = YYTextEffectWindow.placeholder
                mag.captureFadeAnimation = false
            }
            return rotation
        }

        UIGraphicsBeginImageContextWithOptions(captureRect.size, _: false, _: 0)
        let context = UIGraphicsGetCurrentContext()
        if context == nil {
            return rotation
        }
        var tp = CGPoint(x: captureRect.size.width / 2, y: captureRect.size.height / 2)
        tp = tp.applying(CGAffineTransform(rotationAngle: rotation))
        context?.rotate(by: -rotation)
        context?.translateBy(x: tp.x - captureCenter.x, y: tp.y - captureCenter.y)
        var windows = app.windows
        let keyWindow = YYLabel.keyWindow
        if let aWindow = keyWindow {
            if !windows.contains(aWindow) {
                windows.append(aWindow)
            }
        }
        windows = (windows as NSArray).sortedArray(comparator: { w1, w2 in
            let aLevel = (w1 as! UIWindow).windowLevel
            let aLevel1 = (w2 as! UIWindow).windowLevel
            
            if aLevel < aLevel1 {
                return .orderedAscending
            } else if aLevel > aLevel {
                return .orderedDescending
            }
            
            return .orderedSame
        }) as? [UIWindow] ?? windows
        
        let mainScreen = UIScreen.main
        for window in windows {
            if window.isHidden || window.alpha <= 0.01 {
                continue
            }
            if window.screen != mainScreen {
                continue
            }
            if (window.isKind(of: type(of: self))) {
                break //don't capture window above self
            }
            context?.saveGState()
            context?.concatenate(YYTextUtilities.textCGAffineTransformGet(from: window, to: self))
            if let aContext = context {
                window.layer.render(in: aContext)
            } //render
            //[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO]; //slower when capture whole window
            context?.restoreGState()
        }
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if mag.snapshot!.size.width == 1 {
            mag.captureFadeAnimation = true
        }
        mag.snapshot = image
        mag.captureFadeAnimation = false
        return rotation
    }
    
    func _update(dot: YYSelectionGrabberDot, selection: YYTextSelectionView) {
        dot.mirror.isHidden = true
        if selection.hostView?.clipsToBounds == true && dot.yy_visibleAlpha > 0.1 {
            let dotRect = dot.yy_convertRect(dot.bounds, toViewOrWindow: self)
            var dotInKeyboard = false
            var keyboardFrame: CGRect = YYTextKeyboardManager.default.keyboardFrame
            keyboardFrame = YYTextKeyboardManager.default.convert(keyboardFrame, to: self)
            if !keyboardFrame.isNull && !keyboardFrame.isEmpty {
                let inter: CGRect = dotRect.intersection(keyboardFrame)
                if !inter.isNull && (inter.size.width > 1 || inter.size.height > 1) {
                    dotInKeyboard = true
                }
            }
            if !dotInKeyboard {
                let hostRect = selection.hostView!.convert(selection.hostView!.bounds, to: self)
                let intersection: CGRect = dotRect.intersection(hostRect)
                if YYTextUtilities.textCGRectGetArea(intersection) < YYTextUtilities.textCGRectGetArea(dotRect) {
                    let dist = YYTextUtilities.textCGPointGetDistance(to: YYTextUtilities.textCGRectGetCenter(dotRect), r: hostRect)
                    if dist < dot.frame.width * 0.55 {
                        dot.mirror.isHidden = false
                    }
                }
            }
        }
        let center = dot.yy_convertPoint(CGPoint(x: dot.frame.width / 2, y: dot.frame.height / 2), toViewOrWindow: self)
        if center.x.isNaN || center.y.isNaN || center.x.isInfinite || center.y.isInfinite {
            dot.mirror.isHidden = true
        } else {
            dot.mirror.center = center
        }
    }
}
