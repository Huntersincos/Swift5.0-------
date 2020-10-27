//
//  MessageDBHelper.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/2.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import RealmSwift

class MessageDBHelper: NSObject {
    
    
    /// 通过好友 查询会话
    /// - Parameter peerUserName: <#peerUserName description#>
    class func getConversationPeerUserWith( _ peerUserName:String) -> ListConversationObject?{
        let realm = RealmInitModel.getRealmInstance()
        if realm != nil {
          
           // let result:Results<ListConversationObject>? =  realm?.objects(ListConversationObject.self).filter(NSPredicate(format:"%@ == %@","peerUserName",peerUserName)) Predicate expressions must compare a keypath and another keypath or a constant value'
            
              let result:Results<ListConversationObject>? =  realm?.objects(ListConversationObject.self).filter(NSPredicate(format:"peerUserName == %@",peerUserName))
            
            if result?.count == 1 {
                return result?.first
            }
        }
        
        return nil;
    }
    
   
    class func getMessagesWithNumber(_ peerUserName:String) -> Results<ChatMessageObject>?{
        let realm = RealmInitModel.getRealmInstance()
        if realm != nil {
            //Predicate expressions must compare a keypath and another keypath or a constant value'
            //            return realm?.objects(ChatMessageObject.self).filter(NSPredicate(format:"%@ == %@","peerUserName",peerUserName))
            
             return realm?.objects(ChatMessageObject.self).filter(NSPredicate(format:"peerUserName == %@",peerUserName))

        }
        
        return nil
    }
    
    /// 消息设置成已读
    
    class func readAllMessagesWithNumber(_ peerUserName:String){
        
        let realm = RealmInitModel.getRealmInstance()
        // %K 无法识别在swift下
        print(String(format: "%K == %@ && %K == 0","peerUserName",peerUserName,"isRead"))
        print(String(format: "peerUserName == %@ && isRead == 0",peerUserName))
        // 'Unable to parse the format string "peerUserName == 聊天界面 && isRead == 0"'
        //let pred = NSPredicate(format: String(format: "peerUserName == %@ && isRead == 0",peerUserName))
        let pred = NSPredicate(format: "peerUserName == %@ && isRead == 0",peerUserName)
        if realm != nil {
            let result:Results<ChatMessageObject>? = realm?.objects(ChatMessageObject.self).filter(pred)
            realm?.beginWrite()
            let count = result?.count ?? 0
            for _ in 0..<count {
                let messge = result?[0]
                 messge?.isRead = true
                // 应该回传服务端
           }
           try?realm?.commitWrite()
        }
       
       
    }
    
    
}
