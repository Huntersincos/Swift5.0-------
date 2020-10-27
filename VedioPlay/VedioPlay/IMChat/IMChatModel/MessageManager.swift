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
           ////以2001-1-1 0:0:0的偏移秒数来初始化，也可以直接调用类方法 + (id)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds

//           NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:80];
//           //NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:80];
//           NSLog(@"print date is %@",date) 2013-03-04 08:57:40 +0000;
            
            objc.imdnId  = "messagetext123456 + \(Date.timeIntervalSinceReferenceDate)"
            // 模拟个接收用户
            objc.receiverUserName = peerUserName ?? ""
            objc.timestamp =  "\(Date().timeIntervalSince1970 * 1000)"
            objc.senderName = "我"
            
            print("objc.timestamp  == \(objc.timestamp)")
            objc.messageType = .MessageItemTypeText
            objc.state = .MessageItemStateSendOK
            objc.messageTranDirection = .MessagirectionSend
            objc.channelType = .MessageChannelType1On1
            objc.peerUserName = peerUserName ?? ""
            objc.isRead = false
            objc.conversationId = "1587777777764"
            
            objc.content = message ?? ""
            objc.isAtMsg = false
            objc.font = "14"
            
            var conversaton = MessageDBHelper.getConversationPeerUserWith(objc.peerUserName)
            
            if conversaton == nil {
                // key step
                conversaton = ListConversationObject.init()
                conversaton?.peerUserName = objc.peerUserName
                
            }
            
            realm?.beginWrite()
            
            conversaton?.conversationTitleName = objc.peerUserName
            
            
            conversaton?.updateTime = "\(Date().timeIntervalSince1970 * 1000)"
            
            print("conversaton?.updateTime  == \(conversaton?.updateTime)")
    
            realm?.add(objc)
            
            
            realm?.add(conversaton!, update: .all)
            

            try?realm?.commitWrite()
            
            return true
            
            
        }
        
        
        return false
        
    }
    
}
