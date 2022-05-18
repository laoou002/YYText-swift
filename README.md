# 致敬YYText的作者，YYText的Swift版本

[Objecttive-C version of YYText](https://github.com/ibireme/YYText)

> 本项目写了**YYTextView仿微信输入高度动态变化**、 **YYTextView限制输入字数**、**YYLabel之Html富文本超链接检测及点击**、**YYLabel之评论盖楼**等四个示例。


![在这里插入图片描述](https://github.com/laoou002/YYText-swift/blob/main/001.gif)      ![在这里插入图片描述](https://github.com/laoou002/YYText-swift/blob/main/002.gif)

![在这里插入图片描述](https://github.com/laoou002/YYText-swift/blob/main/003.gif)      ![在这里插入图片描述](https://github.com/laoou002/YYText-swift/blob/main/004.gif)

### 扩展了YYLabel设置Html富文本方法
```swift
// MARK: - 添加html富文本配置扩展
extension YYLabel {
    /**
     *  设置html富文本,
     *  由于html转换属于耗时超时操作，异步后台处理
     *  假如是列表，转换完成后再刷新对应的Cell，否则会照成滚动卡顿
     */
    func yy_setHtmlAttributedString(text: String, font: UIFont, lineSpacing: CGFloat, color: UIColor = .black, linkColor: UIColor = .blue, alignment: NSTextAlignment? = nil, completion: ((NSMutableAttributedString?, Bool) -> Void)? = nil) {
        let defAttri = NSMutableAttributedString(string: text)
        defAttri.yy_color = color
        defAttri.yy_font = font
        defAttri.yy_lineSpacing = lineSpacing
        attributedText = defAttri
        
        DispatchQueue.global().async {
            var res:NSMutableAttributedString?
            if let data = text.data(using: .unicode) {
                do {
                    let attributed = try NSMutableAttributedString.init(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                    attributed.yy_lineSpacing = lineSpacing
                    attributed.yy_color = color
                    attributed.yy_font = font
                    attributed.yy_alignment = alignment ?? .left
                    
                    attributed.enumerateAttributes(in: attributed.yy_rangeOfAll, options: .reverse) { keys, range, _ in
                        keys.forEach { i in
                            if i.key.rawValue == "NSLink" {
                                let highlight: YYTextHighlight = YYTextHighlight()
                                highlight.color = linkColor
                                highlight.yy_tapAction { _, _, _, _ in
                                    let link = "\(i.value)"
                                    UIApplication.shared.open(URL(string: link)!, options: [:], completionHandler: nil)
                                }

                                attributed.yy_set(color: linkColor, range: range)

                                attributed.yy_set(textHighlight: highlight, range: range)

                                attributed.yy_set(underlineStyle: NSUnderlineStyle.single, range: range)
                            }
                        }
                    }
                    res = attributed
                } catch _ {}
            }
            DispatchQueue.main.async {
                self.attributedText = res
                completion?(res, false)
            }
        }
    }
}
```

### 扩展了YYLoad，Runtime方法交换的实现方案
```swift
protocol YYLoad: Any {
    static func runOnce()
}

extension UIViewController:YYLoad {
    static func runOnce() {
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
```

### 扩展了YYTextView输入回调textViewWordCountChange
```swift
func textViewWordCountChange(_ textView: YYTextView, count: Int) {
        print("当前输入了\(count)个字")
}
```

>  如果帮助到你的话，点一下**Star**
