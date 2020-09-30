//
//  ChatListViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/29.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import RealmSwift
class ChatListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    static var chatListTableViewCellID = "ChatListTableViewCellIDS"
    var chatListTableView:UITableView?
    var conversationsArray:Results<ListConversationObject>?
    var  token:NotificationToken?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("LISTMESSAGE",tableName: nil, comment: "")
        
        let realm = RealmInitModel.getRealmInstance()
        if realm != nil {
            self.conversationsArray = realm?.objects(ListConversationObject.self).sorted(byKeyPath: "updateTime", ascending: false)
            
            self.token = self.conversationsArray?._observe(DispatchQueue.init(label: "com.getRealmInstance"), { [weak self] (change:RealmCollectionChange<AnyRealmCollection<ListConversationObject>>) in
                if let strongSelf = self{
                    if Thread.isMainThread{
                        strongSelf.chatListTableView?.reloadData()
                    }else{
                        DispatchQueue.main.async {
                         strongSelf.chatListTableView?.reloadData()
                        }
                    }
                    
                }
                
            })
        }else{
            #if DEBUG
             print("数据加载失败")

            #else
            

            #endif
            
        }
        
        self.chatListTableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - (self.navigationController?.navigationBar.frame.size.height ?? 0) - UIApplication.shared.statusBarFrame.size.height), style: .plain)
        self.chatListTableView?.delegate = self
        self.chatListTableView?.dataSource = self
        self.chatListTableView?.tableFooterView = UIView.init()
        self.chatListTableView?.rowHeight = 70
        self.view.addSubview(self.chatListTableView ?? UIView.init())
        self.chatListTableView?.register(UINib.init(nibName: "ChatListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: ChatListViewController.chatListTableViewCellID)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.conversationsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ChatListTableViewCell = tableView.dequeueReusableCell(withIdentifier: ChatListViewController.chatListTableViewCellID) as! ChatListTableViewCell
        if self.conversationsArray != nil {
            cell.configWithConversation(self.conversationsArray![indexPath.row])
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    deinit {
        self.token?.invalidate()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
