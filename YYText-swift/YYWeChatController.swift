//
//  YYWeChatController.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/5.
//

import UIKit

class YYWeChatController: YYBaseViewController {
    let inset:CGFloat = 10
    let maxHeight:CGFloat = 360.0
    let imageWidth:CGFloat = 30
    private var iconImageView1 = UIImageView(image: UIImage(named: "tool_ic01"))
    private var iconImageView2 = UIImageView(image: UIImage(named: "tool_ic02"))
    private var iconImageView3 = UIImageView(image: UIImage(named: "tool_ic03"))
    private var textView = YYTextView()
    private var contentLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "仿微信输入高度动态变化"
        
        contentLabel.numberOfLines = 0
        contentLabel.textColor = .black
        view.addSubview(contentLabel)
        
        toolView.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 255)

        
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.placeholderText = "请输入..."
        textView.placeholderTextColor = .lightGray
        textView.placeholderFont = textView.font
        textView.delegate = self
        textView.returnKeyType = .send
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 5
        textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        textView.frame = CGRect(x: imageWidth + 10 * 2, y: 8, width: YYScreenWidth - imageWidth * 3 - 10 * 5, height: 40)
        
        YYTextKeyboardManager.default.add(observer: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentLabel.frame = CGRect(x: 15, y: 60, width: view.frame.size.width - 30, height: 400)
        reloadUI()
    }
    
    // MARK: - UI
    
    // MARK: - Lazy
    lazy var toolView: UIView = {
        let view = UIView()
        self.view.addSubview(view)
        
        view.addSubview(iconImageView1)
        
        view.addSubview(iconImageView2)
        
        view.addSubview(iconImageView3)
        
        view.addSubview(textView)
        
        return view
    }()
    
    // MARK: - Setter
    
    // MARK: - Reload
    func reloadUI(keyboardFrame:CGRect = YYTextKeyboardManager.default.keyboardFrame) {
        let lineNumber = textView.textLayout?.lines.count ?? 1
        var height:CGFloat = textView.textLayout?.textBoundingSize.height ?? 0
        
        if height > maxHeight {
            height = maxHeight
        }
        
        var iconY = (height - imageWidth) / 2 + 8
        if lineNumber > 1 {
            iconY = height - imageWidth
        }
        
        iconImageView1.frame = CGRect(x: 10, y: iconY, width: imageWidth, height: imageWidth)
        
        iconImageView2.frame = CGRect(x: YYScreenWidth - imageWidth * 2 - 10 * 2, y: iconY, width: imageWidth, height: imageWidth)
        
        iconImageView3.frame = CGRect(x: YYScreenWidth - imageWidth - 10, y: iconY, width: imageWidth, height: imageWidth)
        
        textView.frame = CGRect(x: 44, y: 8, width:iconImageView2.frame.origin.x - iconImageView1.frame.maxX  - 10 * 2, height: height)
        
        var offsetYHeight:CGFloat = 0
        if (!YYTextKeyboardManager.default.keyboardVisible) {
            offsetYHeight = CGFloat(YYiPhoneXSafeBottom)
            let toolHeight = CGFloat(56 + YYiPhoneXSafeBottom)
            toolView.frame = CGRect(x: 0, y: view.frame.size.height - toolHeight, width: YYScreenWidth, height: toolHeight)
        }
        
        guard keyboardFrame.size.height > 0 else {
            return
        }
        
        let rect = YYTextKeyboardManager.default.convert(keyboardFrame, to: view)
        var textFrame: CGRect = toolView.frame
        textFrame.size.height = height + 8 * 2 + offsetYHeight
        let offsetY = textFrame.maxY - rect.origin.y
        if (offsetY > 0 || !textView.isVerticalForm) {
            textFrame.origin.y -= offsetY
            toolView.frame = textFrame
        }
    }
    
    // MARK: - Action
    @objc private func editAction(_ sender: UIBarButtonItem?) {
        view.endEditing(true)
    }
}

// MARK: - YYTextViewDelegate
extension YYWeChatController: YYTextViewDelegate {
    func textViewDidBeginEditing(_ textView: YYTextView) {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editAction(_:)))
        navigationItem.rightBarButtonItem = buttonItem
    }

    func textViewDidEndEditing(_ textView: YYTextView) {
        navigationItem.rightBarButtonItem = nil
    }
    
    func textView(_ textView: YYTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(true)
            contentLabel.text = textView.text
            textView.text = ""
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: YYTextView) {
        reloadUI()
    }
}

extension YYWeChatController: YYTextKeyboardObserver {
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        reloadUI(keyboardFrame: transition.toFrame)
    }
}


