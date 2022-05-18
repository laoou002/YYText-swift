//
//  YYHomeTableViewController.swift
//  YYText-swift
//
//  Created by 老欧 on 2022/5/5.
//

import UIKit

class YYHomeTableViewController: UITableViewController {

    let list:[[String]] = [
        ["仿微信输入高度动态变化", "限制输入字数"],
        ["Html富文本链接检测及点击", "评论盖楼"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "YYTextView" : "YYLabel"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let titles = list[section]
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        let titles = list[indexPath.section]
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        present(YYWeChatController(), animated: true, completion: nil)
        let titles = list[indexPath.section]
        var vc:UIViewController?
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                vc = YYLimitController()
                break
            default:
                vc = YYWeChatController()
                break
            }
        }else{
            switch indexPath.row {
            case 1:
                vc = YYCommentViewController()
                break
            default:
                vc = YYHtmlViewController()
                break
            }
        }
        
        vc?.view.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        
        if vc is YYCommentViewController {
            vc?.view.backgroundColor = .white
        }
        
        vc?.title = titles[indexPath.row]
        navigationController?.pushViewController(vc!, animated: true)
    }
}
