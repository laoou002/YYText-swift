//
//  YYBaseViewController.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/17.
//

import UIKit

class YYBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showToast(_ msg:String) {
        view.endEditing(true)
        
        let label = UILabel()
        label.backgroundColor = .gray
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.textColor = .white
        label.frame = CGRect(x: 0, y: 0, width: 240, height: 50)
        label.center = view.center
        label.alpha = 0
        label.text = msg
        view.addSubview(label)
        
        UIView.animate(withDuration: 0.5) {
            label.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 2.5) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if NSStringFromSelector(action) == "copyAction" {
            return true
        }
        return false
    }
}
