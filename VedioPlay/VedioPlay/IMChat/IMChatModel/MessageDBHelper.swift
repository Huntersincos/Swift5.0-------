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
          
            let result:Results<ListConversationObject>? =  realm?.objects(ListConversationObject.self).filter(NSPredicate(format:"%K == %@","peerUserName",peerUserName))
            
            if result?.count == 1 {
                return result?.first
            }
        }
        
        return nil;
    }
    
   
    class func getMessagesWithNumber(_ peerUserName:String) -> Results<ChatMessageObject>?{
        let realm = RealmInitModel.getRealmInstance()
        if realm != nil {
            return realm?.objects(ChatMessageObject.self).filter(NSPredicate(format:"%K == %@","peerUserName",peerUserName))
        }
        
        return nil
    }
}
