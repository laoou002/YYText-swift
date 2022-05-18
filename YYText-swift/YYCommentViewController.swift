//
//  YYCommentViewController.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/17.
//

import UIKit

class YYCommentViewController: YYBaseViewController {
    
    private let label = YYLabel()
    private let commentLabel = YYLabel()
    private var isShowMore = false
    private var waitCopy = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let html = "<p><strong>假如生活欺骗了你</strong>，不要忧伤，不要心急，犹豫的日子里需要镇静。相信吧，<strong>快乐的日子将会来临</strong>，心儿永远向往着未来，现在去常是忧郁。一切都是瞬息，<a href=\"https://www.baidu.com\" target=\"_self\" title=\"这是一个链接\">这是一个链接</a>一切都将会过去，，而那过来去了的，就会成为亲切的怀恋。</p>"
                
        label.yy_setHtmlAttributedString(text: html, font: UIFont.systemFont(ofSize: 15), lineSpacing: 6, color: .black, linkColor: .blue) { attri, needReload in
            if attri != nil {
                self.setupTag(attri!)
                self.label.attributedText = attri
            }
        }
        view.addSubview(label)
        reloadUI()
        addMoreButton()
        
        setupCommentUI()
        testComment()
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
        label.frame = CGRect(x: 15, y: YYNavigatioHeight + 15, width: width, height: height!)
        label.sizeToFit()
        
        reloadCommentUI()
        
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

// MARK: - 评论
extension YYCommentViewController {
    
    func setupCommentUI() {
        commentLabel.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        commentLabel.backgroundColor = UIColor(0xF7F7F7)
        commentLabel.numberOfLines = 0
        commentLabel.clipsToBounds = true
        commentLabel.layer.cornerRadius = 5
        commentLabel.frame = CGRect(x: 15, y: label.frame.maxY + 10, width: label.frame.size.width, height: 40)
        view.addSubview(commentLabel)
    }
    
    func sendComment(model:YYCommentModel) {
        let attri = NSMutableAttributedString(attributedString: commentLabel.attributedText ?? NSAttributedString())
        attri.yy_lineSpacing = 6
        
        if (attri.string.count > 0) {
            attri.yy_append(string: "\n")
        }
        
        let hiBackgroundColor = UIColor(white: 0.0, alpha: 0.22)
        let location = attri.yy_rangeOfAll.length
        
        // 发评论的用户昵称
        let nicknameAttri = NSMutableAttributedString(string: model.nickname)
        nicknameAttri.yy_color = UIColor(0x616289)
        nicknameAttri.yy_font = UIFont.boldSystemFont(ofSize: 15)
        attri.append(nicknameAttri)
                
        // 添加高亮点击
        attri.yy_set(textHighlightRange: NSRange(location: location, length: model.nickname.length), color: UIColor(0x616289), backgroundColor: hiBackgroundColor, userInfo: ["nickname": model.nickname!]) { view, _, _, _ in
            let highlight = (view as! YYLabel).highlight
            let msg = highlight?.userInfo?["nickname"] as! String
            self.showToast("点击了： \(msg)")
        } longPress: { view, _, _, rect in
            print("yy 长按了")
            let highlight = (view as! YYLabel).highlight
            self.waitCopy = highlight?.userInfo?["nickname"] as! String
            self.showCopyMenu(view!, rect)
        }
        
        if let toNickname = model.toNickname {
            // 回复
            let reAttri = NSMutableAttributedString(string: " 回复 ")
            reAttri.yy_color = UIColor(0x333333)
            reAttri.yy_font = UIFont.systemFont(ofSize: 15)
            attri.append(reAttri)
            
            // 被回复的用户昵称
            let location = attri.yy_rangeOfAll.length
            let toNicknameAttri = NSMutableAttributedString(string: toNickname)
            toNicknameAttri.yy_color = UIColor(0x616289)
            toNicknameAttri.yy_font = UIFont.boldSystemFont(ofSize: 15)
            attri.append(toNicknameAttri)
            
            // 添加高亮点击
            attri.yy_set(textHighlightRange: NSRange(location: location, length: toNickname.length), color: UIColor(0x616289), backgroundColor: hiBackgroundColor, userInfo: ["nickname": toNickname]) { view, _, _, _ in
                let highlight = (view as! YYLabel).highlight
                let msg = highlight?.userInfo?["nickname"] as! String
                self.showToast("点击了： \(msg)")
            } longPress: { view, _, _, rect in
                print("yy 长按了")
                let highlight = (view as! YYLabel).highlight
                self.waitCopy = highlight?.userInfo?["nickname"] as! String
                self.showCopyMenu(view!, rect)
            }
        }
        
        let contentAttri = NSMutableAttributedString(string: "：\(String(model.content))")
        contentAttri.yy_color = UIColor(0x333333)
        contentAttri.yy_font = UIFont.systemFont(ofSize: 15)
        attri.append(contentAttri)
        
        commentLabel.attributedText = attri
        
        reloadCommentUI()
    }
    
    
    func reloadCommentUI() {
        let y = label.frame.maxY + 10
        let width = label.frame.size.width
        let layout = YYTextLayout(containerSize: CGSize(width: width - 20, height: CGFloat.greatestFiniteMagnitude), text: commentLabel.attributedText)
        if let height = layout?.textBoundingSize.height {
            commentLabel.frame = CGRect(x: 15, y: y, width: width, height: height + 20)
        }
    }
    
    func testComment(_ index:Int = 0) {
        let list:[YYCommentModel] = [
            YYCommentModel(nickname: "张三",toNickname: nil, content: "我是来刷存在感的哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈"),
            YYCommentModel(nickname: "李四",toNickname: "张三", content: "me too"),
            YYCommentModel(nickname: "王五",toNickname: nil, content: "晚上吃什么"),
            YYCommentModel(nickname: "老六",toNickname: nil, content: "虽然到现在还不太安稳，你会为我默默留下一盏灯"),
            YYCommentModel(nickname: "赖七",toNickname: "老六", content: "于你而言我只不过是个，匆匆而过的旅人"),
            YYCommentModel(nickname: "老八",toNickname: nil, content: "都你如何毁蚁窝？"),
            YYCommentModel(nickname: "九妹",toNickname: "老八", content: "是带着笑或是很沉默?"),
        ]
        
        if index < list.count {
            let model = list[index]
            sendComment(model: model)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.testComment(index+1)
            }
        }
    }
    
    func showCopyMenu(_ view:UIView, _ rect:CGRect) {
        let copyItem = UIMenuItem(title: "复制", action: #selector(copyAction))
        UIMenuController.shared.menuItems = [copyItem]
        UIMenuController.shared.showMenu(from: view, rect: rect)
    }
    
    // MARK: - Action
    @objc func copyAction() {
        UIPasteboard.general.string = waitCopy
        showToast("复制成功")
    }
}

class YYCommentModel: NSObject {
    var nickname:String!
    var toNickname:String?
    var content:String!
    
    init(nickname:String, toNickname:String?,content:String) {
        super.init()
        self.nickname = nickname
        self.toNickname = toNickname
        self.content = content
    }
}
