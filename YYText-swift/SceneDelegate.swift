//
//  SceneDelegate.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/5.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        yy_load()
        
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let nav = UINavigationController(rootViewController: YYHomeTableViewController())
            window.rootViewController = nav
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    /// 按需对指定类执行方法交换
    func yy_load() {
        let classList:[AnyClass] = [
            UIViewController.self,
            UIView.self
        ]
        for index in 0 ..< classList.count {
            (classList[index] as? YYLoad.Type)?.runOnce()
        }
    }
}

