//
//  YYExchangeMethod.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/10.
//

import Foundation
import UIKit

/**
 *  项目中需要做方法交互的扩展，统一在这个类处理，方便管理
 */

protocol YYLoad: Any {
    static func runOnce()
}

extension UIViewController:YYLoad {
    public static func runOnce() {
        /// 这里写了两个示例给大伙看
        YYExchangeMethod(self, #selector(viewWillAppear(_:)), #selector(yy_viewWillAppear(_:)))
        
        YYExchangeMethod(self, #selector(touchesBegan(_:with:)), #selector(yy_touchesBegan(_:with:)))
    }

    @objc func yy_viewWillAppear(_ animated: Bool) {
        yy_viewWillAppear(animated)
    }
    
    @objc func yy_touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(false)
    }
}
