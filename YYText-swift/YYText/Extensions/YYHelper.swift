//
//  YYHelper.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/5.
//

import UIKit
import Foundation

/// 判断是否是`iPhoneX`系列，此系列有`safeArea`的概念
/// - Returns: true代表是`iPhoneX`系列
public func YYiPhoneX() -> Bool {
    // 利用safeAreaInsets.bottom > 0 来判断是否是iPhoneX系列
    guard let w = UIApplication.shared.windows.first else {
        return false
    }
    
    guard #available(iOS 11.0, *) else {
        return false
    }
    
    return w.safeAreaInsets.bottom > 0.0
}


// ============================================================================
// MARK: - Constants
// ============================================================================

/// -> 手机屏幕的宽度
public let YYScreenWidth = UIScreen.main.bounds.width
/// -> 手机屏幕的高度
public let YYScreenHeight = UIScreen.main.bounds.height

/// `iPhoneX`系列顶部的安全边距
public let YYiPhoneXSafeTop = 44.0
/// `iPhoneX`系列底部的安全边距
public let YYiPhoneXSafeBottom = 34.0

/// App状态栏的高度
var YYStatusBarHeight: CGFloat {
    return YYiPhoneX() ? 40.0 : 20
}

/// App导航栏高度，包含状态栏(20/44)
var YYNavigatioHeight: CGFloat {
    return YYiPhoneX() ? 88.0 : 64.0
}

/// App`TabBar`的高度
var YYTabBarHeight: CGFloat {
    return YYiPhoneX() ? 83.0 : 49.0
}

/**
 *  对象方法的交换
 *
 *  @param anClass    哪个类
 *  @param method1Sel 方法1(原本的方法)
 *  @param method2Sel 方法2(要替换成的方法)
 */
public func YYExchangeMethod(_ anClass:AnyClass, _ method1Sel:Selector, _ method2Sel:Selector) {
    let originalMethod = class_getInstanceMethod(anClass, method1Sel)
    let swizzledMethod = class_getInstanceMethod(anClass, method2Sel)
    
    if originalMethod == nil || swizzledMethod == nil {
        return
    }
    //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
    let didAddMethod: Bool = class_addMethod(anClass, method1Sel, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
    if didAddMethod {
        class_replaceMethod(anClass, method2Sel, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    } else {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

