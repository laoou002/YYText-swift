//
//  UIColor+YYAdd.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/17.
//

import Foundation
import UIKit

extension UIColor {

    /// 使用十六进制颜色码生成`UIColor`对象, eg:`UIColor(0xFF2D3A)`
    /// - Author: HouWan
    /// - Parameters:
    ///   - hexValue: 十六进制数值
    ///   - alpha: alpha, default: 1.0, alpha取值范围是[0...1]
    convenience public init(_ hexValue: Int, alpha: Float = 1.0) {
        self.init(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0,
                 blue: CGFloat(hexValue & 0x0000FF) / 255.0,
                alpha: CGFloat(alpha))
    }
    
}
