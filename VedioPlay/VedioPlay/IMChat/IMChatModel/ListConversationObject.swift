//
//  ListConversationObject.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/29.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import RealmSwift
///RLMObject oc ==== > Object
class ListConversationObject: Object {
    
    /// 对端用户名
    @objc dynamic var peerUserName = ""
    
    
    /// 消息更新时间
    @objc dynamic var updateTime = ""
    
    /// 是否为群聊
    @objc dynamic var isGroup  = false
    
    /// 是否置顶
    @objc dynamic var isStick = false
    
    /// 会话标题内容
    @objc dynamic var conversationTitleName = ""
    
    /// 设置主键
    override class func primaryKey() ->String{
        return "peerUserName"
    }
    
    /// 会话的所有消息
    func getAllMessages() -> Results<ChatMessageObject>?{
         let realm = RealmInitModel.getRealmInstance()
        ///NSPredicate 谓词  通过NSPredicate字符串，也可以使用%K指定键路径。该谓词和其他谓词相同
         //NSPredicate(format: "%K == \(self.peerUserName)")
        //print(String(format:"%@ boy", arguments:[string]))//输出结果：lazy boy
         let pred = NSPredicate(format:  String(format: "%K == %@","peerUserName",self.peerUserName))
        //String(format: <#T##String#>, arguments: <#T##[CVarArg]#>)
        
         let result:Results<ChatMessageObject>? = realm?.objects(ChatMessageObject.self).filter(pred)
         return result
    }
    
    
    /// 获取未读消息数
    func getUnreadCount() -> Int{
        let realm = RealmInitModel.getRealmInstance()
        let pred = NSPredicate(format: String(format: "%K == %@ && %K == 0","peerUserName",self.peerUserName,"isRead"))
        let message:Results<ChatMessageObject>? =  realm?.objects(ChatMessageObject.self).filter(pred)
        if message != nil {
             return message!.count
        }
         return 0
    }
    
    /// 会话消息设置为未读消息
    func readAllMessages(){
       let realm = RealmInitModel.getRealmInstance()
       realm?.beginWrite()
       let pred = NSPredicate(format:String(format: "%K == %@ && %K == 0","peerUserName",self.peerUserName,"isRead"))
        let result:Results<ChatMessageObject>? = realm?.objects(ChatMessageObject.self).filter(pred)
        if result != nil {
            for _ in result! {
                let message:ChatMessageObject = result![0]
                 message.isRead = true
            }
        }
       try?realm?.commitWrite()
    }
    
    func getLastMessage() -> ChatMessageObject?{
        let realm = RealmInitModel.getRealmInstance()
        let pred = NSPredicate(format:String(format:"%K == %@","peerUserName",self.peerUserName))
        let message:Results<ChatMessageObject>? = realm?.objects(ChatMessageObject.self).filter(pred)
        if message != nil {
            if message?.count == 0 {
                return  nil
            }
            
            return message?.last
        }
        
        return nil
    }

}
