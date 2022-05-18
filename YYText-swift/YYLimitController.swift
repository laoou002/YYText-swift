//
//  YYLimitController.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/13.
//

import UIKit

class YYLimitController: YYBaseViewController {

    private var textView = YYTextView()
    
    private var switchView = UISwitch()
    
    private var numberLabel = UILabel()
    
    private var maxWordCount = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let switchY = 20 + CGFloat(YYNavigatioHeight)
        
        let switchLabel = UILabel()
        switchLabel.textColor = .gray
        switchLabel.text = "超出截断："
        switchLabel.font = UIFont.systemFont(ofSize: 15)
        switchLabel.frame = CGRect(x: 15, y: switchY, width: 100, height: 31)
        view.addSubview(switchLabel)
        
        switchView = UISwitch()
        switchView.isOn = false
        switchView.addTarget(self, action: #selector(switchAction(_:)), for: .touchUpInside)
        switchView.frame = CGRect(x: YYScreenWidth - 49 - 15, y: switchY, width: 49, height: 31)
        view.addSubview(switchView)
        
        textView.frame = CGRect(x: 15, y: switchView.frame.maxY + 15, width: YYScreenWidth - 30, height: 240)
        textView.layer.cornerRadius = 8
        textView.clipsToBounds = true
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.placeholderText = "请输入..."
        textView.placeholderTextColor = .lightGray
        textView.placeholderFont = textView.font
        textView.delegate = self
        textView.returnKeyType = .send
        textView.backgroundColor = UIColor(white: 0.134, alpha: 1.000)
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 5
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView.text = "假如生活欺骗了你不要忧伤，不要心急，犹豫的日子里需要镇静。相信吧，快乐的日子将会来临.心儿永远向往着未来，现在去常是忧郁。一切都是瞬息，一切都将会过去，，而那过来去了的，就会成为亲切的怀恋."
        view.addSubview(textView)
        
        numberLabel.frame = CGRect(x: textView.frame.maxX - 72 - 15, y: textView.frame.maxY - 28, width:72 , height: 20)
        numberLabel.textAlignment = .right
        numberLabel.textColor = .lightGray
        numberLabel.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(numberLabel)
        
        reloadUI(textView.text.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Reload
    func reloadUI(_ wordCount:Int = 0) {
        
        let arrti = NSMutableAttributedString(string: "\(wordCount)/\(maxWordCount)")
        arrti.yy_color = .lightGray
        
        if !switchView.isOn && wordCount > maxWordCount {
            arrti.yy_set(color: .red, range: NSRange(location: 0, length: "\(wordCount)".count))
        }
        
        numberLabel.attributedText = arrti
    }
    
    // MARK: - Action
    @objc private func doneAction(_ sender: UIBarButtonItem?) {
        view.endEditing(true)
    }
    
    @objc private func switchAction(_ sender: UISwitch?) {
        view.endEditing(true)
        textView.maxWordCount = switchView.isOn ? maxWordCount : 0
        reloadUI(textView.text.count)
    }
}

// MARK: - YYTextViewDelegate
extension YYLimitController: YYTextViewDelegate {
    func textViewDidBeginEditing(_ textView: YYTextView) {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        navigationItem.rightBarButtonItem = buttonItem
    }

    func textViewDidEndEditing(_ textView: YYTextView) {
        navigationItem.rightBarButtonItem = nil
    }
    
    func textViewWordCountChange(_ textView: YYTextView, count: Int) {
        print("当前输入了\(count)个字")
        reloadUI(count)
    }
    
    func textView(_ textView: YYTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text.count > maxWordCount {
                showToast("#😭字数超了😭#")
            }else{
                showToast("#😊校验通过😊#")
            }
            return false
        }
        return true
    }
}
