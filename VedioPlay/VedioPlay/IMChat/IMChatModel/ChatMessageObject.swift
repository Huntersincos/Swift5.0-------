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
    case MessageChannelTypeGroup
    case MessageChannelTypeList
    
}

public enum JRMessageItemState:Int{
    
    /// 消息的初始状态
    case MessageItemStateInit
    
    /// 正在发送消息
    case MessageItemStateSending
    
    // 消息接收成功
    case MessageItemStateReceiveOK
    
    /// 消息已经撤回
    case MessageItemStateRevoked
    
    /// 消息已读
    case MessageItemStateDelivered
    
    /// 消息已读
    case MessageItemStateRead
    
    /// 发送成功
    case MessageItemStateSendOK
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

public enum MessageItemDirection:Int{
    case MessagirectionSend
    case MessageDirectionReceive
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
    
    /// 消息时间戳
    @objc dynamic var timestamp:NSString = ""
    
    /// 消息唯一标识符
    
    @objc dynamic var imdnId = ""
    
    /// 消息传输方向
    
    var messageTranDirection:MessageItemDirection = .MessagirectionSend
    
    /// 是否抄送
    @objc dynamic var isCarbonCopy = false
    
    /// 图片缩列图相对路径
    
    @objc dynamic var fileThumbPath = ""
    
    /// 媒体长度
    
    @objc dynamic var fileMediaDuration = ""
    
    /// 定位描述
    
    @objc dynamic var geoFreeText = ""
    
    /// 文件路径
    
    @objc dynamic var filePath = ""
    
    /// 文件名
    @objc dynamic var fileName = ""
    
    /// 文件大小
    
    @objc dynamic var fileSize = 0.0
    
    /// 传输唯一标识符
    
    @objc dynamic var transId = ""
    
    
    
    
}
