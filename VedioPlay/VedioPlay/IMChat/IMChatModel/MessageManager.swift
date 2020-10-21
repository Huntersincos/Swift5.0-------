//
//  MessageManager.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/10.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class MessageManager: NSObject {
    
     fileprivate static var  instance = MessageManager()
      var peerUserName:String?
      static public var shareInstance:MessageManager{
        get{
            return instance
        }
    }
    
    
    /**
      方案
       1  发送服务端,在写入数据库,一般是这种,考虑网络问题
       2  发送服务端和写入数据库
     */
    
    func sendTextMessage(_ message:String?, _ peerUserName:String?) ->Bool{
        
        // 发送到服务端
        
        let realm = RealmInitModel.getRealmInstance()
        
        if realm != nil {
           
            let objc = ChatMessageObject.init()
            // id 主键只能赋值一次 * Terminating app due to uncaught exception 'RLMException', reason: 'Attempting to create an object of type 'ChatMessageObject' with an existing primary key value 'messagetext123456' 这个值每次要变动才行
           
            objc.imdnId  = "messagetext123456 + \(Date.timeIntervalSinceReferenceDate)"
            // 模拟个接收用户
            objc.receiverUserName = peerUserName ?? ""
            objc.timestamp =  "\(Date.timeIntervalSinceReferenceDate)"
            objc.messageType = .MessageItemTypeText
            objc.state = .MessageItemStateSendOK
            objc.messageTranDirection = .MessagirectionSend
            objc.channelType = .MessageChannelType1On1
            objc.peerUserName = peerUserName ?? ""
            objc.isRead = true
            objc.conversationId = "1587777777764"
            
            objc.content = message ?? ""
            objc.isAtMsg = false
            objc.font = "14"
            
            var conversaton = MessageDBHelper.getConversationPeerUserWith(objc.peerUserName)
            
            if conversaton == nil {
                
                conversaton = ListConversationObject.init()
                conversaton?.peerUserName = objc.peerUserName
                
            }
            
            realm?.beginWrite()
            
            conversaton?.conversationTitleName = objc.peerUserName
            
            
            conversaton?.updateTime = "\(Date().timeIntervalSince1970 * 1000)"
        // 'RLMException', reason: 'Attempting to create an object of type 'ChatMessageObject' with an existing primary key value 'Âº†‰∏â'.
            realm?.add(objc)
            
            
            realm?.add(conversaton!, update: .all)
            

            try?realm?.commitWrite()
            
            return true
            
            
        }
        
        
        return false
        
    }
    
}
