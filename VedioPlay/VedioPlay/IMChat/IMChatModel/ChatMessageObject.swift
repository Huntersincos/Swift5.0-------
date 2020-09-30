//
//  ChatMessageObject.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/29.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import RealmSwift

public enum MessageChannelType:Int{
     // 单聊
    case MessageChannelType1On1
    
}

public enum JRMessageItemState:Int{
    
    /// 消息的初始状态
    case MessageItemStateInit
    
    // 消息接收成功
    case MessageItemStateReceiveOK
    
    /// 消息已经撤回
    case MessageItemStateRevoked
}

public enum JRMessageItemType:Int{
    
    /// 未知类型
   case MessageItemTypeUnknow
    /// 文本消息
   case MessageItemTypeText
    /// 图片消息
    case MessageItemTypeImage
    /// 视频消息
    case MessageItemTypeVideo
    /// 语音消息
    case MessageItemTypeAudio
    /// 名片消息
   case  MessageItemTypeVcard
    /// 地理位置消息
   case  MessageItemTypeGeo
    /// 其他类型文件消息
   case  MessageItemTypeOtherFile
    /// 群提示消息
   case   MessageItemTypeNotify
}


class ChatMessageObject: Object {
    
    /// 是否已读
    @objc dynamic var isRead = false
    
    /// 发送用户名
    
    @objc dynamic var senderName = ""
    
    /// 消息渠道
    var channelType:MessageChannelType = .MessageChannelType1On1
    
    /// 消息状态
    var state:JRMessageItemState = .MessageItemStateInit
    
    /// 是否@
    @objc dynamic var isAtMsg = false
    
    /// 消息类型
    var messageType:JRMessageItemType = .MessageItemTypeUnknow
    
    /// 文本内容
    @objc dynamic var content = ""
    
}
