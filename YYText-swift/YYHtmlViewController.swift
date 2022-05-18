//
//  YYHtmlViewController.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/16.
//

import UIKit

class YYHtmlViewController: YYBaseViewController {

    private let label = YYLabel()
    private var isShowMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let html = "<p><strong>假如生活欺骗了你</strong>，不要忧伤，不要心急，犹豫的日子里需要镇静。相信吧，<strong>快乐的日子将会来临</strong>，心儿永远向往着未来，现在去常是忧郁。一切都是瞬息，<a href=\"https://www.baidu.com\" target=\"_self\" title=\"这是一个链接\">这是一个链接</a>一切都将会过去，，而那过来去了的，就会成为亲切的怀恋。</p><p><br/></p>"
                
        label.yy_setHtmlAttributedString(text: html, font: UIFont.systemFont(ofSize: 15), lineSpacing: 6, color: .black, linkColor: .blue) { attri, needReload in
            if attri != nil {
                self.setupTag(attri!)
                self.label.attributedText = attri
            }
        }
        view.addSubview(label)
        reloadUI()
        addMoreButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func reloadUI() {
        let lineCount:CGFloat = 3
        label.numberOfLines = Int(isShowMore ? 0 : lineCount)
        
        let width = YYScreenWidth - 30
        let attri = label.attributedText
        
        
        let layout = YYTextLayout(containerSize: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), text: attri)
        var height = layout?.textBoundingSize.height
        self.label.frame = CGRect(x: 15, y: YYNavigatioHeight + 15, width: width, height: height!)
        
        guard !isShowMore else {
            return
        }

        let lines = label.textLayout?.lines
        if let line = lines?[0] {
            height = (line.height + attri!.yy_lineSpacing) * lineCount
            print("height = \(height!)")
            self.label.frame = CGRect(x: 15, y: YYNavigatioHeight + 15, width: width, height: height!)
        }
    }
    
    /// yylabel插入ui
    func setupTag(_ attri:NSMutableAttributedString) {
        let button = UIButton()
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        button.backgroundColor = UIColor(0xFF772A)
        button.setTitle("精选", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight:UIFont.Weight.medium)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 15)
        
        let lineSpacing = attri.yy_lineSpacing
        if let attachText = NSMutableAttributedString.yy_attachmentString(with: button, contentMode: .center, attachmentSize: CGSize(width: 28, height: 15), alignTo: attri.yy_font, alignment: .center) {
            attri.insert(attachText, at: 0)
            attri.yy_lineSpacing = lineSpacing
        }
    }
    
    /// yylabel截断符替换
    func addMoreButton() {
        let attri = NSMutableAttributedString(string: "...展开")
        attri.yy_font = UIFont.systemFont(ofSize: 15)
        attri.yy_color = .black
        attri.yy_set(color: UIColor(0x00C8C8), range: NSRange(location: 3, length: 2))
        
        let hi = YYTextHighlight()
        hi.color = UIColor(0x00C8C8)
        
        hi.yy_tapAction { _, _, _, _ in
            self.isShowMore = true
            self.reloadUI()
        }
        
        attri.yy_set(textHighlight: hi, range: attri.yy_rangeOfAll)
        
        let moreLabel = YYLabel()
        moreLabel.attributedText = attri
        moreLabel.sizeToFit()
        
        let truncationToken = NSAttributedString.yy_attachmentString(with: moreLabel, contentMode: .center, attachmentSize: moreLabel.frame.size, alignTo: attri.yy_font, alignment: .center)
        label.truncationToken = truncationToken
    }
}
