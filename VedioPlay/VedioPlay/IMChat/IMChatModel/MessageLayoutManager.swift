//
//  MessageLayoutManager.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
/**
 提前预存cell layout
 */
class MessageLayoutManager: NSObject {

    fileprivate static var instance = MessageLayoutManager()
    var layoutDic = [String:AnyObject]()
    public static var shareInstance:MessageLayoutManager{
        get{
            return instance
        }
    }
    
    func creatLayoutWithMessage(_ message:ChatMessageObject,_ showTime:Bool){
        
        if message.state == .MessageItemStateRevoked {
            let layout = RevokeLayout.init()
            layout.configWithMessage(message)
            self.layoutDic[message.imdnId] = layout
            return
        }
        
        switch message.messageType {
        case .MessageItemTypeText:
            let  textLayout = TextLayout.init()
            textLayout.configWithMessage(message, showTime, true)
            self.layoutDic[message.imdnId] = textLayout
            break
            
        case .MessageItemTypeImage:fallthrough
        case .MessageItemTypeVideo:
            let thumblLayout = ThumbImageLayout.init()
            thumblLayout.configWithMessage(message, showTime, true)
            self.layoutDic[message.transId] = thumblLayout
            break
        
        case .MessageItemTypeAudio:
            
            let audioLayout = AudioLayout.init()
            audioLayout.configWithMessage(message, showTime, true)
            self.layoutDic[message.transId] = audioLayout
            break
            
        case .MessageItemTypeGeo:
            
            let geoLayout = AudioLayout.init()
             geoLayout.configWithMessage(message, showTime, true)
            self.layoutDic[message.transId] = geoLayout
            break
            
        case .MessageItemTypeVcard:
            
            let vcardLayout = CardLayout.init()
             vcardLayout.configWithMessage(message, showTime, true)
            self.layoutDic[message.transId] = vcardLayout
            break
            
        case .MessageItemTypeOtherFile:
            
            let otherFileLayout = OtherFileLayout.init()
            otherFileLayout.configWithMessage(message, showTime, true)
            self.layoutDic[message.transId] = otherFileLayout
           break
          default:
            break

        }
        
    }
    
}
